# frozen_string_literal: true

module JsonbAttribute
  extend ActiveSupport::Concern

  class_methods do
    def jsonb_attribute(name, default: {})
      attribute name, :jsonb, default: default

      define_method("#{name}=") do |value|
        json_string = case value
                      when String
                        value
                      when NilClass
                        nil
                      else
                        Oj.dump(value, mode: :rails)
                      end

        super(json_string)
      end

      # Define a reader that parses with Oj
      define_method(name) do
        value = super()
        return default if value.nil?

        case value
        when String
          Oj.load(value, mode: :rails)
        when Hash, Array
          value
        else
          default
        end
      rescue Oj::ParseError
        default
      end
    end
  end
end
