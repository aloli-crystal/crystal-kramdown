require "./spec_helper"

describe "Definition lists" do
  it "parses a simple definition list" do
    md = "Term\n: Definition"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<dl>")
    html.should contain("<dt>Term</dt>")
    html.should contain("<dd>Definition</dd>")
    html.should contain("</dl>")
  end

  it "parses multiple terms and definitions" do
    md = "Term 1\n: Definition 1\n\nTerm 2\n: Definition 2"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("Term 1")
    html.should contain("Definition 1")
    html.should contain("Term 2")
    html.should contain("Definition 2")
  end

  it "parses a term with multiple definitions" do
    md = "Term\n: Definition A\n: Definition B"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<dt>Term</dt>")
    html.should contain("Definition A")
    html.should contain("Definition B")
  end
end
