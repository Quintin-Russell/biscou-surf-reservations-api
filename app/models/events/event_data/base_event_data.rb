module Events
  module EventData
    class BaseEventData
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations
    end
  end
end