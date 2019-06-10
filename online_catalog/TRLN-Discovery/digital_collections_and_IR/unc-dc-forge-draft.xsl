<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:unc="http://yourdomain.com/lookup" extension-element-prefixes="unc" version="1.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>
    
    <xsl:variable name="setSpec">
        <xsl:choose>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:City_and_Regional_Planning'">MastersPapers</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:Gillings_ESE'">MastersPapers</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:Gillings_HB'">MastersPapers</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:Gillings_HPM'">MastersPapers</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:Gillings_MCH'">MastersPapers</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:Gillings_Nutrition'">MastersPapers</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:Gillings_PHLP'">MastersPapers</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:Physician_Assistant_Program'">MastersPapers</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:SILS'">MastersPapers</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="*[local-name()='OAI-PMH']/*[local-name()='request']/@set"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:variable>
    
    <!--Set up lookup to assign OCLC numbers based on ETD ID, for ETDs-->
    <xsl:variable name="idLookups" select="document('id_map.xml')"/>
    <xsl:key name="idLookup" match="idmapping" use="@etdid"/>
    
    <!-- lookup table for collection lookup for isPartOf -->
    
    <unc:collections>
        <string id="admin_set:Dissertations">UNC-Chapel Hill Electronic Theses and Dissertations</string>
        <string id="MastersPapers">UNC-Chapel Hill Master's Paper Collection</string>
        <!--<string id="bunkers">Eng &amp; Chang Bunker- The Siamese Twins</string>
        <string id="debry">De Bry Engravings</string>
        <string id="gilmer">Gilmer Civil War Maps Collection</string>
        <string id="graypc">World War I Postcards from the Bowman Gray Collection</string>
        <string id="mackinney">The MacKinney Collection of Medieval Medical Illustrations</string>
        <string id="mccauley">Edward J. McCauley Photographs</string>
        <string id="morton_highlights">Hugh Morton Collection of Photographs and Films</string>
        <string id="nc_post">North Carolina Postcards</string>
        <string id="ncmaps">North Carolina Maps</string>
        <string id="numismatics">Historic Moneys</string>
        <string id="sohp">Southern Oral History Program</string>
        <string id="tobacco_bag">Tobacco Bag Stringing Operations in North Carolina and Virginia</string>
        <string id="vir_museum">Virtual Museum</string>
        <string id="yearbooks">North Carolina College and University Yearbooks</string>-->
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
        <xsl:apply-templates select="*[local-name()='record']"/>
    </xsl:template>
    
    <!-- create records and set static fields -->
    
    <xsl:template match="*[local-name()='record']">
        
        <xsl:text>{&#xA;</xsl:text>
        
        <xsl:apply-templates select="*[local-name()='header']"/>
        
        <xsl:apply-templates select="*[local-name()='metadata']"/>
        
        <!-- iterates through the lookup table until it finds a match and then outputs the name -->
        <xsl:text>&#x9;"virtual_collection": [&#xA;</xsl:text>
        <xsl:for-each select="$strings">
            <xsl:text>&#x9;&#x9;"TRLN Shared Records. </xsl:text>
            <xsl:value-of select="key(&quot;string&quot;, $setSpec)"/>
            <xsl:text>."&#xA;</xsl:text>
        </xsl:for-each>
        <xsl:text>&#x9;], &#xA;</xsl:text>
        
        <xsl:choose>
            <xsl:when test="$setSpec='admin_set:Dissertations'">
                <xsl:text>&#x9;"record_data_source": [&#xA;</xsl:text>
                <xsl:text>&#x9;&#x9;"DC", "Shared Records", "UNC-Chapel Hill Electronic Theses and Dissertations"&#xA;</xsl:text>
                <xsl:text>&#x9;],&#xA;</xsl:text>
            </xsl:when>
            
            <xsl:when test="$setSpec='admin_set:MastersPapers'">
                <xsl:text>&#x9;"record_data_source": [&#xA;</xsl:text>
                <xsl:text>&#x9;&#x9;"DC", "Shared Records", "UNC-Chapel Hill Master's Paper Collection"&#xA;</xsl:text>
                <xsl:text>&#x9;],&#xA;</xsl:text>
            </xsl:when>
            <!--            
            <xsl:otherwise>
    "Primary Source": "Primary Source",
            </xsl:otherwise>
-->
        </xsl:choose>
        
        <xsl:text>&#x9;"available": "Available",&#xA;</xsl:text>
        
        <xsl:text>&#x9;"physical_media": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"Online"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
        
        <xsl:text>&#x9;"access_type": ["Online"],&#xA;</xsl:text>
        
        <xsl:text>&#x9;"institution": ["unc", "duke", "ncsu"],&#xA;</xsl:text>
    
        <xsl:text>&#x9;"owner": "unc"&#xA;</xsl:text>
        
        <xsl:text>}&#xA;</xsl:text>
        
    </xsl:template>
    
    
    <xsl:template match="*[local-name()='header']">
        <xsl:apply-templates select="*[local-name()='identifier']" mode="header"/>
        <xsl:apply-templates select="*[local-name()='datestamp']"/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='metadata']">
        <xsl:apply-templates select="*[local-name()='qualifieddc']"/>
        <xsl:apply-templates select="*[local-name()='dc']"/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='dc']">
     
        <xsl:apply-templates select="*[local-name()='identifier']" mode="dc"/>
        
        <xsl:apply-templates select="*[local-name()='title']"/>
        
        <xsl:apply-templates select="*[local-name()='date'][1]" mode="yearPublished"/>
        
        
        <xsl:choose>
            <xsl:when test="$setSpec='admin_set:Dissertations' or 'MastersPapers'">                
                <xsl:choose>
                    <xsl:when test="*[local-name()='publisher']">
                        <xsl:text>&#x9;"publisher": [&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;"</xsl:text>
                        <xsl:value-of select="normalize-space(*[local-name()='publisher'][1])"/>
                        <xsl:text>"&#xA;</xsl:text>
                        <xsl:text>&#x9;],&#xA;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>&#x9;"publisher": [&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;"University of North Carolina at Chapel Hill"&#xA;</xsl:text>
                        <xsl:text>&#x9;],&#xA;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise> 
            </xsl:otherwise>
        </xsl:choose>
        
        
        <xsl:text>&#x9;"imprint_main":[&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"{\"type\":\"imprint\",\"value\":\"</xsl:text>
        <xsl:if test="$setSpec='admin_set:Dissertations' or 'MastersPapers'">
            <xsl:text>Chapel Hill, NC</xsl:text>
        </xsl:if>
        <xsl:text> : </xsl:text>
        <xsl:choose>
            <xsl:when test="$setSpec='admin_set:Dissertations' or 'MastersPapers'">
                <xsl:choose>
                    <xsl:when test="*[local-name()='publisher']">
                        <xsl:value-of select="normalize-space(*[local-name()='publisher'][1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>University of North Carolina at Chapel Hill</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="*[local-name()='date'][position()=1]" mode="getYear"/>
        <xsl:text>.\"}"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
        
        <xsl:apply-templates select="*[local-name()='language'][1]"/>
        
        <xsl:apply-templates select="*[local-name()='type']"/>
        
        <xsl:apply-templates select="*[local-name()='description'][position()=1]"/>
        
        <xsl:text>&#x9;"statement_of_responsibility": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"value": "by </xsl:text>
        <xsl:value-of select="*[local-name()='creator']"/>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;}&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
        
        <xsl:text>&#x9;"names": [&#xA;</xsl:text>
        <xsl:apply-templates select="*[local-name()='creator']"/>
        
        <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"name": "</xsl:text>
        <xsl:choose>
            <xsl:when test="$setSpec='admin_set:Dissertations' or 'MastersPapers'">
                <xsl:choose>
                    <xsl:when test="*[local-name()='publisher']">
                        <xsl:value-of select="normalize-space(*[local-name()='publisher'][1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>University of North Carolina at Chapel Hill</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        <xsl:text>",&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"type": "publisher",&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"rel": ["publisher"]&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;},&#xA;</xsl:text>

        
        <xsl:apply-templates select="*[local-name()='contributor']"/>
        <xsl:text>&#x9;],&#xA;</xsl:text>
        
        
        <xsl:if test="*[local-name()='subject']">
            
            <xsl:text>&#x9;"subject_topical": [&#xA;</xsl:text>
            <xsl:for-each select="*[local-name()='subject']">
                <xsl:text>&#x9;&#x9;"</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>"</xsl:text>
                <xsl:if test="position() != last()">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#x9;],&#xA;</xsl:text>
            
            <xsl:text>&#x9;"subject_headings": [&#xA;</xsl:text>
            <xsl:for-each select="*[local-name()='subject']">
                <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
                <xsl:text>&#x9;&#x9;&#x9;"value":"</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>"&#xA;</xsl:text>
                <xsl:text>&#x9;&#x9;}</xsl:text>
                <xsl:if test="position() != last()">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text>&#xA;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#x9;],&#xA;</xsl:text>
            
        </xsl:if>
    </xsl:template>
