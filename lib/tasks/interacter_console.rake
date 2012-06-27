task :interacter_console => :environment do
  puts 'interacter console'

  puts "your name please?"
  username = $stdin.gets.strip
  puts "Hello #{username}"
  interacter = Interacter.new(username)
  cmd = ""
  until cmd == "exit" do
    if interacter.feature
      puts "\t#{interacter.feature.question}"
    end

    print "> "
    cmd = $stdin.gets.downcase.strip
    case cmd
    when "exit"
      puts "goodbye"
    when '',nil
    else
      puts interacter.command(cmd)
    end

  end

end