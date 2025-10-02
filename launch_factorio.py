#!/usr/bin/env python3
"""
Factorio Windows Launcher - Development and debugging tool for FactorioAccess.

Key features:
- Launch Factorio with timeout support
- Capture and analyze crash logs
- Run tests and linting
- Format code with stylua
"""

import argparse
import subprocess
import sys
import os
import time
import shutil
from pathlib import Path
from typing import Optional, List, Tuple, Dict, Any
import threading
import queue
import json
import tempfile
import re
import glob


# Constants
FACTORIO_REL_PATH = Path("../../bin/x64/factorio.exe")
DEFAULT_TIMEOUT = 300
LUA_EXE = "lua52.exe"


class LogsNotFoundError(Exception):
    """Raised when critical logs cannot be found during debugging."""

    pass


def validate_factorio_exe() -> Path:
    """Validate and return the Factorio executable path."""
    factorio_path = (Path(__file__).parent / FACTORIO_REL_PATH).resolve()
    if not factorio_path.exists():
        raise FileNotFoundError(
            f"Factorio executable not found at: {factorio_path}\n"
            f"Current working directory: {Path.cwd()}"
        )
    return factorio_path


def stream_process_output(
    cmd: List[str],
    timeout: Optional[int] = None,
    capture: bool = True,
    unbuffered: bool = True,
) -> Tuple[int, float]:
    """
    Stream output from a subprocess with timeout support.

    Uses threading to prevent blocking on pipe reads and handle timeouts properly.

    Returns:
        Tuple of (exit_code, elapsed_time)
    """
    start_time = time.time()
    output_queue = queue.Queue()

    def output_reader(pipe, pipe_name: str):
        """Thread worker to read from stdout/stderr pipes."""
        try:
            for line in iter(pipe.readline, ""):
                if line:
                    output_queue.put((pipe_name, line))
            pipe.close()
        except Exception as e:
            output_queue.put(("error", f"Error reading {pipe_name}: {e}"))

    # Setup subprocess
    popen_args = {
        "bufsize": 0 if unbuffered else -1,
        "encoding": "utf-8",
        "errors": "replace",
        "env": os.environ.copy(),
    }

    if capture:
        popen_args.update(
            {
                "stdout": subprocess.PIPE,
                "stderr": subprocess.PIPE,
            }
        )

    print(f"[INFO] Launching: {' '.join(cmd)}")
    if timeout:
        print(f"[INFO] Timeout: {timeout} seconds")

    try:
        process = subprocess.Popen(cmd, **popen_args)

        if capture:
            # Start reader threads
            stdout_thread = threading.Thread(
                target=output_reader, args=(process.stdout, "stdout")
            )
            stderr_thread = threading.Thread(
                target=output_reader, args=(process.stderr, "stderr")
            )
            stdout_thread.daemon = True
            stderr_thread.daemon = True
            stdout_thread.start()
            stderr_thread.start()

            # Stream output in real-time
            while True:
                try:
                    pipe_name, line = output_queue.get(timeout=0.1)
                    if pipe_name == "stdout":
                        sys.stdout.write(line)
                        sys.stdout.flush()
                    elif pipe_name == "stderr":
                        sys.stderr.write(line)
                        sys.stderr.flush()
                except queue.Empty:
                    # Check if process finished
                    if process.poll() is not None:
                        break
                    # Check timeout
                    elapsed = time.time() - start_time
                    if timeout and elapsed > timeout:
                        print(f"\n[ERROR] Timeout reached ({timeout}s), terminating...")
                        process.terminate()
                        time.sleep(2)
                        if process.poll() is None:
                            process.kill()
                        return -1, elapsed

            # Drain remaining output
            while not output_queue.empty():
                try:
                    pipe_name, line = output_queue.get_nowait()
                    if pipe_name == "stdout":
                        sys.stdout.write(line)
                    elif pipe_name == "stderr":
                        sys.stderr.write(line)
                except queue.Empty:
                    break
        else:
            # Simple wait without capture
            try:
                process.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                elapsed = time.time() - start_time
                print(f"\n[ERROR] Timeout reached ({timeout}s), terminating...")
                process.terminate()
                time.sleep(2)
                if process.poll() is None:
                    process.kill()
                return -1, elapsed

        elapsed = time.time() - start_time
        return process.returncode, elapsed

    except OSError as e:
        elapsed = time.time() - start_time
        if e.errno == 2:
            print(f"[ERROR] Could not find executable: {cmd[0]}")
        else:
            print(f"[ERROR] OS error launching process: {e}")
        return -1, elapsed
    except Exception as e:
        elapsed = time.time() - start_time
        print(f"[ERROR] Unexpected error: {e}")
        return -1, elapsed


