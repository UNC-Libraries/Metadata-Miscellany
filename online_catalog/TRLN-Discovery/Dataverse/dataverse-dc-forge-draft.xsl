<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version=".0">
    <xsl:output method="text" indent="no"/>

<!-- set up variable for later use -->
    <xsl:variable name="vLower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="vUpper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>

<!-- match each record -->
    <xsl:template match="/">
        <xsl:apply-templates select="*[local-name()='OAI-PMH']"/>
    </xsl:template>

    <xsl:template match="*[local-name()='OAI-PMH']">
        <xsl:apply-templates select="*[local-name()='ListRecords']"/>
    </xsl:template>

    <xsl:template match="*[local-name()='ListRecords']">
                <xsl:apply-templates select="*[local-name()='record']"/>
    </xsl:template>

    <xsl:template match="*[local-name()='record']">

        <xsl:variable name="setSpec">
            <xsl:value-of select="*[local-name()='header']/*[local-name()='identifier']"/>
        </xsl:variable>

        <xsl:variable name="rights">
            <xsl:for-each
                select="*[local-name()='metadata']/*[local-name()='dc']/*[local-name()='rights']">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="status" select="*[local-name()='header']/@status"/>

        <xsl:choose>
            <!-- Filters out deleted records -->
            <xsl:when test="contains($status,'deleted')"/>
            <!-- Filters out CDs -->
            <xsl:when test="contains($setSpec,'CD')"/>
            <!-- Filters out DVDs -->
            <xsl:when test="contains($setSpec,'DVD')"/>
            <!-- Filters out DVDs, by examining the third rights element -->
            <xsl:when test="contains($rights,'These data are provided on either CD-ROM or DVD')"/>

            <xsl:otherwise>
{                    <xsl:apply-templates select="*[local-name()='header']">
                        <xsl:with-param name="setSpec">
                            <xsl:value-of select="$setSpec"/>
                        </xsl:with-param>

                    </xsl:apply-templates>
                    <xsl:apply-templates select="*[local-name()='metadata']">
                        <xsl:with-param name="setSpec">
                            <xsl:value-of select="$setSpec"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
}</xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="*[local-name()='header']">
        <xsl:param name="setSpec"/>


        <xsl:apply-templates select="*[local-name()='identifier']" mode="header">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="*[local-name()='datestamp']"/>

    </xsl:template>

<!-- matches/creates fields from header and creates constant fields -->
    
    <xsl:template match="*[local-name()='identifier']" mode="header">
        <xsl:param name="setSpec"/>
        <!-- The next sequence strips punctuation from the identifier -->
        <xsl:variable name="slash">
            <xsl:text>/</xsl:text>
        </xsl:variable>
        <xsl:variable name="null">
            <xsl:text/>
        </xsl:variable>
        <xsl:variable name="period">
            <xsl:text>.</xsl:text>
        </xsl:variable>
        <xsl:variable name="dash">
            <xsl:text>-</xsl:text>
        </xsl:variable>
        <xsl:variable name="colon">
            <xsl:text>:</xsl:text>
        </xsl:variable>

        <xsl:variable name="removeSlash">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="."/>
                <xsl:with-param name="replace" select="$slash"/>
                <xsl:with-param name="by" select="$null"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="removePeriod">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$removeSlash"/>
                <xsl:with-param name="replace" select="$period"/>
                <xsl:with-param name="by" select="$null"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="removeDash">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$removePeriod"/>
                <xsl:with-param name="replace" select="$dash"/>
                <xsl:with-param name="by" select="$null"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="UniqueId">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$removeDash"/>
                <xsl:with-param name="replace" select="$colon"/>
                <xsl:with-param name="by" select="$null"/>
            </xsl:call-template>
        </xsl:variable>
    "id": "<xsl:text>UNCDataverse</xsl:text><xsl:value-of select="$UniqueId"/>",
    "rollup_id": "<xsl:text>Dataverse</xsl:text><xsl:value-of select="$UniqueId"/>",
    "local_id": {
        "other": [],
        "value": "<xsl:text>Dataverse</xsl:text><xsl:value-of select="$UniqueId"/>"
    },
    "resource_type": ["Dataset – Statistical"],
    "access_type": ["Online"],
    "physical_media": ["Online"],    
    "institution": ["unc", "duke", "nccu", "ncsu"],
    "owner": "unc",
    "record_data_source":["Shared Records", "Dataverse"],
    "virtual_collection":[
        "TRLN Shared Records. Odum Institute Dataverse."
    ],
    "language":[
        "English"
    ],</xsl:template>


    <xsl:template match="*[local-name()='datestamp']">
    "date_cataloged": [
        "<xsl:value-of select="substring(.,1,10)"/>T05:00:00Z"
    ],</xsl:template>

