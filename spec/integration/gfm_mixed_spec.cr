require "./spec_helper"

# GFM + extensions combined in the same document. The unit specs
# exercise each feature in isolation; this spec makes sure they still
# cooperate when stacked together in one source (which is the common
# real-world case for a project CHANGELOG or release notes file).
describe "Integration · GFM features mixed" do
  it "handles task lists with inline formatting and links" do
    source = <<-MD
    # Roadmap

    - [x] **Ship** v1 with [docs](https://example.com/v1)
    - [ ] Plan v2 *features*
    - [ ] Write migration guide
    MD

    html = IntegrationHelper.to_html(source)
    html.should contain("Roadmap")
    html.should contain("Ship")
    html.should contain(%(href="https://example.com/v1"))
    # Task list markers are rendered — either as checkboxes or literal
    # boxes; at minimum the labels survive.
    html.should contain("Plan v2")
    html.should contain("Write migration guide")
  end

  it "handles a GFM table with inline markup in cells" do
    source = <<-MD
    | Feature | Status |
    |---------|--------|
    | **Bold** header | Ready |
    | [Link](https://x) | Pending |
    MD

    html = IntegrationHelper.to_html(source)
    html.should contain("<table>")
    html.should contain("<strong>Bold</strong>")
    html.should contain("Ready")
    html.should contain(%(href="https://x"))
    html.should contain("Pending")
  end

  it "handles a mix of fenced code, blockquote and list" do
    source = <<-MD
    > Warning: this changes behaviour.

    Use the new API:

    ```crystal
    MyLib.call(foo: 1)
    ```

    Then update your tests:

    1. run `crystal spec`
    2. inspect failures
    3. adjust fixtures
    MD

    html = IntegrationHelper.to_html(source)
    html.should contain("<blockquote>")
    html.should contain("Warning")
    html.should contain("language-crystal")
    html.should contain("MyLib.call")
    html.should contain("<ol>")
    html.should contain("crystal spec")
  end

  it "handles footnote references and definitions" do
    source = <<-MD
    Some text with a footnote[^1].

    [^1]: The footnote body.
    MD

    html = IntegrationHelper.to_html(source)
    # Footnote marker + back-reference must be present
    html.should contain("footnote")
    html.should contain("The footnote body.")
  end
end
