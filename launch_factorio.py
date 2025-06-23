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
- GUI testing: python3 launch_factorio.py --gui-test --suppress-window --timeout 60
- Lint Lua code: python3 launch_factorio.py --lint
- Check formatting: python3 launch_factorio.py --format-check
- Apply formatting: python3 launch_factorio.py --format

WSL INTEROP NOTES:
- Windows error 0xc0000142 (DLL init failed) may occur - use --shell flag as workaround
- Output buffering issues are handled by default with unbuffered mode
- Paths are automatically resolved from WSL to Windows format

GUI TESTING FEATURES:
- Take screenshots of the game window
- Control mouse and keyboard
- Suppress window to prevent focus stealing
"""

import argparse
import subprocess
import sys
import os
import signal
import time
from pathlib import Path
from typing import Optional, List, Union, Tuple, Dict, Any
import threading
import queue
import json
import tempfile
import re
from enum import Enum


class MenuActions:
    """
    Common Factorio menu coordinates and actions.
    Coordinates based on 1920x1080 resolution.
    """
    # Main menu buttons (approximate centers)
    MAIN_MENU = {
        "single_player": (960, 400),
        "multiplayer": (960, 450),
        "mods": (960, 500),
        "settings": (960, 550),
        "quit": (960, 900),
    }
    
    # Single player menu
    SINGLE_PLAYER = {
        "new_game": (960, 400),
        "load_game": (960, 450),
        "back": (960, 900),
    }
    
    # New game menu
    NEW_GAME = {
        "play": (1600, 900),  # Bottom right
        "back": (320, 900),   # Bottom left
    }
    
    # Common actions
    ESCAPE_KEY = "{ESC}"
    ENTER_KEY = "{ENTER}"
    TAB_KEY = "{TAB}"


class PowerShellInterface:
    """
    Abstraction for running PowerShell commands from WSL.
    
    This class provides a clean interface for executing PowerShell scripts
    and commands, handling the WSL-to-Windows boundary.
    """

    def __init__(self):
        """Initialize the PowerShell interface."""
        self.powershell_exe = "powershell.exe"
        # Check if we can find PowerShell
        try:
            subprocess.run(
                [self.powershell_exe, "-Command", "echo test"],
                capture_output=True,
                timeout=5,
            )
        except (subprocess.TimeoutExpired, FileNotFoundError) as e:
            print(f"[LLM_WARNING] PowerShell may not be available: {e}")

    def run_script(self, script: str, timeout: int = 30) -> Tuple[int, str, str]:
        """
        Run a PowerShell script and return results.
        
        Args:
            script: PowerShell script to execute
            timeout: Maximum execution time in seconds
            
        Returns:
            Tuple of (exit_code, stdout, stderr)
        """
        try:
            # Use -NoProfile for faster execution
            result = subprocess.run(
                [self.powershell_exe, "-NoProfile", "-Command", script],
                capture_output=True,
                text=True,
                timeout=timeout,
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return -1, "", "PowerShell script timed out"
        except Exception as e:
            return -1, "", str(e)

    def run_command(self, command: str, timeout: int = 10) -> Tuple[int, str, str]:
        """
        Run a simple PowerShell command.
        
        Args:
            command: Simple PowerShell command
            timeout: Maximum execution time in seconds
            
        Returns:
            Tuple of (exit_code, stdout, stderr)
        """
        return self.run_script(command, timeout)


class WindowsGUIController:
    """
    Control Windows GUI elements via PowerShell.
    
    Provides methods for taking screenshots, controlling mouse/keyboard,
    and managing window visibility.
    """

    def __init__(self):
        """Initialize the GUI controller."""
        self.ps = PowerShellInterface()
        self._init_types()

    def _init_types(self):
        """Initialize .NET types for GUI control."""
        # Define the types we'll need for GUI control
        init_script = """
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue

# Check if Win32 class already exists to avoid duplicate type errors
$win32Type = [System.Type]::GetType("Win32")
if ($null -eq $win32Type) {
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        using System.Drawing;
        
        public class Win32 {
            [DllImport("user32.dll")]
            public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            
            [DllImport("user32.dll")]
            public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
            
            [DllImport("user32.dll")]
            public static extern bool SetForegroundWindow(IntPtr hWnd);
            
            [DllImport("user32.dll")]
            public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
            
            [DllImport("user32.dll")]
            public static extern bool SetCursorPos(int X, int Y);
            
            [DllImport("user32.dll")]
            public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, int dwExtraInfo);
            
            [DllImport("user32.dll")]
            public static extern short GetAsyncKeyState(int vKey);
            
            public const int SW_HIDE = 0;
            public const int SW_SHOW = 5;
            public const int SW_MINIMIZE = 6;
            public const int SW_RESTORE = 9;
            
            public const uint MOUSEEVENTF_LEFTDOWN = 0x0002;
            public const uint MOUSEEVENTF_LEFTUP = 0x0004;
            public const uint MOUSEEVENTF_RIGHTDOWN = 0x0008;
            public const uint MOUSEEVENTF_RIGHTUP = 0x0010;
            public const uint MOUSEEVENTF_MIDDLEDOWN = 0x0020;
            public const uint MOUSEEVENTF_MIDDLEUP = 0x0040;
            
            [StructLayout(LayoutKind.Sequential)]
            public struct RECT {
                public int Left;
                public int Top;
                public int Right;
                public int Bottom;
            }
        }
