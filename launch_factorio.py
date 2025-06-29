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
- Run tests: python3 launch_factorio.py --run-tests --timeout 300
- Headless server: python3 launch_factorio.py --timeout 3600 -- --start-server mysave.zip
- With mods: python3 launch_factorio.py --timeout 300 --mod-directory ./mods --load-game mysave.zip
- Lint Lua code: python3 launch_factorio.py --lint
- Check formatting: python3 launch_factorio.py --format-check
- Apply formatting: python3 launch_factorio.py --format

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
from typing import Optional, List, Tuple, Dict, Any
import threading
import queue
import json
import tempfile
import re


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
                    print(
                        "[LLM_INFO] Process didn't terminate gracefully, forcing kill..."
                    )
                    self.process.kill()
            except Exception as e:
                print(f"[LLM_ERROR] Error terminating process: {e}")


def find_factorio_type_definitions() -> Optional[str]:
    """
    Find Factorio type definitions from various possible locations.

    Returns:
        Path to the Factorio library directory, or None if not found
    """
    # Common paths to check
    search_paths = [
        # VSCode on Windows (via WSL)
        "/mnt/c/Users/*/AppData/Roaming/Code/User/workspaceStorage/*/justarandomgeek.factoriomod-debug/sumneko-3rd/factorio/library",
        # VSCode on Linux
        "~/.config/Code/User/workspaceStorage/*/justarandomgeek.factoriomod-debug/sumneko-3rd/factorio/library",
        # VSCode Server
        "~/.vscode-server/data/User/workspaceStorage/*/justarandomgeek.factoriomod-debug/sumneko-3rd/factorio/library",
        # Manual installation
        "~/.local/share/factorio-lua-types/library",
        "/usr/local/share/factorio-lua-types/library",
    ]

    import glob

    for pattern in search_paths:
        expanded = os.path.expanduser(pattern)
        matches = glob.glob(expanded)
        if matches:
            # Use the first match found
            return matches[0]

    return None


def create_or_update_luarc(config_path: str) -> None:
    """
    Create .luarc.json configuration at the specified path.

    Args:
        config_path: Full path where the config file should be created
    """
    luarc_path = Path(config_path)

    # Find Factorio type definitions
    factorio_lib = find_factorio_type_definitions()

    config = {
        "$schema": "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json",
        "runtime": {
            "version": "Lua 5.2",
            "path": ["?.lua", "?/init.lua", "scripts/?.lua"],
            "pathStrict": False,
        },
        "workspace": {
            "library": [],
            "checkThirdParty": False,
            "ignoreDir": [".vscode", ".git"],
        },
        "diagnostics": {
            "enable": True,
            "globals": [
                # Custom mod globals
                "players",
                "printout",
                "get_selected_ent",
                "direction_lookup",
                "cursor_highlight",
                "sync_build_cursor_graphics",
                "get_direction_of_that_from_this",
                "clear_obstacles_in_rectangle",
                "ENT_TYPES_YOU_CAN_BUILD_OVER",
            ],
            "disable": [
                "lowercase-global",
                "deprecated",
                "need-check-nil",
                "redefined-local",  # Added per user request
            ],
            "severity": {
                "unused-local": "Information",
                "undefined-global": "Warning",
                "undefined-field": "Information",
                "redundant-parameter": "Information",
                "cast-local-type": "Warning",
                "assign-type-mismatch": "Information",
            },
        },
        "format": {"enable": False},
        "telemetry": {"enable": False},
        "hint": {"enable": True, "setType": False},
    }

    # Add Factorio library if found
    if factorio_lib:
        config["workspace"]["library"].append(factorio_lib)
        print(f"[LLM_INFO] Found Factorio type definitions at: {factorio_lib}")
    else:
        print(
            "[LLM_WARNING] Factorio type definitions not found. Some API completions may be missing."
        )
        print(
            "[LLM_HINT] Install the factoriomod-debug VSCode extension for better type checking."
        )

    # Write the configuration
    with open(luarc_path, "w") as f:
        json.dump(config, f, indent=2)

    print(f"[LLM_INFO] Updated {luarc_path}")


