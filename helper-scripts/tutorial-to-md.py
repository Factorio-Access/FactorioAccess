'''
A tool for creating a markdown document from the built-in factorio access tutorial. Can be used to easily create a wiki page from the tutorial.
Reads the tutorial steps from the english factorio access tutorial file fa-tutorial.cfg. Gets the default english controls from the mod's data.lua file and inserts them to the tutorial steps.
To use just run from the repository root and the resulting tutorial.md is created there.
'''

import configparser
import re
from pathlib import Path

# where to find the required mod files
mod_path = Path(__file__).parent.parent
data_lua_path = mod_path / 'data.lua'
tutorial_path = mod_path / 'locale' / 'en' / 'fa-tutorial.cfg'
missing_control_count = 0
controls_section_found = False

# controls that could not be extracted from data.lua
# new ones can be inserted if needed. The tool prints names of controls it could not find.
extra_controls = {
    'clear-cursor': 'Q'
}


def extract_controls_from_lua(file_path):
    '''
    Gets the controls from data.lua and stores them in two dictionaries.
    First has the control name as key and second the linked_game_control used in some tutorial steps.
    '''
    global controls_section_found
    controls_dict = {}
    alt_controls = {}
    in_controls_section = False  # are we in the file section that has the controls
    in_control = False  # are we processing a control
    linked_control = None  # linked game control name

    try:
        with open(file_path, 'r') as lua_file:
            for line in lua_file:
                # Check if we're entering the controls section
                if "--New custom input events--" in line:
                    print("Entered data.lua controls section.")
                    in_controls_section = True
                    controls_section_found = True
                elif in_controls_section:
                    # Check if the current section has ended and we are done
                    if "})" in line:
                        print("Finished data.lua controls section.")
                        break
                    # Look for lines that define control attributes
                    # todo update to work if this does not come first before other control attributes
                    if "type = \"custom-input\"" in line:
                        in_control = True
                    elif "name" in line and in_control:
                        # Extract the control name
                        name = line.split("\"")[1]
                    elif "linked_game_control" in line and in_control:
                        # Extract the linked control name
                        linked_control = line.split("\"")[1]
                    elif "key_sequence" in line and 'alternative_key_sequence' not in line   and in_control:
                        # Extract the key sequence
                        key_sequence = line.split("\"")[1]
                    elif "}" in line and in_control:
                        # one control processed add to dicts
                        controls_dict[name] = key_sequence
                        if linked_control is not None:
                            alt_controls[linked_control] = key_sequence

                            # prepare for next possible control
                            linked_control = None

                        in_control = False
        if not controls_section_found:
            print("Error: Failed to locate controls section in data.lua")
        return controls_dict, alt_controls
    except FileNotFoundError:
        print(f"File not found: {data_lua_path}")
        return {}


def findControl(match: re.Match):
    '''
    Helper method for replacing control names in tutorial steps with actual key commands.
    Parameter is a regular expression match object used in the replace operation.
    '''
    global missing_control_count
    control = match.group(1)
    key = controls.setdefault(control, None)
    if key is None:
        key = alt_controls.setdefault(control, None)
        if key is None:
            missing_control_count += 1
            print(f'Warning no key found for control "{control}" and the event name was used instead ({str(missing_control_count)})')
            return control

    return key


# get mod controls from data.lua so that control names can be replaced with actual keyboard commands.
controls, alt_controls = extract_controls_from_lua(data_lua_path)
# add manually defined controls that could not be found from data.lua
controls.update(extra_controls)

# Initialize configparser for parsing the tutorial file
config = configparser.ConfigParser()

# Load the tutorial cfg file
config.read(tutorial_path)

# Open the markdown file to write the output
with open(Path(__file__).parent / 'tutorial.md', 'w') as md_file:
    # Check if 'tutorial' section exists
    if 'tutorial' in config:
        # Iterate through each item in the 'tutorial' section
        # todo now assumes that everything is in order, could be updated to work with chapter and step numbers to make sure
        for key, value in config['tutorial'].items():
            # Split the key to get the chapter and step information
            split_key = key.split('-')
            if len(split_key) < 6:
                # not a tutorial text item
                continue

            chapter_num = split_key[2]
            step_num = split_key[4]
            kind = split_key[5]  # Either 'header' or 'detail'
            if kind not in [ 'header', 'detail' ]:
                continue

            # For the first step's header, use it as the chapter title
            if step_num == '1' and kind == 'header':
                md_file.write(f"## {value}\n\n")
            elif kind == 'header':
                md_file.write("### " + step_num + f": {value}\n\n")
            elif kind == 'detail' and step_num != '1':
                # detail of first step is same as chapter header so do not repeat that
                # Replace the control names with corresponding keyboard commands
                formatted_value = re.sub(r"__CONTROL__(.+?)__", findControl, value)
                md_file.write(f"{formatted_value}\n\n")

print("Conversion to markdown completed.")
