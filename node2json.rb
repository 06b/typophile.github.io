require 'reverse_markdown'
require 'nokogiri'
require 'json'
require 'uri'

def file2json(f)
  id = f.match(/node\/(\d+).html/)
  if not id then return end
  id = id[1]
  outhandle = File.open("json/#{id}.json", "w")

  doc = Nokogiri::HTML(File.open(f))
  r = doc.root
  node = {"id" => id}

  r.css("img").each do |i|
    begin
    i["src"] = URI.join("http://web.archive.org/",i.attr("src")).to_s
    rescue
    end
  end

  r.css("div.content a").each do |l|
    # Make links into other typophile nodes into links into our system
    # otherwise...
    begin
      uri = URI.parse(l.attr("href"))
    rescue
      begin
        uri = URI.parse(URI.escape(l.attr("href") || ""))
      rescue
      end
    end
    if uri then
      l["href"] = URI.join("http://web.archive.org/",uri).to_s
    end
  end

  title = r.css("title")
  if title.first
    title = title.first.content.gsub(/ \| Typophile/,"").gsub(/^\s*\|\s*/,"").strip
    node["title"] = ReverseMarkdown.convert(title).strip
    if title == ";) BRB" then
      puts("Uhoh, #{id} was a bad copy")
      return
    end
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
  if author == "Submitted by" then
    author = info.children[1].to_s.strip
  end

  if author.length < 1 then
    info = r.css("span.submitted")
    author = info.children[1]
    if author then
      author = author.children[0].to_s
      time = info.children[-1].to_s.strip
      if info.children[1]["href"] then # May be a guest
        uid = info.children[1]["href"].gsub(/.*user\//,"")
      end
    end
  else
    picture = r.css("div.node .picture a")
    if picture.first then
      uid = picture.first["href"].gsub(/.*user\//,"")
    elsif info.children.count > 1 and info.children[1]["href"] then
      uid = info.children[1]["href"].gsub(/.*user\//,"")
    end
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
      author = metadata.children[0].to_s
      time = metadata.children[3].to_s
    else
      metadata = c.css("div.info")

      author = metadata.css("a").first.children[0]
      time = metadata.children[5]
      if time then
        time = time.children[0].to_s
      else
        time=metadata.children[3].to_s
      end
    end
    comment["time"] = time
    content = c.css("div.content")
    comment["content"] = ReverseMarkdown.convert(content.to_s)
    comment["author"] = ReverseMarkdown.convert(author.to_s)
    node["comments"] << comment
  end

  outhandle.puts(JSON.pretty_generate(node))
  outhandle.close()
end

Dir.glob("public/node/*.html").each do |f|
  puts(f)
  file2json(f)
end

