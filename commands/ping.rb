module Commands
  class Ping
    def self.call(event)
      event.respond 'Pong!'
    end
  end
end

bot.message(start_with: '!ping') do |event|
  Commands::Ping.call(event)  # Memanggil perintah Ping dari class Ping
end