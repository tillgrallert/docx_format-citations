<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
    xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:mv="urn:schemas-microsoft-com:mac:vml" 
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
    xmlns:v="urn:schemas-microsoft-com:vml"
    xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    xmlns:w10="urn:schemas-microsoft-com:office:word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
    xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
    xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
    xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
    xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:till="http://www.sitzextase.de"
    xmlns="http://www.w3.org/1999/xhtml">

    <xsl:output method="xml" name="xml" encoding="UTF-8" indent="yes" version="1.0"/>
    <xsl:output method="html" name="html" encoding="UTF-8" indent="yes"/>

    <!-- this stylesheet re-unites the information generated through DocxFormatCitations.xsl. It has to be performed on the TempFootnotesXml.xml. The stylesheet searches the file for my private citation IDs and looks them up in the corresponding TempBibliographyXml.xml. -->
    
    <!-- v2: in order to format correctly format italics, the temporary citations must be further processes, which already contain such information:
    <till:reference citation="Bauernfeind 1889b">Bauernfeind <w:r
              w:rsidRPr="00F9512">
            <w:rPr>
               <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
               <w:i/>
               <w:noProof/>
               <w:sz w:val="18"/>
               <w:szCs w:val="18"/>
            </w:rPr>
            <w:t>Reisetagebuch 1888/89</w:t>
         </w:r>,  Damaskus, entry of 9 May 1889</till:reference>
    -->


    <!-- link xslt functions: this works only with a local copy of functions_core.xsl -->
    <!--    <xsl:include href="https://rawgit.com/tillgrallert/xslt-functions/master/functions_core.xsl"/>-->
    <xsl:include href="/Volumes/Dessau HD/BachUni/BachBibliothek/GitHub/xslt-functions/functions_core.xsl"/>
 
    <xsl:variable name="vgTempBibl" select="document(concat( substring-before(base-uri(),'footnotes-temporary'),'bibliography-temporary.xml'))"/>
    
    <!-- indentity transformation -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <!-- the formatted footnotes should be saved in the word folder -->
        <xsl:result-document href="../word/footnotes-formatted.xml" method="xml">
            <xsl:apply-templates/>
        </xsl:result-document>
        <!-- all other documents are saved to a temporary folder -->
        <xsl:result-document href="../html/DuplicateCitationIDs.html" method="html">
            <html>
                <head>
                    <title>Errors <xsl:value-of select="format-date(current-date(),'[Y0000][M01][D01]')"/></title>
                </head>
                <body>
                    <div>
                        <h2>Duplicates:</h2>
                        <ul>
                            <xsl:for-each-group select="$vgTempBibl/till:bibliography/till:refGroup/till:reference[contains(.,'**duplicate**')]" group-by="@citation">
                                <xsl:sort select="current-grouping-key()"/>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat('sente://BachBibliographie/',replace(current-grouping-key(),' ','+'))"/>
                                        <xsl:value-of select="current-grouping-key()"/>
                                    </a>
                                </li>
                            </xsl:for-each-group>
                        </ul>
                        <h2>Not found:</h2>
                        <ul>
                            <xsl:for-each-group select="$vgTempBibl/till:bibliography/till:refGroup/till:reference[contains(.,'**not found**')]" group-by="@citation">
                                <xsl:sort select="current-grouping-key()"/>
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat('sente://BachBibliographie/',replace(current-grouping-key(),' ','+'))"/>
                                        <xsl:value-of select="current-grouping-key()"/>
                                    </a>
                                </li>
                            </xsl:for-each-group>
                        </ul>
                    </div>
                </body>
            </html>
        </xsl:result-document>
        <xsl:result-document href="../html/bibliography.html" method="html">
            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
            <html>
                <head>
                    <title>Bibliography <xsl:value-of select="format-date(current-date(),'[Y0000][M01][D01]')"/></title>
                    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"></meta>
                </head>
                <body>
                    <div>
                        <h2>Bibliography:</h2>
                        <xsl:variable name="vCitIDs1">
                            <xsl:for-each select="$vgTempBibl/till:bibliography/till:refGroup/till:reference/@citation">
                                <xsl:value-of select="."/>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="vCitIDs2">
                            <xsl:for-each select="tokenize($vCitIDs1,';')">
                                <xsl:choose>
                                    <xsl:when test="contains(.,'@')">
                                        <xsl:value-of select="substring-before(.,'@')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="vCitIDs3">
                            <xsl:for-each-group select="tokenize($vCitIDs2,';')" group-by=".">
                                <xsl:value-of select="current-grouping-key()"/>
                                <xsl:if test="position()!=last()">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each-group>
                        </xsl:variable>
                        <!--<xsl:call-template name="funcCitation">
                            <xsl:with-param name="pCitID" select="$vRefs"/>
                            <xsl:with-param name="pMode" select="'bibl'"/>
                            <xsl:with-param name="pOutputFormat" select="'hmtl'"/>
                        </xsl:call-template>-->
                        <xsl:call-template name="funcCitation">
                            <xsl:with-param name="pCitID" select="$vCitIDs2"/>
                            <xsl:with-param name="pMode" select="'bibl'"/>
                            <xsl:with-param name="pLibrary" select="$pgSecondary"/>
                            <!-- /BachUni/projekte/XML/Sente XML exports/all/ secondarylit 140328.xml, sources 140310.xml')"/> -->
                            <xsl:with-param name="pOutputFormat" select="'html'"/>
                            <xsl:with-param name="pBibStyle" select="'C15TillArchBib'"/>
                        </xsl:call-template>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
     
    <xsl:template match="w:t">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="vText" select="."/>
            <xsl:choose>
                <xsl:when test="contains($vText,'}') and contains($vText,'{')">
                    <xsl:for-each select="tokenize($vText,'\}')">
                        <xsl:variable name="vCitID" select="substring-after(.,'{')"/>
                        <xsl:variable name="vTextBefore" select="substring-before(.,'{')"/>
                        <!--<xsl:text> </xsl:text>-->
                        <xsl:value-of select="$vTextBefore"/><xsl:text disable-output-escaping="yes">&lt;/w:t&gt;&lt;/w:r&gt;</xsl:text>
                        <xsl:if test="$vCitID!=''">
                            <!-- vCitID should be a string of number;number;number -->
                            <xsl:variable name="vFnId" select="tokenize($vCitID,';')[1]"/>
                            <xsl:variable name="vRId" select="tokenize($vCitID,';')[2]"/>
                            <xsl:variable name="vN" select="tokenize($vCitID,';')[3]"/>
                            <xsl:for-each select="$vTemplBiblProcessed/till:bibliography/till:refGroup">
                                <xsl:if test="@fnId=$vFnId and @rId=$vRId and @n=$vN">
                                    <xsl:for-each select="./till:reference">
                                       <!--<xsl:value-of select="normalize-space(.)"/>-->
                                       <xsl:copy-of select="./child::w:r"/>
                                       <xsl:choose>
                                           <xsl:when test="position()!=last()">
                                               <w:r w:rsidRPr="00F9518">
                                                   <w:rPr>
                                                       <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                                                       <w:noProof/>
                                                       <w:sz w:val="18"/>
                                                       <w:szCs w:val="18"/>
                                                   </w:rPr>
                                                   <w:t xml:space="preserve"><xsl:text>, </xsl:text></w:t></w:r>
                                           </xsl:when>
                                       </xsl:choose>
                                    </xsl:for-each>
                                </xsl:if>
                                
                            </xsl:for-each>
                            <!--<xsl:value-of select="concat('{',$vFnId,';',$vRId,';',position(),'}')"/>-->
                        </xsl:if>
                        <xsl:if test="position()=last()">
                            <w:r
                                w:rsidRPr="00F9515">
                                <w:rPr>
                                    <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                                    <w:noProof/>
                                    <w:sz w:val="18"/>
                                    <w:szCs w:val="18"/>
                                </w:rPr>
                                <w:t xml:space="preserve"><xsl:value-of select="."/></w:t>
                            </w:r>
                        </xsl:if>
                        <xsl:text disable-output-escaping="yes">&lt;w:r w:rsidRPr="00F9516"&gt;&lt;w:rPr&gt;&lt;w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/&gt;&lt;w:noProof/&gt;&lt;w:sz w:val="18"/&gt;&lt;w:szCs w:val="18"/&gt;&lt;/w:rPr&gt;&lt;w:t xml:space="preserve"&gt;</xsl:text>
                      </xsl:for-each>
                </xsl:when>
                <!-- works correctly -->
                <xsl:otherwise>
                    <!--<xsl:text>***TEST***</xsl:text>-->
                    <xsl:value-of select="$vText"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="till:reference" mode="mError">
            <li>
                <a>
                    <xsl:attribute name="href" select="concat('sente://BachBibliographie/',@citation)"/>
                    <xsl:value-of select="."/>
                </a>
            </li>
    </xsl:template>
    <xsl:template match="till:reference" mode="mDocxFormatting">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="child::w:r">
                    <!-- probability of more than one instance of w:r in till:reference -->
                    <xsl:for-each select="child::w:r">
                        <w:r w:rsidRPr="00F9512">
                            <w:rPr>
                                <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                                <w:noProof/>
                                <w:sz w:val="18"/>
                                <w:szCs w:val="18"/>
                            </w:rPr>
                            <w:t xml:space="preserve"><!--<xsl:text> </xsl:text>--><xsl:value-of select="preceding-sibling::text()[1]"/></w:t>
                        </w:r>
                        <xsl:copy-of select="."/>
                        <xsl:if test="position()=last()">
                            <w:r
                                w:rsidRPr="00F9513">
                                <w:rPr>
                                    <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                                    <w:noProof/>
                                    <w:sz w:val="18"/>
                                    <w:szCs w:val="18"/>
                                </w:rPr>
                                <w:t xml:space="preserve"><xsl:value-of select="following-sibling::text()[1]"/></w:t>
                            </w:r>
                        </xsl:if>
                    </xsl:for-each>
                    <!--<w:r w:rsidRPr="00F9512">
                        <w:rPr>
                            <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                            <w:noProof/>
                            <w:sz w:val="18"/>
                            <w:szCs w:val="18"/>
                        </w:rPr>
                        <w:t xml:space="preserve"><xsl:text> </xsl:text><xsl:value-of select="child::w:r/preceding-sibling::text()[1]"/></w:t>
                    </w:r>
                    <xsl:copy-of select="child::w:r"/>
                    <w:r
                        w:rsidRPr="00F9513">
                        <w:rPr>
                            <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                            <w:noProof/>
                            <w:sz w:val="18"/>
                            <w:szCs w:val="18"/>
                        </w:rPr>
                        <w:t xml:space="preserve"><xsl:value-of select="child::w:r/following-sibling::text()[1]"/></w:t>
                    </w:r>-->
                </xsl:when>
                <xsl:otherwise>
                    <w:r
                        w:rsidRPr="00F9514">
                        <w:rPr>
                            <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                            <w:noProof/>
                            <w:sz w:val="18"/>
                            <w:szCs w:val="18"/>
                        </w:rPr>
                        <w:t xml:space="preserve"><xsl:text> </xsl:text><xsl:value-of select="."/></w:t>
                    </w:r>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:variable name="vTemplBiblProcessed">
        <till:bibliography>
            <xsl:for-each select="$vgTempBibl/till:bibliography/till:refGroup">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:for-each select="./till:reference">
                        <!-- v2 -->
                        <xsl:choose>
                            <xsl:when test="contains(.,'**not found**')">
                                <xsl:if test="position()=1">
                                    <till:reference>
                                        <w:r w:rsidRPr="00F9517">
                                            <w:rPr>
                                                <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                                                <w:noProof/>
                                                <w:sz w:val="18"/>
                                                <w:szCs w:val="18"/>
                                            </w:rPr>
                                            <w:t><xsl:text>{</xsl:text><xsl:value-of select="@citation"/><xsl:value-of select="if(@pages!='') then(concat('@',@pages)) else()"/>
                                                <xsl:for-each select="following-sibling::till:reference[contains(.,'**not found**')]"><xsl:text>; </xsl:text><xsl:value-of select="@citation"/><xsl:value-of select="if(@pages!='') then(concat('@',@pages)) else()"/></xsl:for-each><xsl:text>}</xsl:text>
                                            </w:t></w:r>
                                    </till:reference>
                                </xsl:if>
                                <!--<xsl:if test="preceding-sibling::till:reference[1][contains(.,'**not found**')]"/>
                            <xsl:if test="preceding-sibling::till:reference[1][not(contains(.,'**not found**'))]">
                                <xsl:text disable-output-escaping="yes">&lt;till:reference&gt; &lt;w:r w:rsidRPr="00F9517"&gt;&lt;w:rPr&gt;&lt;w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/&gt;&lt;w:noProof/&gt;&lt;w:sz w:val="18"/&gt;&lt;w:szCs w:val="18"/&gt;&lt;/w:rPr&gt;&lt;w:t xml:space="preserve"&gt;{</xsl:text>
                            </xsl:if>  
                            
                            <xsl:value-of select="."/>
                            <xsl:if test="following-sibling::till:reference[1][contains(.,'**not found**')]">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                            <xsl:if test="following-sibling::till:reference[1][not(contains(.,'**not found**'))]">
                                <xsl:text disable-output-escaping="yes">}&lt;/w:t&gt;&lt;/w:r&gt;&lt;/till:reference&gt;</xsl:text>
                            </xsl:if>-->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="mDocxFormatting"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:for-each>
        </till:bibliography>
    </xsl:variable>
    
    

</xsl:stylesheet>
