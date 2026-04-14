require "./spec_helper"

describe "Headings" do
  describe "ATX headings" do
    it "parses h1" do
      doc = Kramdown::Document.new("# Hello")
      doc.to_html.should eq("<h1>Hello</h1>\n")
    end

    it "parses h2" do
      doc = Kramdown::Document.new("## World")
      doc.to_html.should eq("<h2>World</h2>\n")
    end

    it "parses h3 through h6" do
      (3..6).each do |level|
        doc = Kramdown::Document.new("#{"#" * level} Heading #{level}")
        doc.to_html.should eq("<h#{level}>Heading #{level}</h#{level}>\n")
      end
    end

    it "removes trailing hashes" do
      doc = Kramdown::Document.new("## Title ##")
      doc.to_html.should eq("<h2>Title</h2>\n")
    end

    it "handles inline formatting in headings" do
      doc = Kramdown::Document.new("# Hello **world**")
      doc.to_html.should eq("<h1>Hello <strong>world</strong></h1>\n")
    end
  end

  describe "Setext headings" do
    it "parses h1 with ===" do
      doc = Kramdown::Document.new("Title\n=====")
      doc.to_html.should eq("<h1>Title</h1>\n")
    end

    it "parses h2 with ---" do
      doc = Kramdown::Document.new("Subtitle\n--------")
      doc.to_html.should eq("<h2>Subtitle</h2>\n")
    end
  end
end
