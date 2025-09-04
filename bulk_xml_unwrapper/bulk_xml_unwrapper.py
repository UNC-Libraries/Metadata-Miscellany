import os
import zipfile
from lxml import etree
import platform

def merge_xml_files(file_list, output_file, root_tag="bulkMetadata", ns_uri=None, attrib=None, declaration=None):
    attrib = attrib or {}
    if ns_uri:
        attrib["xmlns"] = ns_uri

    root = etree.Element(root_tag, attrib=attrib)
    root.text = "\n"  # Line break for first child

    for file_path in file_list:
        try:
            tree = etree.parse(file_path)
            for child in tree.getroot():
                root.append(child)
        except Exception as e:
            print(f"Error processing {file_path}: {e}")

    tree = etree.ElementTree(root)

    # Write manually with user-specified declaration
    with open(output_file, "wb") as f:
        f.write((declaration + "\n").encode("utf-8"))
        tree.write(
            f,
            encoding="UTF-8",
            pretty_print=True,
            xml_declaration=False  # Prevent lxml from writing its own declaration
        )

def collect_files_from_folder(folder):
    xml_files = []
    for f in os.listdir(folder):
        file_path = os.path.join(folder, f)
        if f.lower().endswith(".xml"):
            xml_files.append(file_path)
        elif f.lower().endswith(".zip"):
            with zipfile.ZipFile(file_path, 'r') as z:
                for name in z.namelist():
                    if name.endswith(".xml"):
                        extracted_path = os.path.join(folder, name)
                        z.extract(name, folder)
                        xml_files.append(extracted_path)
    return xml_files

def normalize_path(path):
    
    # Converts Git Bash-style /c/... paths into Windows C:\\... paths.
    # On non-Windows systems, or with native Windows-style paths, returns input unchanged.
    
    system = platform.system()
    if system == "Windows":
        if path.startswith("/"):
            # Git Bash style: /c/Users/... → C:\Users\...
            drive, rest = path[1], path[2:]
            return os.path.normpath(f"{drive.upper()}:/{rest}")
    return os.path.normpath(path)

def run_script():
    while True:
        folder = input("Drag and drop a folder containing XML or ZIP files here: ").strip().strip('"').strip("'")
        folder = normalize_path(folder)

        if not os.path.isdir(folder):
            print("Invalid folder path. Please try again.\n")
            continue  

        xml_files = collect_files_from_folder(folder)
        if not xml_files:
            print("No XML files found in the folder. Please try again.\n")
            continue  

        break
        
    # User inputs parameters

    root_tag = input("Enter root element name (default: 'bulkMetadata'): ").strip() or "bulkMetadata"
    declaration = input('Enter XML declaration (default: <?xml version="1.0" encoding="utf-8"?>): ').strip()
    if not declaration:
        declaration = '<?xml version="1.0" encoding="utf-8"?>'
    declaration = declaration.replace("'", '"')  # enforce double quotes
    ns_uri = input("Enter root namespace URI (leave empty for none): ").strip() or None
    attrib_input = input("Enter root attributes as key=value pairs separated by commas (e.g., type=bulk,version=1.0) (leave empty for none): ").strip()
    attrib = {}
    if attrib_input:
        for pair in attrib_input.split(","):
            if "=" in pair:
                key, value = pair.split("=", 1)
                attrib[key.strip()] = value.strip()
    output_file = input("Enter output file name (to save in current directory) or path (default: 'combinedmods.xml'): ").strip() or "combinedmods.xml"
    if not output_file.lower().endswith(".xml"):
        output_file += ".xml"

    # Generate output
    
    merge_xml_files(xml_files, output_file, root_tag=root_tag, ns_uri=ns_uri, attrib=attrib, declaration=declaration)

    print(f"Combined XML written to {output_file}.")
    
# Main function call

if __name__ == "__main__":
    while True:
        run_script()
        again = input("\nRun again? (y/n): ").strip().lower()
        if again != "y":
            print("")
            break
