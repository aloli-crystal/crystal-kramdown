require "./spec_helper"

# Baseline check: the full parser + converter pipeline runs on the
# simplest possible inputs without raising, and produces the expected
# shape.
describe "Integration · sanity" do
  it "converts a single paragraph to <p>" do
    IntegrationHelper.to_html("Hello world.\n").should contain("<p>Hello world.</p>")
  end

  it "strips markup when converting to plain text" do
    text = IntegrationHelper.to_text("Hello **bold** and _em_.\n")
    text.should contain("Hello bold and em.")
    text.should_not contain("**")
    text.should_not contain("_em_")
    text.should_not contain("<")
  end

  it "handles an empty document gracefully" do
    IntegrationHelper.to_html("").should eq("")
    # The text converter ends the document with a trailing newline,
    # which is fine — asserting it is not garbage.
    IntegrationHelper.to_text("").strip.should eq("")
  end

  it "handles trailing whitespace-only input" do
    IntegrationHelper.to_html("   \n\n   \n").should_not contain("<p>")
  end
end