<!-- matches/creates fields from metadata/dc -->
    <xsl:template match="*[local-name()='metadata']">
        <xsl:param name="setSpec"/>

        <xsl:apply-templates select="*[local-name()='dc']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        <xsl:apply-templates select="*[local-name()='dc']" mode="generalnotes"/>
    </xsl:template>


    <xsl:template match="*[local-name()='dc']">
        <xsl:param name="setSpec"/>

        <xsl:apply-templates select="*[local-name()='title']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="*[local-name()='type']"/>
    "names":[<xsl:for-each select="*[local-name()='creator']">
        <xsl:apply-templates select="(.)">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        <xsl:if test="position() != last()">,</xsl:if>
        </xsl:for-each>
    ],<xsl:apply-templates select="*[local-name()='identifier']" mode="qualifieddc">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="*[local-name()='publisher']" mode="imprint"/>

        <xsl:apply-templates select="*[local-name()='date']"/>

        <xsl:apply-templates select="*[local-name()='publisher']" mode="publisher"/>
    "subject_topical":[
        <xsl:for-each select="*[local-name()='subject']">
        <xsl:apply-templates select="(.)"/>
        <xsl:if test="position() != last()">,
        </xsl:if>
    </xsl:for-each>
    ],
    "subject_headings":[<xsl:for-each select="*[local-name()='subject']">
        {
            "value":<xsl:apply-templates select="(.)"/>
        }<xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:for-each>
    ],<xsl:apply-templates select="*[local-name()='coverage']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="*[local-name()='description']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
    "available": "Available",</xsl:template>

<!-- title field -->
    <xsl:template match="*[local-name()='title']">
        <xsl:param name="setSpec"/>
    "title_main":[
        {
        "value": "<xsl:value-of select="normalize-space(.)"/>"
        }
    ],
    "title_sort": "<xsl:value-of select="normalize-space(.)"/>",</xsl:template>

<!-- genre field -->
    <xsl:template match="*[local-name()='type']">

        <xsl:call-template name="parseGenre">
            <xsl:with-param name="list" select="."/>
        </xsl:call-template>

    </xsl:template>


    <xsl:template name="parseGenre">
        <xsl:param name="list"/>
        <xsl:param name="pvalName"/>

        <xsl:choose>

            <xsl:when test="contains($list, ',')">
                <xsl:call-template name="writeGenre">
                    <xsl:with-param name="string" select="substring-before($list, ',')"/>
                    <xsl:with-param name="pvalName">
                        <xsl:value-of select="$pvalName"/>
                    </xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="parseGenre">
                    <xsl:with-param name="list" select="substring-after($list, ',')"/>
                    <xsl:with-param name="pvalName">
                        <xsl:value-of select="$pvalName"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="writeGenre">
                    <xsl:with-param name="string" select="$list"/>
                    <xsl:with-param name="pvalName">
                        <xsl:value-of select="$pvalName"/>
                    </xsl:with-param>
                </xsl:call-template>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template name="writeGenre">
        <xsl:param name="string"/>
        <xsl:param name="pvalName"/>
    "subject_genre":[
        "<xsl:value-of select="normalize-space($string)"/>"
    ],</xsl:template>

