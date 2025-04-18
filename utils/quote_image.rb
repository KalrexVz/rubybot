require 'rmagick'
require 'open-uri'
require 'stringio'

include Magick

def generate_quote_image(user, quote_text)
  width, height = 1000, 500
  background = Image.new(width, height) { self.background_color = 'black' }
  draw = Draw.new

  # Load Avatar
  avatar_url = user.avatar_url
  avatar_file = URI.open(avatar_url)
  avatar = Image.from_blob(avatar_file.read).first
  avatar = avatar.resize_to_fill!(width / 2, height)

  # Temp place avatar on the left half
  background.composite!(avatar, 0, 0, OverCompositeOp)

  # Add black overlay on the right half
  overlay = Image.new(width / 2, height) { self.background_color = 'rgba(0, 0, 0, 0.7)' }
  background.composite!(overlay, width / 2, 0, OverCompositeOp)

  # Set up fonts
  font_path = 'assets/Inter.ttf'
  font_quote = Draw.new
  font_quote.font = font_path
  font_quote.pointsize = 30

  font_name = Draw.new
  font_name.font = font_path
  font_name.pointsize = 36

  font_username = Draw.new
  font_username.font = font_path
  font_username.pointsize = 24

  font_watermark = Draw.new
  font_watermark.font = font_path
  font_watermark.pointsize = 20

  # Wrap text
  def wrap_text(text, font, max_width)
    words = text.split
    lines = []
    line = ""
    words.each do |word|
      test_line = "#{line} #{word}".strip
      if font.get_type_metrics(test_line).width <= max_width
        line = test_line
      else
        lines << line unless line.empty?
        line = word
      end
    end
    lines << line unless line.empty?
    lines.join("\n")
  end

  # Text wrapping for quote
  max_text_width = width / 2 - 80
  wrapped_text = wrap_text(quote_text, font_quote, max_text_width)

  # Measure text sizes
  draw = Draw.new
  quote_bbox = draw.get_type_metrics(background, wrapped_text)
  quote_h = quote_bbox.height

  name_bbox = draw.get_type_metrics(background, user.display_name)
  name_h = name_bbox.height

  username_text = "@#{user.username}"
  username_bbox = draw.get_type_metrics(background, username_text)
  username_h = username_bbox.height

  # Calculate vertical position
  start_y = (height - (quote_h + 40 + name_h + 25 + username_h)) / 2
  x_text = width / 2 + 40

  # Draw text
  draw.fill = 'white'
  draw.text(x_text, start_y, wrapped_text)
  draw.text(x_text, start_y + quote_h + 40, user.display_name)
  draw.text(x_text, start_y + quote_h + 40 + name_h + 25, username_text)

  # Watermark
  watermark = "jombloers quote"
  watermark_bbox = draw.get_type_metrics(background, watermark)
  draw.text(width - watermark_bbox.width - 15, height - 25, watermark)

  # Save to buffer
  buffer = StringIO.new
  background.write(buffer, 'PNG')
  buffer.rewind
  buffer
end