<!--   
    <xsl:template match="*[local-name()='qualifieddc']">
        <xsl:variable name="createDate">
            <xsl:value-of select="*[local-name()='date']"/>
        </xsl:variable>
        <xsl:variable name="interviewTitle">
            <xsl:value-of select="*[local-name()='title']"/>
        </xsl:variable>
        <xsl:variable name="interviewee">
            <xsl:value-of select="*[local-name()='creator'][1]"/>
        </xsl:variable>
    "Availability": "Available",
    "999ItemType": "ELECTRONIC",
    "999Lib": "er",
    "999Lib_orig": "er",
    "999Loc": "NET",
        <xsl:apply-templates select="*[local-name()='title']"/>
        
        <xsl:apply-templates select="*[local-name()='type']"/>
        
        <xsl:apply-templates select="*[local-name()='creator']"/>
        
        <xsl:apply-templates select="*[local-name()='extent']"/>
        
        <xsl:apply-templates select="*[local-name()='formatExtent']"/>
        
        <xsl:apply-templates select="*[local-name()='isPartOf']"/>
        
        <xsl:apply-templates select="*[local-name()='language']"/>
        
        <xsl:apply-templates select="*[local-name()='rights']"/>
        
        <xsl:apply-templates select="*[local-name()='medium']"/>
        
        <xsl:apply-templates select="*[local-name()='identifier']" mode="qualifieddc"/>
        
        <xsl:apply-templates select="*[local-name()='date']|*[local-name()='created']"/>
        
        <xsl:apply-templates select="*[local-name()='repository']"/>
        
        <xsl:apply-templates select="*[local-name()='relation']"/>
        
        <xsl:apply-templates select="*[local-name()='publisher']"/>
        
        <xsl:apply-templates select="*[local-name()='subject']"/>
        
        <xsl:apply-templates select="*[local-name()='spatial']"/>
        
        <xsl:apply-templates select="*[local-name()='coverage']"/>
        
        <xsl:apply-templates select="*[local-name()='coverageSpatial']"/>
        
        <xsl:apply-templates select="*[local-name()='description']"/>
        
        <xsl:apply-templates select="*[local-name()='caption']"/>
        
        <xsl:apply-templates select="*[local-name()='abstract']"/>
        
        <xsl:apply-templates select="*[local-name()='source']">
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
-->    
    <!-- controls what part of dc:identifier is used to create UniqueId, etc -->

    <xsl:template match="*[local-name()='identifier']" mode="header">
        <xsl:variable name="set">
            <xsl:choose>
                <xsl:when test="contains(., 'digitalnc.org:')">
                    <xsl:value-of select="substring-after(.,'digitalnc.org:')"/>
                </xsl:when>
                <!-- inserts collection code after UNC, before uuid -->
                <xsl:when test="$setSpec='admin_set:Dissertations'">
                    <xsl:text>ETD</xsl:text>
                    <xsl:value-of select="substring-after(.,'cdr.lib.unc.edu:')"/>
                </xsl:when>
                <xsl:when test="$setSpec='MastersPapers'">
                    <xsl:text>MP</xsl:text>
                    <xsl:value-of select="substring-after(.,'cdr.lib.unc.edu:')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-after(.,'unc.edu:')"/>
                </xsl:otherwise>
                
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="fullid">
            <xsl:choose>
                <xsl:when test="$setSpec='admin_set:Dissertations'">
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
<!-- 
        <xsl:choose>
            <xsl:when test="$setSpec='admin_set:Dissertations'">
            <xsl:variable name="oclcnum">-->
                <!-- sets OCLCNumber property based on lookup of etd id in id_map.xml -->
        <!--                <xsl:for-each select="$idLookups">
                    <xsl:value-of select="key('idLookup', $fullid)"/>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:if test="$oclcnum != ''">
    "OCLCNumber": "<xsl:value-of select="$oclcnum"/>",    
            </xsl:if>
        
            </xsl:when>     
        </xsl:choose>
