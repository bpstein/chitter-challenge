ENV["RACK_ENV"] ||= "development"

require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra'
require 'tilt/erb'
require_relative 'server'
require_relative 'controllers/peeps'
require_relative 'controllers/users'
require_relative 'controllers/sessions'

class Chitter < Sinatra::Base 

  use Rack::MethodOverride
  register Sinatra::Flash
  enable :sessions
  set :session_secret, 'super secret'
  
  get '/' do 
    redirect to '/peeps'
  end

  get '/sessions/new' do 
    erb :'sessions/new'
  end

  post '/sessions' do 
    user = User.authenticate(params[:email], params[:password])
    if @user
      session[:user_id] = @user.id
      redirect to('/peeps')
    else
      flash.now[:errors] = ['The email or password is incorrect']
      erb :'sessions/new'
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash.keep[:notice] = 'goodbye!'
    redirect to '/peeps'
  end

  get '/peeps' do 
    @peeps = Peep.all
    erb :'peeps/index'
  end

  post '/peeps' do 
    time = Time.now.strftime("%H:%M:%S %Y-%m-%d")
    Peep.create(
                content: params[:peep], 
                time: time)
    redirect to('/peeps')
  end

  get '/peeps/new' do 
    erb :'peeps/new'
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do 
    @user = User.create(name: params[:name],
                        username: params[:username],
                        email: params[:email],
                        password: params[:password], 
                        password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/peeps')
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  run! if app_file == $0

end
