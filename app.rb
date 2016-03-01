require 'sinatra/base'
require './models/article'

class Application < Sinatra::Base
  enable :logging
  enable :inline_templates
  enable :method_override

  configure :development do
    enable   :dump_errors
    disable  :show_exceptions

  end

  set :repository, ArticleRepository.new
  set :per_page,   25

  get '/' do
    @page  = [ params[:p].to_i, 1 ].max

    @articles = settings.repository.search \
               query: ->(q, t) do
                query = if q && !q.empty?
                  { match: { _all: q } }
                else
                  { match_all: {} }
                end

                filter = if t && !t.empty?
                  { term: { tags: t } }
                end

                if filter
                  { filtered: { query: query, filter: filter } }
                else
                  query
                end
               end.(params[:q], params[:t]),

               # sort: [{date: {order: 'desc'}}],

               size: settings.per_page,
               from: settings.per_page * (@page-1),

               aggregations: { tags: { terms: { field: 'tags' } } },

               highlight: { fields: { content: { fragment_size: 0, pre_tags: ['<em class="hl">'],post_tags: ['</em>'] } } }

    erb :index
  end

  get '/:id' do
    @articles = settings.repository.search \
               query: { match: { id: params[:id] } }
    @article = @articles.first
    erb :article
  end
end

Application.run! if $0 == __FILE__