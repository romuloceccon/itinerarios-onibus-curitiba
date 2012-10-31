require 'RMagick'

d = Magick::Draw.new
STDIN.readlines.each do |line|
  points = line.strip.split(';')
  a, b = points.map { |x| x.split(',').map { |x| x.to_i } }
  d.line(a[0], a[1], b[0], b[1])
end
i = Magick::Image.new(2004, 1604)
d.draw(i)
i.write('test.png')
