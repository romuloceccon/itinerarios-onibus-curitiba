# coding: utf-8

require 'net/http'
require 'uri'
require 'nokogiri'

def get_linhas_curitiba
  result = {}
  
  uri = URI("http://urbs-web.curitiba.pr.gov.br/centro/conteudo_lista_linhas.asp")

  ['n', 'e'].each do |tipo|
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.request_uri + "?l='#{tipo}'").body
    end
    
    html = Nokogiri::HTML(response)
    select = html.xpath('/html/body/table/tr/td/p/select')
    select.xpath('option').each do |option|
      result[option.attributes['value'].value] = option.text
    end
  end
  
  result
end

if __FILE__ == $0
  get_linhas_curitiba.each_pair do |k, v|
    puts "%3d %s" % [k, v]
  end
end
