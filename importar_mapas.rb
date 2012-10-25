require 'net/http'
require 'yaml'
require 'fileutils'
require 'linhas_curitiba'

RATIO = 501.0 / 401.0
TILE_HEIGHT = 500.0 # 1250.0, 500.0, 200.0
DATABASE = 'map_download.yml'

def generate_tile(linha, req_id, options = {})
  x0 = options['x0'].to_f
  y0 = options['y0'].to_f
  h = options['h'] || 500.0
  
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
  border = TILE_HEIGHT / 2
  ya, row = y0 - border, 1
  while ya < yn + border
    xa, col = x0 - border * RATIO, 1
    while xa < xn + border * RATIO
      result << { 'row' => row, 'col' => col, 'request_options' => { 'x0' => xa, 'y0' => ya, 'h' => TILE_HEIGHT } }
      col += 1
      xa += TILE_HEIGHT * RATIO
    end
    row += 1
    ya += TILE_HEIGHT
  end
  result
end

def save_database(file_name, data)
  tmp = "#{file_name}.tmp"
  File.open(tmp, 'w+') { |x| YAML.dump(data, x) }
  FileUtils.mv(tmp, file_name)
end

if __FILE__ == $0
  unless File.exist?(DATABASE)
    $database = { }
    get_linhas_curitiba.each_pair do |k, v|
      $database[k] = { 'nome' => v }
    end
    save_database(DATABASE, $database)
  else
    $database = File.open(DATABASE) { |x| YAML.load(x) }
  end
  
  $database.each_pair do |k, v|
    next if v['skip']
    next if v['map']
    
    file_name = "#{k}.gif"
    STDERR.puts "Downloading map #{k} (#{v['nome']}) to #{file_name}"

    req_id = rand(1_000_000)
    x0, y0, xn, yn = generate_tile(k, req_id)
    tiles = get_tile_coordinates(x0, y0, xn, yn)
    
    download_tile(file_name, req_id)
    
    tile_database = "#{k}.yml"
    File.open(tile_database, 'w+') { |x| YAML.dump(tiles, x) }
    
    $database[k]['map'] = { 'x0' => x0, 'y0' => y0, 'xn' => xn, 'yn' => yn,
        'file_name' => file_name, 'database' => tile_database }
    save_database(DATABASE, $database)
  end
  
  $database.each_pair do |k, v|
    map = v['map']
    tile_database = map && v['map']['database']
    next unless tile_database
    
    tiles = File.open(tile_database) { |x| YAML.load(x) }
    tiles.each do |tile|
      next if tile['file_name']
      
      row, col = tile['row'], tile['col']
      file_name = "#{k}/%02d_%02d.gif" % [row, col]
      STDERR.puts "Downloading tile #{row},#{col} to #{file_name}"

      req_id = rand(1_000_000)
      generate_tile(k, req_id, tile['request_options'])
      
      Dir.mkdir(k) unless File.exist?(k)
      download_tile(file_name, req_id)
      
      tile['file_name'] = file_name
      save_database(tile_database, tiles)
    end
  end
end
