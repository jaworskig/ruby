#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'mail'

url = 'http://www.bip.otwock.pl/default.asp?IDk=40'
send = false
mail = Mail.new
mail['from'] = 'root@vps94760.ovh.net'
mail[:to] = 'jaworskig@gmail.com'
mail.subject = 'Obwiesczenie ' + Time.now.strftime("%d/%m/%Y %H:%M")
mail.delivery_method :sendmail

doc = Nokogiri::HTML(open(url))
doc.traverse do |el|
    [el[:src], el[:href]].grep(/\.(pdf)$/i).map{|l| URI.join(url, l).to_s}.each do |link|
	fileName = File.basename(link)
        if !File.file?(fileName) 
		File.open(fileName,'wb'){|f| f << open(link,'rb').read}
		mail.add_file(fileName)
		send = true
	end
    end
end

if send
  mail.deliver
end

