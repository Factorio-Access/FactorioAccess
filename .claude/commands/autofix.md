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
3. I'll analyze the captured logs for any crash or error information
4. If a bug is found:
   - I'll show you the relevant error information
   - I'll guide you through the fix process
   - I'll help you test the fix before the user tries again
5. If no bug is found:
   - I'll report that no crash was detected in the logs
   - I'll ask you to describe what issue you encountered
   - I'll then proceed to help debug based on your description

## Important notes

- Act quickly! Logs are overwritten when Factorio restarts
- The user is playing manually, not through the launcher
- Focus on being helpful and responsive to keep the user engaged
- Always format your changes before asking the user to retry
- Unit tests cannot be run while the user has Factorio open - rely on formatting and linting only
- Users will continue in the same session, providing more bugs as followups without rerunning this command.

## Related documentation

See `llm-docs/debugging-manual-runs.md` for the full debugging guide.