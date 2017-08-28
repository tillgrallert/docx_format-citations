---
title: "Read me: docx_format-citations"
author: Till Grallert
date: 2017-08-26 14:43:04 +0200
---

This repository contains XSLT stylesheets to overcome formatting problems with very large Sente libraries (16+ K references in my case), custom reference types and the capitalisation of Arabic transliterated in to Latin script.

The workflow formats references in footnotes and produces a bibliography. It uses a Word .docx file as input that contains references as Sente Citation IDs in curly brackets. Everythings is done by XSLT for bibstyles / bibliographic references/ bibliographies. <!-- The workflow comprises two major steps:

1. run clean-up
2. run the formatting first on secondary literature, as the stylesheets will place those references, which they could not find, inside reference groups in front of the others. Thus, if run first on primary sources, the secondary literature will come first, even though references are otherwise sorted chronologically -->

## workflow

The actual formatting is done via `funcCitation` linked through "BachFunctions v3.xsl" in all stylesheets.

1. Run [`xsl/docx_FootnoteCleanup.xsl`](xsl/docx_FormatCitations.xsl)
    - this stylesheet cleans up a footnote.xml inside a docx file: all separators between Sente Ids ("; "), which are sometimes made into separate nodes in the xml, are rejoined.
    - *Input*: `footnotes.xml` inside the .docx package
    - *Output*: `_output/<filename>/<current date>/word/footnotes-clean.xml`  

2. Run [`xsl/docs_FormatCitations.xsl`](xsl/docs_FormatCitations.xsl)
    - this stylesheet takes a `footnote.xml` inside the microsoft word .docx file as input, searches all text nodes (`<w:t>`) for Sente citation IDs wrapped in curly braces and returns the correctly formatted reference based on a master XML file containing the Sente library defined through `pgLibrary`.
    - *Input*: `footnote.xml` or output of step 1.
    - *Options*: the stylesheets asks whether it should scan for "Sources" or "Secondary literature". Run the formatting first on secondary literature, as the stylesheets will place those references, which they could not find, inside reference groups in front of the others. Thus, if run first on primary sources, the secondary literature will come first, even though references are otherwise sorted chronologically
    - *Output*:
        1. `word/footnotes-original.xml`. This is just a direct copy of the input file to ensure data protection. 
        2. `temp/footnotes-temporary.xml`: This file retains the structure and content of the input file, but replaces all Sente Citation IDs with private placeholder keys which allow me to produce "Ibid." and shortened references based on the position in the file.
        3. `temp/bibliography-temporary.xml`: this file contains till:reference nodes with the correctly formatted references in a .docx compatible format. They are linked to the private keys in `footnotes-temporary.xml`. 
            
3. Run [`xsl/docx_FinaliseCitations.xsl`](xsl/docx_FinaliseCitations.xsl)
    - this stylesheet re-unites the information generated through DocxFormatCitations.xsl. It has to be performed on the TempFootnotesXml.xml. The stylesheet searches the file for my private citation IDs and looks them up in the corresponding TempBibliographyXml.xml.
    - *Input*: `temp/footnotes-temporary.xml` from step 2. This file is already associated with the XSLT.
    - *Output*:
        1. `word/footnotes-formatted.xml`: the contents of this file need to be saved as `footnotes.xml` inside the original .docx
        2. `html/DuplicateCitationIDs.html`: sort of a bug-report for duplicate reference IDs in the Sente library xml
        3. `html/bibliography.html`: a fully formatted bibliography of all cited references. This can then be copied as text. 

4. Run [`xsl/Update Sente with Citations.xsl`](xsl/Update Sente with Citations.xsl)
    - this stylesheet generates a Sente XML file which marks every reference cited in the .docx as such with a custom tag. This can then be used to update the Sente database and to keep track of sources used for particular papers
    - *Input*: `temp/bibliography-temporary.xml` from step 2.
    - *Output*: a Sente xml containing reference nodes with UUIDs and a custom tag with the assigner "Sente User XSLT" 