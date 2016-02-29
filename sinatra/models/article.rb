require 'elasticsearch/persistence'
require 'redcarpet'

class Article
  attr_reader :attributes
  @@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

  def initialize(attributes={})
    @attributes = attributes
  end

  def to_hash
    @attributes
  end

  def content
    @attributes["content"]
  end

  def content_html
    @@markdown.render(content)
  end

  def tags
    @attributes["tags"]
  end

  def time
    @attributes["time"]
  end

  def id
    @attributes["id"]
  end

  def title
    @attributes["title"]
  end
end

class ArticleRepository
  include Elasticsearch::Persistence::Repository

  def initialize(options={})
    client Elasticsearch::Client.new url: options[:url], log: options[:log]
  end

  type :article
  index  :typophile
  klass Article

  settings number_of_shards: 1 do
    mapping do
      indexes :content, analyzer: 'snowball'
      indexes :id, type: "integer", index: "not_analyzed"
      indexes :title, index: "not_analyzed"
      indexes :tags, index: "not_analyzed"
      indexes :comments, type: "nested", properties: {

      }
      indexes :author
      indexes :uid, type: "integer", index: "not_analyzed"
    end
  end
end