<!-- creator field -->
    <xsl:template match="*[local-name()='creator']">
        <xsl:param name="setSpec"/>
        {
            "name": "<xsl:value-of select="normalize-space(.)"/>",
            "type": "creator",
            "rel": ["creator"]
        }</xsl:template>

<!-- url field -->
    <xsl:template match="*[local-name()='identifier']" mode="qualifieddc">
        <xsl:param name="setSpec"/>
    "url": [
        "{\"href\":\"<xsl:value-of select="normalize-space(.)"/>\"}"
    ],</xsl:template>
    
    <xsl:template match="*[local-name()='relation']"/>

<!-- publication year field -->
    <xsl:template match="*[local-name()='date']">
        <xsl:param name="setSpec"/>
        <xsl:choose>
            <xsl:when test="contains((.),'-')" >
    "publication_year":[
        <xsl:value-of select="substring-before((normalize-space(.)),'-')"/>
    ],</xsl:when><xsl:otherwise>
    "publication_year":[ 
        <xsl:value-of select="normalize-space(.)"/>
    ],</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- publisher field -->
    <xsl:template match="*[local-name()='publisher']" mode="publisher">
        <xsl:param name="setSpec"/>
    "publisher":[
        "<xsl:value-of select="normalize-space(.)"/>"
    ],</xsl:template>

<!-- imprint field -->
    <xsl:template match="*[local-name()='publisher']" mode="imprint">
        <xsl:param name="setSpec"/>
        
        <xsl:variable name="imprintDate">
            <xsl:for-each
                select="../*[local-name()='date']">
                <xsl:choose>
                    <xsl:when test="contains((.),'-')" >
                        <xsl:value-of select="substring-before((normalize-space(.)),'-')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>       
    "imprint_main": [
        "{\"type\": \"publication\",\"value\": \"<xsl:value-of select="normalize-space(.)"/>, <xsl:value-of select="$imprintDate"/>\"}"
    ],</xsl:template>
    

<!-- subject fields -->
    <xsl:template match="*[local-name()='subject']">

        <xsl:call-template name="parseSubject">
            <xsl:with-param name="list" select="."/>
        </xsl:call-template>
        
    </xsl:template>


    <xsl:template name="parseSubject">
        <xsl:param name="list"/>

        <xsl:choose>
            <xsl:when test="contains($list, ';')">
                <xsl:call-template name="writeSubjects">
                    <xsl:with-param name="subject"
                        select="substring-before(normalize-space($list), ';')"/>
                </xsl:call-template>

                <xsl:call-template name="parseSubject">
                    <xsl:with-param name="list" select="substring-after($list, ';')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="writeSubjects">
                    <xsl:with-param name="subject" select="normalize-space($list)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template name="writeSubjects">
        <xsl:param name="subject"/>
        <xsl:variable name="length" select="string-length($subject)"/>

        <xsl:variable name="lastchar" select="substring($subject, $length)"/>

        <xsl:variable name="newSubject">
            <xsl:choose>
                <xsl:when test="$lastchar = '.'">
                    <xsl:value-of select="concat(translate(substring($subject, '0', $length),$vLower, $vUpper),
                        substring($subject, 2))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="concat(translate(substring($subject,1,1), $vLower, $vUpper),
                        substring($subject, 2))"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="doubledash">
            <xsl:text>--</xsl:text>
        </xsl:variable>
        <xsl:variable name="doubledashspace">
            <xsl:text> -- </xsl:text>
        </xsl:variable>"<xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="$newSubject"/>
                    <xsl:with-param name="replace" select="$doubledash"/>
                    <xsl:with-param name="by" select="$doubledashspace"/>
        </xsl:call-template>"</xsl:template>

