class RenameTypeColumnToPropertyTypeInAccommodationLocations < ActiveRecord::Migration[8.1]
  def change
    rename_column :accommodation_locations, :type, :property_type
  end
end
