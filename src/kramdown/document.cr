module Kramdown
  class Document
    getter root : Element

    def initialize(source : String)
      parser = Parser.new(source)
      @root = parser.parse
    end

    def to_html : String
      converter = Converter::Html.new
      converter.convert(@root)
    end

    def to_text : String
      converter = Converter::Text.new
      converter.convert(@root)
    end
  end
end
