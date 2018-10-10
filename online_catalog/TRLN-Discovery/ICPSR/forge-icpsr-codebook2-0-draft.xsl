<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:unc="http://yourdomain.com/lookup" extension-element-prefixes="unc" version="1.0">
    <xsl:output method="text" indent="no"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="part"/>

    <xsl:param name="var-token"/>

    <xsl:param name="varGrp-token"/>

    
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
    
    
    <xsl:template match="codeBook">{
    "id": "<xsl:text>UNCICPSR</xsl:text><xsl:value-of select="$ICPSR-id"/>",
    "rollup_id": "<xsl:text>ICPSR</xsl:text><xsl:value-of select="$ICPSR-id"/>",
    "record_data_source": [
        "ICPSR"
    ],
    "url": [
        "{\"href\":\"<xsl:value-of select="$host"/><xsl:value-of select="$ICPSR-id"/>\",\"text\":\"<xsl:text>Access restricted ; authentication may be required.</xsl:text>\"}",
        "{\"href\":\"<xsl:text>http://www.icpsr.umich.edu/icpsrweb/ICPSR/help/\</xsl:text>",<xsl:text>ICPSR help for Duke users</xsl:text>\"}",
        "{\"href\":\"<xsl:text>http://www.lib.ncsu.edu/data/icpsr.html</xsl:text>\",\"text\":\"<xsl:text>ICPSR help for NCSU users</xsl:text>\"}",
        "{\"href\":\"<xsl:text>http://guides.lib.unc.edu/aecontent.php?pid=455857</xsl:text>\",\"text\":\"<xsl:text>ICPSR help for UNC users</xsl:text>\"}"
    ],<xsl:apply-templates select="stdyDscr"/><xsl:apply-templates select="stdyDscr" mode="generalnotes"/><xsl:apply-templates select="fileDscr"/><xsl:apply-templates select="dataDscr"/>
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
    "language": [
        "English"
    ]
}</xsl:template>

    <xsl:template match="stdyDscr" mode="generalnotes">
    "note_general":[<xsl:if test="dataAccs/setAvail/notes">
            <xsl:apply-templates select="dataAccs/setAvail/notes" mode="contents"/>
        </xsl:if>
        <xsl:if test="stdyInfo/sumDscr/geogCover">
        {
        "value": <xsl:text>Geographic Coverage: </xsl:text><xsl:apply-templates select="stdyInfo/sumDscr/geogCover" mode="property"/>"
        },</xsl:if>
        <xsl:if test="citation/verStmt/version">
            <xsl:apply-templates select="citation/verStmt/version"/></xsl:if>
    ],</xsl:template>

    <xsl:template match="docDscr">
        <xsl:apply-templates select="citation"/>
        <xsl:apply-templates select="guide"/>
        <xsl:apply-templates select="docStatus"/>
        <xsl:apply-templates select="docSrc"/>
        <xsl:apply-templates select="notes" mode="row"/>
    </xsl:template>
    <xsl:template match="citation">
        <xsl:apply-templates select="titlStmt"/>
        <xsl:apply-templates select="rspStmt"/>
        <xsl:apply-templates select="prodStmt"/>
        <xsl:apply-templates select="distStmt"/>
        <xsl:apply-templates select="serStmt"/>
        <xsl:apply-templates select="biblCit"/>
        <xsl:apply-templates select="holdings"/>
    </xsl:template>
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

    <xsl:template match="subTitl"> </xsl:template>

    <xsl:template match="altTitl"> </xsl:template>

    <xsl:template match="parTitl"> </xsl:template>

    <xsl:template match="IDNo"> </xsl:template>

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
    "names": [<xsl:for-each select="AuthEnty|othId">
        {
            "name": "<xsl:value-of select="normalize-space(.)"/>",
            "type": "creator",
            "rel": "creator"
        },</xsl:for-each>
        {<xsl:for-each select="../../../docDscr/citation/prodStmt/producer">
            "name": "<xsl:value-of select="normalize-space(.)"/>",
            "type": "publisher",
            "rel": "publisher"
        }</xsl:for-each>     
    ],</xsl:template>

    <xsl:template match="prodStmt">
    </xsl:template>

    <xsl:template match="copyright">
    "PROP NAME="Notes"": "Copyright - <xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    <xsl:template match="software">
    "PROP NAME="Notes"": "<xsl:text>Software used: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    <xsl:template match="fundAg">
    "PROP NAME="Notes"": "<xsl:text>Funding Agency/Sponsor: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    <xsl:template match="grantNo">
    "PROP NAME="Notes"": "<xsl:text>Grant Number: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    <xsl:template match="distStmt">
        <xsl:apply-templates select="distDate"/>
    </xsl:template>
    <xsl:template match="distrbtr">
    "PROP NAME="Notes"": "<xsl:text>Distributor: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    <xsl:template match="contact">
    "PROP NAME="Notes"": "<xsl:text>Contact Persons: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    <xsl:template match="depositr">
    "PROP NAME="Notes"": "<xsl:text>Depositor: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    <xsl:template match="depDate">
    "PROP NAME="Notes"": "<xsl:text>Deposited: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    
    <xsl:template match="distDate">
        <xsl:variable name="distDate">
            <xsl:apply-templates/>
        </xsl:variable>
    "publication_year": [
        <xsl:value-of select="substring ($distDate, 1, 4)"/>
    ],
    "date_cataloged": [
        "<xsl:value-of select="substring ($distDate, 1, 4)"/><xsl:value-of select="substring ($distDate, 6, 2)"/><xsl:value-of select="substring ($distDate, 9, 2)"/>"
    ],</xsl:template>
    
    <xsl:template match="serStmt">
        <xsl:apply-templates select="serName"/>
        <xsl:apply-templates select="serInfo"/>
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

    <xsl:template match="serInfo"> </xsl:template>
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
    
    <xsl:template match="verResp" mode="row">
    "PROP NAME="Version Responsibility:"": "<xsl:text>Version Responsibility: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    
    <xsl:template match="biblCit"> </xsl:template>
    
    <xsl:template match="holdings"> </xsl:template>
    
    <xsl:template match="guide">
    "PROP NAME="Note"": "<xsl:text>Guide to Codebook: </xsl:text><xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
    
    <xsl:template match="docStatus"> </xsl:template>

    <xsl:template match="docSrc"> </xsl:template>

    <xsl:template match="stdyDscr">
        <xsl:apply-templates select="citation"/>
        <xsl:apply-templates select="stdyInfo"/>
        <xsl:apply-templates select="method"/>
        <xsl:apply-templates select="dataAccs"/>
    </xsl:template>

    <xsl:template match="stdyInfo">
        <xsl:apply-templates select="subject" mode="subject_topical"/>
        <xsl:apply-templates select="subject" mode="subject_headings"/>
    "note_summary": [<xsl:for-each select="abstract">
        <xsl:apply-templates select="(.)"/><xsl:if test="position()!=last()">, </xsl:if></xsl:for-each>
    ],
        <xsl:apply-templates select="sumDscr"/>
        <xsl:apply-templates select="notes" mode="row"/>
    </xsl:template>

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


    <xsl:template match="abstract">
        <xsl:variable name="abstract">
            <xsl:call-template name="jsonescape"></xsl:call-template>
        </xsl:variable>
        "<xsl:value-of select="normalize-space($abstract)"/>"</xsl:template>
    

    <xsl:template match="sumDscr">
        <xsl:if test="timePrd">
    "PROP NAME="518"": "<xsl:text>Time Period: </xsl:text>
                    <xsl:apply-templates select="timePrd"/>",
    "PROP NAME="650y"": "<xsl:apply-templates select="timePrd"/>",
        </xsl:if>
        <xsl:if test="dataKind">
    "PROP NAME="567"": "<xsl:text>Data Source: </xsl:text>
                    <xsl:for-each select="dataKind">
                        <xsl:variable name="count">
                            <xsl:number/>
                        </xsl:variable>

                        <xsl:if test="$count&gt;1">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        
                        <xsl:apply-templates/>

                    </xsl:for-each>
        </xsl:if>

        <xsl:if test="geogCover">
        <xsl:for-each select="geogCover">
    "subject_geographic":[
        "<xsl:apply-templates/>"
    ],</xsl:for-each>
        </xsl:if>
        
        <xsl:if test="geogUnit">
    "PROP NAME="522"": "<xsl:text>Geographic Unit(s): </xsl:text>
            <xsl:apply-templates select="geogUnit" mode="property"/>
        </xsl:if>
        <xsl:apply-templates select="universe"/>
    </xsl:template>

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

    <xsl:template match="collDate">
        <xsl:choose>
            <xsl:when test="@event='single'">
                <xsl:if test="@date">
    "PROP NAME="008PubDate"": "<xsl:variable name="collDate">
                                <xsl:value-of select="@date"/>
                            </xsl:variable>

                            <xsl:value-of select="substring ($collDate, 1, 4)"/>",

                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="geogCover" mode="property">
        <xsl:apply-templates/>
        <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:template>



    <xsl:template match="geogUnit">
        <xsl:apply-templates/>
        <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:template>



    <xsl:template match="geoBndBox"> </xsl:template>

    <xsl:template match="gringLat">G-Ring Latitude: <xsl:apply-templates/></xsl:template>

    <xsl:template match="gringLon">G-Ring Longitude: <xsl:apply-templates/></xsl:template>

    <xsl:template match="anlyUnit"> </xsl:template>
    <xsl:template match="universe">
    "PROP NAME="567"": "<xsl:text>Universe: </xsl:text><xsl:apply-templates/>",
    </xsl:template>
    <xsl:template match="method">

        <xsl:apply-templates select="dataColl"/>
    </xsl:template>

    <xsl:template match="dataColl">
        <xsl:apply-templates select="collMode"/>
        <xsl:apply-templates select="sources"/>
    </xsl:template>

    <xsl:template match="collMode">
    "PROP NAME="567"": "<xsl:text>Data Source: </xsl:text><xsl:apply-templates/>",
    </xsl:template>
    <xsl:template match="sources">

        <xsl:apply-templates select="dataSrc"/>
    </xsl:template>

    <xsl:template match="dataSrc">
    "PROP NAME="567"", "<xsl:text>Data Source: </xsl:text><xsl:apply-templates/>",
    </xsl:template>
    <xsl:template match="dataAccs">

        <xsl:apply-templates select="useStmt"/>
    </xsl:template>

    <xsl:template match="useStmt">

        <xsl:apply-templates select="conditions"/>
    </xsl:template>
    <xsl:template match="conditions">
    "note_access_restrictions": [
        "<xsl:apply-templates select="p"/>"
    ],</xsl:template>
    <xsl:template match="disclaimer">
        <tr>
            <td class="h3">
                <xsl:if test="@ID">
                    <a name="{@ID}"/>
                </xsl:if>
                <p>Disclaimer:</p>
            </td>
            <td>
                <p>
                    <xsl:apply-templates/>
                </p>
            </td>
        </tr>"
    </xsl:template>

    <xsl:template match="othrStdyMat">
        <tr class="h2">
            <th colspan="2">
                <xsl:if test="@ID">
                    <a name="{@ID}"/>
                </xsl:if>
                <p>Other Study Description Materials</p>
            </th>
        </tr>
        <xsl:apply-templates select="relMat"/>
        <xsl:apply-templates select="relStdy"/>
        <xsl:apply-templates select="relPubl"/>
        <xsl:apply-templates select="othRefs"/>
    </xsl:template>

    <xsl:template match="relMat">
        <xsl:if test="position()=1">
            <tr>
                <th colspan="2">
                    <p>Related Materials</p>
                </th>
            </tr>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="citation">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td/>
                    <td>
                        <p>
                            <xsl:value-of select="."/>
                        </p>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="relStdy">
        <xsl:if test="position()=1">
            <tr>
                <th colspan="2">
                    <p>Related Studies</p>
                </th>
            </tr>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="citation">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td/>
                    <td>
                        <p>
                            <xsl:value-of select="."/>
                        </p>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="relPubl">
        <xsl:if test="position()=1">
            <tr>
                <th colspan="2">
                    <p>Related Publications</p>
                </th>
            </tr>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="citation">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td/>
                    <td>
                        <p>
                            <xsl:if test="@ID">
                                <a name="{@ID}"/>
                            </xsl:if>
                            <xsl:value-of select="."/>
                        </p>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="othRefs">
        <xsl:if test="position()=1">
            <tr>
                <th colspan="2">
                    <p>Other Reference Note(s)</p>
                </th>
            </tr>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="citation">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td/>
                    <td>
                        <p>
                            <xsl:value-of select="."/>
                        </p>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="fileDscr">

    </xsl:template>

    <xsl:template match="locMap">
        <tr>
            <td class="h3">
                <p>Location Map:</p>
            </td>
            <td>
                <p>Location map data is present, but not displayed.</p>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="fileTxt">
        <xsl:for-each select="fileType">
    "PROP NAME="Notes"": "Type of File: <xsl:text> </xsl:text><xsl:value-of select="normalize-space(.)"/>"
        </xsl:for-each>

    </xsl:template>
    <xsl:template match="fileName"><xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>: <xsl:apply-templates/></xsl:template>
    <xsl:template match="fileCont">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Contents of Files: <xsl:apply-templates/>
            </p>
        </li>
    </xsl:template>
    <xsl:template match="fileStrc">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>File Structure: <xsl:value-of select="@type"/></p>
        </li>
        <xsl:apply-templates select="recGrp"/>
        <xsl:apply-templates mode="list" select="notes"/>
    </xsl:template>
    <xsl:template match="recGrp">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Record Group</p>
            <ul>
                <xsl:apply-templates select="labl" mode="list"/>
                <xsl:apply-templates select="recDimnsn"/>
            </ul>
        </li>
    </xsl:template>
    <xsl:template match="labl" mode="list">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Label: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="recDimnsn">
        <xsl:apply-templates select="varQnty"/>
        <xsl:apply-templates select="caseQnty"/>
        <xsl:apply-templates select="logRecL"/>
    </xsl:template>
    <xsl:template match="varQnty">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>No. of variables per record: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="caseQnty">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Number of cases: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="logRecL">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Logical Record Length: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="dimensns">
        <xsl:apply-templates select="caseQnty"/>
        <xsl:apply-templates select="varQnty"/>
        <xsl:apply-templates select="logRecL"/>
        <xsl:apply-templates select="recPrCas"/>
        <xsl:apply-templates select="recNumTot"/>
    </xsl:template>
    <xsl:template match="recPrCas">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Records per Case: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="recNumTot">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Overall Number of Records: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="fileType">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="format">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Data Format: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="filePlac">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Place of File Production: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="dataChck">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Extent of Processing Checks: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="ProcStat">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Processing Status: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="dataMsng">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Missing Data: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="software" mode="list">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Software: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="verStmt" mode="list">
        <xsl:apply-templates select="version" mode="list"/>
        <xsl:apply-templates select="verResp" mode="list"/>
        <xsl:apply-templates select="notes" mode="list"/>
    </xsl:template>
    <xsl:template match="version" mode="list">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Version: <xsl:apply-templates/></p>
        </li>
    </xsl:template>
    <xsl:template match="verResp" mode="list">
        <li>
            <xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>
            <p>Version Responsibility Statement: <xsl:apply-templates/></p>
        </li>
    </xsl:template>

    <xsl:template match="dataDscr">
        <tr class="h1">
            <th colspan="2">
                <p>
                    <xsl:if test="@ID">
                        <a name="{@ID}"/>
                    </xsl:if>
                    <a name="a4.0">Variable Description</a>
                </p>
            </th>
        </tr>
        <xsl:choose>
            <xsl:when test="varGrp">
                <tr class="h2">
                    <th colspan="2">
                        <p>Variable Groups</p>
                    </th>
                </tr>

                <tr>
                    <td> </td>
                    <td>
                        <ul>
                            <xsl:apply-templates mode="list" select="varGrp"/>
                        </ul>
                    </td>
                </tr>

                <xsl:apply-templates mode="detail" select="varGrp"/>

            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td class="h3">
                        <p>List of Variables:</p>
                    </td>
                    <td>
                        <ul>
                            <xsl:apply-templates mode="list" select="var"/>
                        </ul>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
        <tr class="h2">
            <td colspan="2">
                <p>
                    <strong>Variables</strong>
                </p>
            </td>
        </tr>

        <xsl:apply-templates mode="detail" select="var"/>

        <xsl:if test="nCube">

            <tr>
                <td class="h3">
                    <p>nCube(s):</p>
                </td>
                <td>

                    <xsl:if test="nCubeGrp">
                        <p>nCube groups are present in this XML file.</p>
                    </xsl:if>

                    <table border="1" cellpadding="5" cellspacing="0" width="90%">
                        <tr>
                            <th>
                                <p>ID</p>
                            </th>
                            <th>
                                <p>Label</p>
                            </th>
                            <th>
                                <p>Cells</p>
                            </th>
                            <th>
                                <p>Variables</p>
                            </th>
                        </tr>

                        <xsl:apply-templates select="nCube" mode="row"/>

                    </table>

                </td>
            </tr>

        </xsl:if>

        <xsl:apply-templates select="notes" mode="row"/>



    </xsl:template>


    <xsl:template match="nCube" mode="row">
        <tr>
            <td>
                <p>
                    <xsl:value-of select="@ID"/>
                </p>
            </td>
            <td>
                <p>
                    <xsl:value-of select="labl"/>
                </p>
            </td>
            <td>
                <p>
                    <xsl:value-of select="@cellQnty"/>
                </p>
            </td>
            <td>
                <p>
                    <xsl:apply-templates select="dmns"/>
                </p>
            </td>
        </tr>

    </xsl:template>

    <xsl:template match="dmns"><xsl:value-of select="@varRef"/>&#160;</xsl:template>


    <xsl:template match="varGrp" mode="list">
        <li>
            <xsl:element name="a">
                <xsl:attribute name="href">#<xsl:value-of select="@ID"/></xsl:attribute>
                <xsl:apply-templates mode="no-format" select="labl"/>
            </xsl:element>
        </li>

    </xsl:template>
    <xsl:template match="varGrp" mode="detail">

        <xsl:if test="@varGrp">
            <tr>
                <th colspan="2">
                    <p>
                        <xsl:element name="a">
                            <xsl:attribute name="name">
                                <xsl:value-of select="@ID"/>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:value-of select="@ID"/>
                            </xsl:attribute>
                            <xsl:value-of select="labl"/>
                        </xsl:element>
                    </p>
                </th>
            </tr>
            <tr>
                <td/>
                <td>
                    <p>Variable Groups within <xsl:value-of select="labl"/></p>
                    <ul>
                        <xsl:apply-templates mode="list-varGrp" select="../varGrp">
                            <xsl:with-param name="varGrp-token" select="@varGrp"/>
                        </xsl:apply-templates>
                    </ul>
                </td>
            </tr>
        </xsl:if>


        <xsl:if test="@var">
            <tr>
                <th colspan="2">
                    <p>
                        <xsl:element name="a">
                            <xsl:attribute name="name">
                                <xsl:value-of select="@ID"/>
                            </xsl:attribute>
                            <xsl:attribute name="id">
                                <xsl:value-of select="@ID"/>
                            </xsl:attribute>
                            <xsl:value-of select="labl"/>
                        </xsl:element>
                    </p>

                </th>
            </tr>
            <tr>
                <td/>
                <td>
                    <p>Variables within <xsl:value-of select="labl"/></p>
                    <ul>
                        <xsl:apply-templates mode="varGrp" select="../var">
                            <xsl:with-param name="var-token" select="@var"/>
                        </xsl:apply-templates>
                    </ul>

                </td>
            </tr>

        </xsl:if>

        <xsl:apply-templates mode="row" select="txt"/>
        <xsl:apply-templates select="concept"/>
        <xsl:apply-templates select="defntn"/>
        <xsl:apply-templates mode="row" select="universe"/>
        <xsl:apply-templates mode="row" select="notes"/>

        <xsl:apply-templates select="table"/>

    </xsl:template>

    <xsl:template match="varGrp" mode="list-varGrp">
        <xsl:param name="varGrp-token"/>
        <xsl:if test="contains($varGrp-token,@ID)">
            <li>
                <a href="{@ID}">
                    <xsl:apply-templates mode="no-format" select="labl"/>
                </a>
            </li>
        </xsl:if>
    </xsl:template>

    <xsl:template match="var" mode="varGrp">
        <xsl:param name="var-token"/>
        <xsl:choose>
            <xsl:when test="contains($var-token,@ID)">
                <li>
                    <a href="#{@name}">
                        <xsl:choose>
                            <xsl:when test="labl">
                                <xsl:apply-templates select="labl"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@name"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </li>
            </xsl:when>
            <xsl:when
                test="contains($var-token,@ID) and string-length(substring-after($var-token,@ID))=0">
                <li>
                    <a href="#{@name}">
                        <xsl:choose>
                            <xsl:when test="labl">
                                <xsl:apply-templates select="labl"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@name"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </li>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="labl" mode="no-format">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="txt" mode="list">
        <li><xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>Text: <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="defntn">
        <tr>
            <td class="h3">
                <xsl:if test="@ID">
                    <a name="{@ID}"/>
                </xsl:if>
                <p>Definition:</p>
            </td>
            <td>
                <p>
                    <xsl:apply-templates/>
                </p>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="concept">
        <tr>
            <td class="h3">
                <xsl:if test="@ID">
                    <a name="{@ID}"/>
                </xsl:if>
                <p>Concept:</p>
            </td>
            <td>
                <p>
                    <xsl:apply-templates/>
                </p>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="txt" mode="row">
        <tr>
            <td class="h3">
                <xsl:if test="@ID">
                    <a name="{@ID}"/>
                </xsl:if>
                <p>Text:</p>
            </td>
            <td>
                <p>
                    <xsl:apply-templates/>
                </p>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="universe" mode="list">
        <li><xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>Universe: <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="var" mode="list">
        <li>
            <a href="#{@name}">
                <xsl:value-of select="@name"/>
            </a>
            <xsl:if test="labl and labl!=''">&#160;-&#160;<xsl:apply-templates select="labl"
                /></xsl:if>

        </li>
    </xsl:template>


    <xsl:template match="var" mode="detail">
        <tr>
            <th colspan="2">
                <p>
                    <a name="{@name}"/>
                    <a id="{@ID}"/>
                    <xsl:choose>
                        <xsl:when test="labl and labl!=''">
                            <xsl:apply-templates select="labl"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
            </th>
        </tr>




        <tr>
            <td valign="top">
                <xsl:apply-templates select="location"/>
            </td>
            <td valign="top">
                <xsl:apply-templates select="qstn"/>
                <xsl:apply-templates mode="para" select="txt"/>
                <xsl:choose>
                    <xsl:when test="catgryGrp">
                        <table border="1" cellpadding="5" cellspacing="0" width="90%">
                            <xsl:apply-templates select="catgryGrp"/>
                        </table>
                    </xsl:when>
                    <xsl:when test="catgry">
                        <table border="1" cellpadding="5" cellspacing="0" width="90%">
                            <tr>
                                <th>
                                    <p>Value</p>
                                </th>
                                <th>
                                    <p>Label</p>
                                </th>
                                <th>
                                    <p>Frequency</p>
                                </th>
                                <th>
                                    <p>Text</p>
                                </th>
                            </tr>
                            <xsl:apply-templates mode="no-catgryGrp" select="catgry"/>
                        </table>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="catgry/catStat/table"/>
                <xsl:apply-templates select="imputation"/>
                <xsl:apply-templates select="security"/>
                <xsl:apply-templates select="embargo"/>
                <xsl:apply-templates select="respUnit"/>
                <xsl:apply-templates select="anlysUnit"/>
                <xsl:apply-templates select="valrng"/>
                <xsl:apply-templates select="invalrng"/>
                <xsl:apply-templates select="undocCod"/>
                <xsl:apply-templates mode="para" select="universe"/>
                <xsl:apply-templates select="TotlResp"/>

                <xsl:if test="sumStat">
                    <p>Summary Statistics: <xsl:apply-templates select="sumStat"/></p>
                </xsl:if>

                <xsl:apply-templates select="stdCatgry"/>
                <xsl:apply-templates select="codInstr"/>
                <xsl:apply-templates select="verStmt" mode="list2"/>
                <xsl:apply-templates select="concept"/>
                <xsl:apply-templates select="derivation"/>
                <xsl:apply-templates select="varFormat"/>
                <xsl:apply-templates select="geoMap"/>
                <xsl:apply-templates mode="para" select="notes"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="catgryGrp">

        <tr>
            <th align="left" colspan="4">
                <p>
                    <strong>
                        <xsl:apply-templates mode="no-format" select="labl"/>
                    </strong>
                    <xsl:apply-templates mode="no-format" select="txt"/>
                </p>
            </th>
        </tr>
        <tr>
            <th>
                <p>Value</p>
            </th>
            <th>
                <p>Label</p>
            </th>
            <th>
                <p>Frequency</p>
            </th>
            <th>
                <p>Text</p>
            </th>
        </tr>
        <xsl:apply-templates mode="group-list" select="../catgry">
            <xsl:with-param name="catgryGrp-token" select="@catgry"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="txt" mode="no-format"><xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if> - <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="catgry" mode="no-catgryGrp">
        <tr>
            <td>
                <xsl:apply-templates select="catValu"/>
            </td>
            <td>
                <p>
                    <xsl:apply-templates select="labl"/>
                </p>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="catStat/table">
                        <p>see table below</p>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="catStat"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <p>
                    <xsl:value-of select="txt"/>
                </p>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="catStat">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="catgry" mode="group-list">
        <xsl:param name="catgryGrp-token"/>
        <xsl:choose>
            <xsl:when test="contains($catgryGrp-token,concat(@ID,' '))">
                <tr>
                    <td>
                        <xsl:apply-templates select="catValu"/>
                    </td>
                    <td>
                        <p>
                            <xsl:apply-templates select="labl"/>

                        </p>
                    </td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="catStat/table">
                                <p>see table below</p>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="catStat"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                    <td>
                        <p>
                            <xsl:value-of select="txt"/>
                        </p>
                    </td>
                </tr>
            </xsl:when>
            <xsl:when
                test="contains($catgryGrp-token,@ID) and string-length(substring-after($catgryGrp-token,@ID))=0">
                <tr>
                    <td>
                        <xsl:apply-templates select="catValu"/>
                    </td>
                    <td>
                        <p>
                            <xsl:apply-templates select="labl"/>

                        </p>
                    </td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="catStat/table">
                                <p>see table below</p>
                            </xsl:when>
                            <xsl:otherwise>
                                <p>
                                    <xsl:apply-templates select="catStat"/>
                                </p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                    <td>
                        <p>
                            <xsl:value-of select="txt"/>
                        </p>
                    </td>
                </tr>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="catValu">

        <p>
            <xsl:apply-templates/>
            <xsl:if test="substring(catValu,string-length(catValu)-1,1)!='.'">.</xsl:if>
        </p>


    </xsl:template>

    <xsl:template match="location">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p class="small">
            <xsl:if test="@fileid">
                <xsl:value-of select="@fileid"/> </xsl:if>Location:</p>
        <p class="small">
            <xsl:if test="@StartPos"> Start: <xsl:value-of select="@StartPos"/>
                <br/>
            </xsl:if>
            <xsl:if test="@EndPos"> End: <xsl:value-of select="@EndPos"/>
                <br/>
            </xsl:if>
            <xsl:if test="@width"> Width: <xsl:value-of select="@width"/>
                <br/>
            </xsl:if>
            <xsl:if test="@RecSegNo"> Record Segment No. <xsl:value-of select="@RecSegNo"/>
                <br/>
            </xsl:if>
        </p>
    </xsl:template>
    <xsl:template match="imputation">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Imputation: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="security">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Security: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="embargo">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Embargo: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="respUnit">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Response Unit: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="anlysUnit">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Analysis Unit: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="qstn">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Question: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="preQTxt">
        <xsl:apply-templates/> </xsl:template>
    <xsl:template match="qstnLit">
        <xsl:apply-templates/> </xsl:template>
    <xsl:template match="postQTxt">
        <xsl:apply-templates/> </xsl:template>
    <xsl:template match="forward">
        <xsl:apply-templates/> </xsl:template>
    <xsl:template match="backward">
        <xsl:apply-templates/> </xsl:template>
    <xsl:template match="ivuInstr">
        <xsl:apply-templates/> </xsl:template>
    <xsl:template match="valrng">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Range of Valid Data Values: <xsl:apply-templates select="range"/>
            <xsl:apply-templates select="item"/>
            <xsl:apply-templates select="key"/>
            <xsl:apply-templates mode="no-format" select="notes"/>
        </p>
    </xsl:template>
    <xsl:template match="invalrng">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Range of Invalid Data Values: <xsl:apply-templates select="range"/>
            <xsl:apply-templates select="item"/>
            <xsl:apply-templates select="key"/>
            <xsl:apply-templates mode="no-format" select="notes"/>
        </p>
    </xsl:template>
    <xsl:template match="range">
        <xsl:value-of select="@min"/>-<xsl:value-of select="@max"/>
    </xsl:template>

    <xsl:template match="key">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="item">
        <xsl:value-of select="@VALUE"/>
    </xsl:template>

    <xsl:template match="undocCod">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>List of Undocumented Codes: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="universe" mode="para">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Universe: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="TotlResp">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Total Responses: <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template match="sumStat">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="@type='vald'">Valid <xsl:apply-templates/><xsl:if
                    test="position()!=last()">; </xsl:if></xsl:when>
            <xsl:when test="@type='min'">Min. <xsl:apply-templates/><xsl:if
                    test="position()!=last()">; </xsl:if></xsl:when>
            <xsl:when test="@type='max'">Max. <xsl:apply-templates/><xsl:if
                    test="position()!=last()">; </xsl:if></xsl:when>
            <xsl:when test="@type='mean'">Mean <xsl:apply-templates/><xsl:if
                    test="position()!=last()">; </xsl:if></xsl:when>
            <xsl:when test="@type='stdev'">StDev <xsl:apply-templates/><xsl:if
                    test="position()!=last()">; </xsl:if></xsl:when>
        </xsl:choose>

    </xsl:template>




    <xsl:template match="txt" mode="para">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Variable Text: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="stdCatgry">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Standard Categories: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="codInstr">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Coder Instructions: <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="verStmt" mode="list2">
        <ul>
            <xsl:apply-templates mode="list" select="version"/>
            <xsl:apply-templates mode="list" select="verResp"/>
            <xsl:apply-templates mode="list" select="notes"/>
        </ul>
    </xsl:template>

    <xsl:template match="concept">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Concept: <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="derivation">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Derivation</p>
        <ul>
            <xsl:apply-templates select="drvdesc"/>
            <xsl:apply-templates select="drvcmd"/>
        </ul>
    </xsl:template>
    <xsl:template match="drvdesc">
        <li><xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>Description: <xsl:value-of select="(.)"/>
        </li>
    </xsl:template>
    <xsl:template match="drvcmd">
        <li><xsl:if test="@ID">
                <a name="{@ID}"/>
            </xsl:if>Command: <xsl:value-of select="(.)"/>
        </li>
    </xsl:template>

    <xsl:template match="geoMap">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Geographic Map: <xsl:value-of select="@URI"/>
        </p>
    </xsl:template>


    <xsl:template match="varFormat">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <p>Variable Format: <xsl:value-of select="@type"/>
        </p>
    </xsl:template>

    <xsl:template match="otherMat">
        <tr>
            <th align="left" colspan="2">
                <p>
                    <xsl:if test="@ID">
                        <a name="{@ID}"/>
                    </xsl:if>
                    <a name="5.0">Other Study-Related Materials</a>
                </p>
            </th>
        </tr>
        <xsl:apply-templates mode="row" select="labl"/>
        <xsl:apply-templates mode="para2" select="txt"/>
        <xsl:apply-templates mode="row" select="notes"/>
        <xsl:apply-templates select="table"/>
        <xsl:apply-templates select="citation"/>
        <xsl:apply-templates select="otherMat"/>
    </xsl:template>
    <xsl:template match="labl" mode="row">
        <tr>
            <td align="right" valign="top">
                <xsl:if test="@ID">
                    <a name="{@ID}"/>
                </xsl:if>
                <p>Label:</p>
            </td>
            <td>
                <p>
                    <xsl:apply-templates/>
                </p>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="labl">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="txt" mode="para2">
        <tr>
            <td align="right" valign="top">
                <xsl:if test="@ID">
                    <a name="{@ID}"/>
                </xsl:if>
                <p>Text:</p>
            </td>
            <td>
                <p>
                    <xsl:apply-templates/>
                </p>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="table">
        <xsl:if test="@ID">
            <a name="{@ID}"/>
        </xsl:if>
        <table border="1" cellpadding="5" cellspacing="0" width="90%">
            <xsl:if test="titl">
                <caption>
                    <xsl:value-of select="titl"/>
                </caption>
            </xsl:if>
            <xsl:apply-templates select="tgroup"/>
        </table>
    </xsl:template>
    <xsl:template match="tgroup">
        <xsl:apply-templates select="thead"/>
        <xsl:apply-templates select="tbody"/>
    </xsl:template>
    <xsl:template match="thead">
        <xsl:apply-templates mode="thead" select="row"/>
    </xsl:template>
    <xsl:template match="row" mode="thead">
        <tr>
            <xsl:apply-templates mode="thead" select="entry"/>
        </tr>
    </xsl:template>
    <xsl:template match="entry" mode="thead">
        <th>
            <p>
                <xsl:apply-templates/>
            </p>
        </th>
    </xsl:template>
    <xsl:template match="tbody">
        <xsl:apply-templates mode="tbody" select="row"/>
    </xsl:template>
    <xsl:template match="row" mode="tbody">
        <tr>
            <xsl:apply-templates mode="tbody" select="entry"/>
        </tr>
    </xsl:template>
    <xsl:template match="entry" mode="tbody">
        <td>
            <p>
                <xsl:apply-templates/>
            </p>
        </td>
    </xsl:template>

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

    <xsl:template match="Link"> &#160;(<a href="#{@refs}">link</a>) </xsl:template>

    <xsl:template match="ExtLink"> (<a href="{@URI}">external link</a>) </xsl:template>

    <xsl:template match="p">

        <xsl:apply-templates/>

    </xsl:template>

    <xsl:template match="emph">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    
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
