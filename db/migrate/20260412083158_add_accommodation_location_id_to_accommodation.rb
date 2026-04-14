class AddAccommodationLocationIdToAccommodation < ActiveRecord::Migration[8.1]
  def change
    add_column :accommodations, :accommodation_location_id, :uuid
  end
end
