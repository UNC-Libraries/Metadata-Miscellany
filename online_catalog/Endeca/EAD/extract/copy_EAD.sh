#!/bin/sh
#
# copy_syndetics.sh -- used to move data from /incoming/INST/Syndetics to /projectdir/data/incoming
#
# Copyright (c) 2006 Endeca Technologies Inc. All rights reserved.
# COMPANY CONFIDENTIAL
#
#

WORKING_DIR=`dirname ${0} 2>/dev/null`

# Set the institution variable here

INST=UNC

echo "setting variables"
WORKING_DIR=/data/EAD${INST}/control

. "${WORKING_DIR}/../config/script/set_environment.sh"

NOW="`date`"


echo "Copying EAD to backup"
rm -f /data/uploads/${INST}/EAD/externaldata.xml
cp -v /data/uploads/${INST}/EAD/*.xml  /data/uploads/${INST}/backup/
cp -v /data/uploads/${INST}/EAD/DEL*.*  /data/uploads/${INST}/backup/


cd /data/uploads/${INST}/EAD
ls *.xml >/data/uploads/${INST}/Temp/EAD.list

while read fileout
do
    echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    if test ! -s "$fileout"
    then
	rm -f -v /data/uploads/${INST}/EAD/$fileout
	echo "WARN: ${INST}EAD Daily Delta included empty file at ${NOW}: ${fileout}" >> /data/util/logs/job_status.log
	echo "Skipping empty file: ${fileout}"
    else
	#returns string with length of 0 if document is well formed
	wellformed="`xmlwf $fileout`"

	#-z means "is zero length string"
	if [ -z $wellformed ]
	then
	    echo "${fileout} is well-formed XML and will be sent to Forge."
	    echo "Copying ${fileout} to web accessible XML directory"
	    . ${WORKING_DIR}/uncsedscript.sed /data/uploads/${INST}/EAD/${fileout} /usr/local/tomcat/webapps/EAD_xml/${fileout}

	    echo "Adding filename field to XML file"
	    # This is so that the EAD ID property can just be set on the file name, instead of all the other
	    # nonsense to figure that out. In late summer 2016, L&IT moved all EAD files and didn't update the EAD
	    # ID or URL properties in the actual EAD XML. 
	    sed "/<eadid/ i\ <eadfilename>${fileout}</eadfilename>" /data/uploads/${INST}/EAD/${fileout} > /data/uploads/${INST}/EAD/${fileout}ed
	    
	    echo "Pre-pending Institution name and moving file to data incoming directory"
	    . ${WORKING_DIR}/uncsedscript.sed /data/uploads/${INST}/EAD/${fileout}ed ${ENDECA_PROJECT_DIR}/data/incoming/${INST}${fileout}
		    
	    rm -f -v /data/uploads/${INST}/EAD/$fileout
	    rm -f -v /data/uploads/${INST}/EAD/${fileout}ed

	    "${WORKING_DIR}/set_baseline_data_ready_flag.sh"
	else
	    echo "${fileout} is malformed XML and will not be sent to Forge."
	    echo "WARN: ${INST}EAD Daily Delta skipped malformed file at ${NOW}: ${fileout}" >> /data/util/logs/job_status.log
	    rm -f -v /data/uploads/${INST}/EAD/$fileout
	fi
    fi


done </data/uploads/${INST}/Temp/EAD.list

rm -f /data/uploads/${INST}/EAD/*.xml
mv -v /data/uploads/${INST}/EAD/DEL*.* ${ENDECA_PROJECT_DIR}/data/incoming/.

