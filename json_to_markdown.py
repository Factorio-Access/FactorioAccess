#!/usr/bin/env python3
"""
Convert Factorio JSON API documentation to organized markdown files.

Usage:
    python json_to_markdown.py --type runtime --input path/to/runtime-api.json --output docs/
    python json_to_markdown.py --type prototype --input path/to/prototype-api.json --output docs/
"""

import json
import argparse
import os
from pathlib import Path
from typing import Any, Dict, List, Optional, Union


def format_type(type_info: Any, inline: bool = True) -> str:
    """Convert type information to readable markdown string.

    Args:
        type_info: The type information from JSON
        inline: If True, format for inline display. If False, return a marker for detailed expansion.
    """
    if isinstance(type_info, str):
        return f"`{type_info}`"

    if isinstance(type_info, dict):
        complex_type = type_info.get("complex_type")

        if complex_type == "array":
            value_type = format_type(type_info.get("value", "unknown"))
            return f"Array[{value_type}]"
        elif complex_type == "union":
            options = type_info.get("options", [])
            formatted_options = [format_type(opt) for opt in options]
            return " | ".join(formatted_options)
        elif complex_type == "literal":
            value = type_info.get("value", "")
            return f'`"{value}"`' if isinstance(value, str) else f"`{value}`"
        elif complex_type == "tuple":
            values = type_info.get("values", [])
            formatted_values = [format_type(val) for val in values]
            return f"({', '.join(formatted_values)})"
        elif complex_type == "function":
            params = type_info.get("parameters", [])
            param_str = ", ".join([format_type(p) for p in params])
            return f"function({param_str})"
        elif complex_type == "dictionary":
            key = format_type(type_info.get("key", "string"))
            value = format_type(type_info.get("value", "any"))
            return f"Dictionary[{key}, {value}]"
        elif complex_type == "table":
            # Table types need detailed expansion
            if inline:
                return "Table (see below for parameters)"
            return "table"
        elif complex_type == "LuaStruct":
            # LuaStruct types need detailed expansion
            struct_name = type_info.get("name", "LuaStruct")
            if inline:
                return f"`{struct_name}` (see below for attributes)"
            return struct_name
        elif complex_type == "struct":
            # Struct types (prototype docs) need detailed expansion
            struct_name = type_info.get("name", "Struct")
            if inline:
                return f"`{struct_name}` (see below for attributes)"
            return struct_name
        elif complex_type == "builtin":
            builtin_type = type_info.get("description", "builtin")
            return f"`{builtin_type}`"
        elif complex_type == "LuaCustomTable":
            key = format_type(type_info.get("key", "unknown"))
            value = format_type(type_info.get("value", "unknown"))
            return f"LuaCustomTable[{key}, {value}]"
        elif complex_type == "LuaLazyLoadedValue":
            value = format_type(type_info.get("value", "unknown"))
            return f"LuaLazyLoadedValue[{value}]"
        elif complex_type == "type":
            # Type reference
            type_value = type_info.get("value", "unknown")
            return f"`{type_value}`"

    # Unknown type - make it obvious
    return f"**[UNHANDLED TYPE: {type_info}]**"


def format_default_value(default: Any) -> str:
    """Format default value for display."""
    if isinstance(default, dict):
        if default.get("complex_type") == "literal":
            value = default.get("value", "")
            if isinstance(value, str):
                return f'"{value}"'
            return str(value)
    if isinstance(default, str):
        return f'"{default}"'
    return str(default)


def escape_markdown(text: str) -> str:
    """Escape special markdown characters in regular text."""
    if not text:
        return ""
    # Only escape in non-code contexts
    return text


def format_description(desc: str, indent: int = 0) -> str:
    """Format description with proper indentation."""
    if not desc:
        return ""

    indent_str = "  " * indent
    lines = desc.split('\n')
    return '\n'.join(indent_str + line if line.strip() else "" for line in lines)


