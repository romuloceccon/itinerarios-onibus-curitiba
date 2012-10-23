# coding: utf-8
require 'net/http'
require 'uri'
require 'nokogiri'
require 'yaml'

$uri = URI("http://urbs-web.curitiba.pr.gov.br/centro/conteudo_lista_linhas.asp?l='n'")

def importar_itinerario(codigo, nome)
  response_linha = Net::HTTP.start($uri.host, $uri.port) do |http|
    http.get("/centro/printRuas.asp?codLinha=#{codigo}").body
  end
  
  if response_linha =~ /The page cannot be displayed/
    STDERR.puts "Erro: Não foi possível importar linha #{codigo}: #{nome}"
    return
  else
    STDERR.puts "#{codigo}: #{nome}"
  end
  
  data = Hash.new { |h, k| h[k] = [] }
  index = 0
  
  html_linha = Nokogiri::HTML(response_linha)
  td_list = html_linha.xpath('/html/body/table/tr/td')
  
  td_list.each do |td|
    if (title = td.xpath('strong')).empty? then
      data[index] << td.text
    else
      index = title.text.match(/\w.*\w/).to_s
    end
  end

  File.open("itinerarios/#{nome.gsub('/', '-')} (#{codigo}).yml", 'w') do |x|
    x << { 'CODIGO' => codigo, 'NOME' => nome }.merge(data).to_yaml
  end
end

codigo, nome = ARGV[0], ARGV[1]

if codigo && nome
  importar_itinerario(codigo, nome)
else
  response = Net::HTTP.start($uri.host, $uri.port) do |http|
    http.get($uri.request_uri).body
  end
  
  Dir.mkdir('itinerarios') unless File.exist?('itinerarios')
  
  html = Nokogiri::HTML(response)
  select = html.xpath('/html/body/table/tr/td/p/select')
  select.xpath('option').each do |option|
    importar_itinerario(option.attributes['value'].value, option.text)
  end
end
