<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:mods="http://www.loc.gov/mods/v3">
    
<xsl:template match="/">
filename,type,width,height,title
<xsl:for-each select="bulk/imageinfo">
<xsl:value-of select="filename"/>,<xsl:value-of select="type"/>,<xsl:value-of select="width"/>,<xsl:value-of select="height"/>,"<xsl:value-of select="title"/>"
</xsl:for-each>
</xsl:template>   

</xsl:stylesheet>