def write_runtime_class(class_info: Dict[str, Any], output_dir: Path):
    """Write a single runtime class to a markdown file."""
    class_name = class_info["name"]
    output_file = output_dir / "runtime" / "classes" / f"{class_name}.md"
    output_file.parent.mkdir(parents=True, exist_ok=True)

    with open(output_file, "w", encoding="utf-8") as f:
        # Header
        f.write(f"# {class_name}\n\n")

        # Description
        if class_info.get("description"):
            f.write(f"{class_info['description']}\n\n")

        # Metadata
        if class_info.get("parent"):
            f.write(f"**Parent:** [{class_info['parent']}]({class_info['parent']}.md)\n\n")

        if class_info.get("abstract"):
            f.write(f"**Abstract:** Yes\n\n")

        # Attributes
        attributes = class_info.get("attributes", [])
        if attributes:
            f.write("## Attributes\n\n")
            for attr in sorted(attributes, key=lambda x: x.get("order", 0)):
                attr_name = attr["name"]
                f.write(f"### {attr_name}\n\n")

                if attr.get("description"):
                    f.write(f"{attr['description']}\n\n")

                # Type information
                read_type = attr.get("read_type")
                write_type = attr.get("write_type")

                if read_type:
                    f.write(f"**Read type:** {format_type(read_type)}\n\n")

                if write_type:
                    f.write(f"**Write type:** {format_type(write_type)}\n\n")

                if attr.get("optional"):
                    f.write(f"**Optional:** Yes\n\n")

                if attr.get("subclasses"):
                    f.write(f"**Subclasses:** {', '.join(attr['subclasses'])}\n\n")

        # Methods
        methods = class_info.get("methods", [])
        if methods:
            f.write("## Methods\n\n")
            for method in sorted(methods, key=lambda x: x.get("order", 0)):
                method_name = method["name"]
                f.write(f"### {method_name}\n\n")

                if method.get("description"):
                    f.write(f"{method['description']}\n\n")

                # Parameters
                params = method.get("parameters", [])
                if params:
                    f.write("**Parameters:**\n\n")
                    for param in params:
                        param_name = param["name"]
                        param_type = format_type(param.get("type", "unknown"))
                        param_desc = param.get("description", "")
                        optional = " *(optional)*" if param.get("optional") else ""
                        f.write(f"- `{param_name}` {param_type}{optional}")
                        if param_desc:
                            f.write(f" - {param_desc}")
                        f.write("\n")
                    f.write("\n")

                # Return values
                return_vals = method.get("return_values", [])
                if return_vals:
                    f.write("**Returns:**\n\n")
                    for ret_val in return_vals:
                        ret_type = format_type(ret_val.get("type", "unknown"))
                        ret_desc = ret_val.get("description", "")
                        optional = " *(optional)*" if ret_val.get("optional") else ""
                        f.write(f"- {ret_type}{optional}")
                        if ret_desc:
                            f.write(f" - {ret_desc}")
                        f.write("\n")
                    f.write("\n")

                # Examples
                examples = method.get("examples", [])
                if examples:
                    f.write("**Examples:**\n\n")
                    for example in examples:
                        f.write(f"{example}\n\n")

                # Notes
                notes = method.get("notes", [])
                if notes:
                    f.write("**Notes:**\n\n")
                    for note in notes:
                        f.write(f"- {note}\n")
                    f.write("\n")

        # Operators
        operators = class_info.get("operators", [])
        if operators:
            f.write("## Operators\n\n")
            for op in operators:
                op_name = op.get("name", "operator")
                f.write(f"### {op_name}\n\n")

                if op.get("description"):
                    f.write(f"{op['description']}\n\n")


