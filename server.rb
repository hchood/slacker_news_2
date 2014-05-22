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

# validate form input

def missing_attributes?(params)
  params[:title].empty? || params[:description].empty? || params[:url].empty?
end

def invalid?(url)
  !url.start_with?('http://') || !url.match(/[.][a-z]{2,}\z/i)
end

def errors(params)
  errors = []

  if missing_attributes?(params)
    error = "You must supply a title, URL, and description."
    errors << error
  end

  if invalid?(params[:url])
    error = "You must supply a valid URL (starting with 'http://')."
    errors << error
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
