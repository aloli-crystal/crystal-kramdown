require "spec"
require "../../src/kramdown"

# Integration-test helpers: round-trip a full Markdown document (loaded
# from disk or inlined) through the real parser + converters, and expose
# a couple of primitives for assertions.
#
# The unit specs already cover every individual element; what these
# tests bring on top is end-to-end behaviour on realistic mixed
# documents (README-style, CHANGELOG-style, GFM + extensions combined
# in the same source) and cross-converter consistency (`to_html` vs
# `to_text` on the same input).
module IntegrationHelper
  # Parses `source` and returns the HTML output of the real converter.
  def self.to_html(source : String) : String
    Kramdown::Document.new(source).to_html
  end

  # Parses `source` and returns the plain-text output of the real
  # converter. Useful to assert that inline markup is stripped but
  # the visible words survive.
  def self.to_text(source : String) : String
    Kramdown::Document.new(source).to_text
  end

  # Reads a fixture file from `spec/integration/fixtures/` and returns
  # its content as a string. Keeps realistic documents out of the
  # Crystal source files.
  def self.fixture(name : String) : String
    File.read(File.join(__DIR__, "fixtures", name))
  end
end
