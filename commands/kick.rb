module Commands
  class Kick
    def self.call(event)
      return unless event.user.permission?(:kick_members)

      target = event.message.mentions.first
      alasan = event.message.content.split[2..]&.join(' ') || 'Tidak ada alasan'

      if target
        event.server.kick(target)
        event.respond "#{target.username} telah di-kick. Alasan: #{alasan}"
      else
        event.respond 'Tag seseorang untuk di-kick.'
      end
    end
  end
end

bot.message(start_with: '!kick') { |event| Commands::Kick.call(event) }