def run_lua_linter(
    mod_path: str = ".", lua_ls_path: Optional[str] = None
) -> Tuple[int, str, str]:
    """
    Run lua-language-server on the mod files.

    Args:
        mod_path: Path to the mod directory
        lua_ls_path: Path to lua-language-server executable (searches PATH if not provided)

    Returns:
        Tuple of (exit_code, stdout, stderr)
    """
    if lua_ls_path is None:
        # Try to find lua-language-server in common locations
        possible_paths = [
            "lua-language-server",
            "/usr/local/bin/lua-language-server",
            "/usr/bin/lua-language-server",
            os.path.expanduser("~/.local/bin/lua-language-server"),
            # Common VSCode extension paths
            os.path.expanduser(
                "~/.vscode-server/extensions/sumneko.lua-*/server/bin/lua-language-server"
            ),
            os.path.expanduser(
                "~/.vscode/extensions/sumneko.lua-*/server/bin/lua-language-server"
            ),
        ]

        for path_pattern in possible_paths:
            # Handle glob patterns
            if "*" in path_pattern:
                import glob

                matches = glob.glob(path_pattern)
                if matches:
                    path = matches[0]  # Use first match
                else:
                    continue
            else:
                path = path_pattern

            try:
                subprocess.run([path, "--version"], capture_output=True, timeout=2)
                lua_ls_path = path
                break
            except (subprocess.TimeoutExpired, FileNotFoundError):
                continue

        if lua_ls_path is None:
            return (
                1,
                "",
                "lua-language-server not found. Please install it or specify --lua-ls-path",
            )

    # Ensure we're in the mod directory for proper .luarc.json detection
    mod_path = Path(mod_path).resolve()

    # Create temporary config file
    config_file = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as tmp:
            config_file = tmp.name
            create_or_update_luarc(config_file)

        # Run lua-language-server in check mode with temp config
        cmd = [lua_ls_path, "--check", ".", "--configpath", config_file]

        # Set VSCODE_FACTORIO_PATH if possible to help with Factorio library detection
        env = os.environ.copy()
        factorio_path = Path(__file__).parent.parent.parent / "bin" / "x64"
        if factorio_path.exists():
            env["FACTORIO_PATH"] = str(factorio_path)

        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=60, cwd=str(mod_path), env=env
        )

        # Filter out noise from the output
        stdout_lines = result.stdout.split("\n")
        stderr_lines = result.stderr.split("\n")

        # Remove progress indicators and empty lines
        filtered_stdout = []
        for line in stdout_lines:
            if line and not line.startswith(">") and not line.strip() == "":
                # Also filter out the initialization message
                if "Initializing" not in line and "Diagnosis complete" not in line:
                    filtered_stdout.append(line)

        # Count problems
        problems_line = [l for l in stdout_lines if "problems found" in l]
        if problems_line:
            filtered_stdout.append(problems_line[-1])

        return result.returncode, "\n".join(filtered_stdout), "\n".join(stderr_lines)
    except subprocess.TimeoutExpired:
        return -1, "", "Linting timed out after 60 seconds"
    except Exception as e:
        return -1, "", str(e)
    finally:
        # Clean up temp config file
        if config_file and os.path.exists(config_file):
            try:
                os.unlink(config_file)
            except Exception:
                pass  # Best effort cleanup


def run_stylua(
    mod_path: str = ".", stylua_path: Optional[str] = None, check_only: bool = True
) -> Tuple[int, str, str]:
    """
    Run stylua formatter on Lua files.

    Args:
        mod_path: Path to the mod directory
        stylua_path: Path to stylua executable (searches PATH if not provided)
        check_only: If True, only check formatting; if False, apply formatting

    Returns:
        Tuple of (exit_code, stdout, stderr)
    """
    if stylua_path is None:
        # Try to find stylua in common locations
        possible_paths = [
            "stylua",
            "/usr/local/bin/stylua",
            "/usr/bin/stylua",
            os.path.expanduser("~/.local/bin/stylua"),
            os.path.expanduser("~/.cargo/bin/stylua"),
        ]

        for path in possible_paths:
            try:
                subprocess.run([path, "--version"], capture_output=True, timeout=2)
                stylua_path = path
                break
            except (subprocess.TimeoutExpired, FileNotFoundError):
                continue

        if stylua_path is None:
            return 1, "", "stylua not found. Please install it or specify --stylua-path"

    # Build stylua command
    cmd = [stylua_path]
    if check_only:
        cmd.append("--check")
    cmd.append(mod_path)

    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=30, cwd=mod_path
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Formatting timed out after 30 seconds"
    except Exception as e:
        return -1, "", str(e)


