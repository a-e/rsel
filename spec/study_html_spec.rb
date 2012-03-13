require 'spec/spec_helper'

require 'rsel/support'
require 'rsel/study_html'

describe Rsel::StudyHtml do
  before(:all) do
    @study = Rsel::StudyHtml.new
  end

  describe "#initialize" do
    it "succeeds when reading html" do
      @study = Rsel::StudyHtml.new(IO.read('test/views/form.erb'))
      @study.clean?.should be_true
      @study.keeping_clean?.should be_false
      @study.get_node('xpath=/html/head/title').inner_text.should eq('Rsel Test Forms')
    end

    it "fails when reading non-html" do
      lambda do
        @study = Rsel::StudyHtml.new(42)
      end.should raise_error

      @study.clean?.should be_false
      @study.keeping_clean?.should be_false
      @study.get_node('xpath=/html/head/title').should eq(nil)
    end
  end
  
  describe "#study" do
    it "succeeds when reading html" do
      @study.study(IO.read('test/views/form.erb'), true)
      @study.clean?.should be_true
      @study.keeping_clean?.should be_true
      @study.get_node('xpath=/html/head/title').inner_text.should eq('Rsel Test Forms')
    end

    it "fails when reading non-html" do
      lambda do
        @study.study(42, true)
      end.should raise_error

      @study.clean?.should be_false
      @study.keeping_clean?.should be_false
      @study.get_node('xpath=/html/head/title').should eq(nil)
    end
  end

  describe "#dirty" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'))
    end
    
    it "dirties a page" do
      @study.clean?.should be_true
      @study.dirty
      @study.clean?.should be_false
    end
  end
  describe "#undo_last_dirty" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'))
    end
    
    it "undirties a page dirtied once" do
      @study.clean?.should be_true
      @study.dirty
      @study.clean?.should be_false
      @study.undo_last_dirty
      @study.clean?.should be_true
    end

    it "does not undirty a page dirtied twice" do
      @study.clean?.should be_true
      @study.dirty
      @study.dirty
      @study.clean?.should be_false
      @study.undo_last_dirty
      @study.clean?.should be_false
    end

    it "does not undirty a page whose load failed" do
      lambda do
        @study.study(42)
      end.should raise_error

      @study.undo_last_dirty
      @study.clean?.should be_false
    end
  end

  describe "#undo_all_dirties" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'))
    end
    
    it "undirties a page dirtied once" do
      @study.clean?.should be_true
      @study.dirty
      @study.clean?.should be_false
      @study.undo_all_dirties
      @study.clean?.should be_true
    end

    it "undirties a page dirtied twice" do
      @study.clean?.should be_true
      @study.dirty
      @study.dirty
      @study.clean?.should be_false
      @study.undo_all_dirties.should be_true
      @study.clean?.should be_true
    end

    it "does not undirty a page whose load failed" do
      lambda do
        @study.study(42)
      end.should raise_error

      @study.undo_all_dirties.should be_false
      @study.clean?.should be_false
    end
  end
  
  describe "#keep_clean" do
    it "prevents dirty from working when used in study" do
      @study.study(IO.read('test/views/form.erb'), true)
      @study.clean?.should be_true
      @study.dirty
      @study.clean?.should be_true
    end
    it "prevents dirty from working when used after study" do
      @study.study(IO.read('test/views/form.erb'))
      @study.clean?.should be_true
      @study.dirty
      @study.clean?.should be_false
      @study.keep_clean(true)
      @study.clean?.should be_true
      @study.dirty
      @study.clean?.should be_true
    end
    it "stops working when turned off" do
      @study.study(IO.read('test/views/form.erb'), true)
      @study.keeping_clean?.should be_true
      @study.keep_clean(false)
      @study.keeping_clean?.should be_false
      @study.clean?.should be_false
      @study.undo_all_dirties.should be_true
      @study.clean?.should be_true
    end
  end
  
  describe "#begin_section" do
    it "studies a new page" do
      lambda do
        @study = Rsel::StudyHtml.new(42)
      end.should raise_error

      @study.dirty
      @study.begin_section {IO.read('test/views/form.erb')}
      @study.get_node('xpath=/html/head/title').inner_text.should eq('Rsel Test Forms')
      @study.end_section
      @study.get_node('xpath=/html/head/title').should eq(nil)
    end
    it "continues with an old, studied page" do
      @study.study(IO.read('test/views/form.erb'))
      @study.begin_section {42}
      @study.get_node('xpath=/html/head/title').inner_text.should eq('Rsel Test Forms')
      @study.end_section
      @study.clean?.should be_false
    end
    it "maintains studying after a new section" do
      @study.study(IO.read('test/views/form.erb'), true)
      @study.begin_section {42}
      @study.get_node('xpath=/html/head/title').inner_text.should eq('Rsel Test Forms')
      @study.end_section
      @study.clean?.should be_true
      @study.get_node('xpath=/html/head/title').inner_text.should eq('Rsel Test Forms')
    end
  end
  
  describe "#end_section" do
    it "works like keep_clean(false) if it runs out of stack parameters" do
      @study.study(IO.read('test/views/form.erb'), true)
      @study.keeping_clean?.should be_true
      @study.end_section
      @study.keeping_clean?.should be_false
      @study.clean?.should be_false
      @study.undo_all_dirties.should be_true
      @study.clean?.should be_true
    end
  end

  describe "#simplify_locator" do
    before(:all) do
      @study.study(IO.read('test/views/form.erb'))
    end

    context "does not simplify" do
      it "an id" do
        @study.simplify_locator('id=first_name').should eq('id=first_name')
      end
      it "a name" do
        @study.simplify_locator('name=second_duplicate').should eq('name=second_duplicate')
      end
      it "a link" do
        @study.simplify_locator('link=second duplicate').should eq('link=second duplicate')
      end
      it "a dom path" do
        @study.simplify_locator('dom=document.links[42]').should eq('dom=document.links[42]')
        @study.simplify_locator('document.links[42]').should eq('document.links[42]')
      end
    end

    context "simplifies" do
      it "a control to an id" do
        my_xpath = @study.loc('First name', 'field')
        @study.simplify_locator(my_xpath).should eq('id=first_name')
      end
      it "a css path to an id" do
        @study.simplify_locator('css=#first_name').should eq('id=first_name')
      end
      it "an xpath to a name" do
        my_xpath = @study.loc('duplicate', 'field', :within => 'other_form')
        @study.simplify_locator(my_xpath).should eq('name=second_duplicate')
      end
      it "a css path to a name" do
        @study.simplify_locator('css=#other_form #duplicate').should eq('name=second_duplicate')
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
        @study.get_node('id=person_height').inner_text.should include('Average')
      end
      it "finds a name" do
        @study.get_node('name=underwear briefs')['value'].should eq('briefs')
      end
      it "finds a link" do
        @study.get_node('link=Home')['href'].should eq('/')
      end
      it "finds an element by css" do
        @study.get_node('css=#other_form #duplicate')['name'].should eq('second_duplicate')
      end
      it "finds an element by xpath" do
        my_xpath = @study.loc('duplicate', 'field', :within => 'other_form')
        @study.get_node(my_xpath)['name'].should eq('second_duplicate')
      end
      it "finds an element by implied xpath" do
        @study.get_node("//*[@name='underwear']")['value'].should eq('boxers')
      end
      it "finds an element by default" do
        @study.get_node("underwear")['value'].should eq('boxers')
      end
    end

    context "fails when" do
      it "does not find an id" do
        @study.get_node('id=impersonated').should eq(nil)
      end
      it "does not find a name" do
        @study.get_node('name=impersonated').should eq(nil)
      end
      it "does not find a link" do
        @study.get_node('link=impersonated').should eq(nil)
      end
      it "does not find an element by css" do
        @study.get_node('css=#impersonated').should eq(nil)
      end
      it "does not find an element by xpath" do
        @study.get_node('xpath=//impersonated').should eq(nil)
      end
      it "does not find an element by implied xpath" do
        @study.get_node('//impersonated').should eq(nil)
      end
      it "does not find an element by default" do
        @study.get_node('impersonated').should eq(nil)
      end
      it "is given a dom path" do
        @study.get_node('dom=document.links[0]').should eq(nil)
      end
      it "is given an implied dom path" do
        @study.get_node('document.links[0]').should eq(nil)
      end
    end
  end
end
