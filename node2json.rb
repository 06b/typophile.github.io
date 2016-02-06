require 'reverse_markdown'
require 'nokogiri'
doc = Nokogiri::HTML(STDIN)
r = doc.root
node = {}

title = r.css("h2")
node["title"] = ReverseMarkdown.convert(title.first.content) if title.first

forum = r.css("div.breadcrumb a")
node["forum"] = ReverseMarkdown.convert(forum.last.content) if forum.first

content = r.css(".node div.content")
node["content"] = ReverseMarkdown.convert(content.first) if content.first

print node