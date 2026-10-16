namespace :events do
  desc "Reads the event stream and enqueues handler jobs (runs until TERM/INT)"
  task listen: :environment do
    EventListener.new.run
  end
end
