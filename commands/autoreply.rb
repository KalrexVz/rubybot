module Commands
  class Autoreply
    def self.call(event)
      args = event.message.content.split(' ', 2)
      command = args[1]&.downcase

      case command
      when 'add'
        add_autoreply(event, args[2])
      when 'edit'
        edit_autoreply(event, args[2])
      when 'delete'
        delete_autoreply(event, args[2])
      when 'list'
        list_autoreplies(event)
      else
        show_help(event)
      end
    end

    def self.add_autoreply(event, input)
      if input.nil? || !input.include?('|')
        event.respond("❌ Format salah! Gunakan: !autoreply add [trigger] | [response]")
        return
      end

      trigger, response = input.split('|', 2).map(&:strip)
      if trigger.empty? || response.empty?
        event.respond("❌ Format salah! Gunakan: !autoreply add [trigger] | [response]")
        return
      end

      DB[:autoreplies].insert_one({
        server_id: event.server.id.to_s,
        trigger: trigger.downcase,
        response: response
      })

      event.respond("✅ Auto-reply untuk '#{trigger}' berhasil ditambahkan.")
    end

    def self.edit_autoreply(event, input)
      if input.nil? || !input.include?('|')
        event.respond("❌ Format salah! Gunakan: !autoreply edit [trigger] | [new_response]")
        return
      end

      trigger, new_response = input.split('|', 2).map(&:strip)
      if trigger.empty? || new_response.empty?
        event.respond("❌ Format salah! Gunakan: !autoreply edit [trigger] | [new_response]")
        return
      end

      result = DB[:autoreplies].find_one_and_update(
        { server_id: event.server.id.to_s, trigger: trigger.downcase },
        { '$set' => { response: new_response } }
      )

      if result
        event.respond("✏️ Auto-reply untuk '#{trigger}' berhasil diperbarui.")
      else
        event.respond("❌ Trigger tidak ditemukan.")
      end
    end

    def self.delete_autoreply(event, input)
      if input.nil?
        event.respond("❌ Format salah! Gunakan: !autoreply delete [trigger]")
        return
      end

      trigger = input.strip
      result = DB[:autoreplies].delete_one({ server_id: event.server.id.to_s, trigger: trigger.downcase })

      if result.deleted_count > 0
        event.respond("🗑️ Auto-reply untuk '#{trigger}' berhasil dihapus.")
      else
        event.respond("❌ Trigger tidak ditemukan.")
      end
    end

    def self.list_autoreplies(event)
      replies = DB[:autoreplies].find({ server_id: event.server.id.to_s }).to_a
      if replies.empty?
        event.respond("❌ Tidak ada auto-reply yang terdaftar.")
      else
        list = replies.map { |r| "`#{r[:trigger]}` => #{r[:response]}" }.join("\n")
        event.respond("**Daftar Auto-Reply:**\n#{list}")
      end
    end

    def self.show_help(event)
      event.respond("🔹 **Cara menggunakan perintah !autoreply:** 🔹\n" \
                    "`!autoreply add [trigger] | [response]` - Menambahkan auto-reply\n" \
                    "`!autoreply edit [trigger] | [new_response]` - Mengedit auto-reply yang ada\n" \
                    "`!autoreply delete [trigger]` - Menghapus auto-reply\n" \
                    "`!autoreply list` - Menampilkan daftar auto-replies yang ada")
    end
  end
end