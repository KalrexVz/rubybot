module Commands
  class Unlockdown
    def self.call(event)
      return unless event.user.permission?(:manage_channels)

      channel = event.channel
      channel.define_overwrite(event.server.everyone_role, true, :send_messages)
      event.respond "Channel ini telah dibuka kembali dari lockdown."
    end
  end
end

bot.message(start_with: '!lockdown off') { |event| Commands::Unlockdown.call(event) }