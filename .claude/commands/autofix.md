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
2. I'll check important file paths using `python3 launch_factorio.py --show-paths`
3. I'll immediately run `python3 launch_factorio.py --capture-logs` to save the logs
4. **CRITICAL REQUIREMENT**: 
   - If the launcher returns empty/null logs, I MUST STOP IMMEDIATELY
   - I will NOT proceed without logs - it's a waste of everyone's time
   - I will ask for help to locate the logs instead of guessing or continuing blindly
   - The launcher should fail hard if logs can't be found
5. I'll analyze the captured logs for any crash or error information
6. If a bug is found:
   - I'll show you the relevant error information
   - I'll guide you through the fix process
   - **CRITICAL**: I'll use MessageBuilder for ALL string concatenation with LocalisedStrings
   - I'll format the code and commit the changes
   - I'll help you test the fix before the user tries again
7. If no bug is found but logs were captured:
   - I'll report that no crash was detected in the logs
   - I'll ask you to describe what issue you encountered
   - I'll then proceed to help debug based on your description

## Important notes

- Act quickly! Logs are overwritten when Factorio restarts
- The user is playing manually, not through the launcher
- Focus on being helpful and responsive to keep the user engaged
- Always format your changes before asking the user to retry
- ALWAYS commit your changes after fixing bugs or adding features
- Unit tests cannot be run while the user has Factorio open - rely on formatting and linting only
- **NEVER run tests during debugging** - they overwrite the printout log!
- If you can't find the issue after examining logs, ask the user for help instead of flailing
- The launcher now captures factorio-access-printout.log which contains all speech output
- Users will continue in the same session, providing more bugs as followups without rerunning this command.

## CRITICAL: Localization and String Handling

**ALWAYS USE MessageBuilder FOR LOCALIZATION!** Never concatenate LocalisedStrings with regular strings using `..`

### Common Localization Errors to Avoid:

1. **WRONG**: String concatenation with LocalisedStrings
   ```lua
   -- This will crash!
   local result = "Power: " .. get_power_string(power) .. " capacity"
   ```

2. **WRONG**: Mixed table concatenation
   ```lua
   -- This will also crash!
   local result = {"", "Power: ", get_power_string(power), " capacity"}
   ```

3. **CORRECT**: Use MessageBuilder
   ```lua
   local message = MessageBuilder.new()
   message:fragment("Power: ")
   message:fragment(get_power_string(power))
   message:fragment(" capacity")
   printout(message:build(), pindex)
   ```

### MessageBuilder Pattern:
- Always `require("scripts.message-builder")` at the top of files
- Create new instance with `MessageBuilder.new()`
- Add fragments with `message:fragment(text_or_localised_string)`
- Build final message with `message:build()`
- MessageBuilder properly handles mixing LocalisedStrings and regular strings

### Direction Localization:
- Use `{"fa.direction", direction_number}` not `"fa.direction-" .. direction_name`
- Direction numbers: 0=North, 4=East, 8=South, 12=West, etc.

## Related documentation

See `llm-docs/debugging-manual-runs.md` for the full debugging guide.