# Syntrax Overview - Rail Placement Language for Factorio Access

## What is Syntrax?

Syntrax is a domain-specific language (DSL) that enables blind players to describe train rail layouts using text commands instead of Factorio's visual rail planner. It was developed as part of the Factorio Access mod to make train network planning accessible.

## Current Integration Status

As of the current version, Syntrax has been copied into the FactorioAccess codebase but is not yet actively integrated. The code is imported in `control.lua` to verify it loads without errors, but no rail-building functionality uses it yet.

## Language Basics

### Simple Commands
- `l` - Place a left-turning rail (rotates hand 1/16 turn counterclockwise)
- `r` - Place a right-turning rail (rotates hand 1/16 turn clockwise)  
- `s` - Place a straight rail (hand direction unchanged)

### Grouping and Repetition
- `[l r s]` - Group commands in a sequence
- `[l r] x 4` - Repeat a sequence 4 times

### Rail Stack Commands (for creating junctions)
- `rpush` - Save current position and direction
- `rpop` - Restore saved position and direction
- `reset` - Return to initial position

### Examples

```
# Simple straight track
s s s s

# Circle (8 repetitions of left-left-straight)
[l l s] x 8

# T-junction
s s rpush l s s reset r s s

# Station with sidings
s s rpush [
  rpop rpush           # Return and save position
  l l [s] x 10         # Station siding
  rpop                 # Return to mainline
  s s s rpush          # Advance for next station
] x 5                  # 5 stations
```

## API Usage

```lua
local Syntrax = require("syntrax")

-- Compile and execute Syntrax code
local rails, error = Syntrax.execute("l r s")

if error then
    print("Error: " .. error.message)
else
    -- Process rail placements
    for i, rail in ipairs(rails) do
        print(string.format("Rail %d: %s at direction %d", 
            i, rail.kind, rail.outgoing_direction))
    end
end
```

## Architecture

The Syntrax implementation consists of:

1. **Lexer** (`syntrax/lexer.lua`) - Tokenizes source code
2. **Parser** (`syntrax/parser.lua`) - Builds abstract syntax tree (AST)
3. **Compiler** (`syntrax/compiler.lua`) - Converts AST to bytecode
4. **VM** (`syntrax/vm.lua`) - Executes bytecode to generate rail placements

## Development Tools

### Command Line Interface
```bash
# Test a program
lua syntrax-cli.lua -c "[l r s] x 4"

# Show compilation stages
lua syntrax-cli.lua -c "l r s" -o all

# Run from file
lua syntrax-cli.lua program.syn
```

### Testing
```bash
# Run test suite
lua syntrax-tests.lua
```

## Future Integration Plans

Syntrax will eventually replace the broken rail-building functionality in FactorioAccess, allowing players to:

1. Enter Syntrax commands through the mod's UI
2. Preview rail layouts before placement
3. Execute placement with audio feedback
4. Save and load rail patterns

## File Structure

```
syntrax/
├── ast.lua              # Abstract syntax tree definitions
├── compilation_result.lua # Compilation pipeline results
├── compiler.lua         # AST to bytecode compiler
├── directions.lua       # Factorio direction constants
├── errors.lua          # Error types and builders
├── lexer.lua           # Tokenizer
├── parser.lua          # Parser (tokens to AST)
├── span.lua            # Source location tracking
├── vm.lua              # Virtual machine
└── tests/              # Unit tests

syntrax.lua             # Main public API
syntrax-cli.lua         # Command-line interface
syntrax-tests.lua       # Test runner
luaunit.lua            # Unit testing framework
```

## Additional Documentation

- See `syntrax-spec.md` for the complete language specification
- See `syntrax-architecture.md` for detailed implementation notes