"@
}
Write-Output "Types initialized"
"""
        exit_code, stdout, stderr = self.ps.run_script(init_script, timeout=15)
        if exit_code != 0:
            print(f"[LLM_WARNING] Failed to initialize GUI types: {stderr}")
            # Try to continue anyway, types might already be loaded

    def find_window(self, title: str = "Factorio") -> Optional[str]:
        """
        Find a window by title and return its handle.
        
        Args:
            title: Window title to search for
            
        Returns:
            Window handle as string, or None if not found
        """
        script = f"""
$hwnd = [Win32]::FindWindow($null, "{title}")
if ($hwnd -ne [IntPtr]::Zero) {{
    Write-Output $hwnd
}} else {{
    Write-Output "0"
}}
"""
        exit_code, stdout, stderr = self.ps.run_command(script)
        if exit_code == 0 and stdout.strip() != "0":
            return stdout.strip()
        return None

    def suppress_window(self, process_name: str = "Factorio", hide: bool = False) -> bool:
        """
        Hide or minimize window to prevent focus stealing.
        
        Args:
            process_name: Name of the window to suppress
            hide: If True, completely hide; if False, minimize
            
        Returns:
            True if successful, False otherwise
        """
        hwnd = self.find_window(process_name)
        if not hwnd or hwnd == "0":
            print(f"[LLM_WARNING] Could not find {process_name} window")
            return False

        cmd_show = "[Win32]::SW_HIDE" if hide else "[Win32]::SW_MINIMIZE"
        script = f"""
$hwnd = [IntPtr]{hwnd}
$result = [Win32]::ShowWindow($hwnd, {cmd_show})
Write-Output $result
"""
        exit_code, stdout, stderr = self.ps.run_command(script)
        return exit_code == 0 and stdout.strip().lower() == "true"

    def restore_window(self, process_name: str = "Factorio") -> bool:
        """
        Restore a hidden or minimized window.
        
        Args:
            process_name: Name of the window to restore
            
        Returns:
            True if successful, False otherwise
        """
        hwnd = self.find_window(process_name)
        if not hwnd or hwnd == "0":
            return False

        script = f"""
$hwnd = [IntPtr]{hwnd}
[Win32]::ShowWindow($hwnd, [Win32]::SW_RESTORE)
[Win32]::SetForegroundWindow($hwnd)
Write-Output "Restored"
"""
        exit_code, stdout, stderr = self.ps.run_command(script)
        return exit_code == 0

    def _ensure_types_loaded(self):
        """Ensure .NET types are loaded before operations."""
        # Quick check if types are loaded
        check_script = """
try {
    $null = [System.Windows.Forms.SystemInformation]
    $null = [System.Drawing.Bitmap]
    Write-Output "TYPES_OK"
} catch {
    Write-Output "TYPES_MISSING"
}
"""
        _, stdout, _ = self.ps.run_command(check_script)
        if "TYPES_MISSING" in stdout:
            print("[LLM_DEBUG] Types not loaded, reinitializing...")
            self._init_types()

    def take_screenshot(
        self, save_path: str, window_title: Optional[str] = None
    ) -> bool:
        """
        Capture a screenshot of the screen or specific window.
        
        Args:
            save_path: Where to save the screenshot (WSL path)
            window_title: If specified, capture only this window
            
        Returns:
            True if successful, False otherwise
        """
        # Ensure types are loaded
        self._ensure_types_loaded()
        
        # Convert WSL path to Windows path
        if save_path.startswith("/mnt/c/"):
            windows_path = save_path.replace("/mnt/c/", "C:\\\\").replace("/", "\\\\")
        elif save_path.startswith("/mnt/d/"):
            windows_path = save_path.replace("/mnt/d/", "D:\\\\").replace("/", "\\\\")
        else:
            # Assume C: drive as default
            windows_path = "C:\\\\temp\\\\" + save_path.split("/")[-1]
            save_path = "/mnt/c/temp/" + save_path.split("/")[-1]

        # Ensure parent directory exists in Windows
        parent_dir = Path(save_path).parent
        parent_dir.mkdir(parents=True, exist_ok=True)

        if window_title:
            # Window-specific screenshot
            script = f"""
# Try loading assemblies if not already loaded
try {{
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms
}} catch {{
    # Ignore if already loaded
}}

try {{
    $hwnd = [Win32]::FindWindow($null, "{window_title}")
    if ($hwnd -eq [IntPtr]::Zero) {{
        Write-Error "Window not found"
        exit 1
    }}

    $rect = New-Object Win32+RECT
    [Win32]::GetWindowRect($hwnd, [ref]$rect) | Out-Null

    $width = $rect.Right - $rect.Left
    $height = $rect.Bottom - $rect.Top

    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
    $bitmap.Save("{windows_path}")
    $graphics.Dispose()
    $bitmap.Dispose()

    # Verify file was saved and get file info
    if (Test-Path "{windows_path}") {{
        $fileInfo = Get-Item "{windows_path}"
        Write-Output "SAVED:{windows_path}|SIZE:$($fileInfo.Length)"
    }} else {{
        Write-Error "File not saved"
        exit 1
    }}
}} catch {{
    Write-Error "Screenshot failed: $_"
    exit 1
}}
"""
        else:
            # Full screen screenshot - use alternative method if types not loaded
            script = f"""
# Try loading assemblies if not already loaded
try {{
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms
}} catch {{
    # Ignore if already loaded
}}

# Method 1: Try standard screenshot method
$success = $false
try {{
    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bitmap = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($screen.Location, [System.Drawing.Point]::Empty, $screen.Size)
    $bitmap.Save("{windows_path}")
    $graphics.Dispose()
    $bitmap.Dispose()
    $success = $true
}} catch {{
    # Fall back to alternative method
}}

