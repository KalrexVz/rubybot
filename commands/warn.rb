module Commands
  class Warn
    def self.call(event, db)
      return unless event.user.permission?(:kick_members)

      target = event.message.mentions.first
      alasan = event.message.content.split[2..]&.join(' ') || 'Tidak ada alasan'

      if target
        db[:warnings].insert_one({
          user_id: target.id,
          moderator_id: event.user.id,
          reason: alasan,
          timestamp: Time.now
        })

        event.respond "#{target.username} telah diberi peringatan. Alasan: #{alasan}"
      else
        event.respond 'Tag seseorang untuk diberi peringatan.'
      end
    end
  end
end

bot.message(start_with: '!warn') do |event|
  Commands::Warn.call(event, db)
end