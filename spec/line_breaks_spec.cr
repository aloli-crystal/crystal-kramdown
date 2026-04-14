require "./spec_helper"

describe "Line breaks" do
  it "converts trailing backslash to <br>" do
    doc = Kramdown::Document.new("Line one\\\nLine two")
    html = doc.to_html
    html.should contain("<br />")
    html.should contain("Line one")
    html.should contain("Line two")
  end

  it "converts two trailing spaces to <br>" do
    doc = Kramdown::Document.new("Line one  \nLine two")
    html = doc.to_html
    html.should contain("<br />")
  end

  it "treats single newline as soft break" do
    doc = Kramdown::Document.new("Line one\nLine two")
    html = doc.to_html
    html.should contain("Line one Line two")
  end
end
