class CreateAccomodations < ActiveRecord::Migration[8.1]
  def change
    create_table :accommodations do |t|
      t.string :name
      t.string :type
      t.integer :bed_number
      t.integer :capacity

      t.timestamps
      t.references :location, foreign_key: { to_table: :accommodation_locations }
    end
  end
end
