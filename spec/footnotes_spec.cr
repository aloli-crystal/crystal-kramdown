require "./spec_helper"

describe "Footnotes" do
  it "parses footnote references" do
    md = "Text[^1] here.\n\n[^1]: Footnote content"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("fnref:1")
    html.should contain("fn:1")
    html.should contain("Footnote content")
  end

  it "renders footnote section at end" do
    md = "Hello[^note].\n\n[^note]: This is a note"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("class=\"footnotes\"")
    html.should contain("This is a note")
    html.should contain("reversefootnote")
  end

  it "numbers footnotes sequentially" do
    md = "First[^a] and second[^b].\n\n[^a]: Note A\n[^b]: Note B"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain(">1</a>")
    html.should contain(">2</a>")
  end
end
