# Bulk MODS Element Adder

This script was written to add missing interview numbers to SOHP interviews in DCR, but can be modified to add any element(s) to a DCR MODS file based on PID.

## Before Running

This script prompts the user for three variables: an original MODS XML file, a CSV listing PIDs with corresponding missing values, and a location to output the updated MODS document.

One column in the CSV should be labeled "pid" and include the full PID as listed in the DCR MODS output (i.e., include the "content/" prefix). The other column should be labeled "element" and include the exact value of the element to be added.

**Important:** This script will add whatever is entered in the CSV. It does **not** check if there is already a MODS element with the defined Xpath present for each PID, or any existing values.

## Modifying the script

This script is written so that the MODS and XLINK namespaces are added to every MODS parent element (mods:mods), which is a requirement for SOHP interviews in DCR. Different collections may have different namespace requirements. Refer to comments in the code to see where namespaces and their placements are defined.

This script is written to add the "identifier" MODS element, and the attributes that are particular to it in SOHP interviews in DCR. Refer to comments in the code to see where the element to add and its attributes are defined. 