def run_syntrax_tests() -> Tuple[int, str, str]:
    """
    Run the Syntrax test suite using LuaUnit.

    Returns:
        Tuple of (exit_code, stdout, stderr)
    """
    print("[LLM_INFO] Running Syntrax test suite...")

    # Run the syntrax-tests.lua file
    cmd = ["lua", "syntrax-tests.lua"]

    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=30, cwd=Path(__file__).parent
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Syntrax tests timed out after 30 seconds"
    except FileNotFoundError:
        return -1, "", "lua command not found. Please ensure Lua is installed."
    except Exception as e:
        return -1, "", str(e)


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
            "  %(prog)s --dry-run -- --help  # See all Factorio options\n"
            "  %(prog)s --run-tests --timeout 300  # Run Factorio tests and Syntrax tests\n"
            "  %(prog)s --lint  # Run lua-language-server to check for errors\n"
            "  %(prog)s --format-check  # Check if Lua files are properly formatted\n"
            "  %(prog)s --format  # Apply stylua formatting to Lua files"
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
        "--run-tests",
        action="store_true",
        help="Run FactorioAccess tests and Syntrax tests",
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

    # Linting and formatting options
    lint_group = parser.add_argument_group("linting and formatting")
    lint_group.add_argument(
        "--lint",
        action="store_true",
        help="Run lua-language-server to check for Lua errors and warnings",
    )

    lint_group.add_argument(
        "--lua-ls-path",
        help="Path to lua-language-server executable",
    )

    lint_group.add_argument(
        "--format-check",
        action="store_true",
        help="Check Lua formatting with stylua (does not modify files)",
    )
    
    # Debugging support options
    debug_support_group = parser.add_argument_group("debugging support")
    debug_support_group.add_argument(
        "--capture-logs",
        action="store_true",
        help="Capture current Factorio logs without running the game (for debugging crashes from manual runs)",
    )
    
    debug_support_group.add_argument(
        "--last-lines",
        type=int,
        default=100,
        help="Number of lines to capture from logs (default: %(default)s)",
    )

    lint_group.add_argument(
        "--format",
        action="store_true",
        help="Apply Lua formatting with stylua (modifies files)",
    )

    lint_group.add_argument(
        "--stylua-path",
        help="Path to stylua executable",
    )

    lint_group.add_argument(
        "--mod-path",
        default=".",
        help="Path to the mod directory for linting/formatting (default: current directory)",
    )

    # Pass-through for other Factorio arguments
    parser.add_argument(
        "extra_args",
        nargs="*",
        help="Additional Factorio arguments (use -- before them)",
    )

    return parser.parse_args()


def find_factorio_log_path(factorio_path: Path) -> Optional[Path]:
    """
    Find the factorio-current.log file by checking common locations.
    
    Args:
        factorio_path: Path to factorio executable
        
    Returns:
        Path to log file or None if not found
    """
    # Common locations relative to the executable
    possible_locations = [
        # Same directory as executable
        factorio_path.parent / "factorio-current.log",
        # Parent directory (common for portable installs)
        factorio_path.parent.parent / "factorio-current.log",
        # Config directory (if specified)
        factorio_path.parent / "config" / "factorio-current.log",
    ]
    
    # On Windows, also check %APPDATA%
    if sys.platform.startswith('win') or 'microsoft' in sys.platform.lower():
        appdata = os.environ.get('APPDATA')
        if appdata:
            possible_locations.append(Path(appdata) / "Factorio" / "factorio-current.log")
    
    # Check each location
    for location in possible_locations:
        if location.exists():
            return location
            
    return None


