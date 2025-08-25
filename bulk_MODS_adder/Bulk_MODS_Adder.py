import pandas as pd
import xml.etree.ElementTree as ET

xml_input = input("Enter the path to the original XML file to be modified: ").strip('"')
csv_input = input("Enter the path to the CSV file with the list of PIDs and values: ").strip('"')
xml_output = input("Enter the path for the updated XML file: ").strip('"')

tree = ET.parse(xml_input)
root = tree.getroot()

missing_pids = pd.read_csv(csv_input)
missing_pids = missing_pids.set_index('pid')['element'].to_dict()

#Namespaces are defined here, add or take away as needed
ET.register_namespace('mods', 'http://www.loc.gov/mods/v3')
ET.register_namespace('xlink', 'http://www.w3.org/1999/xlink')

#Namespaces are put into a variable here
ns = {
    "mods": "http://www.loc.gov/mods/v3",
    "xlink": "http://www.w3.org/1999/xlink"
}

#Namespaces are added to every MODS parent element here
for mods_el in root.findall('.//mods:mods', ns):
    mods_el.set("xmlns:mods", ns["mods"])
    mods_el.set("xmlns:xlink", ns["xlink"])

for obj in root.findall('object'):
    pid = obj.get('pid')
    if pid in missing_pids:
        datastream = obj.find('datastream')
        mods_el = datastream.find('mods:mods', ns)
        if mods_el is not None:  
            new_element = ET.Element(
                f"{{{ns['mods']}}}identifier", #MODS element to be added is defined here
                attrib={"displayLabel": "Interview Number", "type": "local"} #MODS attributes to be added are defined here
            )
            new_element.text = missing_pids[pid]
            mods_el.append(new_element)

tree.write(xml_output, encoding="utf-8", xml_declaration=True)

print(f"Updated XML has been written to {xml_output}")