module Kramdown
  class Parser
    # Reference link definitions: [id]: url "title"
    alias RefLink = NamedTuple(url: String, title: String)

    # Footnote definitions: [^id]: text
    alias FootnoteDef = NamedTuple(content: String)

    @lines : Array(String)
    @pos : Int32 = 0
    property ref_links : Hash(String, RefLink)
    property footnotes : Hash(String, FootnoteDef)

    def initialize(source : String)
      @lines = source.gsub("\r\n", "\n").gsub("\r", "\n").split("\n")
      @ref_links = {} of String => RefLink
      @footnotes = {} of String => FootnoteDef
    end

    def parse : Element
      root = Element.new(:root)
      # First pass: collect reference links and footnote definitions
      collect_references
      # Second pass: parse blocks
      @pos = 0
      parse_blocks(root)
      root
    end

    # -------------------------------------------------------------------------
    # Reference / footnote collection
    # -------------------------------------------------------------------------

    private def collect_references
      @pos = 0
      while @pos < @lines.size
        line = @lines[@pos]

        # Footnote definition: [^id]: content
        if m = line.match(/^\[\^([^\]]+)\]:\s*(.*)$/)
          id = m[1]
          content = m[2]
          # Continuation lines (indented)
          while @pos + 1 < @lines.size && @lines[@pos + 1].match(/^    /)
            @pos += 1
            content += "\n" + @lines[@pos].lstrip
          end
          @footnotes[id] = {content: content}
          @pos += 1
          next
        end

        # Reference link: [id]: url "title"
        if m = line.match(/^\[([^\]]+)\]:\s*(\S+)(?:\s+"([^"]*)")?\s*$/)
          @ref_links[m[1].downcase] = {url: m[2], title: m[3]? || ""}
          @pos += 1
          next
        end

        @pos += 1
      end
    end

    # -------------------------------------------------------------------------
    # Block-level parsing
    # -------------------------------------------------------------------------

    private def parse_blocks(parent : Element, indent : Int32 = 0)
      while @pos < @lines.size
        line = @lines[@pos]
        stripped = line.lstrip

        # Blank line
        if stripped.empty?
          @pos += 1
          next
        end

        # Skip reference link definitions (already collected)
        if stripped.matches?(/^\[([^\]]+)\]:\s*(\S+)/)
          @pos += 1
          next
        end

        # Skip footnote definitions (already collected)
        if stripped.matches?(/^\[\^([^\]]+)\]:\s*/)
          # Skip continuation lines too
          @pos += 1
          while @pos < @lines.size && @lines[@pos].starts_with?("    ")
            @pos += 1
          end
          next
        end

        # ATX Heading: # ... ######
        if m = stripped.match(/^(\#{1,6})\s+(.*)$/)
          level = m[1].size
          content = m[2].gsub(/\s*\#+\s*$/, "")
          el = parent.add_child(:header)
          el.options["level"] = level.to_s
          parse_inline(el, content)
          @pos += 1
          next
        end

        # Setext heading (check next line for === or ---)
        if @pos + 1 < @lines.size && !stripped.empty?
          next_line = @lines[@pos + 1].strip
          if next_line.matches?(/^={2,}\s*$/)
            el = parent.add_child(:header)
            el.options["level"] = "1"
            parse_inline(el, stripped)
            @pos += 2
            next
          elsif next_line.matches?(/^-{2,}\s*$/) && !stripped.starts_with?("-")
            el = parent.add_child(:header)
            el.options["level"] = "2"
            parse_inline(el, stripped)
            @pos += 2
            next
          end
        end

        # Horizontal rule
        if is_horizontal_rule?(stripped)
          parent.add_child(:horizontal_rule)
          @pos += 1
          next
        end

        # Fenced code block
        if m = stripped.match(/^(`{3,}|~{3,})(.*)$/)
          fence_char = m[1][0]
          fence_len = m[1].size
          lang = m[2].strip
          code_lines = [] of String
          @pos += 1
          while @pos < @lines.size
            cl = @lines[@pos]
            if cl.strip.starts_with?(fence_char.to_s * fence_len) && cl.strip.size >= fence_len && cl.strip.chars.all? { |c| c == fence_char }
              @pos += 1
              break
            end
            code_lines << cl
            @pos += 1
          end
          el = parent.add_child(:code_block, code_lines.join("\n") + (code_lines.empty? ? "" : "\n"))
          el.attributes["class"] = "language-#{lang}" unless lang.empty?
          el.options["language"] = lang unless lang.empty?
          next
        end

        # Indented code block (4 spaces or 1 tab, not inside a list context)
        if line.starts_with?("    ") && indent == 0
          code_lines = [] of String
          while @pos < @lines.size
            cl = @lines[@pos]
            if cl.starts_with?("    ")
              code_lines << cl[4..]
              @pos += 1
            elsif cl.strip.empty?
              code_lines << ""
              @pos += 1
            else
              break
            end
          end
          # Remove trailing blank lines
          while !code_lines.empty? && code_lines.last.empty?
            code_lines.pop
          end
          parent.add_child(:code_block, code_lines.join("\n") + "\n")
          next
        end

        # HTML block (starts with <tag)
        if stripped.matches?(/^<\/?[a-zA-Z][\w-]*(\s|>|$)/) && !stripped.matches?(/^<(a|em|strong|code|span|img|br)\b/i)
          html_lines = [line]
          @pos += 1
          while @pos < @lines.size && !@lines[@pos].strip.empty?
            html_lines << @lines[@pos]
            @pos += 1
          end
          parent.add_child(:html_block, html_lines.join("\n") + "\n")
          next
        end

        # Blockquote
        if stripped.starts_with?(">")
          bq_lines = [] of String
          while @pos < @lines.size
            cl = @lines[@pos].lstrip
            if cl.starts_with?(">")
              # Strip one level of >
              inner = cl[1..]?
              inner = inner.lstrip if inner && inner.starts_with?(" ")
              bq_lines << (inner || "")
              @pos += 1
            elsif cl.strip.empty?
              break
            else
              # Lazy continuation
              bq_lines << cl
              @pos += 1
            end
          end
          el = parent.add_child(:blockquote)
          sub_parser = Parser.new(bq_lines.join("\n"))
          sub_parser.ref_links = @ref_links
          sub_parser.footnotes = @footnotes
          sub_root = sub_parser.parse
          sub_root.children.each { |c| el.add_child(c) }
          next
        end

        # Table (GFM): detect header | sep | rows
        if stripped.includes?("|") && @pos + 1 < @lines.size
          next_stripped = @lines[@pos + 1].strip
          if next_stripped.matches?(/^\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$/)
            parse_table(parent)
            next
          end
        end

        # Definition list: term followed by : definition
        if @pos + 1 < @lines.size && @lines[@pos + 1].strip.starts_with?(": ")
          parse_definition_list(parent)
          next
        end

        # Unordered list
        if m = stripped.match(/^([-*+])\s+(.*)$/)
          parse_list(parent, :unordered, indent)
          next
        end

        # Ordered list
        if stripped.matches?(/^\d+\.\s+/)
          parse_list(parent, :ordered, indent)
          next
        end

        # Paragraph (default)
        para_lines = [] of String
        while @pos < @lines.size
          cl = @lines[@pos]
          cs = cl.strip

          break if cs.empty?
          break if cs.matches?(/^(\#{1,6})\s+/)
          break if is_horizontal_rule?(cs)
          break if cs.matches?(/^(`{3,}|~{3,})/)
          break if cs.starts_with?(">")
          break if cs.matches?(/^[-*+]\s+/)
          break if cs.matches?(/^\d+\.\s+/)
          break if cs.matches?(/^<\/?[a-zA-Z][\w-]*(\s|>|$)/) && !cs.matches?(/^<(a|em|strong|code|span|img|br)\b/i)
          break if cs.includes?("|") && @pos + 1 < @lines.size && @lines[@pos + 1].strip.matches?(/^\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$/)
          break if @pos + 1 < @lines.size && @lines[@pos + 1].strip.starts_with?(": ")

          # Setext underline ends paragraph as heading (handled above on re-loop)
          if @pos + 1 < @lines.size
            nl = @lines[@pos + 1].strip
            if nl.matches?(/^={2,}\s*$/) || (nl.matches?(/^-{2,}\s*$/) && !cs.starts_with?("-"))
              para_lines << cl.lstrip
              break
            end
          end

          # Preserve trailing spaces for hard line breaks
          para_lines << cl.lstrip
          @pos += 1
        end

        unless para_lines.empty?
          el = parent.add_child(:paragraph)
          parse_inline(el, para_lines.join("\n"))
        end
      end
    end

    # -------------------------------------------------------------------------
    # List parsing
    # -------------------------------------------------------------------------

    private def parse_list(parent : Element, kind : Symbol, base_indent : Int32)
      list = parent.add_child(:list)
      list.options["type"] = kind == :ordered ? "ordered" : "unordered"

      marker_re = kind == :ordered ? /^(\s*)\d+\.\s+(.*)$/ : /^(\s*)([-*+])\s+(.*)$/

      while @pos < @lines.size
        line = @lines[@pos]
        stripped = line.strip
        break if stripped.empty? && (@pos + 1 >= @lines.size || @lines[@pos + 1].strip.empty?)
        break if stripped.empty? && @pos + 1 < @lines.size && !@lines[@pos + 1].starts_with?(" ") && !@lines[@pos + 1].strip.matches?(kind == :ordered ? /^\d+\.\s+/ : /^[-*+]\s+/)

        if kind == :ordered
          if m = line.match(/^(\s*)\d+\.\s+(.*)$/)
            item_indent = m[1].size
            content = m[2]
            parse_list_item(list, content, kind)
            next
          end
        else
          if m = line.match(/^(\s*)([-*+])\s+(.*)$/)
            item_indent = m[1].size
            content = m[3]
            parse_list_item(list, content, kind)
            next
          end
        end

        # Blank or continuation — skip
        @pos += 1
      end
    end

    private def parse_list_item(list : Element, first_line : String, kind : Symbol)
      item = list.add_child(:list_item)
      @pos += 1

      # Task list detection
      task_checked : Bool? = nil
      content = first_line
      if m = content.match(/^\[([ xX])\]\s*(.*)$/)
        task_checked = m[1] != " "
        content = m[2]
        item.options["task"] = task_checked.to_s
      end

      # Collect continuation lines
      item_lines = [content]
      while @pos < @lines.size
        cl = @lines[@pos]
        cs = cl.strip

        break if cs.empty? && (@pos + 1 >= @lines.size || !@lines[@pos + 1].starts_with?("  "))
        break if cs.matches?(/^[-*+]\s+/) && !cl.starts_with?("  ")
        break if cs.matches?(/^\d+\.\s+/) && !cl.starts_with?("  ")

        if cl.starts_with?("  ")
          item_lines << cl[2..].lstrip
        elsif cs.empty?
          item_lines << ""
        else
          break
        end
        @pos += 1
      end

      # Check if sub-items contain nested lists
      text = item_lines.join("\n").strip
      has_nested = item_lines.any? { |l| l.matches?(/^[-*+]\s+/) || l.matches?(/^\d+\.\s+/) }

      if has_nested
        sub_parser = Parser.new(text)
        sub_parser.ref_links = @ref_links
        sub_parser.footnotes = @footnotes
        sub_root = sub_parser.parse
        sub_root.children.each { |c| item.add_child(c) }
      else
        parse_inline(item, text)
      end
    end

    # -------------------------------------------------------------------------
    # Table parsing (GFM)
    # -------------------------------------------------------------------------

    private def parse_table(parent : Element)
      table = parent.add_child(:table)

      # Header row
      header_line = @lines[@pos].strip
      @pos += 1

      # Separator row (determines alignment)
      sep_line = @lines[@pos].strip
      @pos += 1

      alignments = parse_table_separators(sep_line)

      # Parse header
      header_row = table.add_child(:table_row)
      header_row.options["type"] = "header"
      cells = split_table_row(header_line)
      cells.each_with_index do |cell, i|
        th = header_row.add_child(:table_header, cell.strip)
        if i < alignments.size && !alignments[i].empty?
          th.attributes["align"] = alignments[i]
        end
        parse_inline_into(th, cell.strip)
      end

      # Parse body rows
      while @pos < @lines.size
        line = @lines[@pos].strip
        break if line.empty?
        break unless line.includes?("|")
        @pos += 1

        row = table.add_child(:table_row)
        cells = split_table_row(line)
        cells.each_with_index do |cell, i|
          td = row.add_child(:table_cell, cell.strip)
          if i < alignments.size && !alignments[i].empty?
            td.attributes["align"] = alignments[i]
          end
          parse_inline_into(td, cell.strip)
        end
      end
    end

    private def parse_table_separators(line : String) : Array(String)
      parts = split_table_row(line)
      parts.map do |part|
        p = part.strip
        if p.starts_with?(":") && p.ends_with?(":")
          "center"
        elsif p.ends_with?(":")
          "right"
        elsif p.starts_with?(":")
          "left"
        else
          ""
        end
      end
    end

    private def split_table_row(line : String) : Array(String)
      l = line.strip
      l = l[1..] if l.starts_with?("|")
      l = l[...-1] if l.ends_with?("|")
      l.split("|")
    end

    # -------------------------------------------------------------------------
    # Definition list parsing (kramdown extension)
    # -------------------------------------------------------------------------

    private def parse_definition_list(parent : Element)
      dl = parent.add_child(:definition_list)

      while @pos < @lines.size
        line = @lines[@pos].strip
        break if line.empty? && (@pos + 1 >= @lines.size || (!@lines[@pos + 1].strip.starts_with?(": ") && (@pos + 2 >= @lines.size || !@lines[@pos + 2].strip.starts_with?(": "))))

        if line.empty?
          @pos += 1
          next
        end

        # Check if next line is a definition
        if @pos + 1 < @lines.size && @lines[@pos + 1].strip.starts_with?(": ")
          # Term
          dt = dl.add_child(:definition_term)
          parse_inline(dt, line)
          @pos += 1

          # Definitions
          while @pos < @lines.size && @lines[@pos].strip.starts_with?(": ")
            dd_text = @lines[@pos].strip[2..].strip
            dd = dl.add_child(:definition_desc)
            parse_inline(dd, dd_text)
            @pos += 1
          end
        else
          break
        end
      end
    end

    # -------------------------------------------------------------------------
    # Inline parsing
    # -------------------------------------------------------------------------

    private def parse_inline_into(el : Element, text : String)
      el.children.clear
      parse_inline(el, text)
      el.value = ""
    end

    private def parse_inline(parent : Element, text : String)
      i = 0
      buf = ""

      while i < text.size
        ch = text[i]

        # Escape sequences
        if ch == '\\' && i + 1 < text.size
          next_ch = text[i + 1]
          if "\\`*_{}[]()#+-.!~|<>".includes?(next_ch)
            buf += next_ch.to_s
            i += 2
            next
          end
        end

        # Hard line break: trailing backslash or two+ spaces before \n
        if ch == '\n'
          if buf.ends_with?("  ") || buf.ends_with?("\\")
            trimmed = buf.rstrip
            trimmed = trimmed[...-1] if trimmed.ends_with?("\\")
            flush_text(parent, trimmed)
            buf = ""
            parent.add_child(:line_break)
            i += 1
            next
          else
            buf += " "
            i += 1
            next
          end
        end

        # Footnote reference: [^id]
        if ch == '[' && i + 1 < text.size && text[i + 1] == '^'
          if m = text[i..].match(/^\[\^([^\]]+)\]/)
            flush_text(parent, buf)
            buf = ""
            fn_id = m[1]
            fn_el = parent.add_child(:footnote_ref)
            fn_el.value = fn_id
            if def_entry = @footnotes[fn_id]?
              fn_el.options["content"] = def_entry[:content]
            end
            i += m[0].size
            next
          end
        end

        # Image: ![alt](url "title")
        if ch == '!' && i + 1 < text.size && text[i + 1] == '['
          if m = text[i..].match(/^!\[([^\]]*)\]\((\S+?)(?:\s+"([^"]*)")?\)/)
            flush_text(parent, buf)
            buf = ""
            img = parent.add_child(:image)
            img.attributes["alt"] = m[1]
            img.attributes["src"] = m[2]
            img.attributes["title"] = m[3] if m[3]?
            i += m[0].size
            next
          end
        end

        # Link: [text](url "title")
        if ch == '['
          if m = text[i..].match(/^\[([^\]]*)\]\((\S+?)(?:\s+"([^"]*)")?\)/)
            flush_text(parent, buf)
            buf = ""
            link = parent.add_child(:link)
            link.attributes["href"] = m[2]
            link.attributes["title"] = m[3] if m[3]?
            parse_inline(link, m[1])
            i += m[0].size
            next
          end
          # Reference link: [text][ref] or [text][]
          if m = text[i..].match(/^\[([^\]]*)\]\[([^\]]*)\]/)
            flush_text(parent, buf)
            buf = ""
            link_text = m[1]
            ref_id = m[2].empty? ? link_text.downcase : m[2].downcase
            link = parent.add_child(:link)
            if ref = @ref_links[ref_id]?
              link.attributes["href"] = ref[:url]
              link.attributes["title"] = ref[:title] unless ref[:title].empty?
            else
              link.attributes["href"] = ""
            end
            parse_inline(link, link_text)
            i += m[0].size
            next
          end
        end

        # Autolink: <url> or <email>
        if ch == '<'
          if m = text[i..].match(/^<(https?:\/\/[^>]+)>/)
            flush_text(parent, buf)
            buf = ""
            link = parent.add_child(:link)
            link.attributes["href"] = m[1]
            link.add_child(:text, m[1])
            i += m[0].size
            next
          end
          if m = text[i..].match(/^<([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})>/)
            flush_text(parent, buf)
            buf = ""
            link = parent.add_child(:link)
            link.attributes["href"] = "mailto:#{m[1]}"
            link.add_child(:text, m[1])
            i += m[0].size
            next
          end
          # HTML inline element
          if m = text[i..].match(/^<(\/?[a-zA-Z][\w-]*(?:\s+[^>]*)?)>/)
            flush_text(parent, buf)
            buf = ""
            parent.add_child(:html_element, "<#{m[1]}>")
            i += m[0].size
            next
          end
        end

        # Bare URL autolink (GFM)
        if (i == 0 || text[i - 1].whitespace?) && text[i..].starts_with?("http")
          if m = text[i..].match(/^(https?:\/\/[^\s<>\[\]"'`]+)/)
            url = m[1]
            # Strip trailing punctuation
            while url.ends_with?(".") || url.ends_with?(",") || url.ends_with?(")")
              url = url[...-1]
            end
            if url.size > 8
              flush_text(parent, buf)
              buf = ""
              link = parent.add_child(:link)
              link.attributes["href"] = url
              link.add_child(:text, url)
              i += url.size
              next
            end
          end
        end

        # Code span: `` or `
        if ch == '`'
          backtick_count = 0
          j = i
          while j < text.size && text[j] == '`'
            backtick_count += 1
            j += 1
          end
          # Find matching closing backticks
          close_pos = text.index("`" * backtick_count, j)
          if close_pos
            flush_text(parent, buf)
            buf = ""
            code_content = text[j...close_pos]
            # Strip one leading and trailing space if both present
            if code_content.starts_with?(" ") && code_content.ends_with?(" ") && code_content.size > 2
              code_content = code_content[1..-2]
            end
            parent.add_child(:code_span, code_content)
            i = close_pos + backtick_count
            next
          end
        end

        # Strikethrough (GFM): ~~text~~
        if ch == '~' && i + 1 < text.size && text[i + 1] == '~'
          if m = text[i..].match(/^~~(.+?)~~/)
            flush_text(parent, buf)
            buf = ""
            el = parent.add_child(:strikethrough)
            parse_inline(el, m[1])
            i += m[0].size
            next
          end
        end

        # Strong: ** or __
        if (ch == '*' && i + 1 < text.size && text[i + 1] == '*') ||
           (ch == '_' && i + 1 < text.size && text[i + 1] == '_')
          delim = text[i..i + 1]
          rest = text[i + 2..]
          # Find closing delimiter
          close_idx = find_closing_delimiter(rest, delim)
          if close_idx && close_idx > 0
            flush_text(parent, buf)
            buf = ""
            inner = rest[0...close_idx]
            el = parent.add_child(:strong)
            parse_inline(el, inner)
            i += 2 + close_idx + 2
            next
          end
        end

        # Emphasis: * or _
        if ch == '*' || ch == '_'
          delim = ch.to_s
          rest = text[i + 1..]
          close_idx = find_closing_delimiter(rest, delim)
          if close_idx && close_idx > 0
            flush_text(parent, buf)
            buf = ""
            inner = rest[0...close_idx]
            el = parent.add_child(:emphasis)
            parse_inline(el, inner)
            i += 1 + close_idx + 1
            next
          end
        end

        buf += ch.to_s
        i += 1
      end

      flush_text(parent, buf)
    end

    private def find_closing_delimiter(text : String, delim : String) : Int32?
      i = 0
      delim_char = delim[0]
      while i < text.size
        if text[i] == '\\'
          i += 2
          next
        end
        if text[i] == delim_char
          if delim.size == 1
            # Single delimiter: skip double-delimiter pairs (e.g., **...**)
            if i + 1 < text.size && text[i + 1] == delim_char
              # This is a double delimiter opening; find its closing pair
              j = i + 2
              found_close = false
              while j + 1 < text.size
                if text[j] == '\\'
                  j += 2
                  next
                end
                if text[j] == delim_char && text[j + 1] == delim_char
                  i = j + 2
                  found_close = true
                  break
                end
                j += 1
              end
              unless found_close
                return i
              end
              next
            end
            return i
          else
            # Double delimiter
            if i + 1 < text.size && text[i + 1] == delim_char
              # Make sure it's not a triple
              if i + 2 < text.size && text[i + 2] == delim_char
                i += 1
                next
              end
              return i
            end
            i += 1
            next
          end
        end
        i += 1
      end
      nil
    end

    private def is_horizontal_rule?(line : String) : Bool
      chars = line.gsub(/\s/, "")
      return false if chars.size < 3
      return false if chars.empty?
      first = chars[0]
      return false unless first == '-' || first == '*' || first == '_'
      chars.chars.all? { |c| c == first }
    end

    private def flush_text(parent : Element, text : String)
      return if text.empty?
      parent.add_child(:text, text)
    end
  end
end
