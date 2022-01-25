1. Search each paragraph object individually for the query. Must return the paragraph as strings.
    - Generate a hash object like the latter one below. Chapter title as keys, arrays for each matching paragraph in the chapter as values. We will iterate on two levels: the chapter title/number hash, and the array of hashes.
{
  1 => "title_of_chapter"
}

{
  { title: "{chapter_title}", chap_num: int } 
  => [{ anchor: int, paragraph: string }, ...]
}
    - Make a method to create the array
    - Make a method to create the hashes

2. Add numbered #id's to each paragraph before printing.
    - In the "/chapters/#" route, incrementally increasing integers must be added as #id attributes. 
3. Modify the result links' href attributes to include the anchor.
4. Modify the links to be sublists under their respective chapter.



Requirements:
input:  query string
output:
  - TITLE
  - BULLETED LIST OF CHAPTERS
  - Beneath each chapter, a BULLETED LIST OF PARAGRAPH LINKS in quotes

Requirements:
  - Paragraph links must contain ANCHOR REFERENCES to chapter pages, corresponding to their paragraph. (Finished)
  - Links must be made out to those anchor points.
  - Chapter pages must contain id anchors. 