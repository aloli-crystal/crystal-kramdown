require "./spec_helper"

describe "Lists" do
  describe "unordered lists" do
    it "parses - items" do
      md = "- one\n- two\n- three"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>\n")
    end

    it "parses * items" do
      md = "* alpha\n* beta"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<ul>\n<li>alpha</li>\n<li>beta</li>\n</ul>\n")
    end

    it "parses + items" do
      md = "+ first\n+ second"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<ul>\n<li>first</li>\n<li>second</li>\n</ul>\n")
    end
  end

  describe "ordered lists" do
    it "parses numbered items" do
      md = "1. one\n2. two\n3. three"
      doc = Kramdown::Document.new(md)
      doc.to_html.should eq("<ol>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ol>\n")
    end
  end

  describe "nested lists" do
    it "parses nested unordered list" do
      md = "- one\n  - nested\n- two"
      doc = Kramdown::Document.new(md)
      html = doc.to_html
      html.should contain("<ul>")
      html.should contain("one")
      html.should contain("nested")
      html.should contain("two")
    end
  end

  describe "task lists" do
    it "parses checked items" do
      md = "- [x] done"
      doc = Kramdown::Document.new(md)
      html = doc.to_html
      html.should contain("checked")
      html.should contain("done")
    end

    it "parses unchecked items" do
      md = "- [ ] todo"
      doc = Kramdown::Document.new(md)
      html = doc.to_html
      html.should contain("checkbox")
      html.should_not contain("checked")
      html.should contain("todo")
    end

    it "parses mixed task list" do
      md = "- [x] done\n- [ ] pending\n- [x] also done"
      doc = Kramdown::Document.new(md)
      html = doc.to_html
      html.should contain("<ul>")
      html.should contain("done")
      html.should contain("pending")
    end
  end

  describe "inline formatting in lists" do
    it "handles bold in list items" do
      md = "- **bold** item"
      doc = Kramdown::Document.new(md)
      doc.to_html.should contain("<strong>bold</strong>")
    end
  end
end
