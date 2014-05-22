require 'sinatra'

def read_articles_from(file)
  articles = []

  CSV.foreach(file, headers: true) do |row|
    article = {
      title: row["title"],
      description: row["description"],
      url: row["url"],
      points: row["points"],
      time_posted: row["time_posted"],
      comments: row["comments"]
    }
    articles << article
  end

  articles
end

get '/articles' do
  @articles = read_articles_from('articles.csv')
  erb :index
end