def launch_factorio(
    args: List[str],
    timeout: Optional[int] = None,
    capture_output: bool = True,
) -> Tuple[int, float]:
    """Launch Factorio with specified arguments."""
    factorio_path = validate_factorio_exe()
    cmd = [str(factorio_path)] + args
    return stream_process_output(cmd, timeout, capture_output)


def find_factorio_type_definitions() -> Optional[str]:
    """Find Factorio type definitions for lua-language-server."""
    search_paths = [
        # VSCode on Windows
        os.path.expanduser(
            "~\\AppData\\Roaming\\Code\\User\\workspaceStorage\\*\\justarandomgeek.factoriomod-debug\\sumneko-3rd\\factorio\\library"
        ),
        # Manual installation
        "C:\\factorio-lua-types\\library",
        os.path.expanduser("~\\factorio-lua-types\\library"),
    ]

    for pattern in search_paths:
        expanded = os.path.expanduser(pattern)
        matches = glob.glob(expanded)
        if matches:
            return matches[0]

    return None


def create_or_update_luarc(config_path: str) -> None:
    """Create .luarc.json configuration for lua-language-server."""
    luarc_path = Path(config_path)
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
                "redefined-local",
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

    if factorio_lib:
        config["workspace"]["library"].append(factorio_lib)
        print(f"[INFO] Found Factorio type definitions at: {factorio_lib}")
    else:
        print(
            "[WARNING] Factorio type definitions not found. Some API completions may be missing."
        )
        print(
            "[HINT] Install the factoriomod-debug VSCode extension for better type checking."
        )

    with open(luarc_path, "w") as f:
        json.dump(config, f, indent=2)

    print(f"[INFO] Updated {luarc_path}")
    


def check_lua_annotations() -> Tuple[int, List[str]]:
    """
    Check for incorrect LuaLS annotation formats.

    Correct format: ---@
    Incorrect formats: -- @, --- @, --@, etc.

    Returns:
        Tuple of (exit_code, error_list)
    """
    mod_path = Path(__file__).parent.resolve()
    errors = []
    files_checked = 0

    # Find all Lua files
    lua_files = glob.glob(str(mod_path / "**/*.lua"), recursive=True)

    for file_path in lua_files:
        files_checked += 1
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            # Check each line for annotation issues
            for line_num, line in enumerate(content.splitlines(), 1):
                stripped = line.strip()
                if not stripped or "@" not in stripped:
                    continue

                # Check if line contains annotation-like pattern
                if re.match(r"^\s*-+\s*@", line):
                    # Check if it's NOT the correct format
                    if not re.match(r"^\s*---@", line):
                        rel_path = Path(file_path).relative_to(mod_path)
                        errors.append(
                            f"{rel_path}:{line_num}: Incorrect annotation format: {line.strip()}"
                        )
                        errors.append(
                            f"  Should be: ---@{line.strip()[line.find('@') + 1 :]}"
                        )

        except Exception as e:
            errors.append(f"Error checking {file_path}: {str(e)}")

    if not errors:
        print(f"[INFO] All annotations correct in {files_checked} Lua files")

    return (1 if errors else 0, errors)


