class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.inet :ip_address
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :sessions, :expires_at
  end
end