def write_prototype(proto_info: Dict[str, Any], output_dir: Path):
    """Write a single prototype to a markdown file."""
    proto_name = proto_info["name"]
    output_file = output_dir / "prototypes" / "prototype" / f"{proto_name}.md"
    output_file.parent.mkdir(parents=True, exist_ok=True)

    with open(output_file, "w", encoding="utf-8") as f:
        # Header
        f.write(f"# {proto_name}\n\n")

        # Description
        if proto_info.get("description"):
            f.write(f"{proto_info['description']}\n\n")

        # Metadata
        metadata_items = []

        if proto_info.get("parent"):
            metadata_items.append(f"**Parent:** [{proto_info['parent']}]({proto_info['parent']}.md)")

        if proto_info.get("abstract"):
            metadata_items.append(f"**Abstract:** Yes")

        if proto_info.get("typename"):
            metadata_items.append(f"**Type name:** `{proto_info['typename']}`")

        if proto_info.get("deprecated"):
            metadata_items.append(f"**Deprecated:** Yes")

        if proto_info.get("instance_limit"):
            metadata_items.append(f"**Instance limit:** {proto_info['instance_limit']}")

        if proto_info.get("visibility"):
            visibility = ", ".join(proto_info["visibility"])
            metadata_items.append(f"**Visibility:** {visibility}")

        if metadata_items:
            f.write("\n".join(metadata_items))
            f.write("\n\n")

        # Examples
        examples = proto_info.get("examples", [])
        if examples:
            f.write("## Examples\n\n")
            for example in examples:
                f.write(f"{example}\n\n")

        # Properties
        properties = proto_info.get("properties", [])
        if properties:
            f.write("## Properties\n\n")
            for prop in sorted(properties, key=lambda x: x.get("order", 0)):
                prop_name = prop["name"]
                f.write(f"### {prop_name}\n\n")

                if prop.get("description"):
                    f.write(f"{prop['description']}\n\n")

                # Type information
                prop_type = prop.get("type")
                if prop_type:
                    f.write(f"**Type:** {format_type(prop_type)}\n\n")

                # Optional/Required
                if prop.get("optional"):
                    f.write(f"**Optional:** Yes\n\n")

                    # Default value
                    if "default" in prop:
                        default = format_default_value(prop["default"])
                        f.write(f"**Default:** {default}\n\n")
                else:
                    f.write(f"**Required:** Yes\n\n")

                # Override flag
                if prop.get("override"):
                    f.write(f"**Overrides parent:** Yes\n\n")

                # Examples for this property
                if prop.get("examples"):
                    f.write("**Examples:**\n\n")
                    for example in prop["examples"]:
                        f.write(f"{example}\n\n")


def write_table_parameters(f, parameters: List[Dict[str, Any]], header_level: int = 2):
    """Write table parameters as structured markdown."""
    if not parameters:
        return

    header = "#" * header_level
    f.write(f"{header} Parameters\n\n")

    for param in parameters:
        param_name = param["name"]
        f.write(f"{header}# {param_name}\n\n")

        if param.get("description"):
            f.write(f"{param['description']}\n\n")

        # Type information
        param_type = param.get("type")
        if param_type:
            f.write(f"**Type:** {format_type(param_type)}\n\n")

        # Optional/Required
        if param.get("optional"):
            f.write(f"**Optional:** Yes\n\n")
        else:
            f.write(f"**Required:** Yes\n\n")

        # Default value
        if "default" in param:
            default = format_default_value(param["default"])
            f.write(f"**Default:** {default}\n\n")


def write_struct_attributes(f, attributes: List[Dict[str, Any]], header_level: int = 2):
    """Write LuaStruct attributes as structured markdown."""
    if not attributes:
        return

    header = "#" * header_level
    f.write(f"{header} Attributes\n\n")

    for attr in attributes:
        attr_name = attr["name"]
        f.write(f"{header}# {attr_name}\n\n")

        if attr.get("description"):
            f.write(f"{attr['description']}\n\n")

        # Type information
        read_type = attr.get("read_type")
        write_type = attr.get("write_type")

        if read_type:
            f.write(f"**Read type:** {format_type(read_type)}\n\n")

        if write_type:
            f.write(f"**Write type:** {format_type(write_type)}\n\n")

        if attr.get("optional"):
            f.write(f"**Optional:** Yes\n\n")


