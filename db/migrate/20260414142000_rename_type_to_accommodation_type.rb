class RenameTypeToAccommodationType < ActiveRecord::Migration[8.1]
  def change
    rename_column :accommodations, :type, :accommodation_type
  end
end
