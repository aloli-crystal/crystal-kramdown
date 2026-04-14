require "./spec_helper"

describe "Blockquotes" do
  it "parses a simple blockquote" do
    doc = Kramdown::Document.new("> Hello world")
    doc.to_html.should eq("<blockquote>\n<p>Hello world</p>\n</blockquote>\n")
  end

  it "parses multi-line blockquotes" do
    md = "> Line one\n> Line two"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<blockquote>")
    html.should contain("Line one")
    html.should contain("Line two")
  end

  it "parses nested blockquotes" do
    md = "> Outer\n> > Inner"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<blockquote>")
    # Should have nested blockquotes
    html.scan("<blockquote>").size.should eq(2)
  end

  it "handles formatting inside blockquotes" do
    doc = Kramdown::Document.new("> **bold** text")
    html = doc.to_html
    html.should contain("<strong>bold</strong>")
  end
end
