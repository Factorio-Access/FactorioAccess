# Factorio JSON to Markdown Converter

This script converts Factorio's JSON API documentation into organized, human-readable markdown files.

## Usage

### Convert Runtime API Documentation

```bash
python json_to_markdown.py --type runtime \
    --input path/to/runtime-api.json \
    --output path/to/output/directory
```

### Convert Prototype API Documentation

```bash
python json_to_markdown.py --type prototype \
    --input path/to/prototype-api.json \
    --output path/to/output/directory
```

## Example

From the FactorioAccess mod directory:

```bash
# Convert runtime docs
python scripts/json_to_markdown.py \
    --type runtime \
    --input "D:\projects\in_progress\factorio_access\factorio\doc-html\runtime-api.json" \
    --output docs/

# Convert prototype docs
python scripts/json_to_markdown.py \
    --type prototype \
    --input "D:\projects\in_progress\factorio_access\factorio\doc-html\prototype-api.json" \
    --output docs/
```

## Output Structure

### Runtime API

```
output/
├── runtime/
│   ├── classes/
│   │   ├── LuaEntity.md
│   │   ├── LuaPlayer.md
│   │   └── ...
│   ├── concepts/
│   │   ├── Position.md
│   │   └── ...
│   ├── events/
│   │   ├── on_tick.md
│   │   └── ...
│   ├── defines/
│   │   ├── index.md
│   │   ├── alert_type.md
│   │   └── ...
│   ├── builtin_types/
│   │   └── ...
│   └── metadata.md
```

### Prototype API

```
output/
├── prototypes/
│   ├── prototype/
│   │   ├── TransportBeltPrototype.md
│   │   ├── ItemPrototype.md
│   │   └── ...
│   ├── concepts/
│   │   └── ...
│   └── metadata.md
```

## Features

- **Complete conversion**: Captures ALL information from the JSON docs
- **Organized structure**: Files organized by type (classes, prototypes, concepts, etc.)
- **Human-readable**: Clean markdown formatting with proper headings and tables
- **Cross-references**: Links to related classes/prototypes preserved
- **Type formatting**: Complex types (unions, arrays, tuples) formatted clearly
- **Metadata preservation**: All optional/required flags, defaults, examples, etc. included

## Statistics

For Factorio 2.0.66:
- **Runtime API**: ~835 files (147 classes, 411 concepts, 217 events, 60 defines)
- **Prototype API**: ~965 files (278 prototypes, 687 types/concepts)
- **Total**: ~1800 markdown files

## Requirements

- Python 3.6+
- No external dependencies (uses only standard library)
