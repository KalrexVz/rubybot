require 'discordrb'
require 'mongo'
require 'logger'
require_relative './utils/confess_handler'
require_relative './utils/welcome_image'
require_relative './utils/quote_image'
require_relative './commands/autoreply'


# Koneksi ke MongoDB
client = Mongo::Client.new(ENV['MONGO_URI'] || 'mongodb+srv://vorze:<db_password>@cluster0.lpvwi.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0')
db = client.database

# Token bot kamu
token = 'MTM2MjYwMjM0MTYwMTI1MTQ4NA.GunPR6.D2rqVgUeXSuMh_bUZrdiHFQG4PaKHi6EcaOQE8'

# Membuat bot baru dengan prefix '!'
bot = Discordrb::Bot.new token: token, client_id: 1362602341601251484

# Logger
logger = Logger.new($stdout)
begin
  mongo_client = Mongo::Client.new(ENV['MONGO_URI'] || 'mongodb://localhost:27017', database: 'nama_database')
  db = mongo_client.database
  logger.info("✅ Berhasil terhubung ke MongoDB: #{db.name}")
rescue => e
  logger.error("❌ Gagal terhubung ke MongoDB: #{e.message}")
end

# Load semua perintah dari folder 'commands'
Dir['./commands/*.rb'].each { |file| require file }

# Handler member join
bot.member_join do |event|
  username = "#{event.user.username}##{event.user.discriminator}"
  avatar_url = event.user.avatar_url

  image_io = generate_welcome_image_blob(username, avatar_url)
  welcome_channel = event.server.channel(1361543454785671220)  # Ganti ke ID channel welcome
  welcome_channel.send_file(image_io, filename: 'welcome.png') if welcome_channel
end

# Handler quote
bot.message(start_with: '@bot quote') do |event|
  quote_text = event.message.content.sub('@bot quote ', '')
  user = event.user

  quote_image = generate_quote_image(user, quote_text)

  target_channel_id = 1359750948674732334  # Ganti ke ID channel quote
  target_channel = event.server.channel(target_channel_id)

  if target_channel
    sent_message = target_channel.send_file(quote_image, filename: 'quote_image.png')
    target_channel.send_message("#{sent_message.jump_url} - by @#{user.username}")
    thread = target_channel.create_thread(name: "Quote by @#{user.username}", message: "This thread is for the quote by @#{user.username}")
    thread.send_message("Here's a quote from @#{user.username}: #{quote_text}")
  else
    event.respond("Channel tidak ditemukan!")
  end
end

# Tampilkan tombol confess & reply saat bot siap
bot.ready do
  bot.update_status('dnd', 'Bot is Online')
  puts 'Bot sudah siap dan status DND diatur!'

  confess_channel = bot.channel(1361550318474887339)  # Ganti ke ID channel confess
  if confess_channel
    confess_channel.send_message(
      content: "Bot telah online! Ingin menyatakan perasaan secara anonim?\nTekan tombol di bawah untuk mulai confess atau membalas seseorang.",
      components: [
        Discordrb::Webhooks::View.new do |view|
          view.row do |row|
            row.button(label: "Confess", style: :primary, custom_id: "confess_start")
            row.button(label: "Reply", style: :secondary, custom_id: "confess_reply")
          end
        end
      ]
    )
  end
end

# Load confess handler
handle_confess_buttons(bot, db)


bot.message(start_with: '!autoreply') { |event| Commands::Autoreply.call(event) }

# Listener untuk auto-reply berdasarkan trigger
bot.message do |event|
  next if event.user.bot_account? || event.message.content.start_with?('!')

  # Cek apakah ada trigger yang cocok
  data = DB[:autoreplies].find({ server_id: event.server.id.to_s, trigger: event.message.content.strip.downcase }).first
  if data
    event.respond(data[:response])
  end
end

# Jalankan bot
bot.run