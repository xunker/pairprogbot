class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.integer "tweet_id", :null => false
      t.string "from_user", :null => false
      t.string "content", :null => false
      t.boolean "answered", :default => false
      t.boolean "error", :default => false
      t.timestamps
    end

    add_index :tweets, :tweet_id, :unique => true
    add_index :tweets, :from_user
  end
end
