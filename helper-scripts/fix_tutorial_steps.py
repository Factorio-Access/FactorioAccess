
"""
Tutorial step number correction script.
You can use this script to fix the step numbering within every chapter after making edits. Here is how:
 1. Make any edits you want.
    - For example, you can delete some steps or insert new steps. 
    - The restriction is that every chapter can fit up to 99 steps and step 0 is the chapter name.
 2. Make sure that after you made edits, all remaining steps have a one-digit or two-digit number, even if it is incorrect.
 3. Run this script using python. 
    - You do this by putting the script into the same folder as your modified version of "fa-tutorial.cfg" 
      and then using the command: "python3 fix-tutorial-steps.py fa-tutorial.cfg"
    - Empty steps will get removed except for those at the end, and all steps after number 99 are not read by the mod.
"""
import re


def renumber_steps_in_file(filename):

    # Dictionary to store the current step number for each chapter
    chapter_step_counters = {}

    # Regular expression pattern to match step headers and details
    pattern = re.compile(r'(tutorial-chapter-(\d+)-step-(\d+)-(header|detail)=)(\n?)')

    # Read the entire file content
    with open(filename, 'r') as file:
        content = file.read()


    # Function to update step numbers within the content
    def replace_step_numbers(match):
        original_step = int(match.group(3))
        chapter_number = int(match.group(2))
        step_type = match.group(4)
        newline = match.group(5)

        # Initialize the step counter for the chapter if not already present
        if chapter_number not in chapter_step_counters:
            chapter_step_counters[chapter_number] = 0  # Start from zero for each chapter

        # Increment the step counter for the chapter
        new_step_number = chapter_step_counters[chapter_number]
        chapter_step_counters[chapter_number] += 1

        # Check if the step is empty (has no content after '=')
        if len(newline.strip()) > 0:
            # Construct and return the new step identifier with newline
            return f'tutorial-chapter-{chapter_number}-step-{new_step_number}-{step_type}={newline}'
        else:
            # Return an empty string to remove this step
            return ''

    
    # Function to append empty steps to ensure each chapter has steps 0 to 99
    def append_empty_steps(content):
        chapter_max_steps = {}  # Dictionary to store max step number for each chapter

        # Regex pattern to match step headers and details with max step number per chapter
        pattern = re.compile(r'tutorial-chapter-(\d+)-step-(\d+)-(header|detail)=')

        # Find max step number for each chapter
        for match in re.finditer(pattern, content):
            chapter_number = int(match.group(1))
            step_number = int(match.group(2))
            if chapter_number not in chapter_max_steps or step_number > chapter_max_steps[chapter_number]:
                chapter_max_steps[chapter_number] = step_number

        # Append empty steps to ensure each chapter has steps 0 to 99
        for chapter_number, max_step in chapter_max_steps.items():
            for i in range(max_step + 1, 100):  # Append steps from max_step + 1 to 99
                empty_step = f'tutorial-chapter-{chapter_number}-step-{i}-header='
                updated_content += empty_step

        return updated_content
    
    
    # Replace old step numbers with new ones using regex substitution
    updated_content = re.sub(pattern, replace_step_numbers, content)

    # Append empty steps
    updated_content = append_empty_steps(updated_content)

    # Write the updated content back to the file
    with open(filename, 'w') as file:
        file.write(updated_content)

    print(f'Successfully renumbered steps in {filename}')

# Main function:
if __name__ == "__main__":
    filename = 'fa-tutorial.cfg'  # Replace with your file path
    renumber_steps_in_file(filename)