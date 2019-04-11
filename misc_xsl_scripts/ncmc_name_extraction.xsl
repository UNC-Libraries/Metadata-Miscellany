<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mods="http://www.loc.gov/mods/v3">
    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:for-each select="bulkMetadata/object/update/mods:mods">
            <xsl:for-each select="mods:name">
                <xsl:choose>
                    <xsl:when test="self::node()[@type='personal']">
                        <xsl:choose>
                            <xsl:when test="mods:namePart[@type='termsOfAddress']">
                                <xsl:value-of select="mods:namePart[@type='family']"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="mods:namePart[@type='given']"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="mods:namePart[@type='termsOfAddress']"/>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>personal</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:value-of select="mods:role/mods:roleTerm"/>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>UNCCH</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>CDR</xsl:text>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="mods:namePart[@type='family']"/>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="mods:namePart[@type='given']"/>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>personal</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:value-of select="mods:role/mods:roleTerm"/>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>UNCCH</xsl:text>
                                <xsl:text>&#x9;</xsl:text>
                                <xsl:text>CDR</xsl:text>
                                <xsl:text>&#xa;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="self::node()[@type='corporate']"> 
                        <xsl:value-of select="mods:namePart"/>
                        <xsl:text>&#x9;</xsl:text>
                        <xsl:text>corporate</xsl:text>
                        <xsl:text>&#x9;</xsl:text>
                        <xsl:text>&#x9;</xsl:text>
                        <xsl:value-of select="mods:role/mods:roleTerm"/>
                        <xsl:text>&#x9;</xsl:text>
                        <xsl:text>&#x9;</xsl:text>
                        <xsl:text>&#x9;</xsl:text>
                        <xsl:text>UNCCH</xsl:text>
                        <xsl:text>&#x9;</xsl:text>
                        <xsl:text>CDR</xsl:text>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
