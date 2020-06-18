class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.string :url, null: false
      t.timestamps
    end
  end
end