def find_script_output_dir(factorio_path: Path) -> Optional[Path]:
    """
    Find the script-output directory where mods write files.
    
    Args:
        factorio_path: Path to factorio executable
        
    Returns:
        Path to script-output directory or None if not found
    """
    # Common locations
    possible_locations = [
        # Relative to executable
        factorio_path.parent.parent / "script-output",
        factorio_path.parent / "script-output",
        # Temp directory (common for testing)
        factorio_path.parent.parent / "temp" / "script-output",
    ]
    
    # On Windows, also check %APPDATA%
    if sys.platform.startswith('win') or 'microsoft' in sys.platform.lower():
        appdata = os.environ.get('APPDATA')
        if appdata:
            possible_locations.append(Path(appdata) / "Factorio" / "script-output")
    
    # Check each location, prefer ones that exist
    for location in possible_locations:
        if location.exists():
            return location
    
    # If none exist, return the most likely location (will be created by Factorio)
    return factorio_path.parent.parent / "script-output"


def capture_crash_info(factorio_path: Path, exit_code: int) -> Dict[str, Any]:
    """
    Capture crash information from logs and save for later analysis.
    
    Args:
        factorio_path: Path to factorio executable
        exit_code: Exit code from Factorio
        
    Returns:
        Dictionary with crash information
    """
    crash_info = {
        "exit_code": exit_code,
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "factorio_log": None,
        "mod_log": None,
        "printout_log": None,
    }
    
    # Try to capture factorio-current.log
    log_path = find_factorio_log_path(factorio_path)
    if log_path and log_path.exists():
        try:
            # Read last 200 lines (usually enough for crash info)
            with open(log_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
                # Look for crash/error patterns
                crash_lines = []
                capture = False
                for i, line in enumerate(lines):
                    if any(pattern in line.lower() for pattern in ['error', 'exception', 'crash', 'stack traceback']):
                        # Capture 20 lines before and all lines after
                        start = max(0, i - 20)
                        crash_lines = lines[start:]
                        capture = True
                        break
                
                if capture:
                    crash_info["factorio_log"] = ''.join(crash_lines[-500:])  # Last 500 lines max
                else:
                    # No obvious crash, just get last 100 lines
                    crash_info["factorio_log"] = ''.join(lines[-100:])
        except Exception as e:
            crash_info["factorio_log"] = f"Failed to read log: {e}"
    
    # Try to capture mod logs from script-output
    script_output_dir = find_script_output_dir(factorio_path)
    if script_output_dir and script_output_dir.exists():
        # Check for factorio-access.log
        mod_log_path = script_output_dir / "factorio-access.log"
        if mod_log_path.exists():
            try:
                with open(mod_log_path, 'r', encoding='utf-8', errors='ignore') as f:
                    crash_info["mod_log"] = f.read()[-10000:]  # Last 10KB
            except Exception as e:
                crash_info["mod_log"] = f"Failed to read mod log: {e}"
        
        # Check for printout log (if we implement it)
        printout_log_path = script_output_dir / "factorio-access-printout.log"
        if printout_log_path.exists():
            try:
                with open(printout_log_path, 'r', encoding='utf-8', errors='ignore') as f:
                    crash_info["printout_log"] = f.read()[-5000:]  # Last 5KB
            except Exception as e:
                crash_info["printout_log"] = f"Failed to read printout log: {e}"
    
    return crash_info


def save_crash_report(crash_info: Dict[str, Any], output_dir: Path = None) -> Path:
    """
    Save crash information to a file for later analysis.
    
    Args:
        crash_info: Dictionary with crash information
        output_dir: Directory to save report (defaults to current directory)
        
    Returns:
        Path to saved crash report
    """
    if output_dir is None:
        output_dir = Path.cwd()
    
    # Create filename with timestamp
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    report_path = output_dir / f"factorio_crash_{timestamp}.json"
    
    # Save as JSON for easy parsing
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(crash_info, f, indent=2)
    
    return report_path


def parse_test_results(log_path: str) -> Optional[Dict[str, Any]]:
    """
    Parse test results from the test log file or JSON results file.

    Args:
        log_path: Path to the test log file

    Returns:
        Dictionary with test summary or None if parsing fails
    """
    # First check for JSON results file
    script_output_dir = os.path.dirname(log_path)
    json_path = os.path.join(script_output_dir, "test-results.json")

    if os.path.exists(json_path):
        try:
            with open(json_path, "r") as f:
                results = json.loads(f.read())

            # Calculate success rate
            success_rate = 0.0
            if results["total"] > 0:
                success_rate = (results["passed"] / results["total"]) * 100

            # Format duration
            duration_str = f"{results['duration']:.2f} seconds"

            # Format failures
            failures = []
            for error in results.get("errors", []):
                failures.append(f"{error['suite']} - {error['test']}")

            return {
                "total": results["total"],
                "passed": results["passed"],
                "failed": results["failed"],
                "success_rate": success_rate,
                "duration": duration_str,
                "failures": failures,
            }
        except Exception as e:
            print(f"[LLM_DEBUG] Error reading JSON test results: {e}")
            # Fall back to log parsing

    if not os.path.exists(log_path):
        return None

    try:
        with open(log_path, "r") as f:
            content = f.read()

        # Look for the test summary (new format)
        summary_match = re.search(
            r"Test Results:\s*\nTotal:\s*(\d+)\s*\nPassed:\s*(\d+)\s*\nFailed:\s*(\d+)\s*\nDuration:\s*(\d+\.\d+)\s*seconds",
            content,
            re.MULTILINE,
        )

        if not summary_match:
            return None

        total = int(summary_match.group(1))
        passed = int(summary_match.group(2))
        failed = int(summary_match.group(3))
        duration = summary_match.group(4) + " seconds"

        # Calculate success rate
        success_rate = 0.0
        if total > 0:
            success_rate = (passed / total) * 100

        # Extract failed test names
        failures = []
        for line in content.split("\n"):
            if "✗" in line and "TestFramework:" in line:
                # Extract test name from failure line
                match = re.search(r"✗ ([^:]+) - ([^:]+):", line)
                if match:
                    failures.append(f"{match.group(1)} - {match.group(2)}")

        return {
            "total": total,
            "passed": passed,
            "failed": failed,
            "success_rate": success_rate,
            "duration": duration,
            "failures": failures,
        }

    except Exception as e:
        print(f"[LLM_DEBUG] Error parsing test results: {e}")
        return None


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

    # Handle capture-logs command (doesn't launch Factorio)
    if args.capture_logs:
        print(f"[LLM_INFO] Capturing Factorio logs from manual run...")
        
        # Try to find Factorio installation
        factorio_path = Path(args.factorio_path).resolve()
        if not factorio_path.exists():
            # Try to find it in common locations
            print("[LLM_WARN] Factorio executable not found at specified path, searching common locations...")
            # Just use the parent directories as a guess
            factorio_path = factorio_path.parent
        
        # Capture crash info (exit_code 1 indicates we're capturing a potential crash)
        crash_info = capture_crash_info(factorio_path, 1)
        
        # Save the report
        crash_report_path = save_crash_report(crash_info)
        print(f"[LLM_INFO] Log capture saved to: {crash_report_path}")
        
        # Also print key information for immediate analysis
        if crash_info.get("factorio_log"):
            print("\n[LLM_INFO] === Last lines of factorio-current.log ===")
            lines = crash_info["factorio_log"].split('\n')[-args.last_lines:]
            print('\n'.join(lines))
            
        if crash_info.get("mod_log"):
            print("\n[LLM_INFO] === Last lines of factorio-access.log ===")
            lines = crash_info["mod_log"].split('\n')[-50:]
            print('\n'.join(lines))
            
        return 0
    
    # Handle linting/formatting commands first (they don't launch Factorio)
    if args.lint:
        print(f"[LLM_INFO] Running lua-language-server on {args.mod_path}")

        exit_code, stdout, stderr = run_lua_linter(args.mod_path, args.lua_ls_path)

        if stdout:
            print(stdout)
        if stderr:
            print(stderr, file=sys.stderr)

        if exit_code == 0:
            print("[LLM_INFO] Linting passed with no errors")
        else:
            print(f"[LLM_ERROR] Linting failed with exit code {exit_code}")

        return exit_code

    if args.format_check or args.format:
        action = "Checking" if args.format_check else "Applying"
        print(f"[LLM_INFO] {action} formatting with stylua on {args.mod_path}")

        exit_code, stdout, stderr = run_stylua(
            args.mod_path, args.stylua_path, check_only=args.format_check
        )

        if stdout:
            print(stdout)
        if stderr:
            print(stderr, file=sys.stderr)

        if exit_code == 0:
            if args.format_check:
                print("[LLM_INFO] All files are properly formatted")
            else:
                print("[LLM_INFO] Formatting applied successfully")
        else:
            if args.format_check:
                print(f"[LLM_ERROR] Formatting check failed with exit code {exit_code}")
            else:
                print(f"[LLM_ERROR] Formatting failed with exit code {exit_code}")

        return exit_code

    # LLM usage warning for Factorio launching
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
    if args.run_tests:
        # For tests, we use benchmark mode with lab_tiles save
        factorio_args.extend(
            ["--benchmark", "lab_tiles.zip", "--benchmark-ticks", "5000"]
        )
        print("[LLM_INFO] Running tests with lab_tiles.zip save file")
        print("[LLM_INFO] Test output will be shown after completion...")
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
                "timed_out": exit_code == -1
                and args.timeout
                and elapsed_time >= args.timeout,
                "factorio_path": str(launcher.factorio_path),
            }

            if args.json_status:
                print(f"\n[LLM_STATUS]{json.dumps(status)}")
            else:
                print(f"\n[LLM_INFO] Factorio exited with code: {exit_code}")
                print(f"[LLM_INFO] Execution time: {elapsed_time:.2f} seconds")

        # Capture crash info if exit code indicates failure
        if exit_code != 0 and exit_code != 130:  # 130 is Ctrl+C
            print(f"\n[LLM_INFO] Factorio exited with error code {exit_code}, capturing crash information...")
            crash_info = capture_crash_info(launcher.factorio_path, exit_code)
            crash_report_path = save_crash_report(crash_info)
            print(f"[LLM_INFO] Crash report saved to: {crash_report_path}")
            
        # Check test results if running tests
        if args.run_tests:
            # Test log is in Factorio's script-output directory - find it dynamically
            script_output_dir = find_script_output_dir(launcher.factorio_path)
            if script_output_dir:
                test_log_path = script_output_dir / "factorio-access-test.log"
            else:
                # Fallback to old hardcoded path
                test_log_path = os.path.join(
                    os.path.dirname(launcher.factorio_path),
                    "..",
                    "..",
                    "script-output",
                    "factorio-access-test.log",
                )
                test_log_path = os.path.normpath(test_log_path)

            # Parse test results from log
            test_summary = parse_test_results(test_log_path)

            if test_summary:
                print("\n" + "=" * 60)
                print("FACTORIO ACCESS TEST RESULTS")
                print("=" * 60)
                print(f"Total Tests: {test_summary['total']}")
                print(f"Passed:      {test_summary['passed']} ✓")
                print(f"Failed:      {test_summary['failed']} ✗")
                print(f"Success Rate: {test_summary['success_rate']:.1f}%")
                print(f"Duration:    {test_summary['duration']}")
                print("=" * 60)

                if test_summary["failed"] > 0:
                    print("\nFAILED TESTS:")
                    for failure in test_summary["failures"]:
                        print(f"  ✗ {failure}")
                    print(f"\nCheck {test_log_path} for details")

            else:
                print("[LLM_WARNING] Test results unclear - check logs")
                print(f"Log file: {test_log_path}")

            # Now run Syntrax tests
            print("\n" + "=" * 60)
            print("RUNNING SYNTRAX TESTS")
            print("=" * 60)

            syntrax_exit_code, syntrax_stdout, syntrax_stderr = run_syntrax_tests()

            if syntrax_stdout:
                print(syntrax_stdout)
            if syntrax_stderr:
                print(syntrax_stderr, file=sys.stderr)

            if syntrax_exit_code == 0:
                print("\n✓ All Syntrax tests passed!")
            else:
                print(f"\n✗ Syntrax tests failed with exit code {syntrax_exit_code}")

            # Return failure if either test suite failed
            if test_summary and test_summary["failed"] > 0:
                return 1
            elif syntrax_exit_code != 0:
                return syntrax_exit_code
            else:
                return 0

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