def write_concepts(concepts: List[Dict[str, Any]], output_dir: Path, doc_type: str):
    """Write concept definitions to markdown files."""
    if not concepts:
        return

    concepts_dir = output_dir / doc_type / "concepts"
    concepts_dir.mkdir(parents=True, exist_ok=True)

    for concept in concepts:
        concept_name = concept["name"]
        output_file = concepts_dir / f"{concept_name}.md"

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"# {concept_name}\n\n")

            if concept.get("description"):
                f.write(f"{concept['description']}\n\n")

            # Type information
            concept_type = concept.get("type")
            has_struct_in_type = False  # Track if we need to expand struct properties

            if concept_type:
                # Check if it's a complex type that needs expansion
                if isinstance(concept_type, dict):
                    complex_type = concept_type.get("complex_type")

                    if complex_type == "table":
                        f.write(f"**Type:** Table\n\n")
                        # Expand table parameters
                        parameters = concept_type.get("parameters", [])
                        if parameters:
                            write_table_parameters(f, parameters)
                    elif complex_type == "LuaStruct" or complex_type == "struct":
                        struct_name = concept_type.get("name", "Struct")
                        f.write(f"**Type:** `{struct_name}`\n\n")
                        # Expand struct attributes (LuaStruct uses "attributes" in type, struct uses "properties" at concept level)
                        attributes = concept_type.get("attributes", [])

                        if attributes:
                            write_struct_attributes(f, attributes)
                        else:
                            has_struct_in_type = True
                    elif complex_type == "union":
                        # Format the union type
                        f.write(f"**Type:** {format_type(concept_type)}\n\n")
                        # Check if union contains a struct - if so, we'll need to expand properties below
                        options = concept_type.get("options", [])
                        for option in options:
                            if isinstance(option, dict) and option.get("complex_type") in ["struct", "LuaStruct"]:
                                has_struct_in_type = True
                                break
                    else:
                        # For other types, just format normally
                        f.write(f"**Type:** {format_type(concept_type)}\n\n")
                else:
                    # Simple type
                    f.write(f"**Type:** {format_type(concept_type)}\n\n")

            # If there's a struct in the type definition and properties at concept level, expand them
            if has_struct_in_type:
                properties = concept.get("properties", [])
                if properties:
                    f.write(f"## Properties\n\n")
                    f.write(f"*These properties apply when the value is a struct/table.*\n\n")
                    for prop in sorted(properties, key=lambda x: x.get("order", 0)):
                        prop_name = prop["name"]
                        f.write(f"### {prop_name}\n\n")

                        if prop.get("description"):
                            f.write(f"{prop['description']}\n\n")

                        # Type information
                        prop_type = prop.get("type")
                        if prop_type:
                            f.write(f"**Type:** {format_type(prop_type)}\n\n")

                        # Optional/Required
                        if prop.get("optional"):
                            f.write(f"**Optional:** Yes\n\n")
                            # Default value
                            if "default" in prop:
                                default = format_default_value(prop["default"])
                                f.write(f"**Default:** {default}\n\n")
                        else:
                            f.write(f"**Required:** Yes\n\n")

            # Category
            if concept.get("category"):
                f.write(f"**Category:** {concept['category']}\n\n")

            # Examples
            if concept.get("examples"):
                f.write("## Examples\n\n")
                for example in concept["examples"]:
                    # Wrap examples in code blocks for proper formatting
                    f.write(f"```\n{example}\n```\n\n")


def write_events(events: List[Dict[str, Any]], output_dir: Path):
    """Write event definitions to markdown files."""
    if not events:
        return

    events_dir = output_dir / "runtime" / "events"
    events_dir.mkdir(parents=True, exist_ok=True)

    for event in events:
        event_name = event["name"]
        output_file = events_dir / f"{event_name}.md"

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"# {event_name}\n\n")

            if event.get("description"):
                f.write(f"{event['description']}\n\n")

            # Data
            data = event.get("data", [])
            if data:
                f.write("## Event Data\n\n")
                for field in data:
                    field_name = field["name"]
                    field_type = format_type(field.get("type", "unknown"))
                    field_desc = field.get("description", "")
                    optional = " *(optional)*" if field.get("optional") else ""

                    f.write(f"### {field_name}\n\n")
                    f.write(f"**Type:** {field_type}{optional}\n\n")
                    if field_desc:
                        f.write(f"{field_desc}\n\n")


def write_defines(defines: List[Dict[str, Any]], output_dir: Path):
    """Write defines to markdown files."""
    if not defines:
        return

    defines_dir = output_dir / "runtime" / "defines"
    defines_dir.mkdir(parents=True, exist_ok=True)

    # Write index file
    index_file = defines_dir / "index.md"
    with open(index_file, "w", encoding="utf-8") as f:
        f.write("# Defines\n\n")
        f.write("This is a list of all defines in the Factorio runtime API.\n\n")

        for define_info in sorted(defines, key=lambda x: x["name"]):
            define_name = define_info["name"]
            f.write(f"- [{define_name}]({define_name}.md)\n")

    # Write individual define files
    for define_info in defines:
        define_name = define_info["name"]
        output_file = defines_dir / f"{define_name}.md"

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"# {define_name}\n\n")

            if define_info.get("description"):
                f.write(f"{define_info['description']}\n\n")

            values = define_info.get("values", [])
            if values:
                f.write("## Values\n\n")
                for value in values:
                    value_name = value["name"]
                    f.write(f"### {value_name}\n\n")

                    if value.get("description"):
                        f.write(f"{value['description']}\n\n")

                    if "value" in value:
                        f.write(f"**Value:** `{value['value']}`\n\n")


