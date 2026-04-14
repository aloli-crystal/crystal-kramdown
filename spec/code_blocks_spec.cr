require "./spec_helper"

describe "Code blocks" do
  describe "fenced code blocks" do
    it "parses ``` blocks" do
      md = "```\nputs 1\n```"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<pre><code>puts 1\n</code></pre>\n")
    end

    it "parses ``` with language" do
      md = "```ruby\nputs 1\n```"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<pre><code class=\"language-ruby\">puts 1\n</code></pre>\n")
    end

    it "parses ~~~ blocks" do
      md = "~~~\ncode\n~~~"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<pre><code>code\n</code></pre>\n")
    end

    it "parses multi-line fenced blocks" do
      md = "```crystal\nx = 1\ny = 2\nputs x + y\n```"
      doc = Kramdown::Document.new(md)
      html = doc.to_html
      html.should contain("language-crystal")
      html.should contain("x = 1\ny = 2\nputs x + y\n")
    end

    it "preserves HTML entities in code blocks" do
      md = "```\n<div>hello</div>\n```"
      doc = Kramdown::Document.new(md)
      doc.to_html.should contain("&lt;div&gt;hello&lt;/div&gt;")
    end
  end

  describe "indented code blocks" do
    it "parses 4-space indented code" do
      md = "    x = 1\n    y = 2"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<pre><code>x = 1\ny = 2\n</code></pre>\n")
    end
  end
end
