import re

from fix_tutorial_steps import renumber_steps_in_file

def convert_markdown_to_cfg(input_file, output_file):
    with open(input_file, 'r') as infile:
        lines = infile.readlines()
    
    # Initialize counters
    chapter_counter = -1
    step_counter = -1
    did_this_step = False
    
    with open(output_file, 'w') as outfile:
        for line in lines:
            
            if line.startswith('# '):  # Chapter header
                chapter_counter += 1
                step_counter = 0
                if chapter_counter > 0:
                    chapter_text = line[2:].strip()
                    outfile.write(f"tutorial-chapter-{chapter_counter}-step-{step_counter}-header={chapter_text}\n")
                    outfile.write(f"tutorial-chapter-{chapter_counter}-step-{step_counter}-detail={chapter_text}\n")
                continue
            elif line.startswith('## '):  # Step header
                step_counter += 1
                header_text = line[3:].strip()  # Remove the '## ' part
                outfile.write(f"\ntutorial-chapter-{chapter_counter}-step-{step_counter}-header={header_text}\n")
                did_this_step = False
                continue
            else:
                detail_text = line.strip() 
                if detail_text == "":
                    continue  # Skip empty lines
                else:
                    if did_this_step is False:  # Add the key for the step
                        outfile.write(f"tutorial-chapter-{chapter_counter}-step-{step_counter}-detail=")
                        did_this_step = True
                    outfile.write(f"{line.strip()}" + " ")  # Append this paragraph.
                    continue

if __name__ == "__main__":
    convert_markdown_to_cfg('fa-tutorial.md', 'fa-tutorial.cfg')
    renumber_steps_in_file('fa-tutorial.cfg')

