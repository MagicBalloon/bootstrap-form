require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

def validate(fields)
  @error, @success = '', ''
  
  fields.each do |k, v|
    if v.nil? || v.empty?
      @error += "Field <b>#{k}</b> can't be empty<br>"
    else 
      @success += "Field <b>#{k}</b>: #{v}<br>"
    end
  end

  @error = nil if @error.empty?
  @success = nil if @success.empty?
  
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/post_form' do
  erb :post_form
end

post '/post_form' do
  @post_data = {
    name: params[:name],
    email: params[:email],
    select: params[:select],
    message: params[:message],
    checkbox1: params[:checkbox1],
    checkbox2: params[:checkbox2]
  }

  validate(@post_data)

  erb :post_form
end


get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
