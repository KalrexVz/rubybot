require 'securerandom'

def handle_confess_buttons(bot, db)
  confess_collection = db[:confessions]

  bot.button(custom_id: "confess_start") do |event|
    event.respond_with_modal(
      title: "Kirim Confess Anonim",
      custom_id: "modal_confess",
      components: [
        {
          type: 1,
          components: [
            {
              type: 4,
              custom_id: "confess_text",
              style: 2,
              label: "Apa yang ingin kamu sampaikan?",
              placeholder: "Tulis isi confess kamu di sini...",
              required: true
            }
          ]
        }
      ]
    )
  end

  bot.button(custom_id: "confess_reply") do |event|
    event.respond_with_modal(
      title: "Balas Confess",
      custom_id: "modal_reply",
      components: [
        {
          type: 1,
          components: [
            {
              type: 4,
              custom_id: "reply_id",
              style: 1,
              label: "ID Confess (contoh: CFS-a1b2)",
              placeholder: "Masukkan ID confess yang ingin dibalas",
              required: true
            }
          ]
        },
        {
          type: 1,
          components: [
            {
              type: 4,
              custom_id: "reply_text",
              style: 2,
              label: "Isi Balasan",
              placeholder: "Tulis balasan kamu di sini...",
              required: true
            }
          ]
        }
      ]
    )
  end

  bot.modal(custom_id: "modal_confess") do |event|
    confess_text = event.values["confess_text"]
    confess_id = "CFS-#{SecureRandom.hex(2)}"

    message = event.channel.send_embed do |embed|
      embed.title = "Confession Anonim"
      embed.description = confess_text
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: confess_id)
      embed.color = 0xFF77AA
    end

    confess_collection.insert_one({
      _id: confess_id,
      text: confess_text,
      message_id: message.id,
      channel_id: message.channel.id,
      replies: []
    })

    event.respond(content: "Confess berhasil dikirim sebagai #{confess_id}!", ephemeral: true)
  end

  bot.modal(custom_id: "modal_reply") do |event|
    confess_id = event.values["reply_id"]
    reply_text = event.values["reply_text"]

    data = confess_collection.find(_id: confess_id).first

    if data.nil?
      event.respond(content: "Confess ID tidak ditemukan.", ephemeral: true)
    else
      # Update DB
      new_reply = {
        id: SecureRandom.hex(2),
        text: reply_text
      }

      confess_collection.update_one({ _id: confess_id }, { "$push" => { replies: new_reply } })

      # Update embed
      channel = bot.channel(data["channel_id"])
      msg = channel.message(data["message_id"])

      base_embed = Discordrb::Webhooks::Embed.new
      base_embed.title = "Confession Anonim"
      base_embed.description = data["text"]
      base_embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: confess_id)
      base_embed.color = 0xFF77AA

      if data["replies"] && !data["replies"].empty?
        reply_str = data["replies"].map.with_index(1) { |r, i| "ID#{i}: #{r['text']}" }.join("\n")
        base_embed.add_field(name: "Replies", value: reply_str)
      end

      msg.edit('', embed: base_embed)

      event.respond(content: "Balasan berhasil dikirim ke confess #{confess_id}.", ephemeral: true)
    end
  end
end