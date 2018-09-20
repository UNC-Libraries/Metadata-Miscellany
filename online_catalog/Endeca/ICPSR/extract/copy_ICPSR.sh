#!/bin/sh
#
# copy_ICPSR.sh -- used to move data from /incoming/INST/STUDY/ to /ICPSR/data/incoming
#
# Copyright (c) 2006 Endeca Technologies Inc. All rights reserved.
# COMPANY CONFIDENTIAL
#
#

WORKING_DIR=`dirname ${0} 2>/dev/null`

# Set the institution variable here

INST=ICPSR

echo "setting variables"
WORKING_DIR=/data/${INST}/control

. "${WORKING_DIR}/../config/script/set_environment.sh"




echo "Copying ICSPR to backup"

cd /data/uploads/ICPSR/STUDY

ls *.xml >/data/uploads/${INST}/Temp/ICPSR.list

while read fileout
do
    if test ! -s "$fileout"
    then
	echo $fileout is empty.
	rm -f -v /data/uploads/${INST}/catalog/$fileout
    else
        echo "Copying ${fileout} to web accessible XML directory"
        echo "Pre-pending Institution name and moving file to data incoming directory"

	# Removes DOCTYPE declaration from the beginning of each file
	. ${WORKING_DIR}/icpsrscript.sed /data/uploads/${INST}/STUDY/${fileout} ${ENDECA_PROJECT_DIR}/data/incoming/DATAFILE-${fileout}

	"${WORKING_DIR}/set_baseline_data_ready_flag.sh"

    fi


done </data/uploads/${INST}/Temp/ICPSR.list

mv /data/uploads/ICPSR/abstracts.tar ../backup/.
rm /data/uploads/ICPSR/STUDY/*
