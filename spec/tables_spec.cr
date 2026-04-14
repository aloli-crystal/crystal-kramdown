require "./spec_helper"

describe "Tables" do
  it "parses a simple table" do
    md = "| Name | Age |\n| --- | --- |\n| Alice | 30 |\n| Bob | 25 |"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<table>")
    html.should contain("<thead>")
    html.should contain("<tbody>")
    html.should contain("<th>Name")
    html.should contain("<th>Age")
    html.should contain("<td>Alice")
    html.should contain("<td>30")
    html.should contain("<td>Bob")
    html.should contain("<td>25")
  end

  it "parses alignment" do
    md = "| Left | Center | Right |\n| :--- | :---: | ---: |\n| a | b | c |"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("align=\"left\"")
    html.should contain("align=\"center\"")
    html.should contain("align=\"right\"")
  end

  it "parses tables without leading/trailing pipes" do
    md = "Name | Age\n--- | ---\nAlice | 30"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<table>")
    html.should contain("Alice")
  end

  it "handles inline formatting in table cells" do
    md = "| Header |\n| --- |\n| **bold** |"
    doc = Kramdown::Document.new(md)
    html = doc.to_html
    html.should contain("<strong>bold</strong>")
  end
end
