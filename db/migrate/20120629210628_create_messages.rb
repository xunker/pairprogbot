class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer "message_id", :null => false
      t.string "from_user", :null => false
      t.string "content", :null => false
      t.boolean "answered", :default => false
      t.boolean "error", :default => false
      t.timestamps
    end

    add_index :messages, :message_id, :unique => true
    add_index :messages, :from_user
  end
end
