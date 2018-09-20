#!/bin/sh
#
# Used to:
# - backup old uploaded DC data and clean uploads directory
# - get new DC data from OAI feed
# - move data from /incoming/INST/DC to /projectdir/data/incoming
#
# Copyright (c) 2006 Endeca Technologies Inc. All rights reserved.
# COMPANY CONFIDENTIAL

WORKING_DIR=`dirname ${0} 2>/dev/null`

# Set the institution variable here

INST=UNC

echo "setting variables"
WORKING_DIR=/data/DC${INST}/control

. "${WORKING_DIR}/../config/script/set_environment.sh"

echo "Copying DC to backup"
cp -v /data/uploads/${INST}/DC/*.xml  /data/uploads/${INST}/backup/.
cp -v /data/uploads/${INST}/DC/DEL*.*  /data/uploads/${INST}/backup/.

cd /data/uploads/${INST}/DC

rm -f *.xml

# Reads /data/DCUNC/control/collections.txt to get a list of OAI collections to harvest
# Harvests data using resumption tokens to get all records associated with collection
# Places them in files named DATAFILE_$collection_n000.xml
. "${WORKING_DIR}/get_unc_oai.sh"


ls DATAFILE*.xml >/data/uploads/${INST}/Temp/DC.list

while read fileout
do
        if [[ $fileout =~ ^DATAFILE-(ETD|s_papers).*$ ]]
	then
#	    echo "Adding setSpec element to ${fileout}"
#	    sed -i 's/<\/datestamp><\/header>/<\/datestamp><setSpec>ETD<\/setSpec><\/header>/g' $fileout
	    echo "Reformatting ${fileout} with xmllint. "
	    xmllint --format --output /data/uploads/${INST}/DC/$fileout.clean /data/uploads/${INST}/DC/$fileout
	    rm -f -v /data/uploads/${INST}/DC/$fileout
	    mv /data/uploads/${INST}/DC/$fileout.clean /data/uploads/${INST}/DC/$fileout
	fi
	
	if test ! -s "$fileout"
	then
	  echo $fileout is empty.
	  rm -f -v /data/uploads/${INST}/DC/$fileout
	else
          echo "Copying ${fileout} to data/incoming "
       	  cp -v /data/uploads/${INST}/DC/${fileout} /data/DC${INST}/data/incoming/${fileout}

          "${WORKING_DIR}/set_baseline_data_ready_flag.sh"
	fi


done </data/uploads/${INST}/Temp/DC.list


