# misc_xsl_scripts

This is a collection of xsl scripts for one-off transformations meant to solve specific problems.

### bxc-child-extractor.xsl
This script isolates nested "child" objects from "parent" objects in BXC metadata exports. It requires a full metadata export of all objects and a metadata export of parent objects to run. Before use, update "path-to-just-parents.xml" and run with the full metadata export.

### contentdm-imageapi.xsl
This script consolidates image api information from CONTENTdm and transforms it into a spreadsheet for analysis.

### honors_delete_datecreated.xsl
This script deletes the originInfo/dateCreated element if the record also has a originInfo/dateIssued element in BXC metadata exports.

### ncmc_name_extraction.xsl
Extracts names from BXC metadata exports and turns them into a spreadsheet with some added data.