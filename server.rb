require 'sinatra'
require 'csv'
require 'pry'
require 'sinatra/flash'

enable :sessions

################################
#         METHODS
################################

# read from and write to CSV

def read_articles_from(file)
  articles = []

  CSV.foreach(file, headers: true) do |row|
    article = {
      title: row["title"],
      description: row["description"],
      url: row["url"],
      points: row["points"],
      posted_by: row["posted_by"] || "anonymous",
      time_posted: row["time_posted"],
      comments: row["comments"]
    }
    articles << article
  end

  articles
end

def write_article_to(file, article_attributes)
  CSV.open(file, 'a') do |csv|
    csv << article_attributes
  end
end

def find_article(title)
  articles = read_articles_from('articles.csv')
  article = {}

  i = 0
  while article.empty?
    article = articles[i] if articles[i][:title] == title
    i += 1
  end

  article
end

# validate form input

def missing_attributes?(params)
  params[:title].empty? || params[:description].empty? || params[:url].empty?
end

def invalid?(url)
  !url.start_with?('http://') || !url.match(/[.][a-z]{2,}\z/i)
end

def too_short?(description)
  description.length < 20
end

def errors(params)
  errors = []

  if missing_attributes?(params)
    errors << "You must supply a title, URL, and description."
  end

  if invalid?(params[:url])
    errors << "You must supply a valid URL (starting with 'http://')."
  end

  if too_short?(params[:description])
    errors << "Your description must be at least 20 characters long."
  end

  errors
end

################################
#         ROUTES
################################

get '/articles' do
  @articles = read_articles_from('articles.csv')
  erb :index
end

get '/articles/new' do
  erb :new
end

get '/articles/:title' do
  @article = find_article(params[:title])
  erb :show
end

post '/articles' do
  errors = errors(params)

  if !errors.empty?
    flash.now[:error] = errors
    erb :new
  else
    article_attributes = [params[:title], params[:description], params[:url], 0, params[:user_name], Time.new, 0]
    write_article_to('articles.csv', article_attributes)
    redirect '/articles'
  end
end
