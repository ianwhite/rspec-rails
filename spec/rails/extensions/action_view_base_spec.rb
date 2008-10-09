require File.dirname(__FILE__) + '/../../spec_helper'
require 'spec/mocks/errors'

describe ActionView::Base, "with RSpec extensions:", :type => :view do 
  
  describe "should_receive(:render)" do
    it "should not raise when render has been received" do
      template.should_receive(:render).with(:partial => "name")
      template.render :partial => "name"
    end
  
    it "should raise when render has NOT been received" do
      template.should_receive(:render).with(:partial => "name")
      lambda {
        template.verify_rendered
      }.should raise_error
    end
    
    it "should return something (like a normal mock)" do
      template.should_receive(:render).with(:partial => "name").and_return("Little Johnny")
      result = template.render :partial => "name"
      result.should == "Little Johnny"
    end
  end
  
  describe "stub!(:render)" do
    it "should not raise when stubbing and render has been received" do
      template.stub!(:render).with(:partial => "name")
      template.render :partial => "name"
    end
  
    it "should not raise when stubbing and render has NOT been received" do
      template.stub!(:render).with(:partial => "name")
    end
  
    it "should not raise when stubbing and render has been received with different options" do
      template.stub!(:render).with(:partial => "name")
      template.render :partial => "view_spec/spacer"
    end

    it "should not raise when stubbing and expecting and render has been received" do
      template.stub!(:render).with(:partial => "name")
      template.should_receive(:render).with(:partial => "name")
      template.render(:partial => "name")
    end
  end
end

describe "When render_partial has been previously alias_method_chained" do
  before(:all) do
    # mess with a copy of ActionView::Base
    @orig_action_view_base = ActionView::Base
    ActionView.send :remove_const, :Base
    ActionView::Base = @orig_action_view_base.clone
    
    # set up the alias_method_chain
    ActionView::Base.class_eval do
      def render_partial_with_chain(*args)
        chain_method_called
      end
      alias_method_chain :render_partial, :chain
    end
    
    # now run the rspec extension stuff (it has to be after the chain)
    Kernel.eval File.read(File.join(File.dirname(__FILE__), '../../../lib/spec/rails/extensions/action_view/base.rb'))
  end
  
  describe "#render_partial", :type => :view do
    before do
      @view = ActionView::Base.new
      @view.stub!(:chain_method_called)
    end

    it "should call the chained method" do
      @view.should_receive :chain_method_called
      @view.render_partial('some/partial')
    end
  end
  
  after(:all) do
    # set ActionView back to how it was
    ActionView.send :remove_const, :Base
    ActionView::Base = @orig_action_view_base
  end
end