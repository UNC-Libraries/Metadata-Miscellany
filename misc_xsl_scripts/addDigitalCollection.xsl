<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mods:mods">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
                <xsl:element name="mods:relatedItem">
                    <xsl:attribute name="type">
                        <xsl:text>host</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="displayLabel">
                        <xsl:text>Digital Collection</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="mods:titleInfo">
                        <xsl:element name="mods:title">
                            <xsl:text>Dwane Powell Collection</xsl:text>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>      
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>