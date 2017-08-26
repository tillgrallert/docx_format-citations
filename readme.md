# format references

- the workflow formats references in footnotes and produces a bibliography. It uses a Word .docx file as input that contains references as Sente Citation IDs in curly brackets.
- it is done by custom XSLT for bibstyles / bibliographic references/ bibliographies:
    1. run clean-up
    2. run the formatting first on secondary literature, as the stylesheets will place those references, which they could not find, inside reference groups in front of the others. Thus, if run first on primary sources, the secondary literature will come first, even though references are otherwise sorted chronologically

## workflow

The actual formatting is done via funcCitation linked through "BachFunctions v3.xsl" in all stylesheets.

1. Run "DocxFootnoteCleanup v1.xsl"
    - this stylesheet cleans up a footnote.xml inside a docx file: all separators between Sente Ids ("; "), which are sometimes made into separate nodes in the xml, are rejoined.
    - *Input*: footnote.xml inside the .docx package
    - *Output*: FootnotesOriginalClean.xml  

2. Run "DoxFormatCitations v5.xsl"
    - this stylesheet takes a footnote.xml inside the microsoft word .docx file as input, searches all text nodes (w:t) for Sente citation IDs wrapped in curly braces and returns the correctly formatted reference based on a master XML file containing the Sente library defined through pgLibrary.
    - *Input*: footnote.xml or output of step 1.
    - *Output*:
        1. FootnotesOriginal.xml. This is just a direct copy of the input file to ensure data protection. 
        2. TempFootnotesXml.xml: This file retains the structure and content of the input file, but replaces all Sente Citation IDs with private placeholder keys which allow me to produce "Ibid." and shortened references based on the position in the file.
        3. TempBibliographyXml.xml: this file contains till:reference nodes with the correctly formatted references in a .docx compatible format. They are linked to the private keys in TempFootnotesXml.xml. 
            
3. Run "DocxFinaliseCitations v2.xsl"
    - this stylesheet re-unites the information generated through DocxFormatCitations.xsl. It has to be performed on the TempFootnotesXml.xml. The stylesheet searches the file for my private citation IDs and looks them up in the corresponding TempBibliographyXml.xml.
    - *Input*: TempFootnotesXml.xml from step 2. This file is already associated with the XSLT.
    - *Output*:
        1. FootnotesFormatted.xml: the contents of this file need to be saved as footnotes.xml inside the original .docx
        2. DuplicateCitationIDs.html: sort of a bug-report for duplicate reference IDs in the Sente library xml
        3. Bibliography.html: a fully formatted bibliography of all cited references. This can then be copied as text. 

4. Run "Update Sente with Citations.xsl"
    - *Input*: TempBibliographyXml.xml from step 2.
    - *Output*: a Sente xml containing reference nodes with UUIDs and a custom tag with the assigner "Sente User XSLT" 