-->        
        <xsl:text>&#x9;"id": "</xsl:text>
        <xsl:text>UNCDC</xsl:text>
        <xsl:value-of select="$UniqueId"/>
        <xsl:text>",&#xA;</xsl:text>
        
        <xsl:text>&#x9;"rollup_id": "</xsl:text>
        <xsl:text>UNCDC</xsl:text>
        <xsl:value-of select="$UniqueId"/>
        <xsl:text>",&#xA;</xsl:text>
        
        <xsl:text>&#x9;"local_id": "</xsl:text>
        <xsl:text>UNCDC</xsl:text>
        <xsl:value-of select="$UniqueId"/>
        <xsl:text>",&#xA;</xsl:text>
        

        
        <!--          
        <xsl:choose>
            
            
          
            <xsl:when test="contains($set, 'graypc')">
    "Item Types": "Postcard",
    "Genre": "Postcard",

            </xsl:when>
            <xsl:when test="contains($set, 'ncpostcards')">
                <PROP NAME="Item Types">
                        <xsl:text>Postcard</xsl:text>
                </PROP>
                <PROP NAME="Genre">
                        <xsl:text>Postcard</xsl:text>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'gilmer')">
                <PROP NAME="Item Types">
                        <xsl:text>Map</xsl:text>
                </PROP>
                <PROP NAME="Genre">
                        <xsl:text>Map</xsl:text>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'ncmaps')">
                <PROP NAME="Item Types">
                        <xsl:text>Map</xsl:text>
                </PROP>
                <PROP NAME="Genre">
                        <xsl:text>Map</xsl:text>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'sohp')">
                <PROP NAME="Item Types">
                        <xsl:text>Sound Recording</xsl:text>
                </PROP>
                <PROP NAME="Genre">
                        <xsl:text>Oral History</xsl:text>
                </PROP>
            </xsl:when>
            <xsl:when test="contains($set, 'yearbook')">
                <PROP NAME="Item Types">
                        <xsl:text>Book</xsl:text>
                </PROP>
                <PROP NAME="Genre">
                        <xsl:text>Yearbook</xsl:text>
                </PROP>
            </xsl:when>
            <xsl:when test="$setSpec='MastersPapers'">
                <PROP NAME="Item Types">
                        <xsl:text>Thesis</xsl:text>
                </PROP>
                <PROP NAME="Genre">
                        <xsl:text>Thesis</xsl:text>
                </PROP>
            </xsl:when>
          
            <xsl:when test="contains($set, 'admin_set:Dissertations')">
    "resource_type": ["Thesis"],</xsl:when>  
            
        <xsl:when test="contains($set, 'morton_highlights')">
                <PROP NAME="Item Types">
                        <xsl:text>Photograph</xsl:text>
                </PROP>
                <PROP NAME="Genre">
                        <xsl:text>Photograph</xsl:text>
                </PROP>
            </xsl:when>

        </xsl:choose> 
        
        
        <xsl:choose>
            <xsl:when test="$setSpec='admin_set:Dissertations'"/>
            <xsl:when test="$setSpec='MastersPapers'"/>
         
            <xsl:when test="$setSpec='yearbooks'">
                <PROP NAME="ThumbnailURL">
                        <xsl:text>http://library.digitalnc.org/cgi-bin/thumbnail.exe?CISOROOT=/yearbooks</xsl:text>
                        <xsl:text>&#38;</xsl:text>
                        <xsl:text>CISOPTR=719</xsl:text>
                </PROP>
                
            </xsl:when>
            <xsl:otherwise>-->
 
                    <!--             http://dc.lib.unc.edu/cgi-bin/thumbnail.exe?CISOROOT=/debry&CISOPTR=36 -->
        <!-- <xsl:variable name="setname">
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
             
                
            </xsl:otherwise> 
        </xsl:choose>-->
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
        
        <xsl:text>&#x9;"date_cataloged":[&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[local-name()='date'][1]" mode="yearPublished">
        <xsl:variable name="theyear">
            <xsl:choose>
                <xsl:when test="$setSpec='admin_set:Dissertations'">
                    <xsl:value-of select="substring(., string-length() -3)"/>
                </xsl:when>
                <xsl:when test="$setSpec='MastersPapers'">
                    <xsl:value-of select="substring(., 1,4)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:text>&#x9;"publication_year": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;</xsl:text>
        <xsl:value-of select="$theyear"/>
        <xsl:text>&#xA;&#x9;],&#xA;</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="*[local-name()='date'][1]" mode="getYear">
        <xsl:variable name="theyear">
            <xsl:choose>
                <xsl:when test="$setSpec='admin_set:Dissertations'">
                    <xsl:value-of select="substring(., string-length() -3)"/>
                </xsl:when>
                <xsl:when test="$setSpec='MastersPapers'">
                    <xsl:value-of select="substring(., 1,4)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="$theyear"/>
        
    </xsl:template>
    
    
    <xsl:template match="*[local-name()='title']">
        <xsl:if test="$setSpec!='sohp'">
            <xsl:text>&#x9;"title_main":[&#xA;</xsl:text>
            <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
            <xsl:text>&#x9;&#x9;&#x9;"value":"</xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text>"&#xA;</xsl:text>
            <xsl:text>&#x9;&#x9;}&#xA;</xsl:text>
            <xsl:text>&#x9;],&#xA;</xsl:text>
            
            <xsl:text>&#x9;"title_sort": "</xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text>",&#xA;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[local-name()='type']">
        <xsl:text>&#x9;"resource_type": ["</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>"],&#xA;</xsl:text>
    </xsl:template>
 

    <xsl:template match="*[local-name()='creator']">
        <xsl:choose>
            <xsl:when test="$setSpec='sohp'">
                <!--<xsl:choose> -->
                    <!-- interviewee is first -->
                    <!-- <xsl:when test="position() &lt; last()">
                        <xsl:variable name="interviewee">
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:variable>
                        <PROP NAME="Interviewee">
                                <xsl:value-of select="normalize-space(.)"/>
                                <xsl:text> Interviewee</xsl:text>
                        </PROP>
                    </xsl:when>
                    <xsl:otherwise> -->
                        <!-- interviewers are second -->
                        <!-- <xsl:choose>
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
                </xsl:choose>--> 
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
        <xsl:if test="$setSpec!='MastersPapers'">
            
            <PROP NAME="Extent">
                    <xsl:value-of select="normalize-space(.)"/>
            </PROP>
        </xsl:if>
        
    </xsl:template>
    
