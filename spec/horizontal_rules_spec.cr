require "./spec_helper"

describe "Horizontal rules" do
  it "parses ---" do
    doc = Kramdown::Document.new("---")
    doc.to_html.should eq("<hr />\n")
  end

  it "parses ***" do
    doc = Kramdown::Document.new("***")
    doc.to_html.should eq("<hr />\n")
  end

  it "parses ___" do
    doc = Kramdown::Document.new("___")
    doc.to_html.should eq("<hr />\n")
  end

  it "parses with spaces" do
    doc = Kramdown::Document.new("- - -")
    doc.to_html.should eq("<hr />\n")
  end

  it "parses long rules" do
    doc = Kramdown::Document.new("----------")
    doc.to_html.should eq("<hr />\n")
  end
end
