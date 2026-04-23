require "./spec_helper"

# Cross-converter consistency: `to_html` and `to_text` run on the same
# AST instance and should agree on the visible words. If the HTML
# converter adds a feature (e.g. emoji replacement, footnote anchors,
# autolink sanitisation), the text converter should carry the visible
# part of it so downstream consumers (search indexes, plain-text mail
# bodies, CLI output) stay in sync.
describe "Integration · cross-converter consistency" do
  it "preserves every word of a paragraph in both outputs" do
    source = "Hello there, this is a **bold** paragraph with *emphasis* and `code`.\n"
    html = IntegrationHelper.to_html(source)
    text = IntegrationHelper.to_text(source)

    words = ["Hello", "there", "bold", "paragraph", "emphasis", "code"]
    words.each do |w|
      html.should contain(w)
      text.should contain(w)
    end

    # HTML has markup; text does not
    html.should contain("<strong>")
    text.should_not contain("<strong>")
  end

  it "preserves list items in both outputs" do
    source = <<-MD
    - alpha
    - beta
    - gamma
    MD

    html = IntegrationHelper.to_html(source)
    text = IntegrationHelper.to_text(source)

    ["alpha", "beta", "gamma"].each do |w|
      html.should contain(w)
      text.should contain(w)
    end
  end

  it "preserves heading text in both outputs" do
    source = "# Main Title\n\n## Subsection\n\nBody.\n"
    html = IntegrationHelper.to_html(source)
    text = IntegrationHelper.to_text(source)

    html.should contain("<h1>Main Title</h1>")
    html.should contain("<h2>Subsection</h2>")
    text.should contain("Main Title")
    text.should contain("Subsection")
    text.should contain("Body.")
  end

  it "preserves link text in both outputs" do
    source = "See [the docs](https://example.com/docs) for more.\n"
    html = IntegrationHelper.to_html(source)
    text = IntegrationHelper.to_text(source)

    html.should contain(%(href="https://example.com/docs"))
    html.should contain("the docs")
    text.should contain("the docs")
  end

  it "preserves code block content in both outputs" do
    source = <<-MD
    ```crystal
    puts "hi"
    ```
    MD

    html = IntegrationHelper.to_html(source)
    text = IntegrationHelper.to_text(source)

    html.should contain("puts")
    # HTML escapes quotes to &quot; inside <code>
    html.should contain("&quot;hi&quot;")
    text.should contain("puts")
    text.should contain(%q("hi"))
  end
end
