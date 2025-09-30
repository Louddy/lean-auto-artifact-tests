import argparse

def filter_lines(input_file, output_file, letter, column):
    with open(input_file, "r") as f:
        lines = f.readlines()

    filtered_lines = []

    for line in lines:
        # find the part inside the brackets
        start = line.find('[')
        end = line.find(']')
        if start == -1 or end == -1:
            continue  # skip lines without brackets

        content = line[start+1:end].strip()
        if not content:
            continue  # skip empty arrays

        # split by commas and strip spaces
        elements = [e.strip() for e in content.split(',')]

        # handle "last" column
        if column == "last":
            idx = -1
        else:
            try:
                idx = int(column)
            except ValueError:
                print(f"Invalid column: {column}")
                return

        # support negative indices
        if -len(elements) <= idx < len(elements):
            if elements[idx].startswith(letter):
                filtered_lines.append(line)

    with open(output_file, "w") as f:
        f.writelines(filtered_lines)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Filter lines based on a letter in a specific column of the array.")
    parser.add_argument("input_file", help="Input file name")
    parser.add_argument("output_file", help="Output file name")
    parser.add_argument("letter", help="Letter to filter by (e.g., S, E, G)")
    parser.add_argument("column", help="Index of the element to check (0-based), negative for reverse indexing, or 'last' for the last element")
    args = parser.parse_args()

    filter_lines(args.input_file, args.output_file, args.letter, args.column)
