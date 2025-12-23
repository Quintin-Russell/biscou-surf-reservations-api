class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pgcrypto'

    create_table :users, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :nationality
      t.string :email
      t.string :password_digest
      t.string :password
      t.string :role
      t.string :permission

      t.timestamps
    end
  end
end
