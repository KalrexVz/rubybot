module Commands
  class Report
    def self.call(event)
      # Cek apakah ada mention user
      target = event.message.mentions.first
      alasan = event.message.content.split[2..]&.join(' ') || nil

      # Petunjuk jika tidak ada alasan atau target
      if !target || alasan.nil?
        help_message = <<~TEXT
          **Cara menggunakan !report:**
          Gunakan command ini untuk melaporkan seseorang di server.
          
          Format:
          ```
          !report @user [kategori] [alasan]
          ```
          **Kategori laporan yang tersedia:**
          - **spam**: Pengguna mengirimkan spam
          - **toxic**: Pengguna bersikap kasar
          - **scam**: Pengguna melakukan penipuan
          - **bot-abuse**: Pengguna menyalahgunakan bot
          
          **Opsional: Lampirkan bukti (attachment)**
          Kamu bisa melampirkan bukti berupa gambar atau file yang relevan dengan laporan kamu. Cukup upload file bersamaan dengan laporan.
          
          Contoh:
          !report @user spam Mengirimkan link spam [lampirkan file bukti]
          ```
        TEXT
        event.respond(help_message)
        return
      end

      # Kategori laporan validasi (opsional)
      valid_categories = ['spam', 'toxic', 'scam', 'bot-abuse']
      kategori = event.message.content.split[1].downcase

      unless valid_categories.include?(kategori)
        event.respond "Kategori yang kamu pilih tidak valid. Gunakan salah satu dari: spam, toxic, scam, bot-abuse."
        return
      end

      # Ambil attachment (jika ada)
      attachment = event.message.attachments.first

      # Kirim laporan ke channel
      report_channel_id = YOUR_REPORT_CHANNEL_ID # Ganti dengan ID channel laporan
      report_channel = event.bot.channel(report_channel_id)

      embed = Discordrb::Webhooks::Embed.new(
        title: "Laporan Pengguna",
        color: 0xff5555,
        timestamp: Time.now,
        fields: [
          { name: "Pelapor", value: "#{event.user.mention} (#{event.user.id})" },
          { name: "Terlapor", value: "#{target.mention} (#{target.id})" },
          { name: "Kategori", value: kategori.capitalize },
          { name: "Alasan", value: alasan }
        ],
        footer: { text: "Channel: ##{event.channel.name} | Server: #{event.server.name}" }
      )

      # Jika ada attachment, tambahkan ke laporan
      if attachment
        embed.add_field(name: "Bukti", value: "Lihat attachment berikut:", inline: false)
        report_channel.send_embed('', embed) do |message|
          message.attachments << attachment.url
        end
      else
        # Jika tidak ada attachment, kirim laporan tanpa file
        report_channel.send_embed('', embed)
      end

      event.respond "Laporan kamu telah dikirim ke tim moderator. Terima kasih!"
    end
  end
end

bot.message(start_with: '!report') { |event| Commands::Report.call(event) }