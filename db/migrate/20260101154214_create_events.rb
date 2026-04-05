class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.datetime :processed_at
      t.string :type
      t.string :source
      t.jsonb :data

      t.timestamps
    end
  end
end
