class CnvertAllIdColumnsToUuid < ActiveRecord::Migration[8.1]
  def change
    tables = ActiveRecord::Base.connection.tables - ["schema_migrations", "ar_internal_metadata"]
    tables.each do |table|
      puts "Starting to convert id column of #{table}"

      add_column table, :new_id, :uuid, default: -> { "gen_random_uuid()" }
      execute "UPDATE #{table} SET new_id = gen_random_uuid()"

      execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey"

      remove_column table, :id

      rename_column table, :new_id, :id

      execute "ALTER TABLE #{table} ADD PRIMARY KEY (id)"
    end
  end
end