def check_non_top_level_requires() -> Tuple[int, List[str]]:
    """
    Check for non-top-level require() statements.

    require() statements should only appear at module level (no indentation),
    not inside functions or other blocks.

    Returns:
        Tuple of (exit_code, error_list)
    """
    mod_path = Path(__file__).parent.resolve()
    errors = []
    files_checked = 0

    # Files/patterns to skip (test infrastructure, CLI tools, etc.)
    skip_patterns = [
        "*-tests.lua",
        "*-cli.lua",
        "run-tests.lua",
        "test-*.lua",
    ]

    # Find all Lua files
    lua_files = glob.glob(str(mod_path / "**/*.lua"), recursive=True)

    for file_path in lua_files:
        # Skip test infrastructure files
        file_name = Path(file_path).name
        if any(glob.fnmatch.fnmatch(file_name, pattern) for pattern in skip_patterns):
            continue

        files_checked += 1
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            # Check each line for non-top-level requires
            for line_num, line in enumerate(content.splitlines(), 1):
                # Skip comments
                if line.strip().startswith("--"):
                    continue

                # Check if line contains require(
                if "require(" in line:
                    # Check if line has leading whitespace (indicating it's inside a block)
                    if line and line[0] in (' ', '\t'):
                        rel_path = Path(file_path).relative_to(mod_path)
                        errors.append(
                            f"{rel_path}:{line_num}: Non-top-level require() found"
                        )
                        errors.append(f"  {line.rstrip()}")
                        errors.append(
                            "  require() statements should only appear at module level (no indentation)"
                        )

        except Exception as e:
            errors.append(f"Error checking {file_path}: {str(e)}")

    if not errors:
        print(f"[INFO] No non-top-level requires found in {files_checked} Lua files")

    return (1 if errors else 0, errors)


def run_lua_linter(lua_ls_path: Optional[str] = None) -> Tuple[int, str, str]:
    """Run lua-language-server on the mod files."""
    mod_path = Path(__file__).parent.resolve()

    if lua_ls_path is None:
        # Try to find lua-language-server
        possible_paths = [
            "lua-language-server.exe",
            os.path.expanduser(
                "~\\.vscode\\extensions\\sumneko.lua-*\\server\\bin\\lua-language-server.exe"
            ),
            os.path.expanduser(
                "~\\AppData\\Roaming\\Code\\User\\globalStorage\\sumneko.lua\\server\\bin\\lua-language-server.exe"
            ),
        ]

        for pattern in possible_paths:
            if pattern == "lua-language-server.exe":
                if shutil.which(pattern):
                    lua_ls_path = pattern
                    break
            else:
                matches = glob.glob(pattern)
                if matches:
                    lua_ls_path = matches[0]
                    break

    if not lua_ls_path:
        return (
            -1,
            "",
            "lua-language-server not found. Install the sumneko.lua VSCode extension.",
        )

    # Create temporary .luarc.json config (don't pollute the mod directory)
    with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as tmp:
        config_file = tmp.name
        create_or_update_luarc(config_file)

    # Run lua-language-server with temp config
    cmd = [lua_ls_path, "--check", ".", "--configpath", config_file]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=60,
            cwd=str(mod_path),
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "lua-language-server timed out after 60 seconds"
    except Exception as e:
        return -1, "", f"Error running lua-language-server: {e}"
    finally:
        # Clean up temp config file
        try:
            os.unlink(config_file)
        except:
            pass


def run_stylua(
    stylua_path: Optional[str] = None, check_only: bool = False
) -> Tuple[int, str, str]:
    """Run stylua formatter on Lua files."""
    mod_path = Path(__file__).parent.resolve()

    if stylua_path is None:
        stylua_path = shutil.which("stylua")

    if not stylua_path:
        return -1, "", "stylua not found in PATH. Please install stylua."

    cmd = [stylua_path]
    if check_only:
        cmd.append("--check")
    cmd.append(str(mod_path))

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=30,
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "stylua timed out after 30 seconds"
    except Exception as e:
        return -1, "", f"Error running stylua: {e}"


def run_lua_tests(test_suite: str = "all") -> Tuple[int, str, str]:
    """Run Lua unit tests (syntrax and/or data structures)."""
    if not shutil.which(LUA_EXE):
        return (
            -1,
            "",
            f"{LUA_EXE} not found. Please ensure Lua 5.2 is installed and in PATH.",
        )

    stdout_parts = []
    stderr_parts = []
    exit_code = 0

    # Determine which tests to run
    test_files = []
    if test_suite in ["syntrax", "all"]:
        test_files.append("syntrax-tests.lua")
    if test_suite in ["ds", "all"]:
        test_files.append("ds-tests.lua")

    for test_file in test_files:
        if not Path(test_file).exists():
            stderr_parts.append(f"Test file {test_file} not found")
            continue

        cmd = [LUA_EXE, test_file]
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=30,
            )
            stdout_parts.append(result.stdout)
            stderr_parts.append(result.stderr)
            if result.returncode != 0:
                exit_code = result.returncode
        except Exception as e:
            stderr_parts.append(f"Error running {test_file}: {e}")
            exit_code = -1

    return exit_code, "\n".join(stdout_parts), "\n".join(stderr_parts)


