#!/bin/sh
#
# copy_Dataverse_DC - harvest Dataverse DC records 
#
# Copyright (c) 2006 Endeca Technologies Inc. All rights reserved.
# COMPANY CONFIDENTIAL
#
#
# Set the institution variable here
INST=Dataverse

echo "setting variables"
WORKING_DIR=/data/${INST}/control

. "${WORKING_DIR}/../config/script/set_environment.sh"





cd /data/uploads/${INST}/catalog
rm -f *.xml

# Harvests data using resumption tokens to get all records associated with collection
# Places them in files named DATAFILE_$collection_n0.xml
. "${WORKING_DIR}/get_dataverse_oai.sh"


ls DATAFILE*.xml >/data/uploads/${INST}/Temp/file.list

while read fileout
do
	if test ! -s "$fileout"
	then
	  echo $fileout is empty.
	  rm -f -v /data/uploads/${INST}/catalog/$fileout
	else

	  echo "Copying DC to backup"
	  cp -v /data/uploads/${INST}/catalog/${fileout} /data/uploads/${INST}/backup/.

          echo "Copying ${fileout} to data/incoming "
       	  mv -v /data/uploads/${INST}/catalog/${fileout} /data/${INST}/data/incoming/${fileout}

          "${WORKING_DIR}/set_baseline_data_ready_flag.sh"

	fi


done </data/uploads/${INST}/Temp/file.list