# Method 2: Alternative using WScript if available
if (-not $success) {{
    try {{
        # Create temp script file
        $vbsFile = [System.IO.Path]::GetTempFileName() + ".vbs"
        $vbsContent = @'
Set shell = CreateObject("WScript.Shell")
WScript.Sleep 100
shell.SendKeys "{{PRTSC}}"
'@
        $vbsContent | Out-File -FilePath $vbsFile -Encoding ASCII
        
        # Run the VBS script to take screenshot
        Start-Process -FilePath "wscript.exe" -ArgumentList $vbsFile -Wait
        Remove-Item $vbsFile
        
        # Try to get from clipboard
        Add-Type -AssemblyName System.Windows.Forms
        $image = [System.Windows.Forms.Clipboard]::GetImage()
        if ($null -ne $image) {{
            $image.Save("{windows_path}")
            $success = $true
        }}
    }} catch {{
        # Ignore
    }}
}}

# Verify file was saved
if ($success -and (Test-Path "{windows_path}")) {{
    $fileInfo = Get-Item "{windows_path}"
    Write-Output "SAVED:{windows_path}|SIZE:$($fileInfo.Length)"
}} else {{
    Write-Error "All screenshot methods failed"
    exit 1
}}
"""

        exit_code, stdout, stderr = self.ps.run_script(script, timeout=10)
        if exit_code != 0:
            print(f"[LLM_ERROR] Screenshot failed: {stderr}")
            return False
            
        # Debug output
        print(f"[LLM_DEBUG] Screenshot stdout: {stdout.strip()}")
        
        # Parse output to verify file was saved on Windows side
        if "SAVED:" in stdout and "|SIZE:" in stdout:
            try:
                size_str = stdout.split("|SIZE:")[1].strip()
                file_size = int(size_str)
                print(f"[LLM_DEBUG] Screenshot saved on Windows side with size: {file_size} bytes")
            except:
                print("[LLM_DEBUG] Could not parse file size from output")
        
        # Wait for WSL file system sync with progressive delays
        max_wait_time = 5.0  # Maximum total wait time in seconds
        check_interval = 0.1  # Initial check interval
        total_waited = 0.0
        
        while total_waited < max_wait_time:
            if Path(save_path).exists():
                # File exists, but let's also check it has non-zero size
                try:
                    file_size = Path(save_path).stat().st_size
                    if file_size > 0:
                        print(f"[LLM_DEBUG] File successfully synced to WSL at {save_path} (size: {file_size} bytes)")
                        return True
                    else:
                        print(f"[LLM_DEBUG] File exists but has zero size, waiting...")
                except Exception as e:
                    print(f"[LLM_DEBUG] Error checking file size: {e}")
                    
            time.sleep(check_interval)
            total_waited += check_interval
            # Increase check interval progressively
            check_interval = min(check_interval * 1.5, 0.5)
            
        # If we're here, file didn't sync in time
        # Try forcing a sync by accessing the directory
        print("[LLM_DEBUG] File not found after waiting, attempting to force sync...")
        try:
            # Force WSL to refresh the directory
            list(parent_dir.iterdir())
            time.sleep(0.5)
            
            # Final check
            if Path(save_path).exists():
                file_size = Path(save_path).stat().st_size
                if file_size > 0:
                    print(f"[LLM_DEBUG] File found after forced sync (size: {file_size} bytes)")
                    return True
        except Exception as e:
            print(f"[LLM_DEBUG] Error during forced sync: {e}")
            
        # As a last resort, check if we can access via PowerShell
        verify_script = f'if (Test-Path "{windows_path}") {{ Write-Output "EXISTS" }} else {{ Write-Output "NOT_FOUND" }}'
        _, verify_out, _ = self.ps.run_command(verify_script)
        if "EXISTS" in verify_out:
            print(f"[LLM_WARNING] File exists on Windows side but WSL cannot see it at {save_path}")
            clean_windows_path = windows_path.replace('\\\\\\\\', '\\\\')
            print(f"[LLM_HINT] Try accessing the file directly via Windows path: {clean_windows_path}")
        else:
            print(f"[LLM_ERROR] File not found on either Windows or WSL side")
            
        return False

    def take_screenshot_with_fallback(
        self, save_path: str, window_title: Optional[str] = None
    ) -> Tuple[bool, Optional[str]]:
        """
        Capture a screenshot with fallback to Windows path if WSL sync fails.
        
        Args:
            save_path: Where to save the screenshot (WSL path)
            window_title: If specified, capture only this window
            
        Returns:
            Tuple of (success, actual_path) where actual_path might be a Windows path
        """
        # First try the normal screenshot method
        if self.take_screenshot(save_path, window_title):
            return True, save_path
            
        # If that failed due to WSL sync, return the Windows path
        if save_path.startswith("/mnt/c/"):
            windows_path = save_path.replace("/mnt/c/", "C:\\").replace("/", "\\")
        elif save_path.startswith("/mnt/d/"):
            windows_path = save_path.replace("/mnt/d/", "D:\\").replace("/", "\\")
        else:
            windows_path = "C:\\temp\\" + save_path.split("/")[-1]
            
        # Verify file exists on Windows side
        escaped_windows_path = windows_path.replace("\\", "\\\\")
        verify_script = f'if (Test-Path "{escaped_windows_path}") {{ Write-Output "EXISTS" }} else {{ Write-Output "NOT_FOUND" }}'
        _, verify_out, _ = self.ps.run_command(verify_script)
        
        if "EXISTS" in verify_out:
            print(f"[LLM_INFO] Screenshot available at Windows path: {windows_path}")
            return True, windows_path
        else:
            return False, None

    def take_screenshot_simple(self, save_path: str) -> bool:
        """
        Take a screenshot using Windows Snipping Tool (simpler alternative).
        
        Args:
            save_path: Where to save the screenshot (WSL path)
            
        Returns:
            True if successful, False otherwise
        """
        # Convert WSL path to Windows path
        if save_path.startswith("/mnt/c/"):
            windows_path = save_path.replace("/mnt/c/", "C:\\").replace("/", "\\")
        elif save_path.startswith("/mnt/d/"):
            windows_path = save_path.replace("/mnt/d/", "D:\\").replace("/", "\\")
        else:
            windows_path = "C:\\temp\\" + save_path.split("/")[-1]
            save_path = "/mnt/c/temp/" + save_path.split("/")[-1]
            
        # Ensure parent directory exists
        parent_dir = Path(save_path).parent
        parent_dir.mkdir(parents=True, exist_ok=True)
            
        # Use Windows built-in screenshot capability via rundll32
        script = f"""