def find_script_output_dir() -> Optional[Path]:
    """Find Factorio's script-output directory."""
    # Script output is relative to Factorio executable
    factorio_dir = Path(__file__).parent.parent.parent
    script_output = factorio_dir / "script-output"

    if script_output.exists():
        return script_output

    # Try alternative location
    alt_output = factorio_dir / "data" / "script-output"
    if alt_output.exists():
        return alt_output

    return None


def capture_crash_info(exit_code: int, fail_hard: bool = True) -> Dict[str, Any]:
    """
    Capture crash information from logs.

    Args:
        exit_code: Exit code from Factorio
        fail_hard: If True, raise exception when critical logs are missing

    Returns:
        Dictionary with crash information
    """
    crash_info = {
        "exit_code": exit_code,
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "factorio_log": None,
        "mod_log": None,
        "speech_log": None,
    }

    logs_found = False
    missing_logs = []

    # Find Factorio log
    factorio_dir = Path(__file__).parent.parent.parent
    log_path = factorio_dir / "factorio-current.log"

    if log_path.exists():
        try:
            with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()

                # Look for error patterns
                error_found = False
                for i, line in enumerate(lines):
                    if any(
                        pattern in line.lower()
                        for pattern in [
                            "error",
                            "exception",
                            "crash",
                            "stack traceback",
                        ]
                    ):
                        # Capture context around error
                        start = max(0, i - 20)
                        crash_info["factorio_log"] = "".join(lines[start:])[
                            -10000:
                        ]  # Last 10KB max
                        error_found = True
                        break

                if not error_found:
                    # No error found, just get last 100 lines
                    crash_info["factorio_log"] = "".join(lines[-100:])

                logs_found = True
        except Exception as e:
            crash_info["factorio_log"] = f"Failed to read log: {e}"
    else:
        missing_logs.append(f"factorio-current.log at {log_path}")

    # Find mod logs
    script_output_dir = find_script_output_dir()
    if script_output_dir:
        # Mod log
        mod_log_path = script_output_dir / "factorio-access.log"
        if mod_log_path.exists():
            try:
                with open(mod_log_path, "r", encoding="utf-8", errors="ignore") as f:
                    crash_info["mod_log"] = f.read()[-10000:]  # Last 10KB
                logs_found = True
            except Exception as e:
                crash_info["mod_log"] = f"Failed to read mod log: {e}"

        # Speech log (critical for debugging)
        speech_log_path = script_output_dir / "factorio-access-speech.log"
        if speech_log_path.exists():
            try:
                with open(
                    speech_log_path, "r", encoding="utf-8", errors="ignore"
                ) as f:
                    crash_info["speech_log"] = f.read()[-5000:]  # Last 5KB
                logs_found = True
            except Exception as e:
                crash_info["speech_log"] = f"Failed to read speech log: {e}"
        else:
            missing_logs.append(f"factorio-access-speech.log at {speech_log_path}")
    else:
        missing_logs.append("script-output directory")

    # Fail if no logs found and fail_hard is True
    if fail_hard and not logs_found:
        error_msg = (
            "[CRITICAL] Cannot find any logs! Debugging is impossible without logs.\n"
        )
        error_msg += "Missing:\n"
        for log in missing_logs:
            error_msg += f"  - {log}\n"
        error_msg += "\nRun with --show-paths to see where logs are expected."
        raise LogsNotFoundError(error_msg)

    return crash_info


def save_crash_report(crash_info: Dict[str, Any]) -> Path:
    """Save crash report to JSON file."""
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    crash_file = Path(f"factorio_crash_{timestamp}.json")

    with open(crash_file, "w", encoding="utf-8") as f:
        json.dump(crash_info, f, indent=2)

    return crash_file


