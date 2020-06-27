class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.string :url, null: false
      t.integer :read, null: false, default: 0
      t.timestamps
    end
  end
end