def write_builtin_types(builtin_types: List[Dict[str, Any]], output_dir: Path):
    """Write builtin type definitions to markdown files."""
    if not builtin_types:
        return

    types_dir = output_dir / "runtime" / "builtin_types"
    types_dir.mkdir(parents=True, exist_ok=True)

    for builtin_type in builtin_types:
        type_name = builtin_type["name"]
        output_file = types_dir / f"{type_name}.md"

        with open(output_file, "w", encoding="utf-8") as f:
            f.write(f"# {type_name}\n\n")

            if builtin_type.get("description"):
                f.write(f"{builtin_type['description']}\n\n")


def process_runtime_docs(input_file: Path, output_dir: Path):
    """Process runtime API documentation."""
    print(f"Processing runtime docs from {input_file}...")

    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Write metadata file
    metadata_file = output_dir / "runtime" / "metadata.md"
    metadata_file.parent.mkdir(parents=True, exist_ok=True)

    with open(metadata_file, "w", encoding="utf-8") as f:
        f.write("# Runtime API Metadata\n\n")
        f.write(f"**Application:** {data.get('application', 'unknown')}\n\n")
        f.write(f"**Application Version:** {data.get('application_version', 'unknown')}\n\n")
        f.write(f"**API Version:** {data.get('api_version', 'unknown')}\n\n")
        f.write(f"**Stage:** {data.get('stage', 'unknown')}\n\n")

    # Process classes
    classes = data.get("classes", [])
    print(f"Processing {len(classes)} classes...")
    for class_info in classes:
        write_runtime_class(class_info, output_dir)

    # Process concepts
    concepts = data.get("concepts", [])
    if concepts:
        print(f"Processing {len(concepts)} concepts...")
        write_concepts(concepts, output_dir, "runtime")

    # Process events
    events = data.get("events", [])
    if events:
        print(f"Processing {len(events)} events...")
        write_events(events, output_dir)

    # Process defines
    defines = data.get("defines", {})
    if defines:
        print(f"Processing {len(defines)} defines...")
        write_defines(defines, output_dir)

    # Process builtin types
    builtin_types = data.get("builtin_types", [])
    if builtin_types:
        print(f"Processing {len(builtin_types)} builtin types...")
        write_builtin_types(builtin_types, output_dir)

    print("Runtime docs processing complete!")


def process_prototype_docs(input_file: Path, output_dir: Path):
    """Process prototype API documentation."""
    print(f"Processing prototype docs from {input_file}...")

    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Write metadata file
    metadata_file = output_dir / "prototypes" / "metadata.md"
    metadata_file.parent.mkdir(parents=True, exist_ok=True)

    with open(metadata_file, "w", encoding="utf-8") as f:
        f.write("# Prototype API Metadata\n\n")
        f.write(f"**Application:** {data.get('application', 'unknown')}\n\n")
        f.write(f"**Application Version:** {data.get('application_version', 'unknown')}\n\n")
        f.write(f"**API Version:** {data.get('api_version', 'unknown')}\n\n")
        f.write(f"**Stage:** {data.get('stage', 'unknown')}\n\n")

    # Process prototypes
    prototypes = data.get("prototypes", [])
    print(f"Processing {len(prototypes)} prototypes...")
    for proto_info in prototypes:
        write_prototype(proto_info, output_dir)

    # Process types (concepts)
    types = data.get("types", [])
    if types:
        print(f"Processing {len(types)} types...")
        write_concepts(types, output_dir, "prototypes")

    print("Prototype docs processing complete!")


def main():
    parser = argparse.ArgumentParser(
        description="Convert Factorio JSON API documentation to markdown files."
    )
    parser.add_argument(
        "--type",
        choices=["runtime", "prototype"],
        required=True,
        help="Type of documentation to convert"
    )
    parser.add_argument(
        "--input",
        type=Path,
        required=True,
        help="Path to input JSON file"
    )
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Path to output directory"
    )

    args = parser.parse_args()

    # Validate input file exists
    if not args.input.exists():
        print(f"Error: Input file not found: {args.input}")
        return 1

    # Create output directory
    args.output.mkdir(parents=True, exist_ok=True)

    # Process based on type
    if args.type == "runtime":
        process_runtime_docs(args.input, args.output)
    else:
        process_prototype_docs(args.input, args.output)

    print(f"\nAll documentation written to: {args.output}")
    return 0


if __name__ == "__main__":
    exit(main())
