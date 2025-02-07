module Cmsify
  class Klass::CmsifiedsController < Klass
    include Cmsify::Schemable

    private
      def class_contents
        local_mass_assignable_fields = mass_assignable_fields
        local_required_fields = required_fields
        local_datetime_fields = datetime_fields

        Proc.new do
          class_eval <<-RUBY
            def allowed_params
              #{ local_mass_assignable_fields }
            end
          RUBY
        end
      end
  end
end
