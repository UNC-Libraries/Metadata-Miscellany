<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
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
            <xsl:if test="not(mods:note[@displayLabel='Degree'])">
                <xsl:element name="mods:note">
                    <xsl:attribute name="displayLabel">
                        <xsl:text>Degree</xsl:text>
                    </xsl:attribute>
                    <xsl:text>MFA</xsl:text> 
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>