#!/usr/bin/env python3
"""
Factorio WSL Launcher - Specialized for LLM Usage

This script launches the Factorio Windows executable from within WSL (Windows Subsystem for Linux)
with proper output handling and timeout support. It's designed specifically for LLM instances to
programmatically control and monitor Factorio execution.

IMPORTANT FOR LLMs:
1. Default path: ../../bin/x64/factorio.exe (relative to this script's location)
2. Always use --timeout to prevent hanging processes
3. Use -- before Factorio-specific arguments not in the predefined options
4. Exit codes: 0=success, -1=error/timeout, 130=interrupted, others=Factorio exit code

COMMON USAGE PATTERNS:
- Quick test: python3 launch_factorio.py --timeout 10 -- --version
- Load save: python3 launch_factorio.py --timeout 300 --load-game mysave.zip
- Headless server: python3 launch_factorio.py --timeout 3600 -- --start-server mysave.zip
- With mods: python3 launch_factorio.py --timeout 300 --mod-directory ./mods --load-game mysave.zip

WSL INTEROP NOTES:
- Windows error 0xc0000142 (DLL init failed) may occur - use --shell flag as workaround
- Output buffering issues are handled by default with unbuffered mode
- Paths are automatically resolved from WSL to Windows format
"""

import argparse
import subprocess
import sys
import os
import signal
import time
from pathlib import Path
from typing import Optional, List, Union, Tuple
import threading
import queue
import json


