require File.dirname(__FILE__) + '/../../spec_helper'

class HideNonActionsSpecController < ActionController::Base
  def some_action
  end
  
  def other_action
  end
  
  def public_non_action
  end
  hide_action :public_non_action
end

describe HideNonActionsSpecController, :type => :controller do
  it "#action_methods should only be set of actions" do
    @controller.class.action_methods.should == ['some_action', 'other_action'].to_set
  end
end