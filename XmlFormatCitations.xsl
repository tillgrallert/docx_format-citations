<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:till="http://www.sitzextase.de/xml"
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

    <xsl:output method="xml" encoding="UTF-8" indent="yes" version="1.0"/>

    <!-- this stylesheet takes an xml file as input, searches for <tei:note> nodes of @type='SenteCitationID' and all text nodes for Sente citation IDs wrapped in curly braces and returns the correctly formatted reference based on a master XML file containing the Sente library defined through pgLibrary
    - footnote or bibliography styles can be toggled via $pgMode -->

    <!-- ATTENTION: the stylesheet inserts a <tei:note> around any Sente CitationID, which is not allowed in DOCX files -->

    <!-- IDEA: instead of reproducing a specific XML tree, I could treat the input as a literal string through the unparsed-text() function -->

    <!-- at the moment, it works with XML (TEI, DOCX), but not with HTML files. WHY? -->


    <xsl:include href="/BachUni/projekte/XML/Functions/BachFunctions v3.xsl"/>

    <xsl:param name="pgLibrary"
        select="document('/BachUni/projekte/XML/Sente XML exports/all/sources 140310.xml')"/>

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

    <xsl:template match="@*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:teiHeader">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="./tei:fileDesc">
                    <xsl:apply-templates select="./tei:fileDesc"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="./tei:encodingDesc">
                    <xsl:apply-templates select="./tei:encodingDesc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="tei:encodingDesc" inherit-namespaces="no">
                        <xsl:element name="tei:refsDecl" inherit-namespaces="no">
                            <xsl:element name="tei:p" inherit-namespaces="no">
                            <xsl:text>Bibliographic notes are marked with the note element. This
                                element carries the attribute @type identifying the source of the
                                reference – usually a reference managing software. The @corresp
                                attribute contains the placeholder tag used by the software
                                identified in @type to refer to an individual reference or a group
                                of references.</xsl:text>
                            </xsl:element>
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
                        <xsl:element name="tei:note">
                            <xsl:attribute name="type" select="'SenteCitationID'"/>
                            <xsl:attribute name="corresp">
                                <xsl:value-of select="$vCitID" disable-output-escaping="yes"/>
                            </xsl:attribute>
                            <xsl:call-template name="funcCitation">
                                <xsl:with-param name="pCitID" select="$vCitID"/>
                                <xsl:with-param name="pMode" select="$vMode"/>
                                <xsl:with-param name="pLibrary" select="$pgLibrary"/>
                                <xsl:with-param name="pOutputFormat" select="'tei'"/>
                            </xsl:call-template>
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
    
    <xsl:template match="tei:note[@type='SenteCitationID']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
        <xsl:call-template name="funcCitation">
            <xsl:with-param name="pCitID" select="@corresp"/>
            <xsl:with-param name="pMode" select="$vMode"/>
            <xsl:with-param name="pLibrary" select="$pgLibrary"/>
            <xsl:with-param name="pOutputFormat" select="'tei'"/>
        </xsl:call-template>
        </xsl:copy>
    </xsl:template>



    <!--<xsl:variable name="vRefs1">
        <xsl:call-template name="tRefs"/>
    </xsl:variable>
    <!-\-<xsl:variable name="vRefs2">
        <xsl:for-each select="tokenize(translate($vRefs1,'}{','; '),';')">
            <xsl:element name="reference">
                <xsl:attribute name="citation"
                    select="normalize-space(if(contains(.,'@')) then(substring-before(.,'@')) else(.))"/>
                <xsl:attribute name="pages"
                    select="normalize-space(if(contains(.,'@')) then(substring-after(.,'@')) else())"/>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>-\->
    <!-\- vRefs2a builds a tree of refGroups containing references with @citation and @pages -\->
    <xsl:variable name="vRefs2a">
        <xsl:for-each select="tokenize(translate($vRefs1,'{',''),'\}')">
            <xsl:element name="refGroup">
                <xsl:choose>
                    <xsl:when test="contains(.,';')">
                        <xsl:for-each select="tokenize(.,';')">
                            <xsl:element name="reference">
                                <xsl:attribute name="citation"
                                    select="normalize-space(if(contains(.,'@')) then(substring-before(.,'@')) else(.))"/>
                                <xsl:attribute name="pages"
                                    select="normalize-space(if(contains(.,'@')) then(substring-after(.,'@')) else())"/>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="reference">
                            <xsl:attribute name="citation"
                                select="normalize-space(if(contains(.,'@')) then(substring-before(.,'@')) else(.))"/>
                            <xsl:attribute name="pages"
                                select="normalize-space(if(contains(.,'@')) then(substring-after(.,'@')) else())"/>
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="vRefs2b">
        <xsl:for-each select="$vRefs2a/refGroup">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:for-each select="./reference">
                    <xsl:variable name="vCitId" select="@citation"/>
                    <xsl:copy>
                        <xsl:apply-templates select="@*"/>
                        <xsl:attribute name="date">
                            <xsl:for-each
                                select="$pgLibrary//tss:reference[.//tss:characteristic[@name='Citation identifier']=$vCitId]">
                                <xsl:value-of
                                    select="concat(.//tss:date[@type='Publication']/@year,'-',.//tss:date[@type='Publication']/@month,'-',.//tss:date[@type='Publication']/@day)"
                                />
                            </xsl:for-each>
                        </xsl:attribute>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>
    <!-\- vRefs3 establishes the position of the reference within the document: first, subsequent, ibid. -\->
    <!-\-<xsl:variable name="vRefs3">
        <xsl:for-each select="$vRefs2/reference">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:attribute name="position">
                    <xsl:choose>
                        <xsl:when test="preceding::reference/@citation=@citation">
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
    </xsl:variable>-\->
    <xsl:variable name="vRefs3a">
        <xsl:for-each select="$vRefs2b/refGroup">
            <xsl:copy>
                <xsl:for-each select="./reference">
                    <xsl:sort select="@date"/>
                    <xsl:copy>
                        <xsl:apply-templates select="@*"/>
                        <xsl:attribute name="position">
                            <xsl:choose>
                                <xsl:when test="preceding::reference/@citation=@citation">
                                    <xsl:choose>
                                        <xsl:when test="preceding::reference[1]/@citation=@citation">
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
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>
    <!-\-<xsl:variable name="vRefs4">
        <xsl:for-each select="$vRefs3//reference">
            <xsl:copy>
                <xsl:apply-templates select="@*"/>
                <xsl:choose>
                    <xsl:when test="@position='first'">
                        <xsl:call-template name="funcCitation">
                            <xsl:with-param name="pCitID" select="@citation"/>
                            <xsl:with-param name="pMode" select="'fn'"/>
                            <xsl:with-param name="pCitedPages" select="@pages"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="@position='following'">
                        <xsl:call-template name="funcCitation">
                            <xsl:with-param name="pCitID" select="@citation"/>
                            <xsl:with-param name="pMode" select="'fn2'"/>
                            <xsl:with-param name="pCitedPages" select="@pages"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="@position='ibid'">
                        <xsl:text>Ibid.</xsl:text>
                        <!-\- missing information on cited pages -\->
                    </xsl:when>
                </xsl:choose>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>-\->
    <xsl:variable name="vRefs4a">
        <xsl:for-each select="$vRefs3a/refGroup">
            <xsl:copy>
                <xsl:attribute name="n" select="position()"/>
                <xsl:for-each select="./reference">
                    <xsl:copy>
                        <xsl:apply-templates select="@*"/>
                        <xsl:choose>
                            <xsl:when test="@position='first'">
                                <xsl:call-template name="funcCitation">
                                    <xsl:with-param name="pCitID" select="@citation"/>
                                    <xsl:with-param name="pMode" select="'fn'"/>
                                    <xsl:with-param name="pCitedPages" select="@pages"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="@position='following'">
                                <xsl:call-template name="funcCitation">
                                    <xsl:with-param name="pCitID" select="@citation"/>
                                    <xsl:with-param name="pMode" select="'fn2'"/>
                                    <xsl:with-param name="pCitedPages" select="@pages"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="@position='ibid'">
                                <xsl:text>Ibid.</xsl:text>
                                <!-\- missing information on cited pages -\->
                                <xsl:if test="@pages!=''">
                                    <xsl:text>:</xsl:text>
                                    <xsl:value-of select="@pages"/>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>

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
                    <!-\-<xsl:otherwise>
                    <xsl:if test=".!=' '">
                        <xsl:value-of select="concat('NO CITATION: ',$vText)"/>
                    </xsl:if>
                </xsl:otherwise>-\->
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="normalize-space($vRefs)"/>
    </xsl:template>-->

</xsl:stylesheet>