# Method 1: Try using Windows screenshot capability
$tempFile = [System.IO.Path]::GetTempFileName() + ".png"
$process = Start-Process -FilePath "snippingtool.exe" -ArgumentList "/clip" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 1
$process | Stop-Process -Force -ErrorAction SilentlyContinue

# Try to save from clipboard if available
try {{
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop
    
    $image = [System.Windows.Forms.Clipboard]::GetImage()
    if ($null -ne $image) {{
        $image.Save("{windows_path}")
        $image.Dispose()
        Write-Output "SAVED:{windows_path}"
        exit 0
    }}
}} catch {{
    # Continue to next method
}}

# Method 2: Use PowerShell screenshot command if available
try {{
    # Create a simple screenshot using Windows API directly
    $code = @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class ScreenCapture {{
    [DllImport("user32.dll")]
    private static extern IntPtr GetDesktopWindow();
    [DllImport("user32.dll")]
    private static extern IntPtr GetWindowDC(IntPtr hWnd);
    [DllImport("user32.dll")]
    private static extern bool ReleaseDC(IntPtr hWnd, IntPtr hDC);
    [DllImport("gdi32.dll")]
    private static extern bool BitBlt(IntPtr hdcDest, int nXDest, int nYDest, int nWidth, int nHeight, IntPtr hdcSrc, int nXSrc, int nYSrc, int dwRop);
    [DllImport("gdi32.dll")]
    private static extern IntPtr CreateCompatibleBitmap(IntPtr hdc, int nWidth, int nHeight);
    [DllImport("gdi32.dll")]
    private static extern IntPtr CreateCompatibleDC(IntPtr hdc);
    [DllImport("gdi32.dll")]
    private static extern IntPtr SelectObject(IntPtr hdc, IntPtr hgdiobj);
    [DllImport("gdi32.dll")]
    private static extern bool DeleteObject(IntPtr hObject);
    [DllImport("gdi32.dll")]
    private static extern bool DeleteDC(IntPtr hdc);
    
    public static void CaptureScreen(string filename) {{
        int screenWidth = System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width;
        int screenHeight = System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height;
        
        IntPtr desktopWindow = GetDesktopWindow();
        IntPtr desktopDC = GetWindowDC(desktopWindow);
        IntPtr memoryDC = CreateCompatibleDC(desktopDC);
        IntPtr bitmap = CreateCompatibleBitmap(desktopDC, screenWidth, screenHeight);
        IntPtr oldBitmap = SelectObject(memoryDC, bitmap);
        
        BitBlt(memoryDC, 0, 0, screenWidth, screenHeight, desktopDC, 0, 0, 0x00CC0020);
        
        Bitmap bmp = Image.FromHbitmap(bitmap);
        bmp.Save(filename, ImageFormat.Png);
        bmp.Dispose();
        
        SelectObject(memoryDC, oldBitmap);
        DeleteObject(bitmap);
        DeleteDC(memoryDC);
        ReleaseDC(desktopWindow, desktopDC);
    }}
}}
'@
    
    Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing, System.Windows.Forms
    [ScreenCapture]::CaptureScreen("{windows_path}")
    
    if (Test-Path "{windows_path}") {{
        $fileInfo = Get-Item "{windows_path}"
        Write-Output "SAVED:{windows_path}|SIZE:$($fileInfo.Length)"
        exit 0
    }}
}} catch {{
    Write-Error "Screenshot failed: $_"
    exit 1
}}
"""
        
        exit_code, stdout, stderr = self.ps.run_script(script, timeout=15)
        if exit_code != 0:
            print(f"[LLM_ERROR] Simple screenshot failed: {stderr}")
            return False
            
        # Check if file exists with sync wait
        max_wait_time = 3.0
        check_interval = 0.1
        total_waited = 0.0
        
        while total_waited < max_wait_time:
            if Path(save_path).exists():
                try:
                    file_size = Path(save_path).stat().st_size
                    if file_size > 0:
                        print(f"[LLM_DEBUG] Screenshot saved at {save_path} (size: {file_size} bytes)")
                        return True
                except:
                    pass
                    
            time.sleep(check_interval)
            total_waited += check_interval
            
        return False

    def move_mouse(self, x: int, y: int) -> bool:
        """
        Move mouse to absolute screen coordinates.
        
        Args:
            x: X coordinate
            y: Y coordinate
            
        Returns:
            True if successful
        """
        script = f"[Win32]::SetCursorPos({x}, {y})"
        exit_code, _, _ = self.ps.run_command(script)
        return exit_code == 0

    def click(
        self, x: Optional[int] = None, y: Optional[int] = None, button: str = "left"
    ) -> bool:
        """
        Click at specified position or current position.
        
        Args:
            x: X coordinate (None for current position)
            y: Y coordinate (None for current position)
            button: "left", "right", or "middle"
            
        Returns:
            True if successful
        """
        # Move mouse if coordinates provided
        if x is not None and y is not None:
            if not self.move_mouse(x, y):
                return False
            time.sleep(0.1)  # Small delay for mouse movement

        # Map button names to flags
        button_map = {
            "left": ("[Win32]::MOUSEEVENTF_LEFTDOWN", "[Win32]::MOUSEEVENTF_LEFTUP"),
            "right": (
                "[Win32]::MOUSEEVENTF_RIGHTDOWN",
                "[Win32]::MOUSEEVENTF_RIGHTUP",
            ),
            "middle": (
                "[Win32]::MOUSEEVENTF_MIDDLEDOWN",
                "[Win32]::MOUSEEVENTF_MIDDLEUP",
            ),
        }

        if button not in button_map:
            print(f"[LLM_ERROR] Unknown button: {button}")
            return False

        down_flag, up_flag = button_map[button]
        script = f"""
