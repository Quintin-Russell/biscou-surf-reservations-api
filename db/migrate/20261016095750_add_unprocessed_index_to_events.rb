class AddUnprocessedIndexToEvents < ActiveRecord::Migration[8.1]
  # EventStreamSweeperJob scans for unprocessed events by age
  def change
    add_index :events, :created_at, where: "processed_at IS NULL", name: "index_events_on_created_at_unprocessed"
  end
end
