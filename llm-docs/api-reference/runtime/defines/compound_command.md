# compound_command

How commands are joined together in a compound command (see [defines.command.compound](runtime:defines.command.compound)).

## Values

### logical_and

Fail on first failure. Only succeeds if all commands (executed one after another) succeed.

### logical_or

Succeed on first success. Only fails if all commands (executed one after another) fail.

### return_last

Execute all commands in sequence and fail or succeed depending on the return status of the last command.

