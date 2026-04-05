class CreateAccomodationLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :accommodation_locations do |t|
      t.string :name
      t.string :location
      t.string :city
      t.string :type
      t.integer :capacity

      t.timestamps
    end
  end
end
