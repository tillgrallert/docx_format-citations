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

    <xsl:output method="xml" encoding="UTF-8" indent="yes" version="1.0" />

    <!-- this stylesheet takes a microsoft word .docx file as input, searches all text nodes (w:t) for Sente citation IDs wrapped in curly braces and returns the correctly formatted reference based on a master XML file containing the Sente library defined through pgLibrary -->

    <!-- PROBLEM: the formatting of bibliographies does not yet deal with the issue of Ayalon 2000a, Ayalon 2000b in all instances. In mode 'fn2' this won't be a problem, but in 'fn' things are still awry
        - Update: as the current formatting in both fn modes includes information on the title, there are letters to be appended to the publication date -->

    <!-- v4: as Word cannot deal with mmd marks for italics and bold text, I had to introduce a new marker to the funcStringTextDecoration -->
    <!-- IDEA for v4: instead of reproducing a specific XML tree, I could treat the input as a literal string through the unparsed-text() function -->

    <!-- v3a: due to applying the formatting always to individual references and not reference groups, all fancy tricks for shortening the references are lost.-->
    <!-- v3: general improvements -->
    <!-- v2: produces two files which need further processing. pgMode has been discontinued.
        1) an XML file containing reference Groups, which correspond to the groups of Citation IDs wrapped in curled braces in the original file
        - the formatting is triggered by vRefs4a as based on the position within the DOCX file, which call different modes in the funcCitation template
            - first: 'fn'
            - consecutive: 'fn2'
            - ibid.
        2) a copy of the original DOCX file containing references to the till:refGroup/@n of the first file instead of the Citation IDs -->

    <!-- v1: footnote or bibliography styles can be toggled via $pgMode -->



    <xsl:include href="../Functions/BachFunctions v3.xsl"/>

    <!--<xsl:param name="pgLibrarySources"
        select="document('/BachUni/projekte/XML/Sente XML exports/all/SourcesClean 140401.xml')"/>
    <xsl:param name="pgLibrarySecondary"
        select="document('/BachUni/projekte/XML/Sente XML exports/all/SecondaryLitAmended 140401.xml')"/>-->
    <xsl:param name="pgLibrarySources"
        select="$pgSources"/>
    <xsl:param name="pgLibrarySecondary"
        select="$pgSecondary"/>
    <!-- toggles between two modes: mSources and mSecondary -->
    <xsl:param name="pgMode" select="'mSecondary'"/>

    <!--<!-\- values: 'fn' or 'bibl' -\->
    <xsl:param name="pgMode" select="'fn'"/>-->

    <xsl:template match="/">
        <xsl:result-document
            href="/BachUni/projekte/XML/DocxCitations/temp/{format-date(current-date(),'[Y0000][M01][D01]')}/FootnotesOriginal.xml"
            method="xml">
            <xsl:apply-templates mode="mRep"/>
        </xsl:result-document>
        <xsl:result-document
            href="/BachUni/projekte/XML/DocxCitations/temp/{format-date(current-date(),'[Y0000][M01][D01]')}/TempBibliographyXml.xml"
            method="xml">
            <xsl:element name="till:bibliography">
                <!-- v3a: as I do not expect to use ibid. etc. for references to sources. -->
                <xsl:choose>
                    <xsl:when test="$pgMode = 'mSources'">
                        <xsl:copy-of select="$vRefs4b"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$vRefs4a"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:result-document>
        <xsl:result-document
            href="/BachUni/projekte/XML/DocxCitations/temp/{format-date(current-date(),'[Y0000][M01][D01]')}/TempFootnotesXml.xml"
            method="xml">
            <xsl:text disable-output-escaping="yes">&lt;?xml-stylesheet type="text/xsl" href="../../DocxFinaliseCitations%20v2.xsl"?&gt;</xsl:text>
