<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output omit-xml-declaration="yes" method="text" indent="no"/>
        
<!-- define variables for later use -->
    <!-- define availabilty variable to determine if record is available from ICPSR/NADAC for later use-->
    <xsl:variable name="available">
        <xsl:choose>        
            <xsl:when test="//text()[contains(.,'data are not available from ICPSR')]
                or //text()[contains(.,'data are not available for distribution by ICPSR')]
                or //text()[contains(.,'resource is not available from ICPSR')]
                or //text()[contains(.,'data are not available from NADAC')]
                or //text()[contains(.,'study is no longer available')]
                or //text()[contains(.,'UNAVAILABLE')]">
                <xsl:text>not available</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>available</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <xsl:variable name="ICPSR-raw-id">
        <xsl:value-of select="codeBook/docDscr[1]/citation[1]/titlStmt[1]/IDNo[1]"/>
    </xsl:variable>

    <xsl:variable name="id-length">
        <xsl:value-of select="string-length($ICPSR-raw-id)"/>
    </xsl:variable>

    <xsl:variable name="ICPSR-id">
        <xsl:choose>
            <xsl:when test="string-length($ICPSR-raw-id)='1'">

                <xsl:text>0000</xsl:text>
                <xsl:value-of select="$ICPSR-raw-id"/>

            </xsl:when>
            <xsl:when test="string-length($ICPSR-raw-id)='2'">

                <xsl:text>0</xsl:text>
                <xsl:value-of select="$ICPSR-raw-id"/>

            </xsl:when>
            <xsl:when test="string-length($ICPSR-raw-id)='3'">

                <xsl:text>00</xsl:text>
                <xsl:value-of select="$ICPSR-raw-id"/>

            </xsl:when>
            <xsl:when test="string-length($ICPSR-raw-id)='4'">

                <xsl:text>0</xsl:text>
                <xsl:value-of select="$ICPSR-raw-id"/>

            </xsl:when>
            <xsl:otherwise>

                <xsl:value-of select="$ICPSR-raw-id"/>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="producer">
        <xsl:value-of select="codeBook/docDscr[1]/citation[1]/prodStmt[1]/producer[1]"/>
    </xsl:variable>
    <xsl:variable name="prodplace"> Ann Arbor, MI : </xsl:variable>
    <xsl:variable name="proddate">
        <xsl:value-of select="codeBook/stdyDscr[1]/citation[1]/distStmt[1]/distDate[1]"/>
    </xsl:variable>

    <xsl:variable name="host">http://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/</xsl:variable>
    <xsl:variable name="filename">
        <xsl:value-of select="codeBook/docDscr/citation/holdings/@URI"/>
    </xsl:variable>
    <xsl:variable name="fileCount">
        <xsl:value-of select="count(codeBook/fileDscr)" />
    </xsl:variable>
    
<!-- form body of the record, enter constant fields, apply templates to fill out record-->    
    <xsl:template match="codeBook">{
    "id": "<xsl:text>UNCICPSR</xsl:text><xsl:value-of select="$ICPSR-id"/>",
    "rollup_id": "<xsl:text>ICPSR</xsl:text><xsl:value-of select="$ICPSR-id"/>",
    "local_id": {"value": "<xsl:text>ICPSR</xsl:text><xsl:value-of select="$ICPSR-id"/>", "other": []},
    "record_data_source": [
        "DDI", "Shared Records", "ICPSR"
    ],
    "url": [
        "{\"type\":\"fulltext\",\"href\":\"<xsl:value-of select="$host"/><xsl:value-of select="$ICPSR-id"/>\",\"text\":\"<xsl:text>Access restricted ; authentication may be required.</xsl:text>\"}",
        "{\"type\":\"related\",\"href\":\"<xsl:text>https://www.icpsr.umich.edu/icpsrweb/ICPSR/help/</xsl:text>\",\"text\":\"<xsl:text>ICPSR help for Duke users</xsl:text>\"}",
        "{\"type\":\"related\",\"href\":\"<xsl:text>https://www.lib.ncsu.edu/data/icpsr</xsl:text>\",\"text\":\"<xsl:text>ICPSR help for NCSU users</xsl:text>\"}",
        "{\"type\":\"related\",\"href\":\"<xsl:text>http://guides.lib.unc.edu/aecontent.php?pid=455857</xsl:text>\",\"text\":\"<xsl:text>ICPSR help for UNC users</xsl:text>\"}"
        ],<xsl:apply-templates select="stdyDscr"/><xsl:apply-templates select="stdyDscr" mode="generalnotes"/><xsl:apply-templates select="stdyDscr" mode="notesmethod"/>
    "edition": [
        {
            "value": "ICPSR ed."
        }
    ],
    "imprint_main":[
        "{\"type\":\"imprint\",\"value\":\"<xsl:value-of select="normalize-space($prodplace)"/><xsl:text> </xsl:text><xsl:value-of select="normalize-space($producer)"/><xsl:text>, </xsl:text><xsl:value-of select="substring ($proddate, 1, 4)"/>.\"}"
    ],
    "publisher": [
        "<xsl:value-of select="normalize-space($producer)"/>"
    ],
    "resource_type": ["Dataset -- Statistical"],
    <xsl:choose>
    <xsl:when test="$available='available'">"access_type": ["Online"],</xsl:when>
    </xsl:choose>
    <xsl:choose>
    <xsl:when test="$available='available'">
    "physical_media": [
        "Online"
    ],</xsl:when>
    </xsl:choose>    
    "institution": ["unc", "duke", "ncsu"],
    "owner": "unc",
    <xsl:choose>
    <xsl:when test="$available='available'">"available": "Available",</xsl:when>
    </xsl:choose>
    "virtual_collection": [
        "TRLN Shared Records. ICPSR."
    ],
    "language": [
        "English"
    ]
}</xsl:template>
    
