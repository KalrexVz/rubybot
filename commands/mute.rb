module Commands
  class Mute
    def self.call(event)
      return unless event.user.permission?(:manage_roles)

      target = event.message.mentions.first
      alasan = event.message.content.split[2..]&.join(' ') || 'Tidak ada alasan'
      mute_role = event.server.roles.find { |r| r.name.downcase == 'muted' }

      unless mute_role
        event.respond 'Role "Muted" tidak ditemukan.'
        return
      end

      if target
        target.add_role(mute_role)
        event.respond "#{target.username} telah di-mute. Alasan: #{alasan}"
      else
        event.respond 'Tag seseorang untuk di-mute.'
      end
    end
  end
end

bot.message(start_with: '!mute') { |event| Commands::Mute.call(event) }