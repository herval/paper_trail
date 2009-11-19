require 'yaml'
require 'paper_trail/has_paper_trail'
require 'paper_trail/version'

module PaperTrail
  @@whodunnit = nil

  def self.included(base)
    base.before_filter :set_whodunnit
    base.before_filter :set_assumed_user # if a user has 'assumed' someone else and did something ('A on behalf of B'), this will be filled in (e.g.: Zendesk.com 'assume' functionality)
  end

  def self.whodunnit
    @@whodunnit.respond_to?(:call) ? @@whodunnit.call : @@whodunnit
  end
  
  def self.assumed_user
    @@assumed_user.respond_to?(:call) ? @@assumed_user.call : @@assumed_user
  end

  def self.whodunnit=(value)
    @@whodunnit = value
  end
  
  def self.assumed_user=(value)
    @@assumed_user = value
  end

  private

  def set_assumed_user
    @@assumed_user = lambda {
      self.respond_to?(:assumed_user) ? self.assumed_user : nil
    }
  end

  def set_whodunnit
    @@whodunnit = lambda {
      self.respond_to?(:current_user) ? self.current_user : nil
    }
  end
end

ActionController::Base.send :include, PaperTrail
