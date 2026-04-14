module Kramdown
  module Converter
    class Html
      @footnote_counter : Int32 = 0
      @footnotes : Array(Element) = [] of Element

      def convert(root : Element) : String
        @footnote_counter = 0
        @footnotes = [] of Element
        result = convert_element(root)
        unless @footnotes.empty?
          result += render_footnotes
        end
        result
      end

      private def convert_element(el : Element) : String
        case el.type
        when .root?
          convert_children(el)
        when .header?
          level = el.options["level"]? || "1"
          "<h#{level}>#{convert_children(el)}</h#{level}>\n"
        when .paragraph?
          "<p>#{convert_children(el)}</p>\n"
        when .text?
          escape_html(el.value)
        when .raw_text?
          el.value
        when .emphasis?
          "<em>#{convert_children(el)}</em>"
        when .strong?
          "<strong>#{convert_children(el)}</strong>"
        when .strikethrough?
          "<del>#{convert_children(el)}</del>"
        when .code_span?
          "<code>#{escape_html(el.value)}</code>"
        when .code_block?
          if el.attributes["class"]?
            "<pre><code class=\"#{escape_html(el.attributes["class"])}\">#{escape_html(el.value)}</code></pre>\n"
          else
            "<pre><code>#{escape_html(el.value)}</code></pre>\n"
          end
        when .link?
          href = el.attributes["href"]? || ""
          title = el.attributes["title"]?
          s = "<a href=\"#{escape_attr(href)}\""
          s += " title=\"#{escape_attr(title)}\"" if title
          s += ">#{convert_children(el)}</a>"
          s
        when .image?
          src = el.attributes["src"]? || ""
          alt = el.attributes["alt"]? || ""
          title = el.attributes["title"]?
          s = "<img src=\"#{escape_attr(src)}\" alt=\"#{escape_attr(alt)}\""
          s += " title=\"#{escape_attr(title)}\"" if title
          s += " />"
          s
        when .list?
          if el.options["type"]? == "ordered"
            "<ol>\n#{convert_children(el)}</ol>\n"
          else
            "<ul>\n#{convert_children(el)}</ul>\n"
          end
        when .list_item?
          task = el.options["task"]?
          if task
            checkbox = task == "true" ? "<input type=\"checkbox\" checked=\"\" disabled=\"\" /> " : "<input type=\"checkbox\" disabled=\"\" /> "
            "<li>#{checkbox}#{convert_children(el)}</li>\n"
          else
            "<li>#{convert_children(el)}</li>\n"
          end
        when .table?
          render_table(el)
        when .blockquote?
          "<blockquote>\n#{convert_children(el)}</blockquote>\n"
        when .horizontal_rule?
          "<hr />\n"
        when .line_break?
          "<br />\n"
        when .html_block?
          el.value
        when .html_element?
          el.value
        when .blank_line?
          ""
        when .footnote_ref?
          @footnote_counter += 1
          @footnotes << el
          n = @footnote_counter
          "<sup id=\"fnref:#{escape_attr(el.value)}\"><a href=\"#fn:#{escape_attr(el.value)}\" class=\"footnote\">#{n}</a></sup>"
        when .footnote_def?
          "" # Rendered at the end
        when .definition_list?
          "<dl>\n#{convert_children(el)}</dl>\n"
        when .definition_term?
          "<dt>#{convert_children(el)}</dt>\n"
        when .definition_desc?
          "<dd>#{convert_children(el)}</dd>\n"
        else
          convert_children(el)
        end
      end

      private def convert_children(el : Element) : String
        el.children.map { |c| convert_element(c) }.join
      end

      private def render_table(table : Element) : String
        io = String::Builder.new
        io << "<table>\n"

        header_rows = table.children.select { |r| r.options["type"]? == "header" }
        body_rows = table.children.reject { |r| r.options["type"]? == "header" }

        unless header_rows.empty?
          io << "<thead>\n"
          header_rows.each do |row|
            io << "<tr>\n"
            row.children.each do |cell|
              align = cell.attributes["align"]?
              align_attr = align ? " align=\"#{align}\"" : ""
              io << "<th#{align_attr}>#{convert_children(cell)}</th>\n"
            end
            io << "</tr>\n"
          end
          io << "</thead>\n"
        end

        unless body_rows.empty?
          io << "<tbody>\n"
          body_rows.each do |row|
            io << "<tr>\n"
            row.children.each do |cell|
              align = cell.attributes["align"]?
              align_attr = align ? " align=\"#{align}\"" : ""
              io << "<td#{align_attr}>#{convert_children(cell)}</td>\n"
            end
            io << "</tr>\n"
          end
          io << "</tbody>\n"
        end

        io << "</table>\n"
        io.to_s
      end

      private def render_footnotes : String
        return "" if @footnotes.empty?
        io = String::Builder.new
        io << "<div class=\"footnotes\">\n<ol>\n"
        @footnotes.each do |fn|
          content = fn.options["content"]? || fn.value
          io << "<li id=\"fn:#{escape_attr(fn.value)}\">\n"
          io << "<p>#{escape_html(content)}&nbsp;<a href=\"#fnref:#{escape_attr(fn.value)}\" class=\"reversefootnote\">&#8617;</a></p>\n"
          io << "</li>\n"
        end
        io << "</ol>\n</div>\n"
        io.to_s
      end

      private def escape_html(text : String) : String
        text.gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub("\"", "&quot;")
      end

      private def escape_attr(text : String) : String
        escape_html(text)
      end
    end
  end
end
