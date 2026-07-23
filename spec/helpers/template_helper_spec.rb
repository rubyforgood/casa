require "rails_helper"

RSpec.describe TemplateHelper, type: :helper do
  describe "#sanitize_opening_tags" do
    it "strips attributes down to the tag name" do
      expect(helper.sanitize_opening_tags(["<div class=\"foo\">"])).to eq(["<div>"])
    end

    it "leaves tags without attributes untouched" do
      expect(helper.sanitize_opening_tags(["<div>"])).to eq(["<div>"])
    end

    it "removes self-closing tags" do
      expect(helper.sanitize_opening_tags(["<div>", "<br>", "<img src=\"foo\">"])).to eq(["<div>"])
    end
  end

  describe "#sanitize_closing_tags" do
    it "strips surrounding whitespace and slashes from closing tags" do
      expect(helper.sanitize_closing_tags(["  </div>  "])).to eq(["<div>"])
    end

    it "leaves normal closing tags untouched" do
      expect(helper.sanitize_closing_tags(["</div>"])).to eq(["<div>"])
    end
  end

  describe "#validate_closing_tags_exist" do
    it "returns true when every opening tag has a matching closing tag" do
      content = "<div><span>hello</span></div>"

      expect(helper.validate_closing_tags_exist(content)).to be true
    end

    it "returns false when a closing tag is missing" do
      content = "<div><span>hello</div>"

      expect(helper.validate_closing_tags_exist(content)).to be false
    end

    it "ignores self-closing tags that require no closing tag" do
      content = "<div><img src=\"foo\"><br></div>"

      expect(helper.validate_closing_tags_exist(content)).to be true
    end
  end

  describe "#active_if" do
    it "returns 'active' when the condition is truthy" do
      expect(helper.active_if(true)).to eq("active")
    end

    it "returns nil when the condition is falsy" do
      expect(helper.active_if(false)).to be_nil
    end
  end

  describe "#active_if_status" do
    it "returns 'active' when the status is complete" do
      expect(helper.active_if_status("complete")).to eq("active")
    end

    it "returns nil when the status is not complete" do
      expect(helper.active_if_status("in_progress")).to be_nil
    end
  end
end
