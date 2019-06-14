<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:unc="http://yourdomain.com/lookup" extension-element-prefixes="unc" version="1.0">
    <xsl:output omit-xml-declaration="yes" method="text" indent="no"/>
    
    <xsl:variable name="setSpec">
        <xsl:choose>
            
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request']/@set='admin_set:Dissertations'">admin_set:Dissertations</xsl:when>
            <xsl:when test="*[local-name()='OAI-PMH']/*[local-name()='request'][contains(@resumptionToken, 'admin_set:Dissertations')]">admin_set:Dissertations</xsl:when>

            <xsl:otherwise>
                <xsl:text>MastersPapers</xsl:text>
            </xsl:otherwise>
        
        </xsl:choose>
    </xsl:variable>
    
    <!--Set up lookup to assign OCLC numbers based on ETD ID, for ETDs-->
    <xsl:variable name="idLookups" select="document('id_map.xml')"/>
    <xsl:key name="idLookup" match="idmapping" use="@etdid"/>
    
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
        <xsl:variable name="isItArt">
            <xsl:choose>
                <xsl:when test="*[local-name()='metadata']/*[local-name()='dc']/*[local-name()='type']='Art'">art</xsl:when>
            <xsl:otherwise>notArt</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$isItArt='notArt'">
        <xsl:text>{&#xA;</xsl:text>
        
        <xsl:apply-templates select="*[local-name()='header']"/>
        
        <xsl:apply-templates select="*[local-name()='metadata']"/>
        
        <xsl:text>&#x9;"virtual_collection": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"TRLN Shared Records. </xsl:text>
        <xsl:if test="$setSpec='admin_set:Dissertations'">
            <xsl:text>UNC-Chapel Hill Electronic Theses and Dissertations</xsl:text>
        </xsl:if>
        <xsl:if test="$setSpec='MastersPapers'">
            <xsl:text>UNC-Chapel Hill Master's Paper Collection</xsl:text>
        </xsl:if>
        <xsl:text>."&#xA;</xsl:text>
        
        <xsl:text>&#x9;], &#xA;</xsl:text>
                
        <xsl:text>&#x9;"record_data_source": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"DC", "Shared Records", </xsl:text>
        <xsl:if test="$setSpec='admin_set:Dissertations'">
            <xsl:text>"UNC-Chapel Hill Electronic Theses and Dissertations"&#xA;</xsl:text>
        </xsl:if>
        <xsl:if test="$setSpec='admin_set:MastersPapers'">
            <xsl:text>"UNC-Chapel Hill Master's Paper Collection"&#xA;</xsl:text>
        </xsl:if>
        <xsl:text>&#x9;],&#xA;</xsl:text>
                
        <xsl:text>&#x9;"available": "Available",&#xA;</xsl:text>
        
        <xsl:text>&#x9;"physical_media": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"Online"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
        
        <xsl:text>&#x9;"access_type": ["Online"],&#xA;</xsl:text>
        
        <xsl:text>&#x9;"institution": ["unc", "duke", "ncsu"],&#xA;</xsl:text>
    
        <xsl:text>&#x9;"owner": "unc"&#xA;</xsl:text>
        
        <xsl:text>}&#xA;</xsl:text>
       
        </xsl:when>
        <xsl:otherwise/>
        </xsl:choose>
    
    </xsl:template>
    
    
    <xsl:template match="*[local-name()='header']">
        <xsl:apply-templates select="*[local-name()='identifier']" mode="header"/>
        <xsl:apply-templates select="*[local-name()='datestamp']"/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='metadata']">
        <xsl:apply-templates select="*[local-name()='dc']"/>
    </xsl:template>
    
    <xsl:template match="*[local-name()='dc']">
     
        <xsl:apply-templates select="*[local-name()='identifier']" mode="dc"/>
        
        <xsl:apply-templates select="*[local-name()='title']"/>
        
        <xsl:call-template name="writePubYear"/>
        
        <xsl:call-template name="writePublisher"/>
        
        <xsl:call-template name="imprint"/>
        
        <xsl:apply-templates select="*[local-name()='language']"/>
        
        <xsl:apply-templates select="*[local-name()='type']"/>
        
        <xsl:apply-templates select="*[local-name()='description'][1]"/>
        
        <xsl:apply-templates select="*[local-name()='creator']" mode="stmRsp"/>
        
        <xsl:call-template name="writenames"/>
        
        <xsl:call-template name="writesubjects"/>
        
    </xsl:template>
    
