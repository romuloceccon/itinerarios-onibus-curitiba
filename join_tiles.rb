require 'fileutils'
require 'RMagick'

i, j = 1, 1
rows, cols = [], []
while true
  file_name = "%02d_%02d.gif" % [i, j]
  break unless File.exist?(file_name)
  cols << file_name
  j += 1
  file_name = "%02d_%02d.gif" % [i, j]
  unless File.exist?(file_name)
    i += 1
    j = 1
    rows.unshift(cols)
    cols = []
  end
end

row_files = []
rows.each_with_index do |row, i|
  list = Magick::ImageList.new(*row)
  image = list.append(false)
  file_name = "tmp#{i}.gif"
  image.write(file_name)
  row_files << file_name
end

list = Magick::ImageList.new(*row_files)
image = list.append(true)
image.write("map.gif")
row_files.each { |x| FileUtils.rm(x) }
