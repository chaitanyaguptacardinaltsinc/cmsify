require 'active_support/concern'

module Cmsify
  module Schemable
    extend ActiveSupport::Concern

    # TODO: Find a way to get rid of this
    def mass_assignable_fields
      @schema.select { |field_name, field| field[:protected] != true }.reduce([]) do |memo, (field_name, field)|
        if [:attachment, :image].include?(field[:type])
          memo.push({ "attached_#{ field_name }_attributes".to_sym => ::Cmsify::BaseAttached.default_allowed_params })
        else
          memo.push(field_name)
        end
        memo
      end
    end

    def required_fields
      @schema.select { |field_name, field| field[:required] == true }.reduce([]) do |memo, (field_name, field)|
        memo.push(field[:type] == :attachment ? "attached_#{ field_name }" : field_name)
        memo
      end
    end

    def datetime_fields
      @schema.select { |field_name, field| field[:type] == :datetime }
    end
  end
end
