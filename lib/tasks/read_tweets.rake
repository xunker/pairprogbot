task :read_tweets => :environment do
  while true do
    puts "Last tweet id is : #{Tweet.last_tweet_id}"
    results = Twitter.search("to:#{TWITTER_USERNAME}", :rpp => 100, :result_type => "recent", :since_id => Tweet.last_tweet_id)
    results.each do |result|
      next if result["from_user"].downcase == TWITTER_USERNAME.downcase
      next if result["text"].downcase !~ /^\@#{TWITTER_USERNAME.downcase}/
      puts result["id"]
      puts result["from_user"]
      tweet = Tweet.find_or_create_by_tweet_id_and_from_user_and_content(result["id"].to_s, result["from_user"].to_s, result["text"])
    end

    # process
    Tweet.find(
      :all,
      :order => "tweet_id ASC",
      :conditions => ["answered = ? AND error = ?", false, false]
    ).each do |tweet|
      interacter = Interacter.new(tweet.from_user)
      if response = interacter.command(tweet.just_content.downcase)
        message =  "@#{tweet.from_user} #{response} (action ##{tweet.id})"
        puts "TWEETING: #{message}"
        Twitter.update(message)
        tweet.update_attributes(:answered => true)
      else
        puts "Error in message: #{tweet.content}"
        tweet.update_attributes(:error => true)
      end
    end

    puts "sleep"
    sleep 15
  end
end