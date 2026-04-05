class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.string :name
      t.string :description
      t.date :availability_start
      t.date :availability_end

      t.timestamps
    end
  end
end
