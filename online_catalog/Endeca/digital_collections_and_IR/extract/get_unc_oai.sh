#!/bin/sh
#
# Script to retrieve OAI documents from UNC OAI servers
#
# Reads list of collections from collections.txt, looks for resumptionTokens in files 
# to call subsequent files in 1000 record chunks (200-record chunks in the case of ETD)



function get_resumption_Token()
{

FILENAME="$1"
echo ${FILENAME}
TOKEN="`sed -n -e 's/.*<resumptionToken[^>]*>\(.*\)<\/resumptionToken>.*/\1/p' $FILENAME`"


}

function resume_harvest()
{

FILESTEM="$1"
RECORDCOUNT="$2"
RESUMPTIONSTEM="$3"
TOKEN="$4"

# construct resumption url and filename
wget --output-document=$FILESTEM-$RECORDCOUNT.xml $RESUMPTIONSTEM$TOKEN

}

while read collection
do

	if [ $collection = yearbooks ]
	then
        # build initial wget string
        WGETSTRING="http://library.digitalnc.org/cgi-bin/oai.exe?verb=ListRecords&set=$collection&metadataPrefix=qdc"
        # output file name stem
        FILESTEM="DATAFILE-$collection"
        # resumption url stem
        RESUMPTIONSTEM="http://library.digitalnc.org/cgi-bin/oai.exe?verb=ListRecords&resumptionToken="
	increment=1000

	elif [ $collection = ETD ]
	then
        # build initial wget string
        WGETSTRING="http://cdr.lib.unc.edu/oai?set=$collection&verb=ListRecords&metadataPrefix=oai_dc"
        # output file name stem
        FILESTEM="DATAFILE-$collection"
        # resumption url stem
        RESUMPTIONSTEM="http://cdr.lib.unc.edu/oai?verb=ListRecords&resumptionToken="
	increment=200

	elif [ $collection = s_papers ]
	then
        # build initial wget string
        WGETSTRING="http://cdr.lib.unc.edu/oai?set=MastersPapers&verb=ListRecords&metadataPrefix=oai_dc"
        # output file name stem
        FILESTEM="DATAFILE-$collection"
        # resumption url stem
        RESUMPTIONSTEM="http://cdr.lib.unc.edu/oai?verb=ListRecords&resumptionToken="
	increment=200

	else

	# build initial wget string
	WGETSTRING="http://dc.lib.unc.edu/cgi-bin/oai.exe?verb=ListRecords&set=$collection&metadataPrefix=qdc"
	# output file name stem
	FILESTEM="DATAFILE-$collection"
	# resumption url stem
	RESUMPTIONSTEM="http://dc.lib.unc.edu/cgi-bin/oai.exe?verb=ListRecords&resumptionToken="
	increment=1000

	fi

	# do a wget on the $collection to get the initial file
	wget --output-document=${FILESTEM}.xml $WGETSTRING

	# if the initial file is not empty, look for resumption tokens

	if test -s "${FILESTEM}.xml"
	then
		count=0
		get_resumption_Token ${FILESTEM}.xml

		echo $TOKEN		
		while [[ -n "$TOKEN" ]]
		do
			count=`expr $count + $increment`
			resume_harvest $FILESTEM $count $RESUMPTIONSTEM $TOKEN
			get_resumption_Token ${FILESTEM}-$count.xml
		done 
	fi


done </data/DCUNC/control/collections.txt


