<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:unc="http://yourdomain.com/lookup" extension-element-prefixes="unc" version="1.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="vLower" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="vUpper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>


    <xsl:template match="/">
        <xsl:apply-templates select="*[local-name()='OAI-PMH']"/>
    </xsl:template>

    <xsl:template match="*[local-name()='OAI-PMH']">
        <xsl:apply-templates select="*[local-name()='ListRecords']"/>
    </xsl:template>

    <xsl:template match="*[local-name()='ListRecords']">
        <xml>
            <RECORDS>
                <xsl:apply-templates select="*[local-name()='record']"/>
            </RECORDS>
        </xml>
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
	    <!-- Filters out records available only to Duke, by examining rights elements
	       <xsl:when test="contains($rights,'Duke faculty, staff, and students only.')"/>
	    -->

            <xsl:otherwise>
                <RECORD>

                    <xsl:apply-templates select="*[local-name()='header']">
                        <xsl:with-param name="setSpec">
                            <xsl:value-of select="$setSpec"/>
                        </xsl:with-param>

                    </xsl:apply-templates>
                    <xsl:apply-templates select="*[local-name()='metadata']">
                        <xsl:with-param name="setSpec">
                            <xsl:value-of select="$setSpec"/>
                        </xsl:with-param>
                    </xsl:apply-templates>

                </RECORD>
            </xsl:otherwise>
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

        <PROP NAME="UniqueId">
            <PVAL>
                <xsl:text>Dataverse</xsl:text>
                <xsl:value-of select="$UniqueId"/>
            </PVAL>
        </PROP>
        <PROP NAME="Rollup">
            <PVAL>
                <xsl:text>Dataverse</xsl:text>
                <xsl:value-of select="$UniqueId"/>
            </PVAL>
        </PROP>
        <PROP NAME="LocalId">
            <PVAL>
                <xsl:text>Dataverse</xsl:text>
                <xsl:value-of select="$UniqueId"/>
            </PVAL>
        </PROP>

        <PROP NAME="Item Types">
            <PVAL>
                <xsl:text>Dataset</xsl:text>
            </PVAL>
        </PROP>

        <PROP NAME="Language">
            <PVAL>English</PVAL>
        </PROP>

    </xsl:template>



    <xsl:template match="*[local-name()='datestamp']">
        <xsl:variable name="dash">
            <xsl:text>-</xsl:text>
        </xsl:variable>
        <xsl:variable name="null">
            <xsl:text/>
        </xsl:variable>

        <xsl:variable name="dateCataloged">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="."/>
                <xsl:with-param name="replace" select="$dash"/>
                <xsl:with-param name="by" select="$null"/>
            </xsl:call-template>
        </xsl:variable>

        <PROP NAME="DateCataloged">
            <PVAL>
                <xsl:value-of select="substring($dateCataloged,1,8)"/>
            </PVAL>
        </PROP>
        <PROP NAME="909">
            <PVAL>
                <xsl:value-of select="substring($dateCataloged,1,8)"/>
            </PVAL>
        </PROP>


    </xsl:template>


    <xsl:template match="*[local-name()='metadata']">
        <xsl:param name="setSpec"/>

        <xsl:apply-templates select="*[local-name()='dc']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="*[local-name()='dc']">
        <xsl:param name="setSpec"/>

        <xsl:call-template name="Conditions"/>

        <xsl:apply-templates select="*[local-name()='title']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="*[local-name()='type']"/>

        <xsl:apply-templates select="*[local-name()='creator']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="*[local-name()='rights']"/>

        <xsl:apply-templates select="*[local-name()='identifier']" mode="qualifieddc">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="*[local-name()='date']"/>

        <xsl:apply-templates select="*[local-name()='publisher']"/>

        <xsl:apply-templates select="*[local-name()='subject']"/>

        <xsl:apply-templates select="*[local-name()='coverage']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="*[local-name()='description']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>

    </xsl:template>


    <xsl:template name="Conditions">

        <xsl:variable name="allRights">
            <xsl:for-each select="*[local-name()='rights']">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="contains($allRights,'UNC faculty')">
                <PROP NAME="Conditions">
                    <PVAL>restrictedunc</PVAL>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($allRights,'Duke faculty')">
                <PROP NAME="Conditions">
                    <PVAL>restrictedduke</PVAL>
                </PROP>
            </xsl:when>
            <xsl:otherwise>
                <PROP NAME="Conditions">
                    <PVAL>unrestricted</PVAL>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="*[local-name()='title']">
        <xsl:param name="setSpec"/>

        <PROP NAME="Title">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
        <PROP NAME="245sort">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>

    </xsl:template>


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
        <PROP NAME="Genre">
            <PVAL>
                <xsl:value-of select="normalize-space($string)"/>
            </PVAL>
        </PROP>
    </xsl:template>


    <xsl:template match="*[local-name()='creator']">
        <xsl:param name="setSpec"/>
        <PROP NAME="Creator">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>


    <xsl:template match="*[local-name()='rights']">
        <PROP NAME="Rights">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>


    <xsl:template match="*[local-name()='identifier']" mode="qualifieddc">
        <xsl:param name="setSpec"/>

        <PROP NAME="PrimaryURL">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>


    <xsl:template match="*[local-name()='relation']"/>


    <xsl:template match="*[local-name()='date']">
        <xsl:param name="setSpec"/>

        <PROP NAME="YearPublished">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>

        <PROP NAME="DatePublished">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>


    <xsl:template match="*[local-name()='publisher']">
        <xsl:param name="setSpec"/>

        <PROP NAME="Publisher">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>


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
        </xsl:variable>

        <PROP NAME="Subject">
            <PVAL>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="$newSubject"/>
                    <xsl:with-param name="replace" select="$doubledash"/>
                    <xsl:with-param name="by" select="$doubledashspace"/>
                </xsl:call-template>
            </PVAL>
        </PROP>

        <PROP NAME="Subjects">
            <PVAL>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="$newSubject"/>
                    <xsl:with-param name="replace" select="$doubledash"/>
                    <xsl:with-param name="by" select="$doubledashspace"/>
                </xsl:call-template>
            </PVAL>
        </PROP>

    </xsl:template>


    <xsl:template match="*[local-name()='coverage']">
        <xsl:param name="setSpec"/>
        <xsl:variable name="text" select="text()"/>

        <xsl:choose>

            <xsl:when test="starts-with($text,'Geographic Coverage')">

                <PROP NAME="CoverageSpatial">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>

            </xsl:when>

            <xsl:when test="starts-with($text,'Time Period')">

                <xsl:variable name="startText">
                    <xsl:text>Time Period Covered: </xsl:text>
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

                <PROP NAME="CoverageTemporal">
                    <PVAL>
                        <xsl:value-of select="normalize-space($Coverage)"/>
                    </PVAL>
                </PROP>
            </xsl:when>

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

                <PROP NAME="Spatial">
                    <PVAL>
                        <xsl:value-of select="normalize-space($Coverage)"/>
                    </PVAL>
                </PROP>
            </xsl:when>

            <xsl:otherwise>
                <PROP NAME="Notes">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>
            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>


    <xsl:template match="*[local-name()='description']">
        <xsl:variable name="setSpec"/>
        <xsl:variable name="cite" select="text()"/>

        <xsl:choose>
            <!-- Filters out preferred citation elements into the note field -->
            <xsl:when test="starts-with($cite,'Citation')">
                <PROP NAME="Notes">
                    <PVAL>
                        <xsl:value-of select="."/>
                    </PVAL>
                </PROP>
            </xsl:when>

            <xsl:otherwise>
                <PROP NAME="Abstract">
                    <PVAL>
                        <xsl:value-of select="."/>
                    </PVAL>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


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


    <xsl:template name="parseDelimitedField">
        <xsl:param name="list"/>
        <xsl:param name="pvalName"/>

        <xsl:choose>

            <xsl:when test="contains($list, ';')">
                <xsl:call-template name="writeDelimitedField">
                    <xsl:with-param name="string" select="substring-before($list, ';')"/>
                    <xsl:with-param name="pvalName">
                        <xsl:value-of select="$pvalName"/>
                    </xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="parseDelimitedField">
                    <xsl:with-param name="list" select="substring-after($list, ';')"/>
                    <xsl:with-param name="pvalName">
                        <xsl:value-of select="$pvalName"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="writeDelimitedField">
                    <xsl:with-param name="string" select="$list"/>
                    <xsl:with-param name="pvalName">
                        <xsl:value-of select="$pvalName"/>
                    </xsl:with-param>
                </xsl:call-template>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template name="writeDelimitedField">
        <xsl:param name="string"/>
        <xsl:param name="pvalName"/>
        <xsl:variable name="propertyName" select="$pvalName"/>
        <PROP NAME="{$propertyName}">
            <PVAL>

                <xsl:value-of select="normalize-space($string)"/>
            </PVAL>
        </PROP>
    </xsl:template>


</xsl:stylesheet>
