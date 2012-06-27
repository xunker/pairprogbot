task :twitteresque => :environment do
  username = 'bob'
  puts "Your simulated username is '@#{username}'"

  interacter = Interacter.new(username)
  tweet = ""
  until tweet == "bye" do
    print "> "
    tweet = $stdin.gets.downcase.strip
    case tweet
    when "bye"
      puts "goodbye"
    when '',nil
    else
      puts interacter.command(tweet)
    end

  end

end