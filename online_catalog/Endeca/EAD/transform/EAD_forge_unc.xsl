<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Forge xsl for UNC 
  Sets EAD ID property from eadfilename element instead of eadid
     eadfilename element is added to each XML file by copy_EAD.sh
  Includes sequence to remove the -z from EAD IDs
  Sets Primary Source property if EAD ID does not begin with "nps"
  These are the only differences between this forge xsl and EAD_forge.xsl
-->

    <xsl:variable name="UnitTitles"/>
    <xsl:variable name="ScopeContents"/>
    


    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="*[local-name()='ead']">
        <xml>
            <RECORDS>
                <RECORD>
                    <xsl:apply-templates select="//*[local-name()='eadheader']"/>
                    <xsl:apply-templates select="//*[local-name()='archdesc']"/>                  
                </RECORD>
            </RECORDS>
        </xml>


    </xsl:template>


    <xsl:template match="*[local-name()='eadheader']">
        <xsl:apply-templates select="*[local-name()='eadfilename']"/>
        <xsl:apply-templates select="*[local-name()='filedesc']" mode="eadheader"/>
    </xsl:template>
    

    <xsl:template match="*[local-name()='archdesc']">
        <xsl:apply-templates select="*[local-name()='bioghist']"/>
        <xsl:apply-templates select="*[local-name()='did']" mode="archdesc"/>
        <xsl:apply-templates select="*[local-name()='scopecontent']" mode="archdesc"/>
        <xsl:apply-templates select="*[local-name()='arrangement']" mode="archdesc"/>
        <xsl:apply-templates select="*[local-name()='descgrp']"/>
        <xsl:apply-templates select="*[local-name()='dsc']"/>
        <xsl:apply-templates select="*[local-name()='accessrestrict']"/>
        <xsl:apply-templates select="*[local-name()='userestrict']"/>
        <xsl:apply-templates select="*[local-name()='acqinfo']"/>
        <xsl:apply-templates select="*[local-name()='prefercite']"/>
    
    </xsl:template>

   <!-- <xsl:template match="*[local-name()='eadid']">
        <xsl:variable name="theid">
            <xsl:value-of select="."/>
        </xsl:variable>
        
        <PROP NAME="Source">
            <PVAL>EAD</PVAL>
        </PROP>
        <PROP NAME="EAD ID">
            <PVAL>
                <!-\- Remove -z if it is present in UNC eadid /-\->
                <xsl:value-of select="normalize-space(translate(., '-z', ''))"/>
            </PVAL>
        </PROP>
        
        <xsl:if test="not(starts-with($theid, 'nps'))">
            <PROP NAME="Primary Source">
                <PVAL>Primary Source</PVAL>
            </PROP>
        </xsl:if>
    </xsl:template>-->

    <xsl:template match="*[local-name()='eadfilename']">
        <xsl:variable name="thefilename">
            <xsl:value-of select="."/>
        </xsl:variable>
        
        <PROP NAME="Source">
            <PVAL>EAD</PVAL>
        </PROP>
        <PROP NAME="EAD ID">
            <PVAL>
                <xsl:value-of select="."/>
            </PVAL>
        </PROP>
        
        <xsl:if test="not(starts-with($thefilename, 'nps'))">
            <PROP NAME="Primary Source">
                <PVAL>Primary Source</PVAL>
            </PROP>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[local-name()='bioghist']">
        <PROP NAME="EAD Biographical History">
            <PVAL>
                <xsl:apply-templates select="*[local-name()='p']"/>

            </PVAL>
        </PROP>
    </xsl:template>

    <xsl:template match="*[local-name()='did']" mode="archdesc">
        <xsl:apply-templates select="*[local-name()='abstract']" mode="archdesc"/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='abstract']" mode="archdesc">
        <PROP NAME="EAD Abstract">
            <PVAL>
                <xsl:apply-templates/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='scopecontent']" mode="archdesc">

                <xsl:apply-templates select="*[local-name()='p']" mode="scopecontent"/>
        <!-- this picks up the arrangement if it is embedded in scopecontent -->
        <xsl:apply-templates select="*[local-name()='arrangement']" mode="archdesc"/>
    </xsl:template>

    <xsl:template match="*[local-name()='arrangement']" mode="archdesc">
        <PROP NAME="EAD Arrangement">
            <PVAL>
                <xsl:apply-templates/>
            </PVAL>
        </PROP>
    </xsl:template>
    


    <xsl:template match="*[local-name()='descgrp']">
        <xsl:apply-templates select="*[local-name()='accessrestrict']"/>
        <xsl:apply-templates select="*[local-name()='userestrict']"/>
        <xsl:apply-templates select="*[local-name()='acqinfo']"/>
        <xsl:apply-templates select="*[local-name()='prefercite']"/>
    </xsl:template>

    <xsl:template match="*[local-name()='acqinfo']">
        <PROP NAME="EAD Acquisitions Info">
            <PVAL>
                <xsl:apply-templates select="*[local-name()='p']"/>

            </PVAL>
        </PROP>
    </xsl:template>

    <xsl:template match="*[local-name()='prefercite']">
        <PROP NAME="EAD Preferred Citation">
            <PVAL>
                <xsl:apply-templates select="*[local-name()='p']"/>

            </PVAL>
        </PROP>
    </xsl:template>


    <xsl:template match="*[local-name()='accessrestrict']">
        <PROP NAME="EAD Access Restrictions">
            <PVAL>
                <xsl:apply-templates select="*[local-name()='p']"/>

            </PVAL>
        </PROP>
    </xsl:template>

    <xsl:template match="*[local-name()='userestrict']">
        <PROP NAME="EAD Use Restrictions">
            <PVAL>
                <xsl:apply-templates select="*[local-name()='p']"/>
            </PVAL>
        </PROP>
    </xsl:template>






    <xsl:template match="*[local-name()='filedesc']" mode="eadheader">
        <xsl:apply-templates select="*[local-name()='titlestmt']" mode="eadheader"/>
    </xsl:template>

    <xsl:template match="*[local-name()='titlestmt']" mode="eadheader">
        <xsl:apply-templates select="*[local-name()='sponsor']" mode="eadheader"/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='sponsor']" mode="eadheader">     
        <xsl:variable name="sponsor">
            <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($sponsor,'Content, Context, and Capacity')">
                <PROP NAME="EAD Collection">
                    <PVAL>                
                        <xsl:text>CCC</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:otherwise>
                <PROP NAME="EAD Collection">
                    <PVAL>                
                        <xsl:text>FindingAid</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>        


    <!--miscellaneous templates-->
    <xsl:template match="*[local-name()='p']">
        <xsl:apply-templates select="*[local-name()='title']"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template match="*[local-name()='title']">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>


    <xsl:template match="*[local-name()='p']" mode="scopecontent">
        <PROP NAME="EAD Overview">
            <PVAL>                
        <xsl:apply-templates/>
            </PVAL>
        </PROP>
        
    </xsl:template>
    



    <!-- Generating dsc content here.  
        Choose evaluates for three conditions:
        when dsc type = analyticover, it does nothing
        when dsc type = combined, call the dscContent template
        otherwise there is no type attribute so call the dscContent template
        NCSU's data do not have a type attribute  
    -->
    
    <xsl:template match="*[local-name()='dsc']">
        <xsl:choose>
            <xsl:when test="@type = 'analyticover'"/>
            
            <xsl:when test="@type = 'combined'">
                <xsl:call-template name="dscContent"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="dscContent"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- template used to generate dscContent -->
    <xsl:template name="dscContent">

        <xsl:variable name="UnitTitles">

            <xsl:for-each select="*">
                <xsl:text> ,</xsl:text>
                <xsl:apply-templates select="./descendant::*[local-name()='unittitle']" xml:space="preserve" mode="dsc"/>
                <xsl:text>, </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <PROP NAME="EAD Unit Title">
            <PVAL>
                <xsl:value-of select="normalize-space($UnitTitles)"/>
            </PVAL>
        </PROP>
        <xsl:variable name="ScopeContents">
            <xsl:for-each select="*">
                <xsl:text> ,</xsl:text>
                <xsl:apply-templates select="./descendant::*[local-name()='scopecontent']" xml:space="preserve" mode="dsc"/>
                <xsl:text>, </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <PROP NAME="EAD Scope Content">
            <PVAL>
                <xsl:value-of select="normalize-space($ScopeContents)"/>
            </PVAL>
        </PROP>
    </xsl:template>


    <!-- the extra commas are inserted to ensure separation between terms in the index, 
        commas are stripped by Endeca -->
    <xsl:template match="*[local-name()='unittitle']" mode="dsc">
        <xsl:text>, </xsl:text>
        <xsl:apply-templates mode="dsc"/>
        <xsl:text>, </xsl:text>
    </xsl:template>
    
    
    <!-- the extra commas are inserted to ensure separation between terms in the index, 
        commas are stripped by Endeca -->
    <xsl:template match="*[local-name()='scopecontent']" mode="dsc">
        <xsl:text> ,</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>, </xsl:text>
    </xsl:template>
    
    <!-- the extra commas are inserted to ensure separation between terms in the index, 
        commas are stripped by Endeca -->
    <xsl:template match="*[local-name()='unitdate']" mode="dsc">
        <xsl:text> ,</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>, </xsl:text>
    </xsl:template>
    
    <!-- the extra commas are inserted to ensure separation between terms in the index, 
        commas are stripped by Endeca -->
    <xsl:template match="*[local-name()='p']" mode="dsc">
        <xsl:text> ,</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>, </xsl:text>
    </xsl:template>
    
    <!-- the extra commas are inserted to ensure separation between terms in the index, 
        commas are stripped by Endeca -->
    <xsl:template match="*[local-name()='title']" mode="dsc">
        <xsl:text> ,</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>, </xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
