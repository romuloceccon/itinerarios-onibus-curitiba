require 'net/http'
require 'yaml'
require 'linhas_curitiba'

RATIO = 501.0 / 401.0
TILE_HEIGHT = 500.0 # 1250.0, 500.0, 200.0
DATABASE = 'map_download.yml'

def generate_tile(linha, req_id, options = {})
  x0 = options[:x0].to_f
  y0 = options[:y0].to_f
  h = options[:h] || 500.0
  
  if x0 == 0.0
    cx = '0.0'
  else
    cx = '%.3f' % (x0 + h / 2.0 * RATIO)
  end
  
  if y0 == 0.0
    cy = '0.0'
  else
    cy = '%.3f' % (y0 + h / 2.0)
  end
  
  r = "%.1f" % (h / 2.0)
  
  res = Net::HTTP.start('urbs-web.curitiba.pr.gov.br', 80) do |http|
    a = http.get("/centro//j_urbs2.asp?cx=#{cx}&cy=#{cy}&r=#{r}&ll=#{req_id}&cl=#{linha}&u=http://urbs-web.curitiba.pr.gov.br/centro/")
    a.value unless Net::HTTPSuccess === a
    a.body
  end

  res.split(';').compact.map { |x| x.to_f }
end

def download_tile(file_name, req_id)
  res = Net::HTTP.start('urbs-web.curitiba.pr.gov.br', 80) do |http|
    a = http.get("/centro//mapa/tmp#{req_id}.gif")
    a.value unless Net::HTTPSuccess === a
    a.body
  end
  
  File.open(file_name, 'wb+') { |x| x.write(res) }
end

def get_tile_coordinates(x0, y0, xn, yn)
  result = []
  ya, row = y0, 1
  while ya < yn
    xa, col = x0, 1
    while xa < xn
      result << { row: row, col: col, request_options: { x0: xa, y0: ya, h: TILE_HEIGHT } }
      col += 1
      xa += TILE_HEIGHT * RATIO
    end
    row += 1
    ya += TILE_HEIGHT
  end
  result
end

def save_database
  File.open(DATABASE, 'w+') { |x| YAML.dump($database, x) }
end

unless File.exist?(DATABASE)
  $database = { }
  get_linhas_curitiba.each_pair do |k, v|
    $database[k] = { 'nome' => v }
  end
  save_database
else
  $database = File.open(DATABASE) { |x| YAML.load(x) }
end

$database.each_pair do |k, v|
  next if v['skip']
  next if v['map']
  
  req_id = rand(1_000_000)
  x0, y0, xn, yn = generate_tile(k, req_id)
  file_name = "map_#{k}.gif"
  download_tile(file_name, req_id)
  
  $database[k]['map'] = { 'x0' => x0, 'y0' => y0, 'xn' => xn, 'yn' => yn, 'file_name' => file_name }
  save_database
end

=begin
puts "Downloading tile (#{x0}, #{y0}), (#{xn}, #{yn})"

ya, j = y0, 1
while ya < yn
  xa, i = x0, 1
  while xa < xn
    req_id = rand(1_000_000)
    x1, y1, x2, y2 = generate_tile('461', req_id, { x0: xa, y0: ya, h: TILE_HEIGHT })
    puts "Tile #{i},#{j}: (#{x1}, #{y1}), (#{x2}, #{y2})"
    download_tile("t-%02d-%02d.gif" % [i, j], req_id)
    i += 1
    xa += TILE_HEIGHT * RATIO
  end
  j += 1
  ya += TILE_HEIGHT
end
=end