<!--     
    <xsl:template match="*[local-name()='formatExtent']">
        <PROP NAME="FormatExtent">
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='isPartOf']"/>
   
    <xsl:template match="*[local-name()='rights']">
        <PROP NAME="Rights">
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
    </xsl:template>
-->    
    <xsl:template match="*[local-name()='language']">
        <xsl:text>&#x9;"language": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>

<!--        
        <xsl:variable name="length" select="string-length(.)"/>
        
        <xsl:variable name="lastchar" select="substring(., $length)"/>
        
        <PROP NAME="Language">
                <xsl:choose>
                    <xsl:when test="$lastchar = ';'">
                        <xsl:value-of select="substring(., '0', $length)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
        </PROP>
-->        
    </xsl:template>
    
<!--   <xsl:template match="*[local-name()='medium']">
        <xsl:variable name="length" select="string-length(.)"/>
        
        <xsl:variable name="lastchar" select="substring(., $length)"/>
        
        <PROP NAME="FormatMedium">
                <xsl:choose>
                    <xsl:when test="$lastchar = ';'">
                        <xsl:value-of select="substring(., '0', $length)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
        </PROP>
    </xsl:template>
-->
    
    <xsl:template match="*[local-name()='identifier']" mode="dc">
        
        <xsl:variable name="theurl">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:variable>
        
        <xsl:text>&#x9;"url": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"{\"type\":\"fulltext\",\"href\":\"</xsl:text>
        <xsl:value-of select="$theurl"/>
        <xsl:text>\",\"text\":\"</xsl:text>
        <xsl:value-of select="$theurl"/>
        <xsl:text>\"}"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>

