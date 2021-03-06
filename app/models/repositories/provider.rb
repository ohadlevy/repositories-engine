module Repositories
  class Provider < ActiveRecord::Base
    include ::Taxonomix
    TYPES = %w[ Redhat Custom ] #todo: add puppet environment and debian provider types

    has_many :products, :inverse_of => :provider

    validates_with Validators::NameFormat, :attributes => :name
    validates_with Validators::DescriptionFormat, :attributes => :description

    scoped_search :on => [:name, :description,:type], :complete_value => :true

    # with proc support, default_scope can no longer be chained
    # include all default scoping here
    default_scope lambda {
      with_taxonomy_scope do
        order("name")
      end
    }

    def kind
      type =~ /Repositories::(\w+)Provider/
      $1
    end

    # allows to create a specific provider class based on the type.
    def self.new_provider args
      raise ::Foreman::Exception.new(N_("must provide a type")) unless type = args.delete(:kind)
      TYPES.each do |p|
        return "Repositories::#{p}Provider".constantize.new(args) if p.downcase == type.downcase
      end
      raise ::Foreman::Exception.new N_("unknown provider type")
    end
  end
end
