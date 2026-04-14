module Kramdown
  module Converter
    class Text
      def convert(root : Element) : String
        convert_element(root).strip + "\n"
      end

      private def convert_element(el : Element) : String
        case el.type
        when .root?
          convert_children(el)
        when .header?
          convert_children(el) + "\n\n"
        when .paragraph?
          convert_children(el) + "\n\n"
        when .text?
          el.value
        when .raw_text?
          el.value
        when .emphasis?, .strong?, .strikethrough?
          convert_children(el)
        when .code_span?
          el.value
        when .code_block?
          el.value + "\n"
        when .link?
          convert_children(el)
        when .image?
          el.attributes["alt"]? || ""
        when .list?
          convert_children(el)
        when .list_item?
          convert_children(el) + "\n"
        when .table?
          convert_table(el)
        when .blockquote?
          convert_children(el)
        when .horizontal_rule?
          "\n"
        when .line_break?
          "\n"
        when .html_block?, .html_element?
          ""
        when .blank_line?
          ""
        when .footnote_ref?
          "[#{el.value}]"
        when .footnote_def?
          ""
        when .definition_list?
          convert_children(el)
        when .definition_term?
          convert_children(el) + "\n"
        when .definition_desc?
          "  " + convert_children(el) + "\n"
        else
          convert_children(el)
        end
      end

      private def convert_children(el : Element) : String
        el.children.map { |c| convert_element(c) }.join
      end

      private def convert_table(table : Element) : String
        io = String::Builder.new
        table.children.each do |row|
          cells = row.children.map { |c| convert_children(c) }
          io << cells.join(" | ")
          io << "\n"
        end
        io << "\n"
        io.to_s
      end
    end
  end
end
