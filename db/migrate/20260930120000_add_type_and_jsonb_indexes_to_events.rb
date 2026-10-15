class AddTypeAndJsonbIndexesToEvents < ActiveRecord::Migration[8.1]
  def change
    # STI discriminator column so events load as their subclass
    add_column :events, :type, :string
    add_index :events, :type

    change_column_null :events, :event_type, false
    change_column_null :events, :action, false
    change_column_default :events, :data, from: nil, to: {}
    change_column_null :events, :data, false, {}

    # GIN index for containment queries (data @> '{...}')
    add_index :events, :data, using: :gin, opclass: :jsonb_path_ops
    # expression index for reservation lookups (data->>'reservation_id')
    add_index :events, "(data->>'reservation_id')", name: "index_events_on_data_reservation_id"
  end
end