<!-- subject_geographic field -->
    <xsl:template match="*[local-name()='coverage']">
        <xsl:param name="setSpec"/>
        <xsl:variable name="text" select="normalize-space(text())"/>

        <xsl:choose>

            <xsl:when test="starts-with($text,'Country')">

                <xsl:variable name="startText">
                    <xsl:text>Country/Nation: </xsl:text>
                </xsl:variable>
                <xsl:variable name="null">
                    <xsl:text/>
                </xsl:variable>

                <xsl:variable name="Coverage">
                    <xsl:call-template name="string-replace-all">
                        <xsl:with-param name="text" select="$text"/>
                        <xsl:with-param name="replace" select="$startText"/>
                        <xsl:with-param name="by" select="$null"/>
                    </xsl:call-template>
                </xsl:variable>
    "subject_geographic": "<xsl:value-of select="normalize-space($Coverage)"/>",</xsl:when>

        </xsl:choose>

    </xsl:template>

<!-- summary field -->
    <xsl:template match="*[local-name()='description']">
        <xsl:variable name="setSpec"/>
        <xsl:variable name="cite" select="text()"/>
        <xsl:variable name="description">
            <xsl:call-template name="jsonescape"></xsl:call-template>
        </xsl:variable>
        <xsl:variable name="description-nomarkup">
            <xsl:call-template name="remove-markup">
                <xsl:with-param name="string" select = "$description" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <!-- Filters out preferred citation elements into the note field -->
            <xsl:when test="not(starts-with($cite,'Citation'))">
    "note_summary":[
        "<xsl:value-of select="$description-nomarkup"/>"
    ],</xsl:when>
        </xsl:choose>
    </xsl:template>

<!-- general notes -->
    <xsl:template match="*[local-name()='dc']" mode="generalnotes">
    "note_general":[<xsl:for-each select="*[local-name()='description']">
            <xsl:variable name="cite" select="text()"/>
            <xsl:variable name="description">
                <xsl:call-template name="jsonescape"></xsl:call-template>
            </xsl:variable>
                <!-- Filters out preferred citation elements into the note field -->
                <xsl:if test="starts-with($cite,'Citation')">
        {
            "value": "<xsl:value-of select="normalize-space($description)"/>"
        },</xsl:if>
        </xsl:for-each>
        <xsl:for-each select="*[local-name()='rights']">
            <xsl:variable name="rights">
                <xsl:call-template name="jsonescape"></xsl:call-template>
            </xsl:variable>
            <xsl:variable name="rights-nomarkup">
                <xsl:call-template name="remove-markup">
                    <xsl:with-param name="string" select = "$rights" />
                </xsl:call-template>
            </xsl:variable>
        {
            "value": "<xsl:value-of select="normalize-space($rights-nomarkup)"/>"
        },</xsl:for-each>
        <xsl:for-each select="*[local-name()='coverage']">
            <xsl:variable name="text" select="text()"/>
            <xsl:choose>
            <xsl:when test="starts-with($text,'Time Period')">
        {
            "value": "<xsl:value-of select="normalize-space($text)"/>"
        },</xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:for-each select="*[local-name()='coverage']">
            <xsl:variable name="text" select="text()"/>
            <xsl:choose>
                <xsl:when test="starts-with($text,'Geographic Coverage')">
        {
            "value": "<xsl:value-of select="normalize-space(.)"/>"
        },</xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <xsl:call-template name="Conditions"/>
    ]</xsl:template>
    
<!-- choose condition displayed based on rights fields -->
    <xsl:template name="Conditions">
        <xsl:variable name="allRights">
            <xsl:for-each select="*[local-name()='rights']">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($allRights,'UNC faculty')">
        {
            "value": "Conditions: restricted unc"
        }</xsl:when>
            <xsl:when test="contains($allRights,'Duke faculty')">
        {
            "value": "Conditions: restricted duke"
        }</xsl:when>
            <xsl:otherwise>
        {
            "value": "Conditions: unrestricted"
        }</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- template to escape reserved JSON characters -->
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
                <xsl:call-template name="remove-markup"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- template to remove html tags -->
    <xsl:template name="remove-markup">
        <xsl:param name="string"/> 
        <xsl:choose>
            <xsl:when test="contains($string, '&lt;')">
                <xsl:value-of select="substring-before($string, '&lt;')" />
                <xsl:call-template name="remove-markup">
                    <xsl:with-param name="string" select="substring-after($string, '&gt;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- formatting template -->
    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
