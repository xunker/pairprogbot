task :read_tweets => :environment do
  client = Twitter::Client.new
  while true do
    # # direct messages
    # puts "Direct Messages"
    # client.direct_messages.each do |message|
    #   interacter = Interacter.new(message.sender.screen_name)
    #   puts [message.id, message.sender.screen_name, message.text].join(', ')
    #   local_message = Message.find_or_create_by_message_id_and_from_user_and_content(message.id, message.sender.screen_name, message.text)
    #   if local_message.new_record?
    #     puts "Error saving Message #{message.id} from #{message.sender.screen_name}: #{message.text}"
    #   else
    #     if response = interacter.command(message.text.downcase)
    #       reply_text =  "#{response} (action ##{local_message.id})"
    #       puts "DM'ING: #{response}"
    #       client.direct_message_create(message.sender.screen_name, reply_text)
    #       local_message.update_attributes(:answered => true)
    #     else
    #       puts "Error in message: #{tweet.content}"
    #       client.direct_message_create(message.sender.screen_name, "Something broke inside me and I can't reply properly. Try again later.")
    #       local_message.update_attributes(:error => true)
    #     end
    #     client.direct_message_destroy(message.id)
    #   end
    # end
    # sleep 5

    # tweets
    puts "Last tweet id is : #{Tweet.last_tweet_id}"
    results = Twitter.search("to:#{TWITTER_USERNAME}", :rpp => 100, :result_type => "recent", :since_id => Tweet.last_tweet_id)
    results.each do |result|
      next if result["from_user"].downcase == TWITTER_USERNAME.downcase
      next if result["text"].downcase !~ /^\@#{TWITTER_USERNAME.downcase}/
      puts result["id"]
      puts result["from_user"]
      tweet = Tweet.find_or_create_by_tweet_id_and_from_user_and_content(result["id"], result["from_user"].to_s, result["text"].to_s)
    end

    # process
    Tweet.find(
      :all,
      :order => "tweet_id ASC",
      :conditions => ["answered = ? AND error = ?", false, false]
    ).each do |tweet|
      interacter = Interacter.new(tweet.from_user)
      if tweet.just_content =~ /spoon/i && !client.friendship(tweet.from_user, TWITTER_USERNAME).target.following?
        puts "Following #{tweet.from_user}"
        client.follow(tweet.from_user)
        tweet.update_attributes(:answered => true)
      else
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
    end

    puts "sleep"
    sleep 15

  end
end