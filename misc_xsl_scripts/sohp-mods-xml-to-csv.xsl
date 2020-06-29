<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mods="http://www.loc.gov/mods/v3">
    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:text>pid</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>title</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>identifier</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>Original Folder</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>Digital Folder Number</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>Accession Identifier</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>language</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>abstract</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>subject</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>extent-hours</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>extent</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>type of resource</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>corporate name</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>personal name</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>note-general</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>note-interview number</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>note-description</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>note-biographical/historical</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>related item</xsl:text>
        <xsl:text>&#x9;</xsl:text>
        <xsl:text>date created</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        
        
        <xsl:for-each select="bulkMetadata/object">
            <xsl:value-of select="./@pid"/>
            <xsl:text>&#x9;</xsl:text>
            <xsl:for-each select="update/mods">
                <xsl:value-of select="titleInfo/title"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="identifier[not(@displayLabel)]"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="identifier[@displayLabel='Original Folder']"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="identifier[@displayLabel='Digital Folder Number']"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="identifier[@displayLabel='Accession Identifier']"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="language/languageTerm"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="abstract"/>
                <xsl:text>"</xsl:text>
                <xsl:text>&#x9;</xsl:text>
                <xsl:for-each select="subject/topic">
                    <xsl:value-of select="."/>
                    <xsl:text>; </xsl:text>
                </xsl:for-each>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="physicalDescription/extent[@unit='hours']"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="physicalDescription/extent[not(@unit='hours')]"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="typeOfResource"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:for-each select="name[@type='corporate']/namePart">
                    <xsl:value-of select="."/>
                    <xsl:if test="../role/roleTerm">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="../role/roleTerm"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:text>&#x9;</xsl:text>
                <xsl:for-each select="name[@type='personal']">
                    <xsl:if test="namePart[not(@type)]">
                        <xsl:value-of select="namePart"/>
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="namePart[@type='family']">
                        <xsl:value-of select="namePart[@type='family']"/>
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="namePart[@type='given']">
                        <xsl:value-of select="namePart[@type='given']"/>
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="namePart[@type='termsOfAddress']">
                        <xsl:value-of select="namePart[@type='termsOfAddress']"/>
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="namePart[@type='date']">
                        <xsl:value-of select="namePart[@type='date']"/>
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="description">
                        <xsl:text>(</xsl:text>
                        <xsl:value-of select="description"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="role/roleTerm">
                        <xsl:text>(</xsl:text>
                        <xsl:value-of select="role/roleTerm"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:text>| </xsl:text>
                </xsl:for-each>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="note[not(@displayLabel) and not(@type)]"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="note[@displayLabel='Interview Number']"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="note[@displayLabel='Description']"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="note[@type='biographical/historical']"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="relatedItem/location/url"/>
                <xsl:text>&#x9;</xsl:text>
                <xsl:value-of select="originInfo/dateCreated"/>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each>
        
    </xsl:template>
</xsl:stylesheet>
