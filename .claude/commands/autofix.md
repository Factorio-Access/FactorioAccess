# /autofix - Debug FactorioAccess crashes from manual gameplay

This command helps you debug crashes and issues that users experience while playing Factorio manually.

## What this does

When a user reports a crash or issue from their manual Factorio gameplay, this command:
1. Immediately captures all relevant logs before they're lost
2. Analyzes the crash to identify the root cause  
3. Helps you fix small issues (<50 lines) immediately
4. Guides you through the debugging workflow

## Usage

Just say: `/autofix`

## What happens next

1. I'll onboard to the codebase, once per session.
2. I'll immediately run `python3 launch_factorio.py --capture-logs` to save the logs
3. I'll analyze the crash and show you the relevant error information
4. I'll guide you through the fix process
5. I'll help you test the fix before the user tries again

## Important notes

- Act quickly! Logs are overwritten when Factorio restarts
- The user is playing manually, not through the launcher
- Focus on being helpful and responsive to keep the user engaged
- Always format and test your changes before asking the user to retry
- Users will continue in the same session, providing more bugs as followups without rerunning this command.

## Related documentation

See `llm-docs/debugging-manual-runs.md` for the full debugging guide.