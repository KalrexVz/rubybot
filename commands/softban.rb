module Commands
  class Softban
    def self.call(event)
      return unless event.user.permission?(:ban_members)

      target = event.message.mentions.first
      alasan = event.message.content.split[2..]&.join(' ') || 'Tidak ada alasan'

      if target
        event.server.ban(target, 1, alasan)  # Ban + hapus 1 hari pesan
        event.server.unban(target)          # Langsung unban (softban)
        event.respond "#{target.username} telah di-softban. Alasan: #{alasan}"
      else
        event.respond 'Tag seseorang untuk di-softban.'
      end
    end
  end
end

bot.message(start_with: '!softban') { |event| Commands::Softban.call(event) }