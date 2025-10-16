# Syntrax Architecture Overview

## Project Purpose
Syntrax is a domain-specific language for specifying Factorio train layouts as part of the Factorio Access mod, which makes Factorio accessible to blind players. The language addresses the inaccessibility of Factorio's rail planner by providing a text-based way to specify rail layouts.

## Language Basics
- Basic commands: `l` (left curve), `r` (right curve), `s` (straight)
- Rail stack commands: `rpush` (save position), `rpop` (restore position), `reset` (return to initial)
- Sequences: `[commands]` - groups commands, can be empty
- Repetition: `[pattern] rep n` - repeats pattern n times
- Empty programs are valid (useful as a no-op or placeholder)
- Example: `[l l s] rep 8` creates a complete circle with 8 repetitions of left-left-straight
- Fork example: `rpush l r s reset s s s reset r s l` creates a 3-way split
- Note: Only square brackets `[]` are allowed for sequences (parentheses and curly braces reserved for future use)

## Technical Constraints
- Must use Lua 5.2 (Factorio's Lua version)
- Targeting Factorio 2.0 (different rail shapes from 1.1)
- Coordinates provided by Factorio engine at runtime via LuaRailEnd API

## Architecture Overview

### Compilation Pipeline
lexer → AST → VM bytecode → execution

The pipeline follows a traditional compiler architecture:

### Core Modules

#### 1. Lexer (`syntrax/lexer.lua`)
- **Purpose**: Tokenizes Syntrax source code into a token tree
- **Key Design Decisions**:
  - Uses a "token tree" approach inspired by Rust - tokens can be simple or bracketed groups
  - Non-standard implementation due to Lua string processing performance (O(N²) for many operations)
  - Two-phase approach: first splits at possible token boundaries, then builds typed tokens
- **Token Types**:
  - `L`, `R`, `S` - directional commands
  - `REP` - repetition keyword
  - `RPUSH`, `RPOP`, `RESET` - rail stack commands
  - `IDENTIFIER` - generic identifiers
  - `NUMBER` - numeric literals
  - `TREE` - bracketed token groups
- **Bracket Matching**: Handles `()`, `[]`, `{}` with proper nesting and error reporting

#### 2. Span (`syntrax/span.lua`)
- **Purpose**: Tracks source text locations for error reporting
- **Features**:
  - Immutable objects representing text ranges (start/stop character indices)
  - Lazy line/column resolution for human-readable error messages
  - Merge operation to combine spans as larger constructs are built

#### 3. Errors (`syntrax/errors.lua`)
- **Purpose**: Structured error reporting
- **Components**:
  - Error codes enum for programmatic handling
  - Error builder pattern for constructing errors with notes
  - Support for multiple notes with optional source locations
- **Current Error Codes**:
  - `INVALID_TOKEN` - unrecognized token
  - `BRACKET_NOT_CLOSED` - unclosed bracket at EOF
  - `BRACKET_MISMATCH` - mismatched bracket types (e.g., `(]`)
  - `RUNTIME_ERROR` - runtime errors (e.g., rpop on empty stack)

#### 4. Compilation Result (`syntrax/compilation_result.lua`)
- **Purpose**: Manages compilation pipeline state
- **Features**:
  - Holds either a successful result or an error
  - Simple container for compilation outcomes

#### 5. AST (`syntrax/ast.lua`)
- **Purpose**: Abstract syntax tree representation
- **Node Types**:
  - `LEFT`, `RIGHT`, `STRAIGHT` - basic rail placement commands
  - `RPUSH`, `RPOP`, `RESET` - rail stack manipulation commands
  - `SEQUENCE` - ordered list of statements
  - `REPETITION` - repeat a body N times (includes count field)
- **Design**: Uses factory functions to create nodes with proper type fields

#### 6. Parser (`syntrax/parser.lua`)
- **Purpose**: Converts token trees to AST
- **Implementation**: Recursive descent parser leveraging pre-parsed bracket structure
- **Key Features**:
  - Only square brackets `[]` allowed for sequences (others reserved)
  - Empty sequences and empty programs are valid
  - Proper span tracking and merging throughout
- **Error Codes Added**:
  - `UNEXPECTED_TOKEN` - token not valid in current context
  - `EXPECTED_NUMBER` - repetition count must be numeric

#### 7. Directions (`syntrax/directions.lua`)
- **Purpose**: Direction constants and utilities matching Factorio's direction system
- **Constants**: 16 directions from NORTH (0) to NORTH_NORTHWEST (15)
- **Utilities**:
  - `to_name` - Convert numeric direction to short name (e.g., 0 → "N")
  - `rotate` - Rotate direction by given amount (positive = clockwise)
  - `opposite` - Get the opposite direction (e.g., NORTH → SOUTH)

#### 8. VM (`syntrax/vm.lua`)
- **Purpose**: Virtual machine that executes bytecode to produce rail graphs
- **Architecture**:
  - General-purpose registers holding values
  - Bytecode array with program counter
  - Output graph of rails with parent references
  - Hand direction state using direction constants from directions module
  - Rail stack for saving/restoring position and direction
  - Initial rail and direction support for fork operations
- **Bytecode Instructions**:
  - `LEFT`, `RIGHT`, `STRAIGHT` - place rails and update hand direction
  - `RPUSH` - push current rail index and hand direction to stack
  - `RPOP` - pop rail index and hand direction from stack (error if empty)
  - `RESET` - clear stack and return to initial rail/direction
  - `MOV` - move values into registers
  - `MATH` - arithmetic operations (+, -, *, /)
  - `CMP` - comparisons (<, <=, ==, >=, >, !=) storing 0/1 result
  - `JNZ` - jump if not zero (relative offsets)
- **Output Format**: Array of rails with parent index, kind, and direction tracking
- **Runtime Errors**: Bytecode includes span information for error reporting

#### 9. Compiler (`syntrax/compiler.lua`)
- **Purpose**: Transforms AST into VM bytecode
- **Key Features**:
  - Register allocation for loop counters
  - Generates efficient bytecode for repetitions using JNZ loops
  - Handles nested repetitions with separate registers
  - Pretty-prints bytecode listings with labels for debugging
- **Compilation Strategy**:
  - Simple nodes (LEFT, RIGHT, STRAIGHT) → direct bytecode emission
  - Sequences → recursive compilation of statements
  - Repetitions → MOV/loop/MATH/JNZ pattern with allocated registers

### Testing Infrastructure
- **Framework**: LuaUnit (local copy included)
- **Helper Libraries**: Serpent for debugging output (use with `nocode = true`)
- **Test Organization**: Module-specific test files in `syntrax/tests/`
- **Run Tests**: `lua tests.lua`

## Development Patterns

### Error Handling
- Errors are first-class objects with structured information
- Functions return `result, error` pairs (nil result on error)
- Error builder pattern for rich error messages with contextual notes

### Token Tree Approach
The lexer produces a hierarchical structure where bracketed expressions are pre-parsed into trees. This simplifies later parsing stages by handling bracket matching early and providing a natural recursive structure.

### Performance Considerations
- Custom lexer implementation to avoid Lua string performance pitfalls
- Pattern matching used carefully to avoid O(N²) behavior
- Span resolution is lazy to avoid unnecessary line counting

## Language Compilation

### Minimal Subset
The "minimal subset" currently consists of just l/r/s commands. For example:
```
-- Full syntax
[l s r] rep 3
-- Minimal subset (after expansion)
l s r l s r l s r
```

This will be extended as features like variables and forks are added.

### VM Design
The VM will include:
- Registers (effectively infinite array)
- List of rail placement commands
- Bytecodes for primitive commands (l/r/s)
- Bytecodes for constants and control flow (decrement-and-jump)

The language exposes only bounded repetition constructs, ensuring programs always terminate in a fixed number of steps despite the VM being Turing-complete.

## Factorio Integration
- Will use mock interface with 16 directions enum
- Abstract rail types to be replaced with concrete values at runtime
- Multiple rail types exist based on runtime circumstance

## Development Tools

### CLI Interface
- `syntrax-cli.lua` - Main command line interface with full feature support
  - Run files or inline code with `-c`
  - Output formats: rails (default), bytecode, ast, or all
  - Quiet mode with `-q` for scripting
  - Proper error handling and help

### Debugging Scripts
- `print-ast.lua` - Pretty-prints AST in YAML-like format
- `print-vm.lua` - Demonstrates VM execution with sample bytecode
- `compile-and-run.lua` - Simple pipeline demo (use syntrax-cli.lua instead)
- `check-lua.sh` - Runs lua-language-server for type checking

## Next Steps
1. **Extended Features**: Variables, flips, stacks, railrefs as described in the proposal
2. **Optimization**: Potential bytecode optimizations (constant folding, register reuse)
3. **Error Handling**: Add source location tracking through compilation for better runtime errors

## Development Notes
- Test-driven development using LuaUnit
- Proper Lua class style with metatables
- Type annotations for lua-language-server
- Separate from Factorio runtime for easier testing

## Key Implementation Details

### Operand System
The VM uses a typed operand system with four kinds:
- `VALUE` - Numeric literals with type field
- `REGISTER` - Register references  
- `MATH_OP` - Arithmetic operations (+, -, *, /)
- `CMP_OP` - Comparison operations (<, <=, ==, >=, >, !=)

This prevents type confusion and ensures operations are properly distinguished from values.

### Register Allocation
The compiler uses a simple incrementing allocator for registers. Each repetition gets its own counter register, allowing proper nesting. Future features (variables, expressions) will extend this system.

### Error Philosophy
- Parse errors include source location via spans
- Runtime errors include source location via bytecode spans
- Runtime errors: uninitialized registers, rpop on empty stack
- All valid programs terminate due to bounded repetition
- Bytecode carries span information for precise error reporting