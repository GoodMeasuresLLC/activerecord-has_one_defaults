require "activerecord/has_one_defaults/version"


require 'active_record'

module ActiveRecord
  module Associations # :nodoc:
    extend ActiveSupport::Autoload

    module ClassMethods


      # add a :default option to has_one that will build the relationship if it
      # does not exist.
      alias_method :original_has_one, :has_one

      # See ActiveRecord::Associations::ClassMethods for documentation.
      #
      # === Options
      # [:default]
      #   Specifies that if the association is access, but has not yet been
      #   initialized.  Use with a boolean or a hash.  If a hash is provided, those
      #   will be the defaults for a newly built object
      def has_one(name, scope = nil, **options)
        default_option = scope.is_a?(Hash) ? scope.delete(:default) : options.delete(:default)
        klass = self
        original_has_one(name, scope, options).tap do
          if default_option
            klass.send(:define_method, name) do
              super() || send("build_#{name}", default_option.is_a?(Hash) ? default_option : {})
            end
          end
        end
      end
    end
  end
end

