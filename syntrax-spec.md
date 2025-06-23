# Syntrax Language Specification

## Overview

Syntrax is a domain-specific language for describing Factorio train rail layouts. Programs consist of rail placement commands that can be grouped and repeated.

## Lexical Structure

### Tokens

- **Rail Commands**: `l` (left), `r` (right), `s` (straight)
- **Rail Stack Commands**: `rpush` (save position), `rpop` (restore position), `reset` (return to initial)
- **Keywords**: `rep` (repetition)
- **Numbers**: Decimal integers (e.g., `1`, `42`, `100`)
- **Brackets**: `[` `]` (sequences only; parentheses and braces reserved)
- **Whitespace**: Space, tab, newline (ignored between tokens)

### Comments

No comment syntax is currently defined.

## Grammar

```
program     = statement*
statement   = command | sequence | repetition
command     = "l" | "r" | "s" | "rpush" | "rpop" | "reset"
sequence    = "[" statement* "]"
repetition  = sequence "rep" number
number      = [0-9]+
```

## Semantics

### Rail Commands

Each command places a rail and updates the "hand" direction:
- `l` - Place left-turning rail, rotate hand 1/16 turn counterclockwise
- `r` - Place right-turning rail, rotate hand 1/16 turn clockwise
- `s` - Place straight rail, hand direction unchanged

The hand starts facing north (direction 0).

### Rail Stack Commands

These commands manipulate a stack of saved positions:
- `rpush` - Push current rail index and hand direction onto the stack
- `rpop` - Pop rail index and hand direction from the stack (error if empty)
- `reset` - Clear the stack and return to the initial rail and hand direction

The rail stack is global and not scoped to sequences or loops.

### Sequences

Square brackets group statements: `[l r s]`

- Sequences can be empty: `[]`
- Sequences can be nested: `[[l r] s]`
- Only square brackets are allowed (parentheses and braces are reserved)

### Repetition

The `rep` keyword repeats a sequence a fixed number of times:
```
[l r s] rep 3   -- Expands to: l r s l r s l r s
```

- Repetition count must be a positive integer
- Repetition only applies to sequences (not individual commands)
- Nested repetitions are allowed: `[[l] rep 2] rep 3`

## Execution Model

### Output

Programs produce an ordered list of rail placements:
```
{
  kind: "left" | "right" | "straight",
  parent: index | nil,  -- Index of previous rail
  incoming_direction: 0-15,
  outgoing_direction: 0-15
}
```

### Direction System

Directions use Factorio's 16-direction system:
- 0 = North
- 4 = East  
- 8 = South
- 12 = West

Each unit represents 22.5 degrees (1/16 of a circle).

### Virtual Machine

The implementation compiles to bytecode executed by a stack-based VM:
- **Registers**: Unlimited array for loop counters and future features
- **Instructions**: LEFT, RIGHT, STRAIGHT, RPUSH, RPOP, RESET, MOV, MATH, CMP, JNZ
- **Rail Stack**: Stack of (rail_index, hand_direction) pairs for fork support
- **Initial State**: Can be provided with initial rail and direction
- **Execution**: Sequential with jump instructions for loops

## Examples

### Circle
```
[l l s] rep 8   -- Creates a complete circle
```

### Square
```
[[s s s s] [r r r r]] rep 4   -- Four straight sides with 90° turns
```

### 3-way Fork
```
rpush
l r s reset      -- First branch
s s s reset      -- Middle branch  
r s l            -- Last branch
```

### Station Loop
```
s s rpush [
  rpop rpush           -- Return and save position
  l l [s] rep 10       -- Station siding
  rpop                 -- Return to mainline
  s s s rpush          -- Advance for next station
] rep 5                -- 5 stations
```

### Empty Program
```
-- Valid, produces no rails
```

## Error Conditions

- **Parse Errors**:
  - Unrecognized tokens
  - Mismatched brackets
  - Missing repetition count
  - Invalid repetition count (zero or negative)

- **Execution Errors**:
  - `rpop` on empty rail stack
  - Uninitialized register access (internal VM error)

## Future Extensions

The following syntax is reserved for future use:
- Parentheses `()` - Possible grouping or function calls
- Braces `{}` - Possible code blocks or objects
- Identifiers - Variables and user-defined sequences
- Additional keywords - Control flow, rail references, etc.