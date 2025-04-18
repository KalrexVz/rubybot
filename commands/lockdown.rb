module Commands
  class Lockdown
    def self.call(event)
      return unless event.user.permission?(:manage_channels)

      channel = event.channel

      channel.define_overwrite(event.server.everyone_role, false, :send_messages)
      event.respond "Channel ini telah di-lockdown."
    end
  end
end

bot.message(start_with: '!lockdown') { |event| Commands::Lockdown.call(event) }