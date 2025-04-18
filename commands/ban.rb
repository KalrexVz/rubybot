module Commands
  class Ban
    def self.call(event)
      return unless event.user.permission?(:ban_members)

      target = event.message.mentions.first
      alasan = event.message.content.split[2..]&.join(' ') || 'Tidak ada alasan'

      if target
        event.server.ban(target, 0, alasan)
        event.respond "#{target.username} telah di-banned. Alasan: #{alasan}"
      else
        event.respond 'Tag seseorang untuk diban.'
      end
    end
  end
end


bot.message(start_with: '!ban') { |event| Commands::Ban.call(event) }