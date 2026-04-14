require "./spec_helper"

describe "Inline formatting" do
  describe "emphasis" do
    it "parses *italic*" do
      doc = Kramdown::Document.new("*hello*")
      doc.to_html.should eq("<p><em>hello</em></p>\n")
    end

    it "parses _italic_" do
      doc = Kramdown::Document.new("_hello_")
      doc.to_html.should eq("<p><em>hello</em></p>\n")
    end
  end

  describe "strong" do
    it "parses **bold**" do
      doc = Kramdown::Document.new("**hello**")
      doc.to_html.should eq("<p><strong>hello</strong></p>\n")
    end

    it "parses __bold__" do
      doc = Kramdown::Document.new("__hello__")
      doc.to_html.should eq("<p><strong>hello</strong></p>\n")
    end
  end

  describe "code spans" do
    it "parses `code`" do
      doc = Kramdown::Document.new("`code`")
      doc.to_html.should eq("<p><code>code</code></p>\n")
    end

    it "parses ``code with backtick``" do
      doc = Kramdown::Document.new("`` code with `backtick` ``")
      doc.to_html.should eq("<p><code>code with `backtick`</code></p>\n")
    end

    it "escapes HTML in code spans" do
      doc = Kramdown::Document.new("`<div>`")
      doc.to_html.should eq("<p><code>&lt;div&gt;</code></p>\n")
    end
  end

  describe "strikethrough" do
    it "parses ~~deleted~~" do
      doc = Kramdown::Document.new("~~deleted~~")
      doc.to_html.should eq("<p><del>deleted</del></p>\n")
    end
  end

  describe "nested formatting" do
    it "handles bold inside italic" do
      doc = Kramdown::Document.new("*hello **world***")
      doc.to_html.should eq("<p><em>hello <strong>world</strong></em></p>\n")
    end
  end

  describe "escape sequences" do
    it "escapes special characters with backslash" do
      doc = Kramdown::Document.new("\\*not italic\\*")
      doc.to_html.should eq("<p>*not italic*</p>\n")
    end

    it "escapes backslash" do
      doc = Kramdown::Document.new("\\\\backslash")
      doc.to_html.should eq("<p>\\backslash</p>\n")
    end
  end
end
