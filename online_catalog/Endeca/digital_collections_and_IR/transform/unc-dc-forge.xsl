<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:unc="http://yourdomain.com/lookup" extension-element-prefixes="unc" version="1.0">
    <xsl:output method="xml" indent="yes"/>
    
    <!--Set up lookup to assign OCLC numbers based on ETD ID, for ETDs-->
    <xsl:variable name="idLookups" select="document('id_map.xml')"/>
    <xsl:key name="idLookup" match="idmapping" use="@etdid"/>
    
    <!-- lookup table for collection lookup for isPartOf -->
    <unc:collections>
        <string id="bunkers">Eng &amp; Chang Bunker- The Siamese Twins</string>
        <string id="debry">De Bry Engravings</string>
        <string id="ETD">UNC-Chapel Hill Electronic Theses and Dissertations</string>
        <string id="gilmer">Gilmer Civil War Maps Collection</string>
        <string id="graypc">World War I Postcards from the Bowman Gray Collection</string>
        <string id="mackinney">The MacKinney Collection of Medieval Medical Illustrations</string>
        <string id="mccauley">Edward J. McCauley Photographs</string>
        <string id="morton_highlights">Hugh Morton Collection of Photographs and Films</string>
        <string id="nc_post">North Carolina Postcards</string>
        <string id="ncmaps">North Carolina Maps</string>
        <string id="numismatics">Historic Moneys</string>
        <string id="MastersPapers">UNC-Chapel Hill Master's Paper Collection</string>
        <string id="sohp">Southern Oral History Program</string>
        <string id="tobacco_bag">Tobacco Bag Stringing Operations in North Carolina and Virginia</string>
        <string id="vir_museum">Virtual Museum</string>
        <string id="yearbooks">North Carolina College and University Yearbooks</string>
    </unc:collections>
    
    <xsl:key name="string" match="unc:collections/string" use="@id"/>
    <xsl:variable name="strings" select="document(&quot;&quot;)//unc:collections"/>
    
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
            <xsl:value-of select="*[local-name()='header']/*[local-name()='setSpec']"/>
        </xsl:variable>
        
        
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
            
            
            
            
            <PROP NAME="RelationIsPartOf">
                <PVAL>
                    <!-- iterates through the lookup table until it finds a match and then outputs the name -->
                    <xsl:for-each select="$strings">
                        <xsl:value-of select="key(&quot;string&quot;, $setSpec)"/>
                    </xsl:for-each>
                    
                    
                </PVAL>
            </PROP>
        </RECORD>
    </xsl:template>
    
    
    
    <xsl:template match="*[local-name()='header']">
        <xsl:param name="setSpec"/>
        <xsl:apply-templates select="*[local-name()='identifier']" mode="header">
            <xsl:with-param name="setSpec" select="$setSpec"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="*[local-name()='datestamp']"/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='metadata']">
        <xsl:param name="setSpec"/>
        
        <xsl:apply-templates select="*[local-name()='qualifieddc']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='dc']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[local-name()='dc']">
        <xsl:param name="setSpec"/>
        
        <xsl:variable name="rightsVal">
            <xsl:value-of select="*[local-name()='rights']"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$rightsVal!='Restricted'">
                <PROP NAME="Availability">
                    <PVAL>
                        <xsl:text>Available</xsl:text>
                    </PVAL>
                </PROP>	               
                <PROP NAME="999ItemType">
                    <PVAL>
                        <xsl:text>ELECTRONIC</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="999Lib">
                    <PVAL>
                        <xsl:text>er</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="999Lib_orig">
                    <PVAL>
                        <xsl:text>er</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="999Loc">
                    <PVAL>
                        <xsl:text>NET</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
        </xsl:choose>
        
        <xsl:apply-templates select="*[local-name()='identifier']" mode="dc">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
            <xsl:with-param name="rightsVal">
                <xsl:value-of select="$rightsVal"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='title']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='date']" mode="dc">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='description']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='creator']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='contributor']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='subject']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[local-name()='qualifieddc']">
        <xsl:param name="setSpec"/>
        
        <xsl:variable name="createDate">
            <xsl:value-of select="*[local-name()='date']"/>
        </xsl:variable>
        
        <xsl:variable name="interviewTitle">
            <xsl:value-of select="*[local-name()='title']"/>
        </xsl:variable>
        
        <xsl:variable name="interviewee">
            <xsl:value-of select="*[local-name()='creator'][1]"/>
        </xsl:variable>
        
        <PROP NAME="Availability">
            <PVAL>
                <xsl:text>Available</xsl:text>
            </PVAL>
        </PROP>	               
        <PROP NAME="999ItemType">
            <PVAL>
                <xsl:text>ELECTRONIC</xsl:text>
            </PVAL>
        </PROP>
        <PROP NAME="999Lib">
            <PVAL>
                <xsl:text>er</xsl:text>
            </PVAL>
        </PROP>
        <PROP NAME="999Lib_orig">
            <PVAL>
                <xsl:text>er</xsl:text>
            </PVAL>
        </PROP>
        <PROP NAME="999Loc">
            <PVAL>
                <xsl:text>NET</xsl:text>
            </PVAL>
        </PROP>
        
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
        
        <xsl:apply-templates select="*[local-name()='extent']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='formatExtent']"/>
        
        <xsl:apply-templates select="*[local-name()='isPartOf']"/>
        
        <xsl:apply-templates select="*[local-name()='language']"/>
        
        <xsl:apply-templates select="*[local-name()='rights']"/>
        
        <xsl:apply-templates select="*[local-name()='medium']"/>
        
        <xsl:apply-templates select="*[local-name()='identifier']" mode="qualifieddc">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='date']|*[local-name()='created']"/>
        
        <xsl:apply-templates select="*[local-name()='repository']"/>
        
        <xsl:apply-templates select="*[local-name()='relation']"/>
        
        <xsl:apply-templates select="*[local-name()='publisher']"/>
        
        <xsl:apply-templates select="*[local-name()='subject']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='spatial']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='coverage']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='coverageSpatial']"/>
        
        <xsl:apply-templates select="*[local-name()='description']">
            <xsl:with-param name="setSpec">
                <xsl:value-of select="$setSpec"/>
            </xsl:with-param>
        </xsl:apply-templates>
        
        <xsl:apply-templates select="*[local-name()='caption']"/>
        
        <xsl:apply-templates select="*[local-name()='abstract']"/>
        
        <xsl:apply-templates select="*[local-name()='source']">
            <xsl:with-param name="setSpec" select="$setSpec"/>
            <xsl:with-param name="interviewee">
                <xsl:value-of select="$interviewee"/>
            </xsl:with-param>
            <xsl:with-param name="createDate">
                <xsl:value-of select="$createDate"/>
            </xsl:with-param>
            <xsl:with-param name="interviewTitle">
                <xsl:value-of select="$interviewTitle"/>
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- controls what part of dc:identifier is used to create UniqueId, etc -->
    <xsl:template match="*[local-name()='identifier']" mode="header">
        <xsl:param name="setSpec"/>
        <xsl:variable name="set">
            <xsl:choose>
                <xsl:when test="contains(., 'digitalnc.org:')">
                    <xsl:value-of select="substring-after(.,'digitalnc.org:')"/>
                </xsl:when>
                <!-- inserts collection code after UNC, before uuid -->
                <xsl:when test="$setSpec='ETD'">
                    <xsl:text>ETD</xsl:text>
                    <xsl:value-of select="substring-after(.,'uuid:')"/>
                </xsl:when>
                <xsl:when test="$setSpec='MastersPapers'">
                    <xsl:text>MP</xsl:text>
                    <xsl:value-of select="substring-after(.,'uuid:')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-after(.,'unc.edu:')"/>
                </xsl:otherwise>
                
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="fullid">
            <xsl:choose>
                <xsl:when test="$setSpec='ETD'">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:when test="$setSpec='MastersPapers'">
                    <xsl:value-of select="."/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="slash">
            <xsl:text>/</xsl:text>
        </xsl:variable>
        <xsl:variable name="dash">
            <xsl:text>-</xsl:text>
        </xsl:variable>
        <xsl:variable name="UniqueId">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$set"/>
                <xsl:with-param name="replace" select="$slash"/>
                <xsl:with-param name="by" select="$dash"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:choose>
        <xsl:when test="$setSpec='ETD'">
            <xsl:variable name="oclcnum">
                <!-- sets OCLCNumber property based on lookup of etd id in id_map.xml -->
                <xsl:for-each select="$idLookups">
                    <xsl:value-of select="key('idLookup', $fullid)"/>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:if test="$oclcnum != ''">
                <PROP NAME="OCLCNumber">
                    <PVAL>
                        <xsl:value-of select="$oclcnum"/> 
                    </PVAL>
                </PROP>        
            </xsl:if>
        
            </xsl:when>     
        </xsl:choose>
        
        
        <PROP NAME="UniqueId">
            <PVAL>
                <xsl:text>UNCDC</xsl:text>
                <xsl:value-of select="$UniqueId"/>
            </PVAL>
        </PROP>
        <PROP NAME="Rollup">
            <PVAL>
                <xsl:text>UNCDC</xsl:text>
                <xsl:value-of select="$UniqueId"/>
            </PVAL>
        </PROP>
        <PROP NAME="LocalId">
            <PVAL>
                <xsl:text>UNCDC</xsl:text>
                <xsl:value-of select="$UniqueId"/>
            </PVAL>
        </PROP>
        
        <PROP NAME="Digital Collection">
            <PVAL>
                <xsl:value-of select="$setSpec"/>
            </PVAL>
        </PROP>
        
        <xsl:choose>
            <xsl:when test="$setSpec='MastersPapers'"> </xsl:when>
            <xsl:when test="$setSpec='ETD'"> </xsl:when>            
            <xsl:otherwise>
                <PROP NAME="Primary Source">
                    <PVAL>
                        <xsl:text>Primary Source</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:choose>
            
            
            
            <xsl:when test="contains($set, 'graypc')">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Postcard</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Postcard</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'ncpostcards')">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Postcard</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Postcard</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'gilmer')">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Map</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Map</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'ncmaps')">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Map</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Map</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'sohp')">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Sound Recording</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Oral History</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'yearbook')">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Book</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Yearbook</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:when test="$setSpec='MastersPapers'">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Thesis</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Thesis</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'ETD')">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Thesis</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Thesis</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>            
            <xsl:when test="contains($set, 'morton_highlights')">
                <PROP NAME="Item Types">
                    <PVAL>
                        <xsl:text>Photograph</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Genre">
                    <PVAL>
                        <xsl:text>Photograph</xsl:text>
                    </PVAL>
                </PROP>
            </xsl:when>
        </xsl:choose>
        
        
        
        
        <xsl:choose>
            <xsl:when test="$setSpec='ETD'"></xsl:when>
            <xsl:when test="$setSpec='MastersPapers'"></xsl:when>
            <xsl:when test="$setSpec='yearbooks'">
                <PROP NAME="ThumbnailURL">
                    
                    
                    <PVAL>
                        <xsl:text>http://library.digitalnc.org/cgi-bin/thumbnail.exe?CISOROOT=/yearbooks</xsl:text>
                        <xsl:text>&#38;</xsl:text>
                        <xsl:text>CISOPTR=719</xsl:text>
                        
                    </PVAL>
                </PROP>
                
            </xsl:when>
            <xsl:otherwise>
                <PROP NAME="ThumbnailURL">
                    
                    <!--             http://dc.lib.unc.edu/cgi-bin/thumbnail.exe?CISOROOT=/debry&CISOPTR=36 -->
                    <PVAL>
                        <xsl:variable name="setname">
                            <xsl:value-of select="substring-before($set,$slash)"/>
                        </xsl:variable>
                        <xsl:variable name="setnum">
                            <xsl:value-of select="substring-after($set,$slash)"/>
                        </xsl:variable>
                        
                        <xsl:variable name="CISOPTR">
                            
                            <xsl:text disable-output-escaping="no">CISOPTR=</xsl:text>
                            <xsl:value-of select="$setnum"/>
                        </xsl:variable>
                        <xsl:text>http://dc.lib.unc.edu/cgi-bin/thumbnail.exe?CISOROOT=/</xsl:text>
                        <xsl:value-of select="$setname"/>
                        <xsl:text>&#38;</xsl:text>
                        <xsl:value-of select="$CISOPTR"/>
                        
                    </PVAL>
                </PROP>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    
    
    <xsl:template match="*[local-name()='datestamp']">
        <xsl:variable name="dash">
            <xsl:text>-</xsl:text>
        </xsl:variable>
        <xsl:variable name="null">
            <xsl:text/>
        </xsl:variable>
        <!-- 
            <PROP NAME="DatePublished">
            <PVAL>
            <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
            </PROP>
        -->
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
    </xsl:template>
    
    <xsl:template match="*[local-name()='date']" mode="dc">
        <xsl:param name="setSpec"/>
        <xsl:variable name="dash">
            <xsl:text>-</xsl:text>
        </xsl:variable>
        <xsl:variable name="null">
            <xsl:text/>
        </xsl:variable>
        
        <xsl:variable name="datestring">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="."/>
                <xsl:with-param name="replace" select="$dash"/>
                <xsl:with-param name="by" select="$null"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="theyear">
            <xsl:value-of select="substring($datestring,1,4)"/>
        </xsl:variable>
        
        <xsl:variable name="themonth">
            <xsl:value-of select="substring($datestring,5,2)"/>
        </xsl:variable>
        
        <PROP NAME="YearPublished">
            <PVAL>
                <xsl:value-of select="$theyear"/>
            </PVAL>
        </PROP>
        
        <PROP NAME="DatePublished">
            <PVAL>
                <xsl:value-of select="$theyear"/>-<xsl:value-of select="$themonth"/>
            </PVAL>
        </PROP>        
    </xsl:template>    
    
    <xsl:template match="*[local-name()='title']">
        <xsl:param name="setSpec"/>
        <xsl:if test="$setSpec!='sohp'">
            <PROP NAME="Title">
                <PVAL>
                    <xsl:value-of select="normalize-space(.)"/>
                </PVAL>
            </PROP>
            
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="*[local-name()='type']">
        <PROP NAME="Type">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='creator']">
        <xsl:param name="setSpec"/>
        <xsl:choose>
            <xsl:when test="$setSpec='sohp'">
                <xsl:choose>
                    <!-- interviewee is first -->
                    <xsl:when test="position() &lt; last()">
                        <xsl:variable name="interviewee">
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:variable>
                        <PROP NAME="Interviewee">
                            <PVAL>
                                <xsl:value-of select="normalize-space(.)"/>
                                <xsl:text> Interviewee</xsl:text>
                            </PVAL>
                        </PROP>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- interviewers are second -->
                        <xsl:choose>
                            <xsl:when test="contains(., ';')">
                                <xsl:call-template name="parseInterviewer">
                                    <xsl:with-param name="list" select="."/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="writeInterviewer">
                                    <xsl:with-param name="string" select="."/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="contains(., ';')">
                        <xsl:call-template name="writeCreator">
                            <xsl:with-param name="string" select="substring-before(., ';')"/>
                        </xsl:call-template>
                        
                        <xsl:call-template name="parseCreator">
                            <xsl:with-param name="list" select="substring-after(., '; ')"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="writeCreator">
                            <xsl:with-param name="string" select="."/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[local-name()='extent']">
        <xsl:param name="setSpec"/>
        <xsl:if test="$setSpec!='MastersPapers'">
            
            <PROP NAME="Extent">
                <PVAL>
                    <xsl:value-of select="normalize-space(.)"/>
                </PVAL>
            </PROP>
        </xsl:if>
        
    </xsl:template>
    <xsl:template match="*[local-name()='formatExtent']">
        <PROP NAME="FormatExtent">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='isPartOf']"> </xsl:template>
    
    <xsl:template match="*[local-name()='rights']">
        <PROP NAME="Rights">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='language']">
        
        <xsl:variable name="length" select="string-length(.)"/>
        
        <xsl:variable name="lastchar" select="substring(., $length)"/>
        
        <PROP NAME="Language">
            <PVAL>
                <xsl:choose>
                    <xsl:when test="$lastchar = ';'">
                        <xsl:value-of select="substring(., '0', $length)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </PVAL>
        </PROP>
        
        
    </xsl:template>
    <xsl:template match="*[local-name()='medium']">
        <xsl:variable name="length" select="string-length(.)"/>
        
        <xsl:variable name="lastchar" select="substring(., $length)"/>
        
        <PROP NAME="FormatMedium">
            <PVAL>
                <xsl:choose>
                    <xsl:when test="$lastchar = ';'">
                        <xsl:value-of select="substring(., '0', $length)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='identifier']" mode="dc">
        <xsl:param name="setSpec"/>
        <xsl:param name="rightsVal"/>
        
        <xsl:variable name="theurl">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:variable>  
        
        <xsl:choose>
            <xsl:when test="$rightsVal!='Restricted'">
                <PROP NAME="PrimaryURL">
                    <PVAL>
                        <xsl:value-of select="$theurl"/>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:otherwise>
                <PROP NAME="SecondaryURL">
                    <PVAL>
                        <xsl:value-of select="$theurl"/>
                        <xsl:text>|Details on this thesis, including date it will become available online|</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="Access Restrictions">
                    <PVAL>
                        <xsl:text>This thesis is currently under embargo and is not freely available online. Visit the link in the full record tab to see when it will become available.</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="999Lib">
                    <PVAL>
                        <xsl:text>UNC</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="999Lib_orig">
                    <PVAL>
                        <xsl:text>UNC</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="999Loc">
                    <PVAL>
                        <xsl:text>UNC</xsl:text>
                    </PVAL>
                </PROP>
                <PROP NAME="999ItemNote">
                    <PVAL>
                        <xsl:text>Embargoed item. Full text not currently available. See details in Full Record tab for more information.</xsl:text>
                    </PVAL>
                </PROP>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[local-name()='identifier']" mode="qualifieddc">
        <xsl:param name="setSpec"/>
        
        <xsl:choose>
            <!-- ignore identifier elements that begin with Interviewee name -->
            <xsl:when test="starts-with(.,'http:')">
                
                <PROP NAME="PrimaryURL">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>
            </xsl:when>
            
            <xsl:when test="starts-with(.,'Interview with')"> </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$setSpec!='sohp'">
                        
                        <PROP NAME="Identifier">
                            <PVAL>
                                <xsl:value-of select="normalize-space(.)"/>
                            </PVAL>
                        </PROP>
                        
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    <xsl:template match="*[local-name()='host']">
        <PROP NAME="Host">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='contributor']">
        <xsl:param name="setSpec"/>
        
        <xsl:choose>
            <xsl:when test="$setSpec!='ETD'">
                <PROP NAME="Contributor">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="position() &gt; 1">
                        <PROP NAME="Contributor">
                            <PVAL>
                                <xsl:value-of select="normalize-space(.)"/>
                                <xsl:text>|degree supervisor</xsl:text>
                            </PVAL>
                        </PROP> 
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[local-name()='repository']">
        <PROP NAME="Repository">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    <xsl:template match="*[local-name()='host']">
        <PROP NAME="Host">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='relation']">
        <PROP NAME="OriginalPublication">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='date']|*[local-name()='created']">
        <xsl:variable name="length" select="string-length(.)"/>
        <xsl:variable name="first4chars" select="substring(., 1, 4)"/>
        <xsl:variable name="index">
            <xsl:value-of select="$length - 3"/>
        </xsl:variable>
        <xsl:variable name="last4chars" select="substring(., $index, $length)"/>
        
        <xsl:variable name="year">
            <xsl:choose>
                <xsl:when test="floor($first4chars) = $first4chars">
                    <xsl:value-of select="$first4chars"/>
                </xsl:when>
                <xsl:when test="floor($last4chars) = $last4chars">
                    <xsl:value-of select="$last4chars"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>-</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        
        
        
        <xsl:choose>
            <!-- we have an integer -->
            <xsl:when test="floor($year) = $year">
                <!-- need to trim to get first four chars -->
                <PROP NAME="YearPublished">
                    <PVAL>
                        <xsl:value-of select="$year"/>
                    </PVAL>
                </PROP>
                <!-- date of interviews follows day - month - year, need to extract year -->
            </xsl:when>
        </xsl:choose>
        
        
        <xsl:choose>
            <!-- String begins with a year -->
            <xsl:when test="floor($first4chars) = $first4chars">
                
                <PROP NAME="CoverageTemporal">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>
                
            </xsl:when>
            <xsl:when test="floor($last4chars) = $last4chars">
                
                <PROP NAME="CoverageTemporal">
                    <PVAL>
                        <xsl:value-of select="$last4chars"/>
                    </PVAL>
                </PROP>
                
            </xsl:when>
            
        </xsl:choose>
        
        
        <PROP NAME="DatePublished">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
        
        
        
    </xsl:template>
    
    <xsl:template match="*[local-name()='publisher']">
        
        <xsl:variable name="length" select="string-length(.)"/>
        
        <xsl:variable name="lastchar" select="substring(., $length)"/>
        
        <PROP NAME="Publisher">
            <PVAL>
                <xsl:choose>
                    <xsl:when test="$lastchar = ';'">
                        <xsl:value-of select="substring(., '0', $length)"/>
                        <xsl:text>.</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </PVAL>
        </PROP>        
    </xsl:template>
    
    <xsl:template match="*[local-name()='caption']">
        <PROP NAME="Caption">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='subject']">
        <xsl:param name="setSpec"/>
        
        <xsl:choose>
            <xsl:when test="$setSpec='ETD'">
                <PROP NAME="710a">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                        <xsl:text>|degree granting institution</xsl:text>
                    </PVAL>
                </PROP>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="parseSubject">
                    <xsl:with-param name="list" select="."/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[local-name()='spatial']">
        <xsl:param name="setSpec"/>
        <xsl:choose>
            <xsl:when test="$setSpec='ncmaps'">
                <PROP NAME="CoverageSpatial">
                    <PVAL>
                        <xsl:choose>
                            <xsl:when test="position()=1">
                                <xsl:text>West Longitude </xsl:text>
                            </xsl:when>
                            <xsl:when test="position()=2">
                                <xsl:text>East Longitude </xsl:text>
                            </xsl:when>
                            <xsl:when test="position()=3">
                                <xsl:text>North Latitude </xsl:text>
                            </xsl:when>
                            <xsl:when test="position()=4">
                                <xsl:text>South Latitude </xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:otherwise>
                <PROP NAME="Spatial">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[local-name()='coverageSpatial']">
        <PROP NAME="CoverageSpatial">
            <PVAL>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='coverage']">
        <xsl:param name="setSpec"/>
        <xsl:choose>
            <xsl:when test="$setSpec='ncmaps'">
                <xsl:call-template name="parseDelimitedField">
                    <xsl:with-param name="list">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:with-param>
                    <xsl:with-param name="pvalName">
                        <xsl:text>Spatial</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <PROP NAME="PubPlace">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    <xsl:template match="*[local-name()='description']">
        <xsl:param name="setSpec"/>
        <xsl:variable name="count">
            <xsl:number format="001"/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$setSpec='mackinney'">
                <PROP NAME="Title">
                    <PVAL>
                        <xsl:value-of select="normalize-space(.)"/>
                    </PVAL>
                </PROP>
            </xsl:when>
            
            <xsl:when test="$setSpec='MastersPapers'"> </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="doubledash">
                    <xsl:text>--</xsl:text>
                </xsl:variable>
                <xsl:variable name="doubledashspace">
                    <xsl:text> -- </xsl:text>
                </xsl:variable>
                
                <PROP NAME="Abstract">
                    <PVAL>
                        <xsl:text>seq</xsl:text>
                        <xsl:value-of select="$count"/>
                        <xsl:text>|</xsl:text>                        
                        
                        <xsl:call-template name="string-replace-all">
                            <xsl:with-param name="text" select="."/>
                            <xsl:with-param name="replace" select="$doubledash"/>
                            <xsl:with-param name="by" select="$doubledashspace"/>
                        </xsl:call-template>
                    </PVAL>
                </PROP>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="*[local-name()='abstract']">
        <xsl:variable name="count">
            <xsl:number format="001"/>
        </xsl:variable>
        
        <PROP NAME="Abstract">
            <PVAL>
                <xsl:text>seq</xsl:text>
                <xsl:value-of select="$count"/>
                <xsl:text>|</xsl:text>
                <xsl:value-of select="normalize-space(.)"/>
            </PVAL>
        </PROP>
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
    
    <xsl:template name="parseSubject">
        <xsl:param name="list"/>
        
       <xsl:variable name="sl" select="string-length($list)" />
        
        <xsl:if test="$sl!=0">        
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
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[local-name()='source']">
        <xsl:param name="setSpec"/>
        <xsl:param name="interviewee"/>
        <xsl:param name="createDate"/>
        <xsl:param name="interviewTitle"/>
        <xsl:variable name="comma">
            <xsl:text>,</xsl:text>
        </xsl:variable>
        <xsl:variable name="semicolon">
            <xsl:text>;</xsl:text>
        </xsl:variable>
        <xsl:variable name="space">
            <xsl:text> </xsl:text>
        </xsl:variable>
        
        <xsl:variable name="sourceString">
            <xsl:choose>
                <xsl:when test="contains(., 'http')">
                    
                    
                    <xsl:call-template name="string-replace-all">
                        <xsl:with-param name="text" select="substring-before(., 'http')"/>
                        <xsl:with-param name="replace" select="$comma"/>
                        <xsl:with-param name="by" select="$space"/>
                    </xsl:call-template>
                    
                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="string-replace-all">
                        <xsl:with-param name="text" select="."/>
                        <xsl:with-param name="replace" select="$comma"/>
                        <xsl:with-param name="by" select="$space"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        
        <xsl:choose>
            <xsl:when test="$setSpec='sohp'">
                
                <PROP NAME="Title">
                    <PVAL>
                        <xsl:text>Interview with </xsl:text>
                        <xsl:value-of select="$interviewee"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$createDate"/>
                        <xsl:text>. Interview  </xsl:text>
                        <xsl:value-of select="$interviewTitle"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="$sourceString"/>
                    </PVAL>
                </PROP>
                
                <PROP NAME="Citation">
                    <PVAL>
                        <xsl:value-of select="$sourceString"/>
                    </PVAL>
                </PROP>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:variable name="sourceCollection">
                    <xsl:call-template name="string-replace-all">
                        <xsl:with-param name="text" select="$sourceString"/>
                        <xsl:with-param name="replace" select="$semicolon"/>
                        <xsl:with-param name="by" select="$space"/>
                    </xsl:call-template>
                </xsl:variable>
                
                
                <PROP NAME="SourceCollection">
                    <PVAL>
                        <xsl:value-of select="normalize-space($sourceCollection)"/>
                    </PVAL>
                </PROP>
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
                    <xsl:value-of select="substring($subject, '0', $length)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(translate($subject, '.', ''))"/>
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
    
    <xsl:template name="parseInterviewer">
        <xsl:param name="list"/>
        
        <xsl:choose>
            
            <xsl:when test="contains($list, ';')">
                <xsl:call-template name="writeInterviewer">
                    <xsl:with-param name="string" select="substring-before($list, ';')"/>
                </xsl:call-template>
                
                <xsl:call-template name="parseInterviewer">
                    <xsl:with-param name="list" select="substring-after($list, ';')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="writeInterviewer">
                    <xsl:with-param name="string" select="$list"/>
                </xsl:call-template>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    
    <xsl:template name="writeInterviewer">
        <xsl:param name="string"/>
        <PROP NAME="Interviewer">
            <PVAL>
                <xsl:value-of select="normalize-space($string)"/>
                <xsl:text> Interviewer</xsl:text>
            </PVAL>
        </PROP>
        
        
    </xsl:template>
    
    <xsl:template name="parseCreator">
        <xsl:param name="list"/>
        
        <xsl:choose>
            
            <xsl:when test="contains($list, ';')">
                <xsl:call-template name="writeCreator">
                    <xsl:with-param name="string" select="substring-before($list, ';')"/>
                </xsl:call-template>
                
                <xsl:call-template name="parseCreator">
                    <xsl:with-param name="list" select="substring-after($list, ';')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="writeCreator">
                    <xsl:with-param name="string" select="$list"/>
                </xsl:call-template>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    
    <xsl:template name="writeCreator">
        <xsl:param name="string"/>
        <PROP NAME="Creator">
            <PVAL>
                <xsl:value-of select="normalize-space($string)"/>
            </PVAL>
        </PROP>
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