<!--
            <xsl:otherwise>
    "SecondaryURL": "Details on this thesis, including date it will become available online",
    "Access Restrictions": "This thesis is currently under embargo and is not freely available online. Visit the link in the full record tab to see when it will become available.",
    "999Lib": "UNC",
    "999Lib_orig": "UNC",
    "999Loc": "UNC",
    "999ItemNote": "Embargoed item. Full text not currently available. See details in Full Record tab for more information.",
            </xsl:otherwise> -->

    </xsl:template>
<!--    
    <xsl:template match="*[local-name()='identifier']" mode="qualifieddc">
        
        <xsl:choose>-->
            <!-- ignore identifier elements that begin with Interviewee name -->
            <!-- <xsl:when test="starts-with(.,'http:')">
                
                <PROP NAME="PrimaryURL">
                        <xsl:value-of select="normalize-space(.)"/>
                </PROP>
            </xsl:when>
            
            <xsl:when test="starts-with(.,'Interview with')"> </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$setSpec!='sohp'">
                        
                        <PROP NAME="Identifier">
                                <xsl:value-of select="normalize-space(.)"/>
                        </PROP>
                        
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="*[local-name()='host']">
        <PROP NAME="Host">
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
    </xsl:template> -->
    
    <xsl:template match="*[local-name()='contributor']">
        
        <xsl:choose>
            <xsl:when test="$setSpec='admin_set:Dissertations' or $setSpec='MastersPapers'">
                <xsl:choose>
                    <xsl:when test="position() &gt; 1">
                        <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;&#x9;"name": "</xsl:text>
                        <xsl:value-of select="normalize-space(.)"/>
                        <xsl:text>",&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;&#x9;"type": "thesis advisor",&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;&#x9;"rel": ["thesis advisor"]&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;}</xsl:text>
                        <xsl:if test="position() != last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            
            <xsl:otherwise>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
 <!--
    <xsl:template match="*[local-name()='repository']">
        <PROP NAME="Repository">
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
    </xsl:template>
    <xsl:template match="*[local-name()='host']">
        <PROP NAME="Host">
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
    </xsl:template>
    
    <xsl:template match="*[local-name()='relation']">
        <PROP NAME="OriginalPublication">
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
    </xsl:template>
