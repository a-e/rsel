require_relative 'spec_helper'

require 'rsel/support'
require 'rsel/study_html'

describe Rsel::StudyHtml do
  before(:all) do
    @study = Rsel::StudyHtml.new
  end

  describe "#initialize" do
    it "succeeds when reading html" do
      @study = Rsel::StudyHtml.new(IO.read('test/views/form.erb'))
      expect(@study.clean?).to be true
      expect(@study.keeping_clean?).to be false
      expect(@study.get_node('xpath=/html/head/title').inner_text).to eq('Rsel Test Forms')
    end

    it "fails when reading non-html" do
      expect {
        @study = Rsel::StudyHtml.new(42)
      }.to raise_error

      expect(@study.clean?).to be false
      expect(@study.keeping_clean?).to be false
      expect(@study.get_node('xpath=/html/head/title')).to eq(nil)
    end
  end

  describe "#study" do
    it "succeeds when reading html" do
      @study.study(IO.read('test/views/form.erb'), true)
      expect(@study.clean?).to be true
      expect(@study.keeping_clean?).to be true
      expect(@study.get_node('xpath=/html/head/title').inner_text).to eq('Rsel Test Forms')
    end

    it "fails when reading non-html" do
      expect {
        @study.study(42, true)
      }.to raise_error

      expect(@study.clean?).to be false
      expect(@study.keeping_clean?).to be false
      expect(@study.get_node('xpath=/html/head/title')).to eq(nil)
    end
  end

  describe "#dirty" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'))
    end

    it "dirties a page" do
      expect(@study.clean?).to be true
      @study.dirty
      expect(@study.clean?).to be false
    end
  end
  describe "#undo_last_dirty" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'))
    end

    it "undirties a page dirtied once" do
      expect(@study.clean?).to be true
      @study.dirty
      expect(@study.clean?).to be false
      @study.undo_last_dirty
      expect(@study.clean?).to be true
    end

    it "does not undirty a page dirtied twice" do
      expect(@study.clean?).to be true
      @study.dirty
      @study.dirty
      expect(@study.clean?).to be false
      @study.undo_last_dirty
      expect(@study.clean?).to be false
    end

    it "does not undirty a page whose load failed" do
      expect {
        @study.study(42)
      }.to raise_error

      @study.undo_last_dirty
      expect(@study.clean?).to be false
    end
  end

  describe "#undo_all_dirties" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'))
    end

    it "undirties a page dirtied once" do
      expect(@study.clean?).to be true
      @study.dirty
      expect(@study.clean?).to be false
      @study.undo_all_dirties
      expect(@study.clean?).to be true
    end

    it "undirties a page dirtied twice" do
      expect(@study.clean?).to be true
      @study.dirty
      @study.dirty
      expect(@study.clean?).to be false
      expect(@study.undo_all_dirties).to be true
      expect(@study.clean?).to be true
    end

    it "does not undirty a page whose load failed" do
      expect {
        @study.study(42)
      }.to raise_error

      expect(@study.undo_all_dirties).to be false
      expect(@study.clean?).to be false
    end
  end

  describe "#keep_clean" do
    it "prevents dirty from working when used in study" do
      @study.study(IO.read('test/views/form.erb'), true)
      expect(@study.clean?).to be true
      @study.dirty
      expect(@study.clean?).to be true
    end
    it "prevents dirty from working when used after study" do
      @study.study(IO.read('test/views/form.erb'))
      expect(@study.clean?).to be true
      @study.dirty
      expect(@study.clean?).to be false
      @study.keep_clean(true)
      expect(@study.clean?).to be true
      @study.dirty
      expect(@study.clean?).to be true
    end
    it "stops working when turned off" do
      @study.study(IO.read('test/views/form.erb'), true)
      expect(@study.keeping_clean?).to be true
      @study.keep_clean(false)
      expect(@study.keeping_clean?).to be false
      expect(@study.clean?).to be false
      expect(@study.undo_all_dirties).to be true
      expect(@study.clean?).to be true
    end
  end

  describe "#begin_section" do
    it "studies a new page" do
      expect {
        @study = Rsel::StudyHtml.new(42)
      }.to raise_error

      @study.dirty
      @study.begin_section {IO.read('test/views/form.erb')}
      expect(@study.get_node('xpath=/html/head/title').inner_text).to eq('Rsel Test Forms')
      @study.end_section
      expect(@study.get_node('xpath=/html/head/title')).to eq(nil)
    end
    it "continues with an old, studied page" do
      @study.study(IO.read('test/views/form.erb'))
      @study.begin_section {42}
      expect(@study.get_node('xpath=/html/head/title').inner_text).to eq('Rsel Test Forms')
      @study.end_section
      expect(@study.clean?).to be false
    end
    it "maintains studying after a new section" do
      @study.study(IO.read('test/views/form.erb'), true)
      @study.begin_section {42}
      expect(@study.get_node('xpath=/html/head/title').inner_text).to eq('Rsel Test Forms')
      @study.end_section
      expect(@study.clean?).to be true
      expect(@study.get_node('xpath=/html/head/title').inner_text).to eq('Rsel Test Forms')
    end
  end

  describe "#end_section" do
    it "works like keep_clean(false) if it runs out of stack parameters" do
      @study.study(IO.read('test/views/form.erb'), true)
      expect(@study.keeping_clean?).to be true
      @study.end_section
      expect(@study.keeping_clean?).to be false
      expect(@study.clean?).to be false
      expect(@study.undo_all_dirties).to be true
      expect(@study.clean?).to be true
    end
  end

  describe "#simplify_locator" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'))
    end

    context "does not simplify" do
      it "an id" do
        expect(@study.simplify_locator('id=first_name')).to eq('id=first_name')
      end
      it "a name" do
        expect(@study.simplify_locator('name=second_duplicate')).to eq('name=second_duplicate')
      end
      it "a link" do
        expect(@study.simplify_locator('link=second duplicate')).to eq('link=second duplicate')
      end
      it "a dom path" do
        expect(@study.simplify_locator('dom=document.links[42]')).to eq('dom=document.links[42]')
        expect(@study.simplify_locator('document.links[42]')).to eq('document.links[42]')
      end
      it "an element only accessible by xpath or css from css" do
        expect(@study.simplify_locator('#spouse_form button')).to eq('#spouse_form button')
      end
      it "an element only accessible by xpath or css from xpath if ordered not to" do
        expect(@study.simplify_locator('//button[@value=\'submit_spouse_form\']', false)).to eq('xpath=//button[@value=\'submit_spouse_form\']')
      end
    end

    context "simplifies" do
      it "a control to an id" do
        my_xpath = @study.loc('First name', 'field')
        expect(@study.simplify_locator(my_xpath)).to eq('id=first_name')
      end
      it "a css path to an id" do
        expect(@study.simplify_locator('css=#first_name')).to eq('id=first_name')
      end
      it "an xpath to a name" do
        my_xpath = @study.loc('duplicate', 'field', :within => 'other_form')
        expect(@study.simplify_locator(my_xpath)).to eq('name=second_duplicate')
      end
      it "a css path to a name" do
        expect(@study.simplify_locator('css=#other_form #duplicate')).to eq('name=second_duplicate')
      end
      it "an xpath to a link" do
        my_xpath = @study.loc('Home', 'link')
        expect(@study.simplify_locator(my_xpath)).to eq('link=Home')
      end
      it "a css path to a link" do
        expect(@study.simplify_locator('css=a')).to eq('link=Home')
      end
      it "an element only accessible by xpath or css from an xpath" do
        my_xpath = @study.loc('Submit spouse form', 'button')
        expect(@study.simplify_locator(my_xpath)).to eq('xpath=/html/body/div[2]/form/p[4]/button')
        expect(@study.simplify_locator('//button[@value=\'submit_spouse_form\']')).to eq('xpath=/html/body/div[2]/form/p[4]/button')
      end
      # TODO: Simplify an xpath to a css.
    end
  end
  describe "#get_node" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'), true)
    end

    context "passes when" do
      it "finds an id" do
        expect(@study.get_node('id=person_height').inner_text).to include('Average')
      end
      it "finds a name" do
        expect(@study.get_node('name=underwear briefs')['value']).to eq('briefs')
      end
      it "finds a link" do
        expect(@study.get_node('link=Home')['href']).to eq('/')
      end
      it "finds an element by css" do
        expect(@study.get_node('css=#other_form #duplicate')['name']).to eq('second_duplicate')
      end
      it "finds an element by xpath" do
        my_xpath = @study.loc('duplicate', 'field', :within => 'other_form')
        expect(@study.get_node(my_xpath)['name']).to eq('second_duplicate')
      end
      it "finds an element by implied xpath" do
        expect(@study.get_node("//*[@name='underwear']")['value']).to eq('boxers')
      end
      it "finds an element by default" do
        expect(@study.get_node("underwear")['value']).to eq('boxers')
      end
    end

    context "fails when" do
      it "does not find an id" do
        expect(@study.get_node('id=impersonated')).to eq(nil)
      end
      it "does not find a name" do
        expect(@study.get_node('name=impersonated')).to eq(nil)
      end
      it "does not find a link" do
        expect(@study.get_node('link=impersonated')).to eq(nil)
      end
      it "does not find an element by css" do
        expect(@study.get_node('css=#impersonated')).to eq(nil)
      end
      it "does not find an element by xpath" do
        expect(@study.get_node('xpath=//impersonated')).to eq(nil)
      end
      it "does not find an element by implied xpath" do
        expect(@study.get_node('//impersonated')).to eq(nil)
      end
      it "does not find an element by default" do
        expect(@study.get_node('impersonated')).to eq(nil)
      end
      it "is given a dom path" do
        expect(@study.get_node('dom=document.links[0]')).to eq(nil)
      end
      it "is given an implied dom path" do
        expect(@study.get_node('document.links[0]')).to eq(nil)
      end
    end
  end
end
