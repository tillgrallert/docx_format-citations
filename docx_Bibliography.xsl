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
    xmlns:till="http://www.sitzextase.de">

    <xsl:output method="xml" name="xml" encoding="UTF-8" indent="yes" version="1.0"/>
    <xsl:output method="html" name="html" encoding="UTF-8" indent="yes"/>

    <!-- this stylesheet re-unites the information generated through DocxFormatCitations.xsl. It has to be performed on the TempFootnotesXml.xml. The stylesheet searches the file for my private citation IDs and looks them up in the corresponding TempBibliographyXml.xml. -->


    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>
    <xsl:variable name="vgTempBibl" select="document(concat('/BachUni/projekte/XML/DocxCitations/temp/',format-date(current-date(),'[Y0000][M01][D01]'),'/TempBibliographyXml.xml'))"/>
    <xsl:param name="pgLibrary"
        select="document('/BachUni/projekte/XML/Sente XML exports/all/sources 140112.xml')"/>
    
<!--    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
        </xsl:copy>
    </xsl:template>-->
 
    
    <xsl:template match="/">
        <xsl:result-document href="/BachUni/projekte/XML/DocxCitations/temp/{format-date(current-date(),'[Y0000][M01][D01]')}/CitedReferences.xml" method="xml">
            <tss:senteContainer>
                <tss:library>
                    <tss:references>
                        <xsl:for-each-group select="$vgTempBibl/till:bibliography/till:refGroup/till:reference" group-by="@citation">
                                <xsl:sort select="current-grouping-key()"/>
                            <xsl:copy-of select="$pgLibrary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:characteristics/tss:characteristic[@name='Citation identifier']=current-grouping-key()]"/>
                            </xsl:for-each-group>
                    </tss:references>
                </tss:library>
            </tss:senteContainer>
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
                        <xsl:value-of select="$vTextBefore"/>
                        <xsl:if test="$vCitID!=''">
                            <!-- vCitID should be a string of number;number;number -->
                            <xsl:variable name="vFnId" select="tokenize($vCitID,';')[1]"/>
                            <xsl:variable name="vRId" select="tokenize($vCitID,';')[2]"/>
                            <xsl:variable name="vN" select="tokenize($vCitID,';')[3]"/>
                            <xsl:for-each select="$vgTempBibl/till:bibliography/till:refGroup">
                                <xsl:if test="@fnId=$vFnId and @rId=$vRId and @n=$vN">
                                    <xsl:for-each select="./till:reference">
                                       <xsl:value-of select="normalize-space(.)"/>
                                       <xsl:choose>
                                           <xsl:when test="position()!=last()">
                                               <xsl:text>, </xsl:text>
                                           </xsl:when>
                                       </xsl:choose>
                                    </xsl:for-each>
                                </xsl:if>
                                
                            </xsl:for-each>
                            <!--<xsl:value-of select="concat('{',$vFnId,';',$vRId,';',position(),'}')"/>-->
                        </xsl:if>
                        <xsl:if test="position()=last()">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
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

</xsl:stylesheet>
