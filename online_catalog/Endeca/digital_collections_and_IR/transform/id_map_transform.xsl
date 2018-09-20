<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
    
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>
 
    <xsl:template match="/">
        <idmappings>
            <xsl:apply-templates select="worldcatsyncdetails/addedrecords" />
            <xsl:apply-templates select="worldcatsyncdetails/replacedrecords" />
        </idmappings>
    </xsl:template>
    
    <xsl:template match="worldcatsyncdetails/addedrecords">
        <xsl:for-each select="record">
            <idmapping>
            <xsl:attribute name="etdid">
                <xsl:value-of select="reprecordid"/>
            </xsl:attribute>    
                <xsl:value-of select="oclcrecordnumber"/>
            </idmapping>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="worldcatsyncdetails/replacedrecords">
        <xsl:for-each select="record">
            <idmapping>
                <xsl:attribute name="etdid">
                    <xsl:value-of select="reprecordid"/>
                </xsl:attribute>    
                <xsl:value-of select="oclcrecordnumber"/>
            </idmapping>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>