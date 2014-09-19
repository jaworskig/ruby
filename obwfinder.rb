#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'mail'
require 'mongo'
require 'pp'
include Mongo

mongo_client = MongoClient.new 
db = mongo_client.db("art_db")
coll = db["obwieszczenia"]
pp db.collection_names

url = 'http://www.bip.otwock.pl/default.asp?IDk=40'
send = false
mail = Mail.new
mail['from'] = 'root@vps94760.ovh.net'
mail[:to] = 'jaworskig@gmail.com'
mail.subject = 'Obwieszczenia ' + Time.now.strftime("%d/%m/%Y %H:%M")
mail.delivery_method :sendmail
mail_body = ''

doc = Nokogiri::HTML(open(url))
els = doc.search "[text()*='Obwieszczenie']"

els.each do |e| 
 	obw = e.next_element
	if obw != nil && coll.find('text_content' => obw.text()).to_a.count == 0
		  oText = obw.text()
                  pp 'New article ' + oText
                  coll.insert({ "text_content" => oText, "date" => Time.now})
                  mail_body = mail_body + oText + "\n"
                  send = true
        end

end

#puts els.first.next_element


if send
  mail.body = mail_body
  mail.deliver
end

