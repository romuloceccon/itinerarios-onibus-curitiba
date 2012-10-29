require 'fileutils'
require 'RMagick'
require 'yaml'

$database = ARGV[0]
$base_path = File.dirname($database)
$base_name = File.basename($database, '.yml')

data = File.open($database) { |x| YAML.load(x) }

hash = data.group_by { |x| x['row'] }
$arr = hash.keys.sort.map { |x| hash[x].sort { |a, b| a['col'] <=> b['col'] } }

$blue = Magick::Pixel.new(0, 0, 63736, 0)

def has_blue(i, j)
  image = Magick::Image.read(File.join($base_path, $arr[i][j]['file_name'])).first
  image.each_pixel do |p, c, r|
    if (p <=> $blue) == 0
      return true
    end
  end
  return false
end

def row_has_blue(i)
  $arr[i].each_with_index do |el, j|
    return true if has_blue(i, j)
  end
  return false
end

def col_has_blue(j)
  $arr.each_with_index do |el, i|
    return true if has_blue(i, j)
  end
  return false
end

while !$arr.empty? do
  break if row_has_blue(0)
  $arr.delete_at(0)
end

while $arr.count > 1 do
  break if row_has_blue(-1)
  $arr.delete_at(-1)
end

while !$arr[0].empty? do
  break if col_has_blue(0)
  $arr.each { |x| x.delete_at(0) }
end

while $arr[0].count > 1 do
  break if col_has_blue(-1)
  $arr.each { |x| x.delete_at(-1) }
end

$output_path = File.join($base_path, 'full')
FileUtils.mkdir($output_path) unless File.exist?($output_path)

output_data = {}
output_data['bottom_left'] = $arr[0][0]
output_data['top_right'] = $arr[-1][-1]

row_files = []
$arr.each_with_index do |row, i|
  list = row.map { |x| File.join($base_path, x['file_name']) }.join(' ')
  file_name = "tmp#{i}.gif"
  print `convert +append #{list} #{file_name}`
  row_files.unshift(file_name)
end

print `convert -append #{row_files.join(' ')} #{File.join($output_path, $base_name + '.gif')}`
row_files.each { |x| FileUtils.rm(x) }
File.open(File.join($output_path, $base_name + '.yml'), 'w+') { |x| YAML.dump(output_data, x) }
puts "#{$base_name} ok"
