$LOAD_PATH.unshift(File.expand_path('.'))

require 'sinatra'
require 'sinatra/activerecord'
require_relative 'models/user'
require_relative 'models/post'

begin
require 'dotenv'
Dotenv.load
rescue LoadError
end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])


enable :sessions

post '/posts' do
  @logged_in_user = User.find(session["user_id"])
  @logged_in_user.posts << Post.create(:content => params["user_input"])
  current_username = @logged_in_user.username
  redirect "/user/#{current_username}"
end

get '/' do
  erb :index
end

get "/user/:username" do
  @logged_in_user = User.find(session["user_id"])
  @posts = Post.where(user_id: @logged_in_user.id).reverse
  @users = User.all
  erb :user
end

get '/incorrect-login' do
  erb :incorrect
end

post '/signup' do
  current_user = User.create(username: params[:sign_up_user_name], password: params[:sign_up_password])
  if current_user.valid?
    session["user_id"] = current_user.id
    redirect "/user/#{current_user.username}"
  else
    redirect '/username-taken'
  end
end

post '/login' do
  current_user = User.find_by username: params[:login_user_name]
  unless current_user.nil?
    if current_user.password == params[:login_password]
      session["user_id"] = current_user.id
      redirect "/user/#{current_user.username}"
    else
      redirect '/incorrect-login'
    end
  else
    redirect '/incorrect-login'
  end
end


post '/friend' do
  # Future release implementing navigation to other user pages.
  redirect "/user/#{params["selected_user"]}"
end

get '/username-taken' do
  erb :username_taken
end


