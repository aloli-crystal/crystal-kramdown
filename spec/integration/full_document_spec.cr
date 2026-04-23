require "./spec_helper"

# Full-document round-trip: load a realistic, README-shaped Markdown
# file from disk, convert it, and assert the resulting HTML contains
# the expected structural elements. The unit specs cover each element
# in isolation; this spec makes sure a mixed document doesn't lose any
# element class along the way.
describe "Integration · full README-shaped document" do
  it "converts a realistic README mixing headings, lists, code, tables, quote, rule and link" do
    html = IntegrationHelper.to_html(IntegrationHelper.fixture("readme.md"))

    # Headings at multiple levels
    html.should contain("<h1>my-library</h1>")
    html.should contain("<h2>Installation</h2>")
    html.should contain("<h2>Usage</h2>")
    html.should contain("<h2>Features</h2>")
    html.should contain("<h2>Supported platforms</h2>")
    html.should contain("<h2>Links</h2>")
    html.should contain("<h2>License</h2>")

    # Inline emphasis + strong
    html.should contain("<strong>small</strong>")
    html.should contain("<em>things</em>")

    # Fenced code with language attribute (two blocks: yaml + crystal)
    html.should contain("language-yaml")
    html.should contain("language-crystal")

    # Unordered list with three items
    html.should contain("<ul>")
    html.should contain("Zero dependencies")
    html.should contain("Pure Crystal")
    html.should contain("MIT licensed")

    # Table (GFM extension)
    html.should contain("<table>")
    html.should contain("<th")
    html.should contain("Linux")
    html.should contain("Best-effort")

    # Blockquote
    html.should contain("<blockquote>")

    # Thematic break
    html.should contain("<hr")

    # Autolink / link with target and label
    html.should contain(%(href="LICENSE"))
    html.should contain("MIT license")
  end

  it "produces readable plain text from the same README" do
    text = IntegrationHelper.to_text(IntegrationHelper.fixture("readme.md"))

    # Human-readable words survive
    text.should contain("my-library")
    text.should contain("Installation")
    text.should contain("shards install")
    text.should contain("Pure Crystal")
    text.should contain("MIT license")

    # No HTML tags leaked
    text.should_not contain("<p>")
    text.should_not contain("<h1>")
    text.should_not contain("<table>")
    text.should_not contain("<strong>")
  end
end