<!--compile general note field-->
    <xsl:template match="stdyDscr" mode="generalnotes">
    "note_general":[<xsl:if test="dataAccs/setAvail/notes">
            <xsl:apply-templates select="dataAccs/setAvail/notes" mode="contents"/>
        </xsl:if>
        <xsl:if test="stdyInfo/sumDscr/geogCover">
        {
            "value": <xsl:text>"Geographic Coverage: </xsl:text><xsl:apply-templates select="stdyInfo/sumDscr/geogCover" mode="property"/>"
        },</xsl:if>
    
        <xsl:if test="stdyInfo/sumDscr/geogUnit">
        {
            "value": <xsl:text>"Geographic Unit(s): </xsl:text><xsl:for-each select="stdyInfo/sumDscr/geogUnit"><xsl:value-of select="(.)"/>"</xsl:for-each>
        },</xsl:if>
        <xsl:if test="stdyInfo/sumDscr/timePrd">
        {
            "value": <xsl:text>"Time Period: </xsl:text>
            <xsl:apply-templates select="stdyInfo/sumDscr/timePrd"/>"
        },</xsl:if>
        <xsl:if test="citation/verStmt">
            <xsl:apply-templates select="citation/verStmt"/></xsl:if>
    ],</xsl:template>
    
<!--compile note_methodology field-->    
    <xsl:template match="stdyDscr" mode="notesmethod">
        <xsl:if test="stdyInfo/sumDscr/dataKind">
    "note_methodology":[<xsl:for-each select="stdyInfo/sumDscr/universe">
        {    
            "value": "<xsl:text>Universe: </xsl:text><xsl:value-of select="normalize-space(.)"/>"
        },</xsl:for-each><xsl:for-each select="method/dataColl/collMode">
        {
            "value": "<xsl:text>Data Source: </xsl:text><xsl:value-of select="normalize-space(.)"/>"
        },</xsl:for-each><xsl:for-each select="method/dataColl/sources/dataSrc">
        {
            "value": "<xsl:text>Data Source: </xsl:text><xsl:value-of select="normalize-space(.)"/>"
        },</xsl:for-each>
        {
            "value": "<xsl:text>Data Source: </xsl:text>
            <xsl:for-each select="stdyInfo/sumDscr/dataKind">
                <xsl:variable name="count">
                    <xsl:number/>
                </xsl:variable>
                
                <xsl:if test="$count&gt;1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                
                <xsl:value-of select="normalize-space(.)"/>
                
            </xsl:for-each>"
        }
    ],</xsl:if>
    </xsl:template>

<!--match docDscr and apply templates-->
    <xsl:template match="docDscr">
        <xsl:apply-templates select="citation"/>
    </xsl:template>

<!--match citation and apply templates-->
    <xsl:template match="citation">
        <xsl:apply-templates select="titlStmt"/>
        <xsl:apply-templates select="rspStmt"/>
        <xsl:apply-templates select="serStmt"/>
        <xsl:apply-templates select="distStmt"/>
    </xsl:template>