def detect_module_loading_errors(output_file: str = None) -> Optional[Dict[str, Any]]:
    """Detect Factorio module loading errors from output.

    Args:
        output_file: Path to temporary output file (if buffering was used)

    Returns:
        Dict with error information if module loading failed, None otherwise
    """
    # Check the temporary output file if provided
    if output_file and os.path.exists(output_file):
        try:
            with open(output_file, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()

            # Look for module loading errors
            # Pattern: Error Util.cpp:81: __ModName__/path: module ... not found
            module_error = re.search(
                r"Error\s+\w+\.cpp:\d+:\s+(.+?):\s*module\s+(.+?)\s+not found",
                content
            )

            if module_error:
                return {
                    "error_type": "module_not_found",
                    "location": module_error.group(1),
                    "module": module_error.group(2),
                    "full_error": module_error.group(0)
                }

            # Also check for other loading errors
            generic_error = re.search(
                r"Error\s+\w+\.cpp:\d+:\s+(.+)",
                content
            )

            if generic_error:
                return {
                    "error_type": "loading_error",
                    "full_error": generic_error.group(0),
                    "details": generic_error.group(1)
                }

        except Exception:
            pass

    return None


def parse_test_results(log_path: str) -> Optional[Dict[str, Any]]:
    """Parse test results from log file."""
    log_path = Path(log_path)
    if not log_path.exists():
        return None

    try:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        summary = {
            "total": 0,
            "passed": 0,
            "failed": 0,
            "success_rate": 0.0,
            "duration": "unknown",
            "failures": [],
        }

        # Parse TestFramework output format (PASS/FAIL or checkmarks)
        # Try both Unicode checkmarks and ASCII text
        passed_tests = re.findall(r"TestFramework: (?:✓|PASS:) (.+?)(?:\n|$)", content)

        # Look for failed tests - they appear after ERROR
        failed_tests = re.findall(
            r"\[ERROR\] TestFramework: (?:✗|FAIL:) (.+?):", content
        )

        summary["passed"] = len(passed_tests)
        summary["failed"] = len(failed_tests)
        summary["failures"] = failed_tests[:10]  # Limit to first 10

        summary["total"] = summary["passed"] + summary["failed"]
        if summary["total"] > 0:
            summary["success_rate"] = (summary["passed"] / summary["total"]) * 100

        return summary

    except Exception:
        return None


def parse_factorio_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Factorio Windows Launcher for FactorioAccess development",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    # Commands group
    commands = parser.add_argument_group("commands")
    commands.add_argument(
        "--show-paths", action="store_true", help="Show important paths for debugging"
    )
    commands.add_argument(
        "--capture-logs", action="store_true", help="Capture current logs for debugging"
    )
    commands.add_argument(
        "--debug-logs", action="store_true", help="Show detailed debug information"
    )
    commands.add_argument("--lint", action="store_true", help="Run Lua linter")
    commands.add_argument(
        "--format", action="store_true", help="Apply code formatting with stylua"
    )
    commands.add_argument(
        "--format-check", action="store_true", help="Check code formatting"
    )
    commands.add_argument("--run-tests", action="store_true", help="Run all tests")

    # Tool paths
    tools = parser.add_argument_group("tool paths")
    tools.add_argument("--lua-ls-path", help="Path to lua-language-server executable")
    tools.add_argument("--stylua-path", help="Path to stylua executable")

    # Factorio options
    factorio = parser.add_argument_group("factorio options")
    factorio.add_argument(
        "--factorio-path",
        default="../../bin/x64/factorio.exe",
        help="Path to Factorio executable",
    )
    factorio.add_argument("--timeout", type=int, help="Timeout in seconds")
    factorio.add_argument("--mod-directory", help="Mod directory path")
    factorio.add_argument("--config", help="Config file path")
    factorio.add_argument("--executable-path", help="Executable path for Factorio")
    factorio.add_argument("--create", help="Create new save")
    factorio.add_argument("--load-game", help="Load save game")
    factorio.add_argument("--benchmark", help="Run benchmark")
    factorio.add_argument("--mp-connect", help="Connect to multiplayer server")

    # Test options
    test_options = parser.add_argument_group("test options")
    test_options.add_argument(
        "--lua-tests",
        choices=["all", "syntrax", "ds"],
        default="all",
        help="Which Lua tests to run",
    )
    test_options.add_argument(
        "--verbose", action="store_true", help="Verbose output for tests"
    )

    # Output options
    output = parser.add_argument_group("output options")
    output.add_argument(
        "--no-capture", action="store_true", help="Don't capture Factorio output"
    )
    output.add_argument("--buffered", action="store_true", help="Use buffered output")
    output.add_argument(
        "--json-status", action="store_true", help="Output status as JSON"
    )
    output.add_argument(
        "--last-lines",
        type=int,
        default=100,
        help="Number of log lines to show on error",
    )

    # Other options
    parser.add_argument(
        "--dry-run", action="store_true", help="Show command without executing"
    )
    parser.add_argument("--shell", action="store_true", help="Use shell execution")
    parser.add_argument(
        "extra_args", nargs="*", default=[], help="Extra arguments to pass to Factorio"
    )

    return parser.parse_args()


def main():
    """Main entry point."""
    args = parse_factorio_args()

    # Handle show-paths
    if args.show_paths or args.debug_logs:
        factorio_dir = Path(__file__).parent.parent.parent
        mod_dir = Path(__file__).parent
        script_output = find_script_output_dir()

        print("=" * 60)
        print("FACTORIO ACCESS LAUNCHER - PATH INFORMATION")
        print("=" * 60)
        print(f"Factorio directory: {factorio_dir}")
        print(f"Mod directory: {mod_dir}")
        print(f"Working directory: {Path.cwd()}")

        factorio_exe = factorio_dir / "bin" / "x64" / "factorio.exe"
        if factorio_exe.exists():
            print(f"Factorio executable: {factorio_exe} [EXISTS]")
        else:
            print(f"Factorio executable: {factorio_exe} [NOT FOUND]")

        if script_output:
            print(f"Script output directory: {script_output}")

            # Check for specific files
            for log_file in [
                "factorio-access-speech.log",
                "factorio-access.log",
                "factorio-access-test.log",
            ]:
                log_path = script_output / log_file
                if log_path.exists():
                    print(f"  - {log_file}: {log_path}")
                else:
                    print(f"  - {log_file}: Not found")
        else:
            print("Script output directory: Not found")

        print("=" * 60)
        return 0

    # Handle capture-logs
    if args.capture_logs:
        print("[INFO] Capturing Factorio logs from manual run...")

        try:
            crash_info = capture_crash_info(1, fail_hard=True)
        except LogsNotFoundError as e:
            print(str(e))
            return 2

        # Save the report
        crash_report_path = save_crash_report(crash_info)
        print(f"[INFO] Log capture saved to: {crash_report_path}")

        # Show recent speech log entries
        if crash_info.get("speech_log"):
            print("\n[INFO] === Last lines of speech log ===")
            lines = crash_info["speech_log"].split("\n")[-50:]
            print("\n".join(lines))

        return 0

    # Handle linting
    if args.lint:
        mod_path = Path(__file__).parent.resolve()

        # First check annotations
        print(f"[INFO] Checking LuaLS annotations in {mod_path}")
        ann_exit_code, ann_errors = check_lua_annotations()
        if ann_errors:
            print(f"Found {len(ann_errors) // 2} incorrect annotation(s):")
            for error in ann_errors:
                print(error)

        # Check for non-top-level requires
        print(f"\n[INFO] Checking for non-top-level require() statements in {mod_path}")
        req_exit_code, req_errors = check_non_top_level_requires()
        if req_errors:
            print(f"Found {len(req_errors) // 3} non-top-level require(s):")
            for error in req_errors:
                print(error)

        # Then run lua-language-server
        print(f"\n[INFO] Running lua-language-server on {mod_path}")
        exit_code, stdout, stderr = run_lua_linter(args.lua_ls_path)

        if stdout:
            print(stdout)
        if stderr:
            print(stderr, file=sys.stderr)

        # Return failure if any check failed
        final_exit_code = max(ann_exit_code, req_exit_code, exit_code)
        if final_exit_code == 0:
            print("[INFO] All linting checks passed")
        else:
            print(f"[ERROR] Linting failed with exit code {final_exit_code}")

        return final_exit_code

    # Handle formatting
    if args.format_check or args.format:
        mod_path = Path(__file__).parent.resolve()
        action = "Checking" if args.format_check else "Applying"
        print(f"[INFO] {action} formatting with stylua on {mod_path}")

        exit_code, stdout, stderr = run_stylua(
            args.stylua_path, check_only=args.format_check
        )

        if stdout:
            print(stdout)
        if stderr:
            print(stderr, file=sys.stderr)

        if exit_code == 0:
            if args.format_check:
                print("[INFO] All files are properly formatted")
            else:
                print("[INFO] Formatting applied successfully")
        else:
            if args.format_check:
                print(f"[ERROR] Formatting check failed with exit code {exit_code}")
            else:
                print(f"[ERROR] Formatting failed with exit code {exit_code}")

        return exit_code

    # Build Factorio command line
    factorio_args = []

    # Add options
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
        # For tests, use benchmark mode
        factorio_args.extend(
            ["--benchmark", "lab_tiles.zip", "--benchmark-ticks", "5000"]
        )
        print("[INFO] Running tests with lab_tiles.zip save file")
        if not args.verbose:
            print("[INFO] Test output will be suppressed unless failures occur...")
    if args.mp_connect:
        factorio_args.extend(["--mp-connect", args.mp_connect])

    # Add extra arguments
    factorio_args.extend(args.extra_args)

    # Dry run mode
    if args.dry_run:
        factorio_exe = validate_factorio_exe()
        cmd = [str(factorio_exe)] + factorio_args
        print(f"[INFO] Would execute: {' '.join(cmd)}")
        return 0

    # Warning for no timeout
    if not args.timeout and not args.dry_run:
        print("[WARNING] No timeout specified! Factorio may run indefinitely.")
        print("[HINT] Always use --timeout when running from automation")

    # Handle test execution with output buffering
    if args.run_tests:
        temp_output_file = None
        original_stdout = sys.stdout
        original_stderr = sys.stderr

        try:
            # Buffer output for tests unless verbose
            if not args.verbose:
                temp_output_file = tempfile.NamedTemporaryFile(
                    mode="w+", delete=False, suffix=".log"
                )
                sys.stdout = temp_output_file
                sys.stderr = temp_output_file

            # Run Factorio tests
            exit_code, elapsed_time = launch_factorio(
                factorio_args, timeout=args.timeout, capture_output=not args.no_capture
            )

            # Restore output
            if not args.verbose:
                sys.stdout = original_stdout
                sys.stderr = original_stderr
                temp_output_file.close()

            # Parse test results
            script_output_dir = find_script_output_dir()
            if script_output_dir:
                test_log_path = script_output_dir / "factorio-access-test.log"
            else:
                test_log_path = Path("script-output/factorio-access-test.log")

            # Check if Factorio crashed (exit code -1 typically means a test threw an uncaught error)
            factorio_crashed = exit_code == -1

            # Check for module loading errors
            module_error = None
            if not args.verbose and temp_output_file:
                module_error = detect_module_loading_errors(temp_output_file.name)

            # If we have a module loading error, treat it as a critical failure
            if module_error:
                print("\n" + "=" * 60)
                print("CRITICAL ERROR: MODULE LOADING FAILED")
                print("=" * 60)

                if module_error["error_type"] == "module_not_found":
                    print(f"Module not found: {module_error['module']}")
                    print(f"Location: {module_error['location']}")
                else:
                    print(f"Loading error: {module_error.get('details', 'Unknown error')}")

                print(f"\nFull error: {module_error['full_error']}")
                print("=" * 60)
                print("\nTESTING ABORTED: Fix module loading errors before running tests")

                # Show the full output for debugging
                if temp_output_file:
                    print("\n" + "=" * 60)
                    print("FULL FACTORIO OUTPUT:")
                    print("=" * 60)
                    try:
                        with open(temp_output_file.name, "r") as f:
                            print(f.read())
                    except Exception as e:
                        print(f"[ERROR] Could not read buffered output: {e}")

                # Exit with error code
                sys.exit(1)

            test_summary = parse_test_results(str(test_log_path))

            if test_summary:
                print("\n" + "=" * 60)
                print("FACTORIO ACCESS TEST RESULTS")
                print("=" * 60)
                print(f"Total Tests: {test_summary['total']}")
                print(f"Passed:      {test_summary['passed']}")
                print(f"Failed:      {test_summary['failed']}")
                print(f"Success Rate: {test_summary['success_rate']:.1f}%")
                if factorio_crashed:
                    print(f"Status:      CRASHED (exit code -1)")
                print("=" * 60)

                if test_summary["failed"] > 0 or factorio_crashed:
                    print("\nFAILED TESTS:")
                    for failure in test_summary["failures"]:
                        print(f"  - {failure}")
                    print(f"\nCheck {test_log_path} for details")

                    # Show buffered output on failure
                    if not args.verbose and temp_output_file:
                        print("\n" + "=" * 60)
                        print("FACTORIO OUTPUT (shown due to test failures):")
                        print("=" * 60)
                        try:
                            with open(temp_output_file.name, "r") as f:
                                print(f.read())
                        except Exception as e:
                            print(f"[ERROR] Could not read buffered output: {e}")
            else:
                print("[WARNING] Could not parse test results - check logs")
                print(f"Log file: {test_log_path}")
                if exit_code == -1:
                    print(
                        "[INFO] Exit code -1 usually indicates an uncaught test error"
                    )

            # Run Lua tests
            print("\n" + "=" * 60)
            test_desc = {
                "syntrax": "SYNTRAX TESTS",
                "ds": "DATA STRUCTURES TESTS",
                "all": "LUA TESTS (SYNTRAX & DATA STRUCTURES)",
            }
            print(f"RUNNING {test_desc[args.lua_tests]}")
            print("=" * 60)

            lua_exit_code, lua_stdout, lua_stderr = run_lua_tests(args.lua_tests)

            if lua_stdout:
                print(lua_stdout)
            if lua_stderr:
                print(lua_stderr, file=sys.stderr)

            if lua_exit_code == 0:
                print("\nAll Lua tests passed!")
            else:
                print(f"\nLua tests failed with exit code {lua_exit_code}")

            # Return failure if either test suite failed
            if test_summary and test_summary["failed"] > 0:
                return 1
            elif lua_exit_code != 0:
                return lua_exit_code
            else:
                return exit_code

        finally:
            # Restore output
            sys.stdout = original_stdout
            sys.stderr = original_stderr

            # Clean up temp file
            if temp_output_file:
                try:
                    if hasattr(temp_output_file, "name") and os.path.exists(
                        temp_output_file.name
                    ):
                        os.unlink(temp_output_file.name)
                except Exception:
                    pass

    # Regular Factorio execution
    try:
        exit_code, elapsed_time = launch_factorio(
            factorio_args, timeout=args.timeout, capture_output=not args.no_capture
        )

        # Output status if requested
        if args.verbose or args.json_status:
            status = {
                "exit_code": exit_code,
                "elapsed_time": round(elapsed_time, 2),
                "timeout": args.timeout,
                "timed_out": exit_code == -1
                and args.timeout
                and elapsed_time >= args.timeout,
            }

            if args.json_status:
                print(f"\n[STATUS]{json.dumps(status)}")
            else:
                print(f"\n[INFO] Factorio exited with code: {exit_code}")
                print(f"[INFO] Execution time: {elapsed_time:.2f} seconds")

        # Capture crash info on failure
        if exit_code != 0 and exit_code != 130:  # 130 is Ctrl+C
            print(
                f"\n[INFO] Factorio exited with error code {exit_code}, capturing crash information..."
            )
            try:
                crash_info = capture_crash_info(exit_code, fail_hard=False)
                crash_report_path = save_crash_report(crash_info)
                print(f"[INFO] Crash report saved to: {crash_report_path}")
            except LogsNotFoundError as e:
                print(str(e))
                print("[ERROR] Failed to capture crash information due to missing logs")

        return exit_code

    except KeyboardInterrupt:
        print("\n[INFO] Interrupted by user")
        return 130
    except Exception as e:
        print(f"[ERROR] Unexpected error in launcher: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
