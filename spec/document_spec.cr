require "./spec_helper"

describe Kramdown::Document do
  describe "#to_html" do
    it "converts a complete document" do
      md = <<-MD
      # Welcome

      This is a **complete** document with *various* elements.

      ## Features

      - Item one
      - Item two
      - Item three

      ```crystal
      puts "Hello"
      ```

      > A blockquote

      ---

      [Link](https://example.com)
      MD

      doc = Kramdown::Document.new(md)
      html = doc.to_html
      html.should contain("<h1>Welcome</h1>")
      html.should contain("<strong>complete</strong>")
      html.should contain("<em>various</em>")
      html.should contain("<h2>Features</h2>")
      html.should contain("<ul>")
      html.should contain("<li>Item one</li>")
      html.should contain("language-crystal")
      html.should contain("<blockquote>")
      html.should contain("<hr />")
      html.should contain("<a href=\"https://example.com\">Link</a>")
    end
  end

  describe "#to_text" do
    it "strips all formatting" do
      md = "# Title\n\nHello **world** with *emphasis*."
      doc = Kramdown::Document.new(md)
      text = doc.to_text
      text.should contain("Title")
      text.should contain("Hello world with emphasis.")
      text.should_not contain("<")
      text.should_not contain("**")
      text.should_not contain("*")
    end
  end

  describe "#root" do
    it "returns the AST root element" do
      doc = Kramdown::Document.new("# Title\n\nParagraph")
      root = doc.root
      root.type.should eq(Kramdown::Element::Type::Root)
      root.children.size.should eq(2)
      root.children[0].type.should eq(Kramdown::Element::Type::Header)
      root.children[1].type.should eq(Kramdown::Element::Type::Paragraph)
    end
  end
end
