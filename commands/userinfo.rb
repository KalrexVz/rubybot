module Commands
  class UserInfo
    def self.call(event)
      user = event.message.mentions.first || event.user
      embed = Discordrb::Webhooks::Embed.new(
        title: "#{user.username}'s Information",
        fields: [
          { name: "Username", value: user.username, inline: true },
          { name: "User ID", value: user.id.to_s, inline: true },
          { name: "Status", value: user.status.to_s.capitalize, inline: true },
          { name: "Joined Server", value: event.server.member(user).joined_at.strftime("%b %d, %Y"), inline: true }
        ]
      )
      event.respond(embed)
    end
  end
end

bot.message(start_with: '!userinfo') { |event| Commands::UserInfo.call(event) } 