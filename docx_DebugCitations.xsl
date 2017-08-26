<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
    xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:mv="urn:schemas-microsoft-com:mac:vml" xmlns:o="urn:schemas-microsoft-com:office:office"
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

    <xsl:output method="xml" encoding="UTF-8" indent="yes" version="1.0" name="xml"/>
    <xsl:output method="text" encoding="UTF-8" name="text"/>

    <!-- this stylesheet cleans up a footnote.xml inside a docx file: all separators between Sente Ids ("; "), which are sometimes made into separate nodes in the xml, are rejoined -->

    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>

    <xsl:template match="w:footnotes">
        <xsl:result-document
            href="/BachUni/projekte/XML/DocxCitations/temp/{format-date(current-date(),'[Y0000][M01][D01]')}/Debug.txt" method="text">
            <xsl:text>#Bug Report
        </xsl:text>
            <xsl:apply-templates mode="mDebug"/>
            <xsl:text>#References
        </xsl:text>
            <xsl:variable name="vRefs">
                <xsl:apply-templates mode="mExtract"/>
            </xsl:variable>
            <xsl:for-each-group select="tokenize($vRefs,';')" group-by=".">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:value-of select="current-grouping-key()"/>
                <xsl:if test="position()!=last()">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="text()" mode="mExtract">
        <xsl:choose>
            <xsl:when test="contains(.,'}') and contains(.,'{')">
                <xsl:for-each select="tokenize(.,'\}')">
                    <xsl:variable name="vCitID" select="substring-after(.,'{')"/>
                    <!--<xsl:variable name="vTextBefore" select="substring-before(.,'{')"/>
                    <xsl:value-of select="$vTextBefore"/>-->
                    <xsl:if test="$vCitID!=''">
                        <xsl:value-of select="concat($vCitID,'; ')"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text()" mode="mDebug">
        <xsl:choose>
            <xsl:when test="contains(.,'}') and contains(.,'{')">
                <!--<xsl:text>correct RefID; </xsl:text>-->
            </xsl:when>
            <xsl:when test="contains(.,'{')">
                <xsl:value-of select="ancestor::w:footnote/@w:id"/>
                <xsl:text> opening bracket; </xsl:text>
            </xsl:when>
            <xsl:when test="contains(.,'}')">
                <xsl:value-of select="ancestor::w:footnote/@w:id"/>
                <xsl:text> closing bracket; </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:text>no RefID; </xsl:text>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



</xsl:stylesheet>
