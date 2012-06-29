class Message < ActiveRecord::Base
  attr_accessible :message_id, :from_user, :content, :answered
  validates_presence_of :message_id, :from_user, :content

end
