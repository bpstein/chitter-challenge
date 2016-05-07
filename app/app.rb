ENV["RACK_ENV"] ||= "development"

require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra'
require 'tilt/erb'
require_relative 'models/peep'
require_relative 'models/user'

class Chitter < Sinatra::Base 

  register Sinatra::Flash

  enable :sessions
  set :session_secret, 'super secret'
  
  get '/' do 
    'Hello Chitter!'
  end

  get '/peeps' do 
    @peeps = Peep.all 
    erb :'peeps/index'
  end

  post '/peeps' do 
    Peep.create(content: params[:peep] , time: Time.now.strftime("%H:%M:%S %Y-%m-%d"))
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
    @user = User.create(email: params[:email],
                        password: params[:password], 
                        password_confirmation: params[:password_confirmation])
    if @user.save
      session[:user_id] = @user.id
      redirect to('/peeps')
    else
      flash.now[:notice] = "Password and confirmation password do not match"
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
