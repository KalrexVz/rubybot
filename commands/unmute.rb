module Commands
  class Unmute
    def self.call(event)
      return unless event.user.permission?(:manage_roles)

      target = event.message.mentions.first
      mute_role = event.server.roles.find { |r| r.name.downcase == 'muted' }

      if target && mute_role && target.role?(mute_role)
        target.remove_role(mute_role)
        event.respond "#{target.username} telah di-unmute."
      else
        event.respond 'User tidak dimute atau role "Muted" tidak ditemukan.'
      end
    end
  end
end

bot.message(start_with: '!unmute') { |event| Commands::Unmute.call(event) }