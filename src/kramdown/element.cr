module Kramdown
  class Element
    enum Type
      Root
      Header
      Paragraph
      Text
      Emphasis
      Strong
      CodeSpan
      CodeBlock
      Link
      Image
      List
      ListItem
      Table
      TableRow
      TableCell
      TableHeader
      Blockquote
      HorizontalRule
      LineBreak
      HtmlBlock
      HtmlElement
      FootnoteRef
      FootnoteDef
      DefinitionList
      DefinitionTerm
      DefinitionDesc
      TaskList
      Strikethrough
      RawText
      BlankLine
    end

    property type : Type
    property value : String
    property children : Array(Element)
    property attributes : Hash(String, String)
    property options : Hash(String, String)

    def initialize(@type : Type, @value : String = "")
      @children = [] of Element
      @attributes = {} of String => String
      @options = {} of String => String
    end

    def add_child(child : Element) : Element
      @children << child
      child
    end

    def add_child(type : Type, value : String = "") : Element
      child = Element.new(type, value)
      @children << child
      child
    end
  end
end