-->
    
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
        
        
        
<!--        
        <xsl:choose>

            <xsl:when test="floor($year) = $year">
>
                <PROP NAME="YearPublished">
                        <xsl:value-of select="$year"/>
                </PROP>

            </xsl:when>
        </xsl:choose>
        
        
        <xsl:choose>

            <xsl:when test="floor($first4chars) = $first4chars">
                
                <PROP NAME="CoverageTemporal">
                        <xsl:value-of select="normalize-space(.)"/>
                </PROP>
                
            </xsl:when>
            <xsl:when test="floor($last4chars) = $last4chars">
                
                <PROP NAME="CoverageTemporal">
                        <xsl:value-of select="$last4chars"/>
                </PROP>
                
            </xsl:when>
            
        </xsl:choose>
        
        
        <PROP NAME="DatePublished">
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
        
        
        
    </xsl:template>-->
</xsl:template>    
    <xsl:template match="*[local-name()='publisher'][1]">

                <xsl:value-of select="normalize-space(.)"/>

    </xsl:template>
<!--    
    <xsl:template match="*[local-name()='caption']">
        <PROP NAME="Caption">
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
    </xsl:template>
-->
<!--    
    <xsl:template match="*[local-name()='subject']">
        
        <xsl:choose>
            <xsl:when test="$setSpec='admin_set:Dissertations'">
                <PROP NAME="710a">
                        <xsl:value-of select="normalize-space(.)"/>
                        <xsl:text>|degree granting institution</xsl:text>
                </PROP>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="parseSubject">
                    <xsl:with-param name="list" select="."/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->
<!--
    <xsl:template match="*[local-name()='spatial']">
        <xsl:choose>
            <xsl:when test="$setSpec='ncmaps'">
    "CoverageSpatial": "<xsl:choose>
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
                        <xsl:value-of select="normalize-space(.)"/>",
            </xsl:when>
            <xsl:otherwise>
                <PROP NAME="Spatial">
                        <xsl:value-of select="normalize-space(.)"/>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->
