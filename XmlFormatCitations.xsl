<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
    xmlns:mv="urn:schemas-microsoft-com:mac:vml" 
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:till="http://www.sitzextase.de/xml"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:v="urn:schemas-microsoft-com:vml"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:w10="urn:schemas-microsoft-com:office:word"
    xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
    xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
    xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
    xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
    xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
    xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output encoding="UTF-8" indent="yes" method="xml" version="1.0" exclude-result-prefixes="#all"/>

    <!-- v2: as <tei:note> represented tag-abuse for the intended purpose of this stylsheet, I shifted everything over to <tei:ref type="SenteCitationID"> (reference) elements -->
    <!-- this stylesheet takes an xml file as input, searches for <tei:note> nodes of @type='SenteCitationID' and all text nodes for Sente citation IDs wrapped in curly braces and returns the correctly formatted reference based on a master XML file containing the Sente library defined through pgLibrary
    - footnote or bibliography styles can be toggled via $pgMode -->

    <!-- ATTENTION: the stylesheet inserts a <tei:ref> around any Sente CitationID, which is not allowed in DOCX files -->

    <!-- IDEA: instead of reproducing a specific XML tree, I could treat the input as a literal string through the unparsed-text() function -->

    <!-- at the moment, it works with XML (TEI, DOCX), but not with HTML files. WHY? -->

    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>

    <!-- allows selection of either $pgSources, $pgSecondary, or a document()-->
    <xsl:param name="pgLibrary"
        select="$pgSources"/>

    <!-- values: 'fn' or 'bibl' -->
    <xsl:variable name="vMode" select="'fn'"/>

    <xsl:template match="node()">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test=".=text()">
                    <xsl:call-template name="tCitLookup"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@* ">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!--<xsl:template match="text()" priority="10">
        <xsl:call-template name="tCitLookup"/>
    </xsl:template>-->
    
  <!--  <xsl:template match="@* | node() ">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>-->

    <xsl:template match="tei:teiHeader">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="./tei:fileDesc">
                    <xsl:apply-templates select="./tei:fileDesc"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="./tei:encodingDesc/tei:refsDecl">
                    <xsl:apply-templates select="./tei:encodingDesc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element inherit-namespaces="no" name="tei:encodingDesc">
                        <xsl:element inherit-namespaces="no" name="tei:refsDecl">
                            <tei:p>Bibliographic notes are marked with the <tei:gi>ref</tei:gi> element. This
                                element carries the attribute <tei:att>type</tei:att> identifying the source of the
                                reference – usually a reference managing software. <tei:att>type</tei:att>="SenteCitationID" 
                                identifies Sente as the reference manager. The <tei:att>target</tei:att>
                                attribute contains the placeholder tag used by the software
                                identified in <tei:att>type</tei:att> to refer to an individual reference or a group
                                of references.
                            </tei:p>
                        </xsl:element>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- text() is not working -->
    <xsl:template name="tCitLookup">
        <!-- <xsl:copy>-->
        <xsl:apply-templates select="@*"/>
        <xsl:variable name="vText" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="contains($vText,'}') and contains(.,'{')">
                <xsl:for-each select="tokenize($vText,'\}')">
                    <xsl:variable name="vCitID" select="substring-after(.,'{')"/>
                    <xsl:variable name="vTextBefore" select="substring-before(.,'{')"/>
                    <xsl:value-of select="$vTextBefore"/>
                    <xsl:if test="$vCitID!=''">
                        <!-- toggle for TEI files only -->
                        <xsl:element name="tei:ref">
                            <xsl:attribute name="type" select="'SenteCitationID'"/>
                            <xsl:attribute name="target">
                                <xsl:value-of disable-output-escaping="yes" select="$vCitID"/>
                            </xsl:attribute>
                            <!--<xsl:call-template name="funcCitation">
                                <xsl:with-param name="pCitID" select="$vCitID"/>
                                <xsl:with-param name="pMode" select="$vMode"/>
                                <xsl:with-param name="pLibrary" select="$pgLibrary"/>
                                <xsl:with-param name="pOutputFormat" select="'tei'"/>
                            </xsl:call-template>-->
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="position()=last()">
                        <xsl:value-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
        <!--</xsl:copy>-->
    </xsl:template>

    <xsl:template match="tei:ref[@type='SenteCitationID']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="tei:bibl">
                <xsl:call-template name="funcCitation">
                    <xsl:with-param name="pCitID" select="@target"/>
                    <xsl:with-param name="pMode" select="$vMode"/>
                    <xsl:with-param name="pLibrary" select="$pgLibrary"/>
                    <xsl:with-param name="pOutputFormat" select="'tei'"/>
                </xsl:call-template>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
