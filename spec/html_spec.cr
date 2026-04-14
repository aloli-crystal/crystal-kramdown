require "./spec_helper"

describe "HTML pass-through" do
  it "passes through block HTML" do
    md = "<div class=\"note\">\nHello\n</div>"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<div class=\"note\">")
  end

  it "passes through inline HTML" do
    md = "Text with <span>inline</span> html"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<span>")
    html.should contain("</span>")
  end
end
