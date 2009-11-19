module PaperTrail

  def self.included(base)
    base.send :extend, ClassMethods
  end


  module ClassMethods
    # Options:
    # :ignore    an array of attributes for which a new +Version+ will not be created if only they change.
    def has_paper_trail(options = {})
      send :include, InstanceMethods

      cattr_accessor :ignore
      self.ignore = (options[:ignore] || []).map &:to_s
      
      cattr_accessor :paper_trail_active
      self.paper_trail_active = true

      has_many :versions, :as => :item, :order => 'created_at ASC, id ASC'

      after_create  :record_create
      before_update :record_update
      after_destroy :record_destroy
    end

    def paper_trail_off
      self.paper_trail_active = false
    end

    def paper_trail_on
      self.paper_trail_active = true
    end
  end


  module InstanceMethods
    def record_create
      versions.create(:event     => 'create',
                      :whodunnit => PaperTrail.whodunnit, :super_user => PaperTrail.super_user) if self.class.paper_trail_active
    end

    def record_update
      if changed_and_we_care? and self.class.paper_trail_active
        versions.build :event     => 'update',
                       :object    => object_to_string(previous_version),
                       :whodunnit => PaperTrail.whodunnit,
                       :super_user => PaperTrail.super_user
      end
    end

    def record_destroy
      versions.create(:event     => 'destroy',
                      :object    => object_to_string(previous_version),
                      :whodunnit => PaperTrail.whodunnit,
                      :super_user => PaperTrail.super_user) if self.class.paper_trail_active
    end

    private

    def previous_version
      previous = self.clone
      previous.id = id
      changes.each do |attr, ary|
        previous.send "#{attr}=", ary.first
      end
      previous
    end

    def object_to_string(object)
      object.attributes.to_yaml
    end

    def changed_and_we_care?
      changed? and !(changed - self.class.ignore).empty?
    end
  end

end

ActiveRecord::Base.send :include, PaperTrail
