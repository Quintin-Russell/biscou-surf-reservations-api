class RenameTypeToRoleInUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :type, :role
  end
end
