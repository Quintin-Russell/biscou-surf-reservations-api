class BaseJob < ApplicationJob
  include Sidekiq::Job
  sidekiq_options queue: :events, retry: 3
end