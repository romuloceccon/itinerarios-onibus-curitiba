require 'net/http'

RATIO = 1.249376559

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

x0, y0, xn, yn = generate_tile('461', rand(1_000_000))

puts "Downloading tile (#{x0}, #{y0}), (#{xn}, #{yn})"

ya, j = y0, 1
while ya < yn
  xa, i = x0, 1
  while xa < xn
    req_id = rand(1_000_000)
    x1, y1, x2, y2 = generate_tile('461', req_id, { x0: xa, y0: ya, h: 1250.0 })
    puts "Tile #{i},#{j}: (#{x1}, #{y1}), (#{x2}, #{y2})"
    download_tile("t-%02d-%02d.gif" % [i, j], req_id)
    i += 1
    xa += 1250.0 * RATIO
  end
  j += 1
  ya += 1250.0
end