[Win32]::mouse_event({down_flag}, 0, 0, 0, 0)
Start-Sleep -Milliseconds 50
[Win32]::mouse_event({up_flag}, 0, 0, 0, 0)
Write-Output "Clicked"
"""
        exit_code, _, _ = self.ps.run_command(script)
        return exit_code == 0

    def send_keys(self, keys: str) -> bool:
        """
        Send keyboard input to the active window.
        
        Args:
            keys: Keys to send (PowerShell SendKeys format)
            
        Returns:
            True if successful
        """
        # Escape special characters for PowerShell
        escaped_keys = keys.replace('"', '""')
        script = f'[System.Windows.Forms.SendKeys]::SendWait("{escaped_keys}")'
        exit_code, _, _ = self.ps.run_command(script)
        return exit_code == 0


class ActionScriptExecutor:
    """
    Execute automated GUI actions from a script.
    """
    
    def __init__(self, gui_controller: WindowsGUIController):
        self.gui = gui_controller
        self.screenshot_count = 0
        self.base_screenshot_path = "/mnt/c/temp/factorio_action_"
        
    def execute_script(self, script: Union[str, Dict, List]) -> bool:
        """
        Execute an action script.
        
        Script can be:
        - Path to JSON file
        - JSON string
        - Python dict/list of actions
        
        Returns:
            True if all actions succeeded
        """
        # Parse script
        if isinstance(script, str):
            if script.endswith('.json'):
                # Load from file
                try:
                    with open(script, 'r') as f:
                        actions = json.load(f)
                except Exception as e:
                    print(f"[LLM_ERROR] Failed to load action script: {e}")
                    return False
            else:
                # Try to parse as JSON string
                try:
                    actions = json.loads(script)
                except:
                    # Assume it's a simple action string
                    actions = [{"type": "click", "target": script}]
        elif isinstance(script, dict):
            actions = [script]
        else:
            actions = script
            
        # Execute actions
        for i, action in enumerate(actions):
            print(f"[LLM_INFO] Executing action {i+1}/{len(actions)}: {action.get('type', 'unknown')}")
            if not self._execute_action(action):
                print(f"[LLM_ERROR] Action {i+1} failed")
                return False
                
        return True
        
    def _execute_action(self, action: Dict) -> bool:
        """
        Execute a single action.
        
        Action types:
        - wait: {"type": "wait", "seconds": 5}
        - screenshot: {"type": "screenshot", "name": "menu"}
        - click: {"type": "click", "x": 960, "y": 400} or {"type": "click", "target": "single_player"}
        - move: {"type": "move", "x": 100, "y": 200}
        - key: {"type": "key", "keys": "{ESC}"}
        - drag: {"type": "drag", "from_x": 100, "from_y": 100, "to_x": 200, "to_y": 200}
        """
        action_type = action.get("type", "").lower()
        
        try:
            if action_type == "wait":
                seconds = action.get("seconds", 1)
                print(f"[LLM_INFO] Waiting {seconds} seconds...")
                time.sleep(seconds)
                return True
                
            elif action_type == "screenshot":
                name = action.get("name", f"action_{self.screenshot_count}")
                path = f"{self.base_screenshot_path}{name}.png"
                self.screenshot_count += 1
                print(f"[LLM_INFO] Taking screenshot: {path}")
                success, actual_path = self.gui.take_screenshot_with_fallback(path, None)  # Full screen screenshot
                if success:
                    print(f"[LLM_INFO] Screenshot saved at: {actual_path}")
                return success
                
            elif action_type == "click":
                # Handle named targets
                if "target" in action:
                    coords = self._resolve_target(action["target"])
                    if coords:
                        x, y = coords
                    else:
                        print(f"[LLM_ERROR] Unknown target: {action['target']}")
                        return False
                else:
                    x = action.get("x")
                    y = action.get("y")
                    
                button = action.get("button", "left")
                print(f"[LLM_INFO] Clicking at ({x}, {y}) with {button} button")
                return self.gui.click(x, y, button)
                
            elif action_type == "move":
                x = action.get("x")
                y = action.get("y")
                print(f"[LLM_INFO] Moving mouse to ({x}, {y})")
                return self.gui.move_mouse(x, y)
                
            elif action_type == "key":
                keys = action.get("keys", "")
                print(f"[LLM_INFO] Sending keys: {keys}")
                return self.gui.send_keys(keys)
                
            elif action_type == "drag":
                # Move to start position
                if not self.gui.move_mouse(action["from_x"], action["from_y"]):
                    return False
                time.sleep(0.1)
                
                # Mouse down
                if not self._mouse_down("left"):
                    return False
                time.sleep(0.1)
                
                # Move to end position
                if not self.gui.move_mouse(action["to_x"], action["to_y"]):
                    self._mouse_up("left")
                    return False
                time.sleep(0.1)
                
                # Mouse up
                return self._mouse_up("left")
                
            else:
                print(f"[LLM_ERROR] Unknown action type: {action_type}")
                return False
                
        except Exception as e:
            print(f"[LLM_ERROR] Action execution failed: {e}")
            return False
            
    def _resolve_target(self, target: str) -> Optional[Tuple[int, int]]:
        """
        Resolve a named target to coordinates.
        
        Supports:
        - menu.item format (e.g., "main_menu.single_player")
        - direct item names (searches all menus)
        """
        target = target.lower().replace(" ", "_")
        
        # Check if it's a menu.item format
        if "." in target:
            menu_name, item_name = target.split(".", 1)
            menu_map = {
                "main_menu": MenuActions.MAIN_MENU,
                "single_player": MenuActions.SINGLE_PLAYER,
                "new_game": MenuActions.NEW_GAME,
            }
            if menu_name in menu_map and item_name in menu_map[menu_name]:
                return menu_map[menu_name][item_name]
        else:
            # Search all menus
            for menu in [MenuActions.MAIN_MENU, MenuActions.SINGLE_PLAYER, MenuActions.NEW_GAME]:
                if target in menu:
                    return menu[target]
                    
        return None
        
    def _mouse_down(self, button: str = "left") -> bool:
        """Send mouse down event."""
        button_map = {
            "left": "[Win32]::MOUSEEVENTF_LEFTDOWN",
            "right": "[Win32]::MOUSEEVENTF_RIGHTDOWN",
            "middle": "[Win32]::MOUSEEVENTF_MIDDLEDOWN",
        }
        if button not in button_map:
            return False
            
        script = f"[Win32]::mouse_event({button_map[button]}, 0, 0, 0, 0)"
        exit_code, _, _ = self.gui.ps.run_command(script)
        return exit_code == 0
        
    def _mouse_up(self, button: str = "left") -> bool:
        """Send mouse up event."""
        button_map = {
            "left": "[Win32]::MOUSEEVENTF_LEFTUP",
            "right": "[Win32]::MOUSEEVENTF_RIGHTUP",
            "middle": "[Win32]::MOUSEEVENTF_MIDDLEUP",
        }
        if button not in button_map:
            return False
            
        script = f"[Win32]::mouse_event({button_map[button]}, 0, 0, 0, 0)"
        exit_code, _, _ = self.gui.ps.run_command(script)
        return exit_code == 0


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
        self.gui_controller: Optional[WindowsGUIController] = None

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

    def launch_gui_test(
        self,
        args: List[str],
        suppress_window: bool = True,
        hide_window: bool = False,
        screenshot_delay: int = 10,
        screenshot_path: Optional[str] = None,
        action_script: Optional[str] = None,
    ) -> Tuple[int, float, Optional[str]]:
        """
        Launch Factorio with GUI testing capabilities.
        
        Args:
            args: Command line arguments for Factorio
            suppress_window: If True, minimize or hide window
            hide_window: If True and suppress_window is True, completely hide (not just minimize)
            screenshot_delay: Seconds to wait before taking screenshot
            screenshot_path: Where to save screenshot (auto-generated if None)
            action_script: Path to JSON action script or JSON string
            
        Returns:
            Tuple of (exit_code, execution_time, screenshot_path)
        """
        # Initialize GUI controller
        self.gui_controller = WindowsGUIController()

        # Launch Factorio in a separate thread
        launch_thread = threading.Thread(
            target=self._launch_thread, args=(args,), daemon=True
        )
        launch_thread.start()

        # Wait for window to appear
        print("[LLM_INFO] Waiting for Factorio window...")
        time.sleep(3)

        # Suppress window if requested
        if suppress_window:
            print(
                f"[LLM_INFO] {'Hiding' if hide_window else 'Minimizing'} Factorio window..."
            )
            self.gui_controller.suppress_window("Factorio", hide=hide_window)

        # Wait for main menu to load
        print(f"[LLM_INFO] Waiting {screenshot_delay}s for main menu...")
        time.sleep(screenshot_delay)
        
        # Execute action script if provided
        if action_script:
            print("[LLM_INFO] Executing action script...")
            executor = ActionScriptExecutor(self.gui_controller)
            script_success = executor.execute_script(action_script)
            if not script_success:
                print("[LLM_WARNING] Some actions in the script failed")

        # Take screenshot
        if screenshot_path is None:
            screenshot_path = f"/mnt/c/temp/factorio_screenshot_{int(time.time())}.png"

        # Ensure directory exists
        screenshot_dir = Path(screenshot_path).parent
        screenshot_dir.mkdir(parents=True, exist_ok=True)

        print(f"[LLM_INFO] Taking screenshot: {screenshot_path}")
        success, actual_path = self.gui_controller.take_screenshot_with_fallback(screenshot_path, None)
        if success:
            print(f"[LLM_INFO] Screenshot captured successfully at: {actual_path}")
            screenshot_path = actual_path
        else:
            print("[LLM_ERROR] Failed to capture screenshot")
            screenshot_path = None

        # Wait for process to complete
        launch_thread.join(timeout=self.timeout)

        if self.process and self.process.poll() is None:
            print("[LLM_INFO] Process still running, terminating...")
            self.terminate()

        elapsed = time.time() - self.start_time if self.start_time else 0
        return self.exit_code or -1, elapsed, screenshot_path

    def _launch_thread(self, args: List[str]):
        """Helper method to launch Factorio in a thread."""
        self.launch(args, capture_output=True, stream_output=True)

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

    # GUI control methods when in GUI test mode
    def take_screenshot(self, save_path: Optional[str] = None) -> Optional[str]:
        """Take a screenshot during GUI test mode."""
        if not self.gui_controller:
            print("[LLM_ERROR] GUI controller not initialized")
            return None

        if save_path is None:
            save_path = f"/mnt/c/temp/factorio_action_{int(time.time())}.png"

        if self.gui_controller.take_screenshot(save_path, "Factorio"):
            return save_path
        return None

    def click(self, x: int, y: int, button: str = "left") -> bool:
        """Click at coordinates during GUI test mode."""
        if not self.gui_controller:
            print("[LLM_ERROR] GUI controller not initialized")
            return False
        return self.gui_controller.click(x, y, button)

    def move_mouse(self, x: int, y: int) -> bool:
        """Move mouse during GUI test mode."""
        if not self.gui_controller:
            print("[LLM_ERROR] GUI controller not initialized")
            return False
        return self.gui_controller.move_mouse(x, y)

    def send_keys(self, keys: str) -> bool:
        """Send keyboard input during GUI test mode."""
        if not self.gui_controller:
            print("[LLM_ERROR] GUI controller not initialized")
            return False
        return self.gui_controller.send_keys(keys)


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
            "path": [
                "?.lua",
                "?/init.lua",
                "scripts/?.lua"
            ],
            "pathStrict": False
        },
        "workspace": {
            "library": [],
            "checkThirdParty": False,
            "ignoreDir": [
                ".vscode",
                ".git"
            ]
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
                "ENT_TYPES_YOU_CAN_BUILD_OVER"
            ],
            "disable": [
                "lowercase-global",
                "deprecated",
                "need-check-nil",
                "redefined-local"  # Added per user request
            ],
            "severity": {
                "unused-local": "Information",
                "undefined-global": "Warning",
                "undefined-field": "Information",
                "redundant-parameter": "Information",
                "cast-local-type": "Warning",
                "assign-type-mismatch": "Information"
            }
        },
        "format": {
            "enable": False
        },
        "telemetry": {
            "enable": False
        },
        "hint": {
            "enable": True,
            "setType": False
        }
    }
    
    # Add Factorio library if found
    if factorio_lib:
        config["workspace"]["library"].append(factorio_lib)
        print(f"[LLM_INFO] Found Factorio type definitions at: {factorio_lib}")
    else:
        print("[LLM_WARNING] Factorio type definitions not found. Some API completions may be missing.")
        print("[LLM_HINT] Install the factoriomod-debug VSCode extension for better type checking.")
    
    # Write the configuration
    with open(luarc_path, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"[LLM_INFO] Updated {luarc_path}")


def run_lua_linter(mod_path: str = ".", lua_ls_path: Optional[str] = None) -> Tuple[int, str, str]:
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
            os.path.expanduser("~/.vscode-server/extensions/sumneko.lua-*/server/bin/lua-language-server"),
            os.path.expanduser("~/.vscode/extensions/sumneko.lua-*/server/bin/lua-language-server"),
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
            return 1, "", "lua-language-server not found. Please install it or specify --lua-ls-path"
    
    # Ensure we're in the mod directory for proper .luarc.json detection
    mod_path = Path(mod_path).resolve()
    
    # Create temporary config file
    config_file = None
    try:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as tmp:
            config_file = tmp.name
            create_or_update_luarc(config_file)
        
        # Run lua-language-server in check mode with temp config
        cmd = [lua_ls_path, "--check", ".", "--configpath", config_file]
        
        # Set VSCODE_FACTORIO_PATH if possible to help with Factorio library detection
        env = os.environ.copy()
        factorio_path = Path(__file__).parent.parent.parent / "bin" / "x64"
        if factorio_path.exists():
            env["FACTORIO_PATH"] = str(factorio_path)
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60, cwd=str(mod_path), env=env)
        
        # Filter out noise from the output
        stdout_lines = result.stdout.split('\n')
        stderr_lines = result.stderr.split('\n')
        
        # Remove progress indicators and empty lines
        filtered_stdout = []
        for line in stdout_lines:
            if line and not line.startswith('>') and not line.strip() == '':
                # Also filter out the initialization message
                if "Initializing" not in line and "Diagnosis complete" not in line:
                    filtered_stdout.append(line)
        
        # Count problems
        problems_line = [l for l in stdout_lines if "problems found" in l]
        if problems_line:
            filtered_stdout.append(problems_line[-1])
            
        return result.returncode, '\n'.join(filtered_stdout), '\n'.join(stderr_lines)
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


def run_stylua(mod_path: str = ".", stylua_path: Optional[str] = None, check_only: bool = True) -> Tuple[int, str, str]:
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
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30, cwd=mod_path)
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Formatting timed out after 30 seconds"
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
            "  %(prog)s --gui-test --suppress-window --timeout 60  # GUI testing mode\n"
            "  %(prog)s --gui-test --action-script '[{\"type\": \"click\", \"target\": \"single_player\"}]' --timeout 60\n"
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

    # GUI testing options
    gui_group = parser.add_argument_group("GUI testing options")
    gui_group.add_argument(
        "--gui-test",
        action="store_true",
        help="Enable GUI testing mode with screenshot and control capabilities",
    )

    gui_group.add_argument(
        "--suppress-window",
        action="store_true",
        help="Minimize or hide window to prevent focus stealing (GUI test mode)",
    )

    gui_group.add_argument(
        "--hide-window",
        action="store_true",
        help="Completely hide window instead of minimizing (requires --suppress-window)",
    )

    gui_group.add_argument(
        "--screenshot-delay",
        type=int,
        default=10,
        help="Seconds to wait before taking screenshot (default: %(default)s)",
    )

    gui_group.add_argument(
        "--screenshot-path",
        help="Path to save screenshot (auto-generated if not specified)",
    )
    
    gui_group.add_argument(
        "--action-script",
        help="JSON action script (file path or inline JSON) for automated GUI interaction",
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
        help="Run FactorioAccess tests using lab_tiles.zip save file",
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
            with open(json_path, 'r') as f:
                results = json.loads(f.read())
                
            # Calculate success rate
            success_rate = 0.0
            if results['total'] > 0:
                success_rate = (results['passed'] / results['total']) * 100
                
            # Format duration
            duration_str = f"{results['duration']:.2f} seconds"
            
            # Format failures
            failures = []
            for error in results.get('errors', []):
                failures.append(f"{error['suite']} - {error['test']}")
                
            return {
                'total': results['total'],
                'passed': results['passed'],
                'failed': results['failed'],
                'success_rate': success_rate,
                'duration': duration_str,
                'failures': failures
            }
        except Exception as e:
            print(f"[LLM_DEBUG] Error reading JSON test results: {e}")
            # Fall back to log parsing
    
    if not os.path.exists(log_path):
        return None
        
    try:
        with open(log_path, 'r') as f:
            content = f.read()
            
        # Look for the test summary (new format)
        summary_match = re.search(
            r'Test Results:\s*\nTotal:\s*(\d+)\s*\nPassed:\s*(\d+)\s*\nFailed:\s*(\d+)\s*\nDuration:\s*(\d+\.\d+)\s*seconds',
            content, re.MULTILINE
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
        for line in content.split('\n'):
            if '✗' in line and 'TestFramework:' in line:
                # Extract test name from failure line
                match = re.search(r'✗ ([^:]+) - ([^:]+):', line)
                if match:
                    failures.append(f"{match.group(1)} - {match.group(2)}")
        
        return {
            'total': total,
            'passed': passed,
            'failed': failed,
            'success_rate': success_rate,
            'duration': duration,
            'failures': failures
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
            args.mod_path, 
            args.stylua_path, 
            check_only=args.format_check
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
        factorio_args.extend(["--benchmark", "lab_tiles.zip", "--benchmark-ticks", "5000"])
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
        # GUI test mode
        if args.gui_test:
            print("[LLM_INFO] Running in GUI test mode")
            exit_code, elapsed_time, screenshot_path = launcher.launch_gui_test(
                factorio_args,
                suppress_window=args.suppress_window,
                hide_window=args.hide_window,
                screenshot_delay=args.screenshot_delay,
                screenshot_path=args.screenshot_path,
                action_script=args.action_script,
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
                    "screenshot_path": screenshot_path,
                    "gui_test": True,
                }

                if args.json_status:
                    print(f"\n[LLM_STATUS]{json.dumps(status)}")
                else:
                    print(f"\n[LLM_INFO] Factorio exited with code: {exit_code}")
                    print(f"[LLM_INFO] Execution time: {elapsed_time:.2f} seconds")
                    if screenshot_path:
                        print(f"[LLM_INFO] Screenshot saved: {screenshot_path}")

            return exit_code

        # Normal launch mode
        else:
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
                    "gui_test": False,
                }

                if args.json_status:
                    print(f"\n[LLM_STATUS]{json.dumps(status)}")
                else:
                    print(f"\n[LLM_INFO] Factorio exited with code: {exit_code}")
                    print(f"[LLM_INFO] Execution time: {elapsed_time:.2f} seconds")
            
            # Check test results if running tests
            if args.run_tests:
                # Test log is in Factorio's script-output directory
                test_log_path = os.path.join(
                    os.path.dirname(launcher.factorio_path),
                    "..", "..", "script-output", "factorio-access-test.log"
                )
                test_log_path = os.path.normpath(test_log_path)
                
                # Parse test results from log
                test_summary = parse_test_results(test_log_path)
                
                if test_summary:
                    print("\n" + "="*60)
                    print("TEST RESULTS")
                    print("="*60)
                    print(f"Total Tests: {test_summary['total']}")
                    print(f"Passed:      {test_summary['passed']} ✓")
                    print(f"Failed:      {test_summary['failed']} ✗")
                    print(f"Success Rate: {test_summary['success_rate']:.1f}%")
                    print(f"Duration:    {test_summary['duration']}")
                    print("="*60)
                    
                    if test_summary['failed'] > 0:
                        print("\nFAILED TESTS:")
                        for failure in test_summary['failures']:
                            print(f"  ✗ {failure}")
                        print(f"\nCheck {test_log_path} for details")
                        return 1
                    else:
                        print("\n✓ All tests passed!")
                        return 0
                else:
                    print("[LLM_WARNING] Test results unclear - check logs")
                    print(f"Log file: {test_log_path}")

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