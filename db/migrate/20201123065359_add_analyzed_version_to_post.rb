class AddAnalyzedVersionToPost < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :analyzed_version, :int, null: false, default: 0
  end
end