<!--title fields -->
    <xsl:template match="titlStmt">
        <xsl:apply-templates select="titl"/>
    </xsl:template>
    <xsl:template match="titl">
    "title_main": [
        {
            "value": "<xsl:value-of select="normalize-space(.)"/>"
        }
    ],
    "title_sort": "<xsl:value-of select="normalize-space(.)"/>",</xsl:template>

<!--name fields-->
    <xsl:template match="rspStmt">
        <xsl:variable name="Authors">
            <xsl:for-each select="AuthEnty">
                <xsl:apply-templates/>
                <xsl:if test="position()!=last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:if test="position()=last()-1">
                    <xsl:text>and </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
    "statement_of_responsibility": [
        {
            "value": "<xsl:text>by </xsl:text><xsl:value-of select="$Authors"/>"
        }
    ],
    "names": [<xsl:for-each select="AuthEnty">
        {
            "name": "<xsl:value-of select="normalize-space(.)"/>",
            "type": "creator",
            "rel": ["creator"]
        },</xsl:for-each>
        {<xsl:for-each select="../../../docDscr/citation/prodStmt/producer">
            "name": "<xsl:value-of select="normalize-space(.)"/>",
            "type": "publisher",
            "rel": ["publisher"]
        }</xsl:for-each>
    ],</xsl:template>
    
   <xsl:template match="distStmt">
        <xsl:apply-templates select="distDate"/>
    </xsl:template>

 <!--date fields-->
    <xsl:template match="distDate">
        <xsl:variable name="distDate">
            <xsl:apply-templates/>
        </xsl:variable>
    "publication_year": [
        <xsl:value-of select="substring ($distDate, 1, 4)"/>
    ],
    "date_cataloged": [
        "<xsl:value-of select="substring ($distDate, 1, 4)"/>-<xsl:value-of select="substring ($distDate, 6, 2)"/>-<xsl:value-of select="substring ($distDate, 9, 2)"/>T05:00:00Z"
    ],</xsl:template>

<!--series fields-->
    <xsl:template match="serStmt">
        <xsl:apply-templates select="serName"/>
    </xsl:template>

    <xsl:template match="serName">
    "series_work": [
        {
            "title": [
                "<xsl:value-of select="normalize-space(.)"/>"
            ],
            "details": "<xsl:value-of select="$ICPSR-id"/>",
            "type": "series"
        },
        {
            "title": [
                "<xsl:text>ICPSR</xsl:text>"
            ],
            "details": "<xsl:value-of select="$ICPSR-id"/>",
            "type": "series"
        }
    ],</xsl:template>

<!--title from statement used in note_general-->
    <xsl:template match="verStmt">
        <xsl:if test="position()=last()">
            <xsl:apply-templates select="version"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="version">
        <xsl:if test="@date">
        {
            "value": "<xsl:text>Title from ICPSR DDI metadata of </xsl:text><xsl:value-of select="@date"/>"
        }</xsl:if></xsl:template>

<!-- match stdyDscr and call templates-->
    <xsl:template match="stdyDscr">
        <xsl:apply-templates select="citation"/>
        <xsl:apply-templates select="stdyInfo"/>
        <xsl:apply-templates select="dataAccs"/>
    </xsl:template>

<!-- match stdyInfo and call templates-->
    <xsl:template match="stdyInfo">
        <xsl:apply-templates select="subject" mode="subject_topical"/>
        <xsl:apply-templates select="subject" mode="subject_headings"/>
    "note_summary": [<xsl:for-each select="abstract">
        <xsl:apply-templates select="(.)"/><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>
    ],<xsl:apply-templates select="sumDscr"/>
        <xsl:apply-templates select="notes" mode="row"/>
    </xsl:template>

<!--subject_topical and subject_headings fields-->
    <xsl:template match="subject" mode="subject_topical">
    "subject_topical": [<xsl:for-each select="(keyword|topcClas)">
            <xsl:apply-templates select="(.)" mode="topic"></xsl:apply-templates>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
    ],</xsl:template>

    <xsl:template match="keyword|topcClas" mode="topic">
        <xsl:variable name="subject">
            <xsl:value-of select="normalize-space()"/>
        </xsl:variable>
        "<xsl:value-of
            select="concat(translate(substring($subject,
            1,1),'abcdefghijklmnopqrstuvwxyz',
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($subject,2,string-length($subject)))"
        />"</xsl:template>

    <xsl:template match="subject" mode="subject_headings">
    "subject_headings": [<xsl:for-each select="(keyword|topcClas)">
            <xsl:apply-templates select="(.)" mode="heading"></xsl:apply-templates>
            <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
    ],</xsl:template>
    
    <xsl:template match="keyword|topcClas" mode="heading">
        <xsl:variable name="subject">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:variable>
        {
            "value":"<xsl:value-of
            select="concat(translate(substring($subject,
            1,1),'abcdefghijklmnopqrstuvwxyz',
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($subject,2,string-length($subject)))"/>"
        }</xsl:template>

