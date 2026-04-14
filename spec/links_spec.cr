require "./spec_helper"

describe "Links and images" do
  describe "inline links" do
    it "parses [text](url)" do
      doc = Kramdown::Document.new("[click](https://example.com)")
      doc.to_html.should eq("<p><a href=\"https://example.com\">click</a></p>\n")
    end

    it "parses links with titles" do
      doc = Kramdown::Document.new("[click](https://example.com \"Title\")")
      doc.to_html.should eq("<p><a href=\"https://example.com\" title=\"Title\">click</a></p>\n")
    end

    it "handles formatting inside link text" do
      doc = Kramdown::Document.new("[**bold link**](https://example.com)")
      doc.to_html.should eq("<p><a href=\"https://example.com\"><strong>bold link</strong></a></p>\n")
    end
  end

  describe "reference links" do
    it "parses [text][ref]" do
      md = "[click][link1]\n\n[link1]: https://example.com"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<p><a href=\"https://example.com\">click</a></p>\n")
    end

    it "parses [text][] with implicit ref" do
      md = "[example][]\n\n[example]: https://example.com"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<p><a href=\"https://example.com\">example</a></p>\n")
    end

    it "parses reference links with titles" do
      md = "[click][ref]\n\n[ref]: https://example.com \"My Title\""
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<p><a href=\"https://example.com\" title=\"My Title\">click</a></p>\n")
    end
  end

  describe "images" do
    it "parses ![alt](url)" do
      doc = Kramdown::Document.new("![photo](image.jpg)")
      doc.to_html.should eq("<p><img src=\"image.jpg\" alt=\"photo\" /></p>\n")
    end

    it "parses images with titles" do
      doc = Kramdown::Document.new("![photo](image.jpg \"My photo\")")
      doc.to_html.should eq("<p><img src=\"image.jpg\" alt=\"photo\" title=\"My photo\" /></p>\n")
    end
  end

  describe "autolinks" do
    it "parses <url>" do
      doc = Kramdown::Document.new("<https://example.com>")
      doc.to_html.should eq("<p><a href=\"https://example.com\">https://example.com</a></p>\n")
    end

    it "parses <email>" do
      doc = Kramdown::Document.new("<user@example.com>")
      doc.to_html.should eq("<p><a href=\"mailto:user@example.com\">user@example.com</a></p>\n")
    end

    it "parses bare URLs (GFM)" do
      doc = Kramdown::Document.new("Visit https://example.com today")
      doc.to_html.should eq("<p>Visit <a href=\"https://example.com\">https://example.com</a> today</p>\n")
    end
  end
end
