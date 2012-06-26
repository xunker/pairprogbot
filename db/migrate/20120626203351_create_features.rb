class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :username, :null => false
      t.string :name
      t.string :state, :null => false
      t.timestamps
    end

    add_index :features, :username
    add_index :features, [:username, :name], :unique => true
  end
end
