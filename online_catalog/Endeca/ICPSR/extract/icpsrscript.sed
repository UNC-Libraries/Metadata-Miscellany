#!/bin/sh
sed -r '
/<!DOCTYPE/ d
/^SYSTEM \"http:\/\/www.icpsr.umich.edu\/DDI\/Version2-1.dtd\"/ d
/^SYSTEM \"http:\.*/ d
s/<codeBook[^>]+>/<codeBook>/' <$1 >$2
