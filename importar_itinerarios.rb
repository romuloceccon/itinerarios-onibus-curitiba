require 'net/http'
require 'uri'
require 'nokogiri'
require 'yaml'

uri = URI("http://urbs-web.curitiba.pr.gov.br/centro/conteudo_lista_linhas.asp?l='n'")

response = Net::HTTP.start(uri.host, uri.port) do |http|
  http.get(uri.request_uri).body
end

Dir.mkdir('itinerarios') unless File.exist?('itinerarios')

html = Nokogiri::HTML(response)
select = html.xpath('/html/body/table/tr/td/p/select')
select.xpath('option').each do |option|
  v = option.attributes['value'].value
  t = option.text

  td_list = nil
  
  begin
    puts "#{v} : #{t}"
    
    response_linha = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get("/centro/printRuas.asp?codLinha=#{v}").body
    end
  
    data = Hash.new { |h, k| h[k] = [] }
    index = 0
    
    html_linha = Nokogiri::HTML(response_linha)
    td_list = html_linha.xpath('/html/body/table/tr/td')
  end while td_list.empty?
  
  td_list.each do |td|
    if (title = td.xpath('strong')).empty? then
      data[index] << td.text
    else
      index = title.text.match(/\w.*\w/).to_s
    end
  end

  File.open("itinerarios/#{t.gsub('/', '-')} (#{v}).yml", 'w') do |x|
    x << { 'CODIGO' => v, 'NOME' => t }.merge(data).to_yaml
  end
end
