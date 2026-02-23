# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseListener do
  let(:mock_redis) { instance_double(Redis) }
  let(:listener) { described_class.new(redis: mock_redis) }

  describe "#start" do
    it "starts a thread" do
      listener.start
      expect(listener.thread).to be_a(Thread)
      expect(listener.thread).to be_alive

      # Clean up
      listener.stop
    end
  end

  describe "#stop" do
    it "stops the thread" do
      listener.start
      thread = listener.thread

      listener.stop

      expect(thread.alive?).to be false
      expect(listener.thread).to be_nil
    end
  end

  describe '#process_message' do
    it "handles reservation events" do
      listener.process_message(build(:event, :reservation_created))
    end

    # it "handles user events" do
    #   listener.process_message(build(:event, :user_created))
    # end
    #
    # it "handles activity events" do
    #   listener.process_message(build(:event, :activity_created))
    # end
  end
end