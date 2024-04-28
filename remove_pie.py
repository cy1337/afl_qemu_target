#!/usr/bin/env python3

import sys
import lief
import argparse

def remove_pie_flag(filename, output_filename=None):
    # Load the ELF binary
    binary = lief.parse(filename)
    if not isinstance(binary, lief.ELF.Binary):
        print("The file is not an ELF executable.")
        return

    # Attempt to find the DT_FLAGS_1 entry
    flags_1_entry = None
    for entry in binary.dynamic_entries:
        if entry.tag == lief.ELF.DYNAMIC_TAGS.FLAGS_1:
            flags_1_entry = entry
            break

    if flags_1_entry is None:
        print("DT_FLAGS_1 entry not found. This file may not have PIE set or lacks dynamic flags.")
        return

    # Check if the DF_1_PIE flag is set and remove it
    if flags_1_entry.value & lief.ELF.DYNAMIC_FLAGS_1.PIE:
        print("PIE flag is present. Removing...")
        # Remove the PIE flag by clearing the bit
        flags_1_entry.value ^= lief.ELF.DYNAMIC_FLAGS_1.PIE
    else:
        print("PIE flag is not present. No changes needed.")
        return

    # Save the modified binary
    if output_filename is None:
        output_filename = filename
    binary.write(output_filename)
    print(f"Modified file saved as {output_filename}")

def main():
    parser = argparse.ArgumentParser(description="Remove the PIE flag from an ELF binary.")
    parser.add_argument("filename", type=str, help="The filename of the ELF file to modify.")
    parser.add_argument("--output", type=str, help="Optional: The filename to save the modified ELF file. If not provided, it overwrites the original file.")

    args = parser.parse_args()

    remove_pie_flag(args.filename, args.output)

if __name__ == "__main__":
    main()
