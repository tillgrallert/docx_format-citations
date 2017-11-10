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
    xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">

    <!-- this stylesheet takes a microsoft word .docx file as input, searches all text nodes (w:t) for Sente citation IDs wrapped in curly braces and returns a bibliography of correctly formatted reference based on a master XML file containing the Sente library defined through pgLibrary
    - footnote or bibliography styles can be toggled via $pgMode -->
    
    <!-- IDEA for v2: instead of reproducing a specific XML tree, I could treat the input as a literal string through the unparsed-text() function. This has the advantage of being able to injest any sort of input -->


   <!-- <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v2d.xsl"/>-->
    <xsl:include href="../Functions/BachFunctions v3.xsl"/>
    

    <xsl:param name="pgLibrary"
        select="document('/BachUni/projekte/XML/Sente XML exports/all/sources 130807.xml')"/>

    <!-- values: 'fn' or 'bibl' -->
    <xsl:param name="pgMode" select="'fn'"/>

    <xsl:template match="/">
        <xsl:variable name="vRefs1">
            <xsl:call-template name="tRefs"/>
        </xsl:variable>
        <xsl:variable name="vRefs2">
            <xsl:for-each select="tokenize(translate($vRefs1,'}{','; '),';')">
                <xsl:value-of select="if(contains(.,'@')) then(substring-before(.,'@')) else(.)"/>
                <xsl:text>;</xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vRefs3">
            <xsl:for-each-group select="tokenize($vRefs2,';')" group-by=".">
                <xsl:value-of select="concat(.,';')"/>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:call-template name="funcCitation">
            <xsl:with-param name="pCitID" select="$vRefs3"/>
            <xsl:with-param name="pMode" select="'bibl'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="tRefs">
        <xsl:variable name="vRefs">
            <xsl:for-each select=".//w:t">
                <xsl:variable name="vText" select="."/>
                <xsl:choose>
                    <xsl:when test="contains($vText,'}') and contains($vText,'{')">
                        <xsl:for-each select="tokenize($vText,'\}')">
                            <xsl:variable name="vCitID" select="substring-after(.,'{')"/>
                            <xsl:value-of
                                select="if(contains(.,'{')) then(concat('{',$vCitID,'}')) else()"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="contains($vText,'}')">
                        <xsl:variable name="vTextBefore" select="substring-before(.,'}')"/>
                        <xsl:value-of select="concat($vTextBefore,'}')"/>
                    </xsl:when>
                    <xsl:when test="contains($vText,'{')">
                        <xsl:variable name="vTextAfter" select="substring-before(.,'{')"/>
                        <xsl:value-of select="concat('{',$vTextAfter)"/>
                    </xsl:when>
                    <!--<xsl:otherwise>
                    <xsl:if test=".!=' '">
                        <xsl:value-of select="concat('NO CITATION: ',$vText)"/>
                    </xsl:if>
                </xsl:otherwise>-->
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space($vRefs)"/>
    </xsl:template>

    <!-- test -->
    <xsl:template match="/" mode="mFn">
        <xsl:variable name="vRefs1">
            <xsl:call-template name="tRefs"/>
        </xsl:variable>
        <xsl:variable name="vRefs2">
            <xsl:for-each select="tokenize(translate($vRefs1,'}{','; '),';')">
                <xsl:value-of select="if(contains(.,'@')) then(substring-before(.,'@')) else(.)"/>
                <xsl:text>;</xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vRefs4">
            <xsl:for-each select="tokenize($vRefs2,';')">
                <xsl:element name="reference">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="vRefs5">
            <xsl:for-each select="$vRefs4/reference">
                <xsl:copy>
                    <xsl:attribute name="position">
                        <xsl:choose>
                            <xsl:when test="preceding::reference=.">
                                <xsl:choose>
                                    <xsl:when test="preceding::reference[1]=.">
                                        <xsl:value-of select="'ibid'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="'following'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="'first'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:variable>
        <xsl:result-document href="TempBibliographyXml.xml" method="xml">
            <xsl:copy-of select="$vRefs5"/>
        </xsl:result-document>
        <!--       <xsl:variable name="vRefs3">
            <xsl:for-each-group select="tokenize($vRefs2,';')" group-by=".">
                <xsl:value-of select="concat(.,';')"/>
            </xsl:for-each-group>
        </xsl:variable>-->
        <!--        <xsl:call-template name="funcCitation">
            <xsl:with-param name="pCitID" select="$vRefs3"/>
            <xsl:with-param name="pMode" select="'bibl'"/>
        </xsl:call-template>-->
    </xsl:template>

<!-- this could be repurposed for inserting the formatted references into the original file -->
    <xsl:template match="w:t" mode="o">
        <xsl:variable name="vText" select="."/>
        <xsl:choose>
            <xsl:when test="contains($vText,'}') and contains($vText,'{')">
                <xsl:for-each select="tokenize($vText,'\}')">
                    <xsl:variable name="vCitID" select="substring-after(.,'{')"/>
                    <xsl:value-of select="if(contains(.,'{')) then(concat('{',$vCitID,'}')) else()"
                    />
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="contains($vText,'}')">
                <xsl:variable name="vTextBefore" select="substring-before(.,'}')"/>
                <xsl:value-of select="concat($vTextBefore,'}')"/>
            </xsl:when>
            <xsl:when test="contains($vText,'{')">
                <xsl:variable name="vTextAfter" select="substring-before(.,'{')"/>
                <xsl:value-of select="concat('{',$vTextAfter)"/>
            </xsl:when>
            <!--<xsl:otherwise>
                    <xsl:if test=".!=' '">
                        <xsl:value-of select="concat('NO CITATION: ',$vText)"/>
                    </xsl:if>
                </xsl:otherwise>-->
        </xsl:choose>
    </xsl:template>
    <xsl:template match="text()" mode="m">
        <xsl:analyze-string select="." regex="(\{{.+\}})">
            <xsl:matching-substring>
                <!--<xsl:variable name="vRefs" select="translate(.,'\{\}','')"/>
                 <xsl:call-template name="funcCitation">
                     <xsl:with-param name="pCitID" select="$vRefs"/>
                 </xsl:call-template>-->
                <xsl:value-of select="."/>
                <xsl:text>&#10;</xsl:text>
            </xsl:matching-substring>
            <!--<xsl:non-matching-substring>
                 <xsl:copy-of select="."/>
             </xsl:non-matching-substring>-->
        </xsl:analyze-string>
    </xsl:template>
    <xsl:template match="text()" mode="n">
        <xsl:analyze-string select="." regex="(\{{.+)">
            <xsl:matching-substring>
                <xsl:analyze-string select="." regex="(.+\}})">
                    <xsl:matching-substring>
                        <xsl:copy-of select="."/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:text>- error -</xsl:text>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:matching-substring>
            <!--<xsl:non-matching-substring>
                 <xsl:copy-of select="."/>
             </xsl:non-matching-substring>-->
        </xsl:analyze-string>
    </xsl:template>

</xsl:stylesheet>
