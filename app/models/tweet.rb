class Tweet < ActiveRecord::Base
  attr_accessible :tweet_id, :from_user, :content, :answered
  validates_presence_of :tweet_id, :from_user, :content

  def just_content
    content.gsub(/^\@#{TWITTER_USERNAME} /, '')
  end

  def self.last_tweet_id
    if tweet = find(:first, :order => "tweet_id DESC", :select => 'tweet_id')
      tweet.tweet_id
    else
      0
    end
  end
end
