#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'mail'
require 'mongo'

include Mongo

mongo_client = MongoClient.new 
db = mongo_client.db("art_db")
coll = db["link"]
puts db.collection_names
#puts coll.find.to_a

url = 'http://www.otwock.pl/default.asp?ID=1&w=1'
send = false
mail = Mail.new
mail['from'] = 'root@vps94760.ovh.net'
mail[:to] = 'jaworskig@gmail.com'
mail.subject = 'Artykuly ' + Time.now.strftime("%d/%m/%Y %H:%M")
mail.delivery_method :sendmail
mail_body = ''
doc = Nokogiri::HTML(open(url))
doc.traverse do |el|
    [el[:href]].grep(/ID=110&/).map{|l| URI.join(url, l).to_s}.each do |link|
		
		if coll.find("link_id" => link).to_a.count == 0
		  puts 'New article ' + link
		  coll.insert({ "link_id" => link, "text" => el.text(), "date" => Time.now})
		  mail_body = mail_body + link + " " + el.text() +  "\n"
	          send = true
		end
	end
    end

if send
  mail.body = mail_body
  mail.deliver
end

