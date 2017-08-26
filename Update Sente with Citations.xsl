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
    
    <!-- this stylesheet is run on the TempBibliographyXml file and produces a Sente library xml file with UUIDs and custom tags for all cited references -->
    
    <xsl:include href="../Functions/BachFunctions v3.xsl"/>
    
    <xsl:param name="pgLibrarySources"
        select="document('/BachUni/projekte/XML/Sente XML exports/all/SourcesClean 140401.xml')"/>
    <xsl:param name="pgLibrarySecondary"
        select="document('/BachUni/projekte/XML/Sente XML exports/all/SecondaryLitAmended 140401.xml')"/>
    <!-- toggles between two modes: mSources and mSecondary -->
    <xsl:param name="pMode" select="'mSources'"/>
    
    <xsl:param name="pContext" select="'PhD thesis'"/>
    <xsl:variable name="vLibrary" select="if($pMode='mSecondary') then($pgLibrarySecondary) else($pgLibrarySources)">
    </xsl:variable>
    
    <xsl:template match="till:bibliography">
        <xsl:result-document href="referenced literature-{$pMode}-{format-date(current-date(),'[Y0000][M01][D01]')}.xml">
            <xsl:element name="tss:senteContainer">
                <xsl:element name="tss:library">
                    <xsl:element name="tss:references">
                        <xsl:for-each-group select="descendant::till:reference" group-by="@citation">
                            <xsl:sort select="current-grouping-key()"/>
                            <xsl:variable name="vCitID" select="current-grouping-key()"/>
                            <xsl:variable name="vUUID">
                                <xsl:call-template name="funcCitUUID">
                                    <xsl:with-param name="pCitID" select="$vCitID"/>
                                    <xsl:with-param name="pLibrary" select="$vLibrary"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:if test="$vUUID!=''">
                                <xsl:element name="tss:reference">
                                    <xsl:element name="tss:characteristics">
                                        <xsl:element name="tss:characteristic">
                                            <xsl:attribute name="name" select="'UUID'"/>
                                            <xsl:value-of select="$vUUID"/>
                                        </xsl:element>
                                    </xsl:element>
                                    <xsl:element name="tss:keywords">
                                        <xsl:element name="tss:keyword">
                                            <xsl:attribute name="assigner" select="'Sente User XSLT'"/>
                                            <xsl:text>referenced: </xsl:text>
                                            <xsl:value-of select="$pContext"/>
                                        </xsl:element>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:if>
                        </xsl:for-each-group>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>