<!--            <xsl:variable name="vClean">
                <xsl:apply-templates mode="mFn"/>
            </xsl:variable>-->
            <xsl:apply-templates mode="mFn2"/>
        </xsl:result-document>
    </xsl:template>


    <xsl:template match="node()" mode="mRep">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="mRep"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*" mode="mRep">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mRep"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- mode mFn has been disabled -->
    <xsl:template match="node()" mode="mFn">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="mFn"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*" mode="mFn">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mFn"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node()" mode="mFn2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="mFn2"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*" mode="mFn2">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mFn2"/>
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
                        <xsl:when test="./w:rPr/w:i">
                            <!--<xsl:copy>
                            <xsl:apply-templates select="@* | node()" mode="mFn"/>
                        </xsl:copy>-->
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
                            <xsl:if test="preceding-sibling::w:r[1][./w:rPr/w:i]"><![CDATA[<w:r w:rsidRPr="00F9512">
                        <w:rPr>
                            <w:rFonts w:ascii="Gentium Plus" w:hAnsi="Gentium Plus"/>
                            <w:noProof/>
                            <w:sz w:val="18"/>
                            <w:szCs w:val="18"/>
                        </w:rPr>
                        <w:t xml:space="preserve">]]></xsl:if>
                            <xsl:value-of select="./w:t"/>
                            <xsl:if test="following-sibling::w:r[1][./w:rPr/w:i]"><![CDATA[</w:t></w:r>]]></xsl:if>
                            <xsl:if test="position()=last()"><![CDATA[</w:t></w:r>]]></xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="$vFn" disable-output-escaping="yes"/>
        </xsl:copy>
    </xsl:template>
    

    <xsl:template match="w:t" mode="mFn2">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="mFn2"/>
            <xsl:variable name="vText" select="."/>
            <xsl:variable name="vFnId" select="ancestor::w:footnote/@w:id"/>
            <xsl:variable name="vRId"
                select="concat(count(ancestor::w:p/preceding-sibling::w:p)+1,'-', count(ancestor::w:r/preceding-sibling::w:r))"/>
            <!--<xsl:variable name="vRId" select="count(ancestor::w:r/preceding-sibling::w:r)"/>-->
            <xsl:choose>
                <xsl:when test="contains($vText,'}') and contains($vText,'{')">
                    <xsl:for-each select="tokenize($vText,'\}')">
                        <xsl:variable name="vCitID" select="substring-after(.,'{')"/>
                        <xsl:variable name="vTextBefore" select="substring-before(.,'{')"/>
                        <xsl:value-of select="$vTextBefore"/>
                        <xsl:if test="$vCitID!=''">
                            <xsl:value-of select="concat('{',$vFnId,';',$vRId,';',position(),'}')"/>
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

    <!-- vRefs1 creates a new till:refGroup for each group of Sente Ids found in the source file  -->
    <xsl:variable name="vRefs1">
        <!--<xsl:call-template name="tRefs"/>-->
        <xsl:for-each select=".//w:t">
            <xsl:variable name="vText" select="."/>
            <xsl:variable name="vFnId" select="ancestor::w:footnote/@w:id"/>
            <xsl:variable name="vRId"
                select="concat(count(ancestor::w:p/preceding-sibling::w:p)+1,'-', count(ancestor::w:r/preceding-sibling::w:r))"/>
            <!--<xsl:variable name="vRId" select="count(ancestor::w:r/preceding-sibling::w:r)"/>-->
            <xsl:choose>
                <xsl:when test="contains($vText,'}') and contains($vText,'{')">
                    <xsl:for-each select="tokenize($vText,'\}')">
                        <xsl:variable name="vCitID" select="substring-after(.,'{')"/>
                        <xsl:if test="contains(.,'{')">
                            <xsl:element name="till:refGroup">
                                <xsl:attribute name="fnId" select="$vFnId"/>
                                <xsl:attribute name="rId" select="$vRId"/>
                                <xsl:attribute name="n" select="position()"/>
                                <xsl:value-of select="$vCitID"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="contains($vText,'{')">
                    <xsl:variable name="vTextAfter" select="substring-before(.,'{')"/>
                    <xsl:value-of select="concat('{',$vTextAfter)"/>
                </xsl:when>
                <xsl:when test="contains($vText,'}')">
                    <xsl:variable name="vTextBefore" select="substring-before(.,'}')"/>
                    <xsl:value-of select="concat($vTextBefore,'}')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>


    <!-- vRefs2a breaks up till:refGroups that contain more than a single Sente Id and creates till:reference children -->
    <xsl:variable name="vRefs2a">
        <!-- <xsl:for-each select="tokenize(translate($vRefs1,'{',''),'\}')"> -->
        <xsl:for-each select="$vRefs1/till:refGroup">
            <xsl:element name="till:refGroup">
                <xsl:apply-templates select="@*" mode="mFn"/>
                <xsl:choose>
                    <xsl:when test="contains(.,';')">
                        <xsl:for-each select="tokenize(.,';')">
                            <xsl:element name="till:reference">
                                <xsl:attribute name="citation"
                                    select="normalize-space(if(contains(.,'@')) then(substring-before(.,'@')) else(.))"/>
                                <xsl:attribute name="pages"
                                    select="normalize-space(if(contains(.,'@')) then(substring-after(.,'@')) else())"/>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="till:reference">
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

    <!-- vRef2b sorts all references inside a till:refGroup by publication date, for which this date must be pulled from the library file -->
    <xsl:variable name="vRefs2b">
        <xsl:for-each select="$vRefs2a/till:refGroup">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="mFn"/>
                <xsl:for-each select="./till:reference">
                    <xsl:variable name="vCitId" select="@citation"/>
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="mFn"/>
                        <xsl:attribute name="date">
                            <xsl:for-each
                                select="$pgLibrarySecondary/tss:senteContainer/tss:library/tss:references/tss:reference[./tss:characteristics/tss:characteristic[@name='Citation identifier']=$vCitId]">
                                <xsl:value-of
                                    select="concat(./tss:dates/tss:date[@type='Publication']/@year,'-',format-number(./tss:dates/tss:date[@type='Publication']/@month,'00'),'-',format-number(./tss:dates/tss:date[@type='Publication']/@day,'00'))"
                                />
                            </xsl:for-each>
                        </xsl:attribute>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>

    <!-- vRefs3 establishes the position of the reference within the document: first, subsequent, ibid. -->
    <xsl:variable name="vRefs3a">
        <xsl:for-each select="$vRefs2b/till:refGroup">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="mFn"/>
                <xsl:for-each select="./till:reference">
                    <xsl:sort select="@date"/>
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="mFn"/>
                        <xsl:attribute name="position">
                            <xsl:choose>
                                <xsl:when test="preceding::till:reference/@citation=@citation">
                                    <xsl:choose>
                                        <xsl:when test="preceding::till:reference[1]/@citation=@citation">
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

    <!-- output for published secondary sources -->
    <xsl:variable name="vRefs4a">
        <xsl:for-each select="$vRefs3a/till:refGroup">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="mFn"/>
                <!--<xsl:attribute name="n" select="position()"/>-->
                <xsl:for-each select="./till:reference">
                    <xsl:copy>
                        <xsl:apply-templates select="@*" mode="mFn"/>
                        <xsl:choose>
                            <xsl:when test="@position='first'">
                                <xsl:call-template name="funcCitation">
                                    <xsl:with-param name="pCitID" select="@citation"/>
                                    <xsl:with-param name="pMode" select="'fn'"/>
                                    <xsl:with-param name="pCitedPages" select="@pages"/>
                                    <xsl:with-param name="pLibrary" select="$pgLibrarySecondary"/>
                                    <xsl:with-param name="pOutputFormat" select="'docx'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="@position='following'">
                                <xsl:call-template name="funcCitation">
                                    <xsl:with-param name="pCitID" select="@citation"/>
                                    <xsl:with-param name="pMode" select="'fn2'"/>
                                    <xsl:with-param name="pCitedPages" select="@pages"/>
                                    <xsl:with-param name="pLibrary" select="$pgLibrarySecondary"/>
                                    <xsl:with-param name="pOutputFormat" select="'docx'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="@position='ibid'">
                                <xsl:choose>
                                    <xsl:when test="position()=1">
                                        <xsl:text>Ibid.</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>ibid.</xsl:otherwise>
                                </xsl:choose>
                                <!-- missing information on cited pages -->
                                <xsl:if test="@pages!=''">
                                    <xsl:text>:</xsl:text>
                                    <xsl:value-of select="@pages"/>
                                </xsl:if>
                                <!-- if not the last in the refGroup -->
                                <xsl:if test="position()!=last()">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>
    <!-- output for archival sources etc. for which  -->
    <xsl:variable name="vRefs4b">
        <xsl:for-each select="$vRefs1/till:refGroup">
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="mFn"/>
                <xsl:element name="till:reference">
                    <xsl:attribute name="citation" select="."/>
                    <xsl:choose>
                        <xsl:when test="preceding::till:refGroup[1]=.">
                            <xsl:text>Ibid.</xsl:text>
                            <!-- missing information on cited pages -->
                            <xsl:if test="@pages!=''">
                                <xsl:text>:</xsl:text>
                                <xsl:value-of select="@pages"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="funcCitation">
                                <xsl:with-param name="pCitID" select="."/>
                                <xsl:with-param name="pMode" select="'fn'"/>
                                <xsl:with-param name="pLibrary" select="$pgLibrarySources"/>
                                <xsl:with-param name="pOutputFormat" select="'docx'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>

            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>

    <!--    <xsl:template name="tRefs">
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
