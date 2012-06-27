tw = YAML.load(File.new(File.dirname(__FILE__)+'/../twitter.yaml'))[Rails.env]

TWITTER_USERNAME = tw["username"]

Twitter.configure do |config|
  config.consumer_key = tw["consumer_key"]
  config.consumer_secret = tw["consumer_secret"]
  config.oauth_token = tw["oauth_token"]
  config.oauth_token_secret = tw["oauth_token_secret"]
end