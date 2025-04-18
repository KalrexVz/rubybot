module Commands
  class Warns
    def self.call(event, db)
      target = event.message.mentions.first

      if target
        warnings = db[:warnings].find(user_id: target.id).to_a
        if warnings.any?
          list = warnings.map.with_index(1) do |warn, i|
            "#{i}. #{warn[:reason]} (oleh <@#{warn[:moderator_id]}>, #{warn[:timestamp].strftime('%d %b %Y')})"
          end.join("\n")
          event.respond "**Peringatan untuk #{target.username}:**\n#{list}"
        else
          event.respond "#{target.username} belum memiliki peringatan."
        end
      else
        event.respond 'Tag seseorang untuk melihat peringatannya.'
      end
    end
  end
end

bot.message(start_with: '!warns') { |event| Commands::Warns.call(event, db) }