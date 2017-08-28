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

    <xsl:output method="xml" encoding="UTF-8" indent="yes" version="1.0"/>

    <!-- this stylesheet cleans up a footnote.xml inside a docx file: all separators between Sente Ids ("; "), which are sometimes made into separate nodes in the xml, are rejoined -->

    <xsl:include href="https://rawgit.com/tillgrallert/xslt-functions/master/functions_core.xsl"/>
    
    <xsl:param name="pFileNameInput"/>


    <xsl:template match="/">
        <xsl:result-document href="../temp/{format-date(current-date(),'[Y0000][M01][D01]')}/{$pFileNameInput} FootnotesOriginalClean.xml" method="xml">
        <xsl:apply-templates mode="mFn"/>
        </xsl:result-document>
    </xsl:template>
    
    <!-- identity transformations -->
    <xsl:template match="@* | node()" mode="mFn">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="mFn"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="w:p[parent::w:footnote]" mode="mFn">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mFn"/>
            <xsl:apply-templates select="node()[not(self::w:r[child::w:t])]" mode="mFn"/>
            <xsl:variable name="vFn">
                <xsl:for-each select="child::w:r[child::w:t]">
                    <xsl:choose>
                        <!-- italics -->
                        <xsl:when test="./w:rPr/w:i[not(@w:val='0')]">
                            <![CDATA[<w:r w:rsidRPr="00F9512">
                        <w:rPr>
                            <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                            <w:i/>
                            <w:noProof/>
                            <w:sz w:val="18"/>
                            <w:szCs w:val="18"/>
                        </w:rPr>
                        <w:t xml:space="preserve">]]><xsl:value-of select="./w:t"/><![CDATA[</w:t></w:r>]]>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="position()=1"><![CDATA[<w:r w:rsidRPr="00F9512">
                        <w:rPr>
                            <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                            <w:noProof/>
                            <w:sz w:val="18"/>
                            <w:szCs w:val="18"/>
                        </w:rPr>
                        <w:t xml:space="preserve">]]></xsl:if>
                            <xsl:if test="preceding-sibling::w:r[1][./w:rPr/w:i[not(@w:val='0')]]"><![CDATA[<w:r w:rsidRPr="00F9512">
                        <w:rPr>
                            <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                            <w:noProof/>
                            <w:sz w:val="18"/>
                            <w:szCs w:val="18"/>
                        </w:rPr>
                        <w:t xml:space="preserve">]]></xsl:if>
                            <xsl:value-of select="./w:t"/>
                            <xsl:if test="following-sibling::w:r[1][./w:rPr/w:i[not(@w:val='0')]]"><![CDATA[</w:t></w:r>]]></xsl:if>
                            <xsl:if test="position()=last()"><![CDATA[</w:t></w:r>]]></xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="$vFn" disable-output-escaping="yes"/>
        </xsl:copy>
    </xsl:template>



    <xsl:template match="w:p[descendant::w:t[@xml:space='preserve']='; ']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="w:pPr"/>
            <!-- this is the footnote number -->
            <xsl:apply-templates select="w:r[1]"/>
            
            <!-- this section joins together the entire text of the footnote into a single text field. In the process all italics etc. are lost! -->
            <xsl:element name="w:r">
                <xsl:apply-templates select="w:r[2]/@*"/>
                <xsl:apply-templates select="w:r[2]/node()[not(self::w:t)]"/>
                <xsl:element name="w:t">
                    <xsl:attribute name="xml:space">preserve</xsl:attribute>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="w:p[descendant::w:proofErr]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="w:pPr"/>
            <!-- this is the footnote number -->
            <xsl:apply-templates select="w:r[1]"/>
            
            <!-- this section joins together the entire text of the footnote into a single text field. In the process all italics etc. are lost! -->
            <xsl:element name="w:r">
                <xsl:apply-templates select="w:r[2]/@*"/>
                <xsl:apply-templates select="w:r[2]/node()[not(self::w:t)]"/>
                <xsl:element name="w:t">
                    <xsl:attribute name="xml:space">preserve</xsl:attribute>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
            </xsl:element>
        </xsl:copy>
        
    </xsl:template>



</xsl:stylesheet>
