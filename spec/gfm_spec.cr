require "./spec_helper"

describe "GFM extensions" do
  describe "strikethrough" do
    it "renders ~~text~~ as <del>" do
      doc = Kramdown::Document.new("~~deleted~~")
      doc.to_html.should eq("<p><del>deleted</del></p>\n")
    end

    it "handles strikethrough with other formatting" do
      doc = Kramdown::Document.new("~~**bold deleted**~~")
      html = doc.to_html
      html.should contain("<del>")
      html.should contain("<strong>bold deleted</strong>")
    end
  end

  describe "task lists" do
    it "renders task list items with checkboxes" do
      md = "- [x] Done\n- [ ] Todo"
      doc = Kramdown::Document.new(md)
      html = doc.to_html
      html.should contain("checked")
      html.should contain("disabled")
    end
  end

  describe "tables" do
    it "renders GFM tables" do
      md = "| A | B |\n|---|---|\n| 1 | 2 |"
      doc = Kramdown::Document.new(md)
      html = doc.to_html
      html.should contain("<table>")
      html.should contain("<th>")
      html.should contain("<td>")
    end
  end

  describe "autolinks" do
    it "auto-links bare URLs" do
      doc = Kramdown::Document.new("See https://example.com for info")
      html = doc.to_html
      html.should contain("<a href=\"https://example.com\">https://example.com</a>")
    end
  end
end
