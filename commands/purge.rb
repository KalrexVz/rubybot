module Commands
  class Purge
    def self.call(event)
      return unless event.user.permission?(:manage_messages)

      jumlah = event.message.content.split[1]&.to_i

      if jumlah && jumlah.between?(1, 100)
        event.channel.prune(jumlah)
        event.respond "Berhasil menghapus #{jumlah} pesan."
      else
        event.respond 'Gunakan format: `!purge 10` (1-100 pesan).'
      end
    end
  end
end

bot.message(start_with: '!purge') { |event| Commands::Purge.call(event) }