require 'RMagick'

d = Magick::Draw.new
STDIN.readlines.each do |line|
  point = line.strip.split(' ').map { |x| x.to_i }
  d.circle(point[0], point[1], point[0] + 8, point[1])
end
i = Magick::Image.new(1503, 2005)
d.draw(i)
i.write('test.png')
