# frozen_string_literal: true

module JsonbAttribute
  extend ActiveSupport::Concern

  class_methods do
    def jsonb_attribute(name, default: {})
      attribute name, :jsonb, default: default

      # Parse JSON strings into a Hash/Array before assignment; the :jsonb type
      # handles encoding, so pre-encoding here would store a JSON string scalar
      define_method("#{name}=") do |value|
        parsed = value.is_a?(String) ? Oj.load(value, mode: :rails) : value
        super(parsed)
      rescue Oj::ParseError, EncodingError, JSON::ParserError
        super(default)
      end

      define_method(name) do
        value = super()
        value.is_a?(Hash) || value.is_a?(Array) ? value : default
      end
    end
  end
end
