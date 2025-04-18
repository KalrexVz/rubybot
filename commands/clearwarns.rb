module Commands
  class ClearWarns
    def self.call(event, db)
      return unless event.user.permission?(:kick_members)

      target = event.message.mentions.first

      if target
        result = db[:warnings].delete_many(user_id: target.id)
        event.respond "Berhasil menghapus #{result.deleted_count} peringatan dari #{target.username}."
      else
        event.respond 'Tag seseorang untuk menghapus peringatannya.'
      end
    end
  end
end

bot.message(start_with: '!clearwarns') { |event| Commands::ClearWarns.call(event, db) }