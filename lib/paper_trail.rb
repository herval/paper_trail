require 'yaml'
require 'paper_trail/has_paper_trail'
require 'paper_trail/version'

module PaperTrail
  @@whodunnit = nil
  @@super_user = nil

  def self.included(base)
    base.before_filter :set_whodunnit
    base.before_filter :set_super_user # if a user has 'assumed' someone else and did something ('A on behalf of B'), this will be filled in (e.g.: Zendesk.com 'assume' functionality)
  end

  def self.whodunnit
    @@whodunnit.respond_to?(:call) ? @@whodunnit.call : @@whodunnit
  end
  
  def self.super_user
    @@super_user.respond_to?(:call) ? @@super_user.call : @@super_user
  end

  def self.whodunnit=(value)
    @@whodunnit = value
  end
  
  def self.super_user=(value)
    @@super_user = value
  end

  private

  def set_super_user
    @@super_user = lambda {
      self.respond_to?(:super_user) ? self.super_user : nil
    }
  end

  def set_whodunnit
    @@whodunnit = lambda {
      self.respond_to?(:current_user) ? self.current_user : nil
    }
  end
end

ActionController::Base.send :include, PaperTrail