class FactorioLauncher:
    """
    Factorio launcher with WSL-specific handling.
    
    This class manages the subprocess execution of Factorio.exe from WSL,
    handling common interop issues like buffering, timeouts, and output capture.
    """

    def __init__(self, factorio_path: str, timeout: Optional[int] = None):
        """
        Initialize the launcher.
        
        Args:
            factorio_path: Path to factorio.exe (can be relative or absolute)
            timeout: Maximum execution time in seconds (None for no timeout)
        """
        self.factorio_path = Path(factorio_path).resolve()
        self.timeout = timeout
        self.process: Optional[subprocess.Popen] = None
        self.output_queue = queue.Queue()
        self.start_time: Optional[float] = None
        self.exit_code: Optional[int] = None

    def _validate_executable(self) -> None:
        """
        Validate Factorio executable exists and is accessible.
        
        Raises:
            FileNotFoundError: If the executable doesn't exist
        """
        if not self.factorio_path.exists():
            raise FileNotFoundError(
                f"Factorio executable not found at: {self.factorio_path}\n"
                f"Expected location: {self.factorio_path.absolute()}\n"
                f"Current working directory: {Path.cwd()}"
            )

        # Store the path as-is for WSL interop
        self.windows_path = str(self.factorio_path)

    def _output_reader(self, pipe, pipe_name: str) -> None:
        """
        Thread worker to read output from stdout/stderr pipes.
        
        This prevents blocking when reading subprocess output by using
        a separate thread for each pipe.
        
        Args:
            pipe: The pipe object to read from
            pipe_name: Either "stdout" or "stderr" for identification
        """
        try:
            for line in iter(pipe.readline, b""):
                if line:
                    self.output_queue.put((pipe_name, line))
            pipe.close()
        except Exception as e:
            self.output_queue.put(("error", f"Error reading {pipe_name}: {e}"))

    def launch(
        self,
        args: List[str],
        capture_output: bool = True,
        stream_output: bool = True,
        unbuffered: bool = True,
        use_shell: bool = False,
    ) -> Tuple[int, float]:
        """
        Launch Factorio with specified arguments.
        
        Args:
            args: Command line arguments to pass to Factorio
            capture_output: If True, capture stdout/stderr (default: True)
            stream_output: If True, print output in real-time (default: True)
            unbuffered: If True, disable output buffering (default: True)
            use_shell: If True, use shell execution (workaround for some WSL issues)
        
        Returns:
            Tuple of (exit_code, execution_time_seconds)
            Exit codes:
                0: Success
                -1: Error or timeout
                130: Interrupted (Ctrl+C)
                Other: Factorio-specific exit code
        """
        self._validate_executable()

        # Build command
        cmd = [self.windows_path] + args

        # Setup subprocess arguments
        popen_args = {
            "bufsize": 0 if unbuffered else -1,  # 0 = unbuffered, -1 = system default
            "shell": use_shell,
        }

        if capture_output:
            popen_args.update(
                {
                    "stdout": subprocess.PIPE,
                    "stderr": subprocess.PIPE,
                }
            )

        # Environment setup for better WSL interop
        env = os.environ.copy()
        env["LC_ALL"] = "C.UTF-8"  # Prevent locale issues with Windows exe
        popen_args["env"] = env

        self.start_time = time.time()

        try:
            print(f"[LLM_INFO] Launching Factorio: {' '.join(cmd)}")
            if self.timeout:
                print(f"[LLM_INFO] Timeout set to {self.timeout} seconds")

            self.process = subprocess.Popen(cmd, **popen_args)

            if capture_output and stream_output:
                # Start output reader threads for non-blocking I/O
                stdout_thread = threading.Thread(
                    target=self._output_reader, args=(self.process.stdout, "stdout")
                )
                stderr_thread = threading.Thread(
                    target=self._output_reader, args=(self.process.stderr, "stderr")
                )

                stdout_thread.daemon = True
                stderr_thread.daemon = True
                stdout_thread.start()
                stderr_thread.start()

                # Stream output in real-time
                while True:
                    try:
                        # Non-blocking read with short timeout
                        pipe_name, line = self.output_queue.get(timeout=0.1)
                        if pipe_name == "stdout":
                            sys.stdout.write(line.decode("utf-8", errors="replace"))
                            sys.stdout.flush()
                        elif pipe_name == "stderr":
                            sys.stderr.write(line.decode("utf-8", errors="replace"))
                            sys.stderr.flush()
                    except queue.Empty:
                        # Check if process finished
                        if self.process.poll() is not None:
                            break
                        # Check timeout
                        elapsed = time.time() - self.start_time
                        if self.timeout and elapsed > self.timeout:
                            print(
                                f"\n[LLM_ERROR] Timeout reached ({self.timeout}s), terminating process..."
                            )
                            self.terminate()
                            self.exit_code = -1
                            return -1, elapsed

                # Drain any remaining output
                while not self.output_queue.empty():
                    try:
                        pipe_name, line = self.output_queue.get_nowait()
                        if pipe_name == "stdout":
                            sys.stdout.write(line.decode("utf-8", errors="replace"))
                        elif pipe_name == "stderr":
                            sys.stderr.write(line.decode("utf-8", errors="replace"))
                    except queue.Empty:
                        break

            else:
                # Simple wait with timeout
                try:
                    self.exit_code = self.process.wait(timeout=self.timeout)
                except subprocess.TimeoutExpired:
                    elapsed = time.time() - self.start_time
                    print(
                        f"\n[LLM_ERROR] Timeout reached ({self.timeout}s), terminating process..."
                    )
                    self.terminate()
                    self.exit_code = -1
                    return -1, elapsed

            elapsed = time.time() - self.start_time
            self.exit_code = self.process.returncode
            return self.exit_code, elapsed

        except OSError as e:
            elapsed = time.time() - self.start_time
            if e.errno == 2:
                print(f"[LLM_ERROR] Could not find executable at {self.windows_path}")
                print("[LLM_HINT] Verify path is correct and accessible from WSL")
            else:
                print(f"[LLM_ERROR] OSError launching Factorio: {e}")
            self.exit_code = -1
            return -1, elapsed
        except Exception as e:
            elapsed = time.time() - self.start_time
            print(f"[LLM_ERROR] Unexpected error: {e}")
            self.exit_code = -1
            return -1, elapsed

    def terminate(self) -> None:
        """
        Terminate the Factorio process gracefully, then forcefully if needed.
        
        Attempts SIGTERM first, waits 2 seconds, then SIGKILL if still running.
        """
        if self.process:
            try:
                # Try graceful termination first (SIGTERM)
                self.process.terminate()
                time.sleep(2)

                # Force kill if still running (SIGKILL)
                if self.process.poll() is None:
                    print("[LLM_INFO] Process didn't terminate gracefully, forcing kill...")
                    self.process.kill()
            except Exception as e:
                print(f"[LLM_ERROR] Error terminating process: {e}")


