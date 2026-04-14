require "./spec_helper"

describe Kramdown::Element do
  describe "#initialize" do
    it "creates an element with a type" do
      el = Kramdown::Element.new(:paragraph)
      el.type.should eq(Kramdown::Element::Type::Paragraph)
      el.value.should eq("")
      el.children.should be_empty
      el.attributes.should be_empty
      el.options.should be_empty
    end

    it "creates an element with a type and value" do
      el = Kramdown::Element.new(:text, "Hello")
      el.type.should eq(Kramdown::Element::Type::Text)
      el.value.should eq("Hello")
    end
  end

  describe "#add_child" do
    it "adds a child element" do
      parent = Kramdown::Element.new(:root)
      child = Kramdown::Element.new(:paragraph)
      parent.add_child(child)
      parent.children.size.should eq(1)
      parent.children[0].type.should eq(Kramdown::Element::Type::Paragraph)
    end

    it "adds a child by type and value" do
      parent = Kramdown::Element.new(:root)
      parent.add_child(:text, "Hello")
      parent.children.size.should eq(1)
      parent.children[0].type.should eq(Kramdown::Element::Type::Text)
      parent.children[0].value.should eq("Hello")
    end
  end
end
