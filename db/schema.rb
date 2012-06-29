# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120629210628) do

  create_table "features", :force => true do |t|
    t.string   "username",   :null => false
    t.string   "name"
    t.string   "state",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "features", ["username", "name"], :name => "index_features_on_username_and_name", :unique => true
  add_index "features", ["username"], :name => "index_features_on_username"

  create_table "messages", :force => true do |t|
    t.integer  "message_id",                    :null => false
    t.string   "from_user",                     :null => false
    t.string   "content",                       :null => false
    t.boolean  "answered",   :default => false
    t.boolean  "error",      :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "messages", ["from_user"], :name => "index_messages_on_from_user"
  add_index "messages", ["message_id"], :name => "index_messages_on_message_id", :unique => true

  create_table "tweets", :force => true do |t|
    t.integer  "tweet_id",                      :null => false
    t.string   "from_user",                     :null => false
    t.string   "content",                       :null => false
    t.boolean  "answered",   :default => false
    t.boolean  "error",      :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "tweets", ["from_user"], :name => "index_tweets_on_from_user"
  add_index "tweets", ["tweet_id"], :name => "index_tweets_on_tweet_id", :unique => true

end