<!--escape reserved JSON characters in note_summary-->
    <xsl:template match="abstract">
        <xsl:variable name="abstract">
            <xsl:call-template name="jsonescape"></xsl:call-template>
        </xsl:variable>
        "<xsl:value-of select="normalize-space($abstract)"/>"</xsl:template>

<!--subject_geograpic field-->
    <xsl:template match="sumDscr">
        <xsl:if test="geogCover">
    "subject_geographic":[<xsl:for-each select="geogCover">
        "<xsl:apply-templates/>"<xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each>
    ],</xsl:if>
    </xsl:template>

<!--time period-used in note_general-->  
    <xsl:template match="timePrd">
        <xsl:choose>
            <xsl:when test="@event='start'">
                <xsl:choose>
                    <xsl:when test="@date">
                        <xsl:value-of select="@date"/>
                        <xsl:text> to </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                        <xsl:text> to </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@event='end'">
                <xsl:choose>
                    <xsl:when test="@date">
                        <xsl:value-of select="@date"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@event='single'">
                        <xsl:if test="@date">
                            <xsl:value-of select="@date"/>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- adds commas to and formats note_general Geographic Coverage -->
    <xsl:template match="geogCover" mode="property">
        <xsl:apply-templates/>
        <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:template>

<!--method and sources templates used in note_methodology -->
    <xsl:template match="method">
        <xsl:apply-templates select="dataColl"/>
    </xsl:template>

    <xsl:template match="sources">
        <xsl:apply-templates select="dataSrc"/>
    </xsl:template>
    
<!-- create note_access_restrictions-->
    <xsl:template match="dataAccs">
        <xsl:apply-templates select="useStmt"/>
    </xsl:template>

    <xsl:template match="useStmt">
        <xsl:apply-templates select="conditions"/>
    </xsl:template>
    
    <xsl:template match="conditions">
    <xsl:choose>
    <xsl:when test="$available='available'">
    "note_access_restrictions": [
        "<xsl:apply-templates select="p"/>"
    ],</xsl:when>
    <xsl:otherwise>
    "note_access_restrictions": [
        "ICPSR does not provide this data online. ICSPR provides a link to the data owner, who may be contacted about obtaining the data."
    ],</xsl:otherwise>
    </xsl:choose>
    </xsl:template>
    
<!-- templates used for formatting within notes fields -->
    <xsl:template match="notes" mode="row">
        <tr>
            <td class="h3">
                <xsl:if test="position()=1">
                    <p>Notes:</p>
                </xsl:if>
            </td>
            <td>
                <p>
                    <xsl:if test="@ID">
                        <a name="{@ID}"/>
                    </xsl:if>
                    <xsl:apply-templates/>
                </p>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="notes" mode="list">
        <li><xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if> Notes: <xsl:apply-templates/></li>
    </xsl:template>

    <xsl:template match="notes" mode="para">
        <p><xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if> Notes: <xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="notes" mode="no-format">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="notes" mode="contents">
        {
            "value": "<xsl:text>Contents: </xsl:text><xsl:value-of select="$fileCount"/><xsl:text> data file</xsl:text><xsl:if test="$fileCount&gt;1"><xsl:text>s</xsl:text></xsl:if>"
        },
        {
            "value": "<xsl:text>Contents: </xsl:text><xsl:value-of select="normalize-space(.)"/>"
        },</xsl:template>

    <xsl:template match="p">

        <xsl:apply-templates/>

    </xsl:template>

    <xsl:template match="emph">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

<!--general template to escape reserved JSON characters-->
    <xsl:template name="jsonescape">
        <xsl:param name="str" select="."/>
        <xsl:param name="escapeChars" select="'\&quot;'" />
        <xsl:variable name="first" select="substring(translate($str, translate($str, $escapeChars, ''), ''), 1, 1)" />
        <xsl:choose>
            <xsl:when test="$first">
                <xsl:value-of select="concat(substring-before($str, $first), '\', $first)"/>
                <xsl:call-template name="jsonescape">
                    <xsl:with-param name="str" select="substring-after($str, $first)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
