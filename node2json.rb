require 'reverse_markdown'
require 'nokogiri'
require 'json'
require 'URI'
doc = Nokogiri::HTML(STDIN)
r = doc.root
node = {}

r.css("img").each do |i|
  i["src"] = URI.join("http://web.archive.org/",i.attr("src")).to_s
end

r.css("div.content a").each do |l|
  # Make links into other typophile nodes into links into our system
  # otherwise...
  l["href"] = URI.join("http://web.archive.org/",l.attr("href")).to_s
end

title = r.css("title")
if title.first
  title = title.first.content.gsub(/ \| Typophile/,"").gsub(/^\s*\|\s*/,"").strip
  node["title"] = ReverseMarkdown.convert(title).strip
end

forum = r.css("div.breadcrumb a")
node["forum"] = ReverseMarkdown.convert(forum.last.content).strip if forum.first

tags = r.css("li[class^=taxonomy]")
node["tags"] = tags.map{ |t| ReverseMarkdown.convert(t.content).strip } if tags

content = r.css(".node div.content")
node["content"] = ReverseMarkdown.convert(content.first) if content.first

info = r.css(".node div.info")
author = info.children[0].to_s.strip
time = info.children[2].to_s.strip

if author.length < 1 then
  info = r.css("span.submitted")
  author = info.children[1].children[0].to_s
  time = info.children[-1].to_s.strip
  uid = info.children[1]["href"].gsub(/.*user\//,"")
else
  uid = r.css("div.node .picture a").first["href"].gsub(/.*user\//,"")
end

node["author"] = author
node["time"] = time
node["uid"] = uid
# XXX author ID

node["comments"] = []
r.css("div.comment").each do |c|
  comment = {}
  metadata = c.css("div.author")
  if metadata.children[0] then
    author = metadata.children[0]
    time = metadata.children[3].to_s
  else
    metadata = c.css("div.info")
    author = metadata.children[1]
    time = metadata.children[5].children[0].to_s
  end
  comment["author_name"] = author.children[0].to_s
  comment["author_uid"] =  author.attr("href").gsub(/.*user\//,"")
  comment["time"] = time
  content = c.css("div.content")
  comment["content"] = ReverseMarkdown.convert(content.to_s)
  node["comments"] << comment
end

puts JSON.pretty_generate(node)