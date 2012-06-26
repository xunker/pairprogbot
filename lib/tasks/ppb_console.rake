task :ppb_console => :environment do
  puts 'ppd console'
  puts "your name please?"
  username = $stdin.gets.strip
  puts "Hello #{username}"
  cmd = ""
  until cmd == "exit" do
    if @feature
      puts "\tFeature is complete" if @feature.finished?
      puts "\t#{@feature.question}"
    end

    print "> "
    cmd = $stdin.gets.downcase.strip
    case cmd
    when "exit"
      puts "goodbye"
    when /^start/, /^feature/
      if @feature.nil? || @feature.finished?
        name = if m = cmd.match(/.+\s+(.+)/)
          m[1]
        else
          nil
        end

        @feature = Feature.find_or_create_by_username_and_name(:username => username, :name => name)
        puts "starting feature #{@feature.name}"
      else
        puts "You are in the middle of a feature! You can't start a new feature until you complete the old one!"
      end
    when 'yes', 'no'
      if @feature.completed?(cmd)
        @feature.next!
      else
        puts @feature.negative_answer
        @feature.test! if @feature.refactor?
      end
    when '',nil
    when /^hello/
      if @feature
        puts "Hello #{username}, we are working on #{@feature.name.blank? ? 'a feature' : @feature.name}."
      else
        puts "Hello, we're not working on a feature right now."
        if (features = Feature.find_all_by_username(username)).present?
          puts "We have worked on #{features.size} features in the past."
        end
      end
    when /^list/
      if (features = Feature.find_all_by_username(username)).present?
        puts "In the past we have worked on #{features.size} features. The last 5 were:"
        features[0..4].each do |f|
          puts "- #{f.name} (#{f.created_at})"
        end
      else
        puts "I have never worked on any features with you, #{username}."
      end
    else
      puts "*** unknown command '#{cmd}'"
    end

  end

end