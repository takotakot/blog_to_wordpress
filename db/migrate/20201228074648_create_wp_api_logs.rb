class CreateWpApiLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :wp_api_logs do |t|
      t.bigint :wp_id
      t.text :method
      t.text :endpoint
      t.text :query
      t.text :ret_json

      t.timestamps
    end
  end
end
