require 'rmagick'
require 'open-uri'
require 'stringio'

include Magick

def generate_welcome_image_blob(username, avatar_url)
  background = Image.read("assets/template.png").first

  avatar_file = URI.open(avatar_url)
  avatar = Image.from_blob(avatar_file.read).first
  avatar.resize_to_fill!(440, 440)

  mask = Image.new(440, 440) { self.background_color = 'black' }
  gc = Draw.new
  gc.fill('white')
  gc.ellipse(220, 220, 220, 220, 0, 360)
  gc.draw(mask)

  avatar.matte = true
  avatar.composite!(mask, 0, 0, CopyOpacityCompositeOp)

  avatar_x = (1760 - 440) / 2
  avatar_y = 170
  background.composite!(avatar, avatar_x, avatar_y, OverCompositeOp)

  draw = Draw.new
  draw.font = 'assets/adlas.ttf'
  draw.pointsize = 90
  draw.gravity = NorthWestGravity

  metrics = draw.get_type_metrics(background, username)
  text_width = metrics.width

  text_x = (1760 - text_width) / 2
  text_y = 613

  shadow = Draw.new
  shadow.font = 'assets/adlas.ttf'
  shadow.pointsize = 90
  shadow.fill = 'black'
  shadow.text(text_x + 3, text_y + 3, username)
  shadow.draw(background)

  draw.fill = 'white'
  draw.text(text_x, text_y, username)
  draw.draw(background)

  blob = background.to_blob { self.format = 'PNG' }
  StringIO.new(blob)
end