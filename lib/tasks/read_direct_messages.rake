task :read_direct_messages => :environment do
  client = Twitter::Client.new
  while true do
    # direct messages
    puts "Direct Messages"
    client.direct_messages.each do |message|
      interacter = Interacter.new(message.sender.screen_name)
      puts [message.id, message.sender.screen_name, message.text].join(', ')
      local_message = Message.find_or_create_by_message_id_and_from_user_and_content(message.id, message.sender.screen_name, message.text)
      if local_message.new_record?
        puts "Error saving Message #{message.id} from #{message.sender.screen_name}: #{message.text}"
      else
        if response = interacter.command(message.text.downcase)
          reply_text =  "#{response} (action ##{local_message.id})"
          puts "DM'ING: #{response}"
          client.direct_message_create(message.sender.screen_name, reply_text)
          local_message.update_attributes(:answered => true)
        else
          puts "Error in message: #{tweet.content}"
          client.direct_message_create(message.sender.screen_name, "Something broke inside me and I can't reply properly. Try again later.")
          local_message.update_attributes(:error => true)
        end
        client.direct_message_destroy(message.id)
      end
    end
    sleep 10
  end
end