<!--     
    <xsl:template match="*[local-name()='coverageSpatial']">
    "CoverageSpatial": "<xsl:value-of select="normalize-space(.)"/>",
    </xsl:template>
-->
<!--
    <xsl:template match="*[local-name()='coverage']">
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
                        <xsl:value-of select="normalize-space(.)"/>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->    
    
    
    <xsl:template match="*[local-name()='description'][position()=1]">
        <xsl:variable name="count">
            <xsl:number format="001"/>
        </xsl:variable>
        
        <xsl:choose>
            <!--
            <xsl:when test="$setSpec='mackinney'">
                <PROP NAME="Title">
                        <xsl:value-of select="normalize-space(.)"/>
                </PROP>
            </xsl:when>
            -->
            <xsl:when test="$setSpec='MastersPapers' or 'admin_set:Dissertations'">
                <xsl:text>&#x9;"note_summary": [&#xA;</xsl:text>
                <xsl:text>&#x9;&#x9;"</xsl:text>
                <xsl:call-template name="jsonescape"/>
                <xsl:text>"&#xA;</xsl:text>
                <xsl:text>&#x9;],&#xA;</xsl:text>
                </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
<!--    
    <xsl:template match="*[local-name()='abstract']">
        <xsl:variable name="count">
            <xsl:number format="001"/>
        </xsl:variable>
        
        <PROP NAME="Abstract">
                <xsl:text>seq</xsl:text>
                <xsl:value-of select="$count"/>
                <xsl:text>|</xsl:text>
                <xsl:value-of select="normalize-space(.)"/>
        </PROP>
    </xsl:template>
-->    
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
<!--    
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
-->
<!--
    <xsl:template match="*[local-name()='source']">
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
                        <xsl:text>Interview with </xsl:text>
                        <xsl:value-of select="$interviewee"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$createDate"/>
                        <xsl:text>. Interview  </xsl:text>
                        <xsl:value-of select="$interviewTitle"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="$sourceString"/>
                </PROP>
                
                <PROP NAME="Citation">
                        <xsl:value-of select="$sourceString"/>
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
                        <xsl:value-of select="normalize-space($sourceCollection)"/>
                </PROP>
            </xsl:otherwise>
        </xsl:choose>
        
        
        
    </xsl:template>
-->    
<!--    
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
            <xsl:text> - </xsl:text>
        </xsl:variable>
        <xsl:variable name="doubledashspace">
            <xsl:text> - </xsl:text>
        </xsl:variable>
        
        <PROP NAME="Subject">
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="$newSubject"/>
                    <xsl:with-param name="replace" select="$doubledash"/>
                    <xsl:with-param name="by" select="$doubledashspace"/>
                </xsl:call-template>
        </PROP>
        
        <PROP NAME="Subjects">
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="$newSubject"/>
                    <xsl:with-param name="replace" select="$doubledash"/>
                    <xsl:with-param name="by" select="$doubledashspace"/>
                </xsl:call-template>
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
                <xsl:value-of select="normalize-space($string)"/>
                <xsl:text> Interviewer</xsl:text>
        </PROP>
        
        
    </xsl:template>
-->    
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
        <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"name": "</xsl:text>
        <xsl:value-of select="normalize-space($string)"/>
        <xsl:text>",&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"type": "creator",&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"rel": ["creator"]&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;},&#xA;</xsl:text>
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
                <xsl:value-of select="normalize-space($string)"/>
        </PROP>
    </xsl:template>
    
    <!--general template to escape reserved JSON characters-->
    <xsl:template name="jsonescape">
        <xsl:param name="str" select="."/>
        <xsl:param name="escapeChars" select="'\&quot;'" />
        <xsl:variable name="first" select="substring(translate($str, translate($str, $escapeChars, ''), ''), 1, 1)" />
        <xsl:choose>
            <xsl:when test="$first">
                <xsl:value-of select="concat(substring-before($str, $first), '\', $first)"/>
                <xsl:call-template name="jsonescape">
                    <xsl:with-param name="str" select="substring-after($str, $first)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($str)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
</xsl:stylesheet>
