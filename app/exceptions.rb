module Exceptions
  class BaseError < StandardError
    def initialize(message = nil, **options)
      @status = options[:status] || :unprocessable_entity
      @code = options[:code] || self.class.name.demodulize.underscore
      @details = options[:details]
      super(message || default_message)
    end

    def default_message
      'Something went wrong'
    end
  end

  # Custom Exceptions
  class MissingEventParametersError < BaseError
    def default_message = "Cannot create event: missing parameters"
    def initialize(*) = super(status: :unprocessable_entity)
  end
end