def parse_factorio_args() -> argparse.Namespace:
    """
    Parse command line arguments for Factorio launcher.
    
    Returns:
        Parsed arguments namespace
    """
    parser = argparse.ArgumentParser(
        description="Launch Factorio from WSL - Optimized for LLM usage",
        epilog=(
            "Examples for LLMs:\n"
            "  %(prog)s --timeout 10 -- --version\n"
            "  %(prog)s --timeout 300 --load-game mysave.zip\n"
            "  %(prog)s --timeout 3600 -- --start-server mysave.zip --server-settings settings.json\n"
            "  %(prog)s --dry-run -- --help  # See all Factorio options"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    # Core options
    parser.add_argument(
        "--factorio-path",
        "-f",
        default="../../bin/x64/factorio.exe",
        help="Path to Factorio executable (default: %(default)s)",
    )

    parser.add_argument(
        "--timeout",
        "-t",
        type=int,
        help="Timeout in seconds (REQUIRED for LLM usage to prevent hanging)",
    )

    # Output control
    output_group = parser.add_argument_group("output control")
    output_group.add_argument(
        "--no-capture",
        action="store_true",
        help="Let Factorio write directly to terminal (disables output capture)",
    )

    output_group.add_argument(
        "--no-stream",
        action="store_true",
        help="Capture output but don't stream it (show only at end)",
    )

    output_group.add_argument(
        "--buffered",
        action="store_true",
        help="Use buffered output (default: unbuffered for real-time output)",
    )

    # Common Factorio options
    factorio_group = parser.add_argument_group("common Factorio options")
    factorio_group.add_argument(
        "--mod-directory",
        help="Path to mod directory (e.g., ./mods)",
    )

    factorio_group.add_argument(
        "--config",
        help="Path to config.ini file",
    )

    factorio_group.add_argument(
        "--executable-path",
        help="Override Factorio data directory detection",
    )

    factorio_group.add_argument(
        "--create",
        metavar="SAVE_NAME",
        help="Create a new save file",
    )

    factorio_group.add_argument(
        "--load-game",
        metavar="SAVE_NAME",
        help="Load existing save file",
    )

    factorio_group.add_argument(
        "--benchmark",
        metavar="SAVE_NAME",
        help="Run benchmark with save file",
    )

    factorio_group.add_argument(
        "--mp-connect",
        metavar="ADDRESS:PORT",
        help="Connect to multiplayer server",
    )

    # Debugging and WSL workarounds
    debug_group = parser.add_argument_group("debugging and WSL workarounds")
    debug_group.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Show execution details and timing",
    )

    debug_group.add_argument(
        "--shell",
        action="store_true",
        help="Use shell execution (workaround for WSL interop error 0xc0000142)",
    )

    debug_group.add_argument(
        "--dry-run",
        action="store_true",
        help="Show command without executing (useful for debugging)",
    )

    debug_group.add_argument(
        "--json-status",
        action="store_true",
        help="Output final status as JSON (for LLM parsing)",
    )

    # Pass-through for other Factorio arguments
    parser.add_argument(
        "extra_args",
        nargs="*",
        help="Additional Factorio arguments (use -- before them)",
    )

    return parser.parse_args()


def main():
    """
    Main entry point for Factorio WSL launcher.
    
    Exit codes:
        0: Success
        1: General error
        2: Invalid arguments
        130: Interrupted (Ctrl+C)
        -1: Timeout or launch error
    """
    args = parse_factorio_args()

    # LLM usage warning
    if not args.timeout and not args.dry_run:
        print("[LLM_WARNING] No timeout specified! Factorio may run indefinitely.")
        print("[LLM_HINT] Always use --timeout when running from an LLM")

    # Build Factorio command line
    factorio_args = []

    # Add predefined options
    if args.mod_directory:
        factorio_args.extend(["--mod-directory", args.mod_directory])
    if args.config:
        factorio_args.extend(["--config", args.config])
    if args.executable_path:
        factorio_args.extend(["--executable-path", args.executable_path])
    if args.create:
        factorio_args.extend(["--create", args.create])
    if args.load_game:
        factorio_args.extend(["--load-game", args.load_game])
    if args.benchmark:
        factorio_args.extend(["--benchmark", args.benchmark])
    if args.mp_connect:
        factorio_args.extend(["--mp-connect", args.mp_connect])

    # Add extra pass-through arguments
    factorio_args.extend(args.extra_args)

    # Dry run mode
    if args.dry_run:
        cmd = [args.factorio_path] + factorio_args
        print(f"[LLM_INFO] Would execute: {' '.join(cmd)}")
        return 0

    # Launch Factorio
    launcher = FactorioLauncher(args.factorio_path, args.timeout)

    try:
        exit_code, elapsed_time = launcher.launch(
            factorio_args,
            capture_output=not args.no_capture,
            stream_output=not args.no_stream,
            unbuffered=not args.buffered,
            use_shell=args.shell,
        )

        # Output status information
        if args.verbose or args.json_status:
            status = {
                "exit_code": exit_code,
                "elapsed_time": round(elapsed_time, 2),
                "timeout": args.timeout,
                "timed_out": exit_code == -1 and args.timeout and elapsed_time >= args.timeout,
                "factorio_path": str(launcher.factorio_path),
            }

            if args.json_status:
                print(f"\n[LLM_STATUS]{json.dumps(status)}")
            else:
                print(f"\n[LLM_INFO] Factorio exited with code: {exit_code}")
                print(f"[LLM_INFO] Execution time: {elapsed_time:.2f} seconds")

        return exit_code

    except KeyboardInterrupt:
        print("\n[LLM_INFO] Interrupted by user, terminating Factorio...")
        launcher.terminate()
        return 130  # Standard exit code for SIGINT
    except Exception as e:
        print(f"[LLM_ERROR] Unexpected error in launcher: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())