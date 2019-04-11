<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>
    
    <xsl:key name="object" match="object" use="@*" />
    
    <xsl:template match="/bulkMetadata">
        <xsl:copy>
            <xsl:copy-of select="object[not(key('object', @*, document('path-to-just-parents.xml')))]"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>