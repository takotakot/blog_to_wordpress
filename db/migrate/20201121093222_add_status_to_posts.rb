class AddStatusToPosts < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :status, :int, null: false, default: 0
    add_index :posts, :status
  end
end
