#!/bin/sh
#
# Script to retrieve OAI documents from Dataverse OAI servers
#
# Reads list of collections from collections.txt, looks for resumptionTokens in files 
# to call subsequent files in 10 record chunks



function get_resumption_Token()
{

FILENAME="$1"
# echo ${FILENAME}
TOKEN="`sed -n -e 's/.*<resumptionToken.*>\(.*\)<\/resumptionToken>.*/\1/p' $FILENAME`"

echo ${TOKEN}

}

function resume_harvest()
{

FILESTEM="$1"
RECORDCOUNT="$2"
RESUMPTIONSTEM="$3"
TOKEN="$4"

# construct resumption url and filename
wget --output-document=$FILESTEM-$RECORDCOUNT.xml $RESUMPTIONSTEM$TOKEN

echo $RESUMPTIONSTEM$TOKEN

}

while read collection
do

	cd /data/uploads/Dataverse/catalog/

        # build initial wget string
        WGETSTRING="http://arc.irss.unc.edu/dvn/OAIHandler?verb=ListRecords&set=$collection&metadataPrefix=oai_dc"
        # output file name stem
        FILESTEM="DATAFILE-$collection"
        # resumption url stem
        RESUMPTIONSTEM="http://arc.irss.unc.edu/dvn/OAIHandler?verb=ListRecords&resumptionToken="

	# do a wget on the $collection to get the initial file
	wget --output-document=${FILESTEM}.xml $WGETSTRING

	# if the initial file is not empty, look for resumption tokens

	if test -s "${FILESTEM}.xml"
	then
		count=0
		get_resumption_Token ${FILESTEM}.xml

		echo "Token ${TOKEN}"
		
		while [[ -n "$TOKEN" ]]
		do
			count=`expr $count + 10`
			resume_harvest $FILESTEM $count $RESUMPTIONSTEM $TOKEN
			get_resumption_Token ${FILESTEM}-$count.xml
		done 
	fi


done </data/Dataverse/control/collections.txt