<!-- end of dc template -->

    <!-- controls what part of dc:identifier is used to create UniqueId, etc -->

    <xsl:template match="*[local-name()='identifier']" mode="header">
        <xsl:variable name="set">
            <xsl:choose>

                <!-- inserts collection code after UNC, before uuid -->
                <xsl:when test="$setSpec='admin_set:Dissertations'">
                    <xsl:text>ETD</xsl:text>
                    <xsl:value-of select="substring-after(.,'cdr.lib.unc.edu:')"/>
                </xsl:when>
                <xsl:when test="$setSpec='MastersPapers'">
                    <xsl:text>MP</xsl:text>
                    <xsl:value-of select="substring-after(.,'cdr.lib.unc.edu:')"/>
                </xsl:when>
                
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
        
    </xsl:template> 

    
    <xsl:template match="*[local-name()='datestamp']">
        <xsl:variable name="dash">
            <xsl:text>-</xsl:text>
        </xsl:variable>
        <xsl:variable name="null">
            <xsl:text/>
        </xsl:variable>
        
        <xsl:text>&#x9;"date_cataloged":[&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
    </xsl:template>
    
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
        
    </xsl:template>
    
    <xsl:template match="*[local-name()='title']">
        <xsl:variable name="escapedTitle">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:text>&#x9;"title_main":[&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"value":"</xsl:text>
        <xsl:value-of select="$escapedTitle"/>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;}&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
            
        <xsl:text>&#x9;"title_sort": "</xsl:text>
        <xsl:value-of select="$escapedTitle"/>
        <xsl:text>",&#xA;</xsl:text>
        
    </xsl:template>
    
    <xsl:template name="writePubYear">
        <xsl:if test="*[local-name()='date']">
            <xsl:text>&#x9;"publication_year": [&#xA;</xsl:text>
            <xsl:text>&#x9;&#x9;</xsl:text>
            <xsl:apply-templates select="*[local-name()='date'][1]" mode="getdate"/>
            <xsl:text>&#xA;&#x9;],&#xA;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[local-name()='date'][1]" mode="getdate">
        <xsl:variable name="year">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:if test="$setSpec='admin_set:Dissertations'">
            <xsl:variable name="length">
                <xsl:value-of select="string-length($year)"/> 
            </xsl:variable>
            <xsl:variable name="lengthMinusFour">
                <xsl:value-of select="string-length($year)-3"/> 
            </xsl:variable>
            <xsl:value-of select="substring($year, $lengthMinusFour, $length)"/>
        </xsl:if>
        <xsl:if test="$setSpec='MastersPapers'">
            <xsl:value-of select="substring($year, 1,4)"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="writePublisher">
        <xsl:text>&#x9;"publisher": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"</xsl:text>
        <xsl:choose>
            <xsl:when test="*[local-name()='pusblisher']">
                <xsl:apply-templates select="*[local-name()='publisher'][1]" mode="getpublisher"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>University of North Carolina at Chapel Hill</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[local-name()='publisher'][1]" mode="getpublisher">
        <xsl:variable name="escapedPublisher">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:value-of select="$escapedPublisher"/> 
    </xsl:template>

    <xsl:template name="imprint">
        <xsl:text>&#x9;"imprint_main":[&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"{\"type\":\"imprint\",\"value\":\"</xsl:text>
        <xsl:text>Chapel Hill, NC : </xsl:text>
        <xsl:choose>
            <xsl:when test="*[local-name()='pusblisher']">
                <xsl:apply-templates select="*[local-name()='publisher'][1]" mode="getpublisher"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>University of North Carolina at Chapel Hill</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="*[local-name()='date'][1]" mode="getdate"/>
        <xsl:text>.\"}"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[local-name()='language']">
        <xsl:variable name="escapedLanguage">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:text>&#x9;"language": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"</xsl:text>
        <xsl:value-of select="$escapedLanguage"/>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[local-name()='type']">
        <xsl:variable name="escapedType">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:text>&#x9;"resource_type": ["</xsl:text>
        <xsl:value-of select="$escapedType"/>
        <xsl:text>"],&#xA;</xsl:text>
    </xsl:template>
 
    <xsl:template match="*[local-name()='description'][position()=1]">
        <xsl:variable name="escapedDescription">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:text>&#x9;"note_summary": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;"</xsl:text>
        <xsl:value-of select="$escapedDescription"/>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
    </xsl:template>
 
    <xsl:template match="*[local-name()='creator']" mode="stmRsp">
        <xsl:variable name="escapedCreator">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:text>&#x9;"statement_of_responsibility": [&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"value": "by </xsl:text>
        <xsl:value-of select="$escapedCreator"/>
        <xsl:text>"&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;}&#xA;</xsl:text>
        <xsl:text>&#x9;],&#xA;</xsl:text>
    </xsl:template>
 
 
    <xsl:template name="writenames">
        <xsl:if test="*[local-name()='creator']"> 
            <xsl:text>&#x9;"names": [&#xA;</xsl:text>
        
            <xsl:apply-templates select="*[local-name()='creator']" mode="namecreator"/>
            
            <xsl:choose>
                <xsl:when test="*[local-name()='publisher']">
                    <xsl:apply-templates select="*[local-name()='publisher'][1]" mode="namepublisher"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
                    <xsl:text>&#x9;&#x9;&#x9;"name": "University of North Carolina at Chapel Hill",&#xA;</xsl:text>
                    <xsl:text>&#x9;&#x9;&#x9;"type": "publisher",&#xA;</xsl:text>
                    <xsl:text>&#x9;&#x9;&#x9;"rel": ["publisher"]&#xA;</xsl:text>
                    <xsl:text>&#x9;&#x9;},&#xA;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:apply-templates select="*[local-name()='contributor']"/>
        
            <xsl:text>&#x9;],&#xA;</xsl:text>
            </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[local-name()='creator']" mode="namecreator">
        <xsl:variable name="escapedCreator">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"name": "</xsl:text>
        <xsl:value-of select="$escapedCreator"/>
        <xsl:text>",&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"type": "creator",&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"rel": ["creator"]&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;},&#xA;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[local-name()='publisher'][1]" mode="namepublisher">
        <xsl:variable name="escapedPublisher">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"name": "</xsl:text>
        <xsl:value-of select="$escapedPublisher"/>
        <xsl:text>",&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"type": "publisher",&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;"rel": ["publisher"]&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;},&#xA;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[local-name()='contributor']">
        <xsl:variable name="escapedContributor">
            <xsl:call-template name="jsonescape"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="position() &gt; 1">
                <xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
                <xsl:text>&#x9;&#x9;&#x9;"name": "</xsl:text>
                <xsl:value-of select="$escapedContributor"/>
                        <xsl:text>",&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;&#x9;"type": "thesis advisor",&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;&#x9;"rel": ["thesis advisor"]&#xA;</xsl:text>
                        <xsl:text>&#x9;&#x9;}</xsl:text>
                        <xsl:if test="position() != last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
    </xsl:template>
    
    <xsl:template name="writesubjects">
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
    
    <!--general template to escape reserved JSON characters-->
    <xsl:template name="jsonescape">
        <xsl:param name="str" select="normalize-space(.)"/>
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
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>