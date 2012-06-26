task :ppb_console => :environment do
  puts 'ppd console'
  puts "your name please?"
  username = $stdin.gets
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
    else
      puts "*** unknown command '#{cmd}'"
    end

  end

end