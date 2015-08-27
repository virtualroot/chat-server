require "./app.rb"

use Rack::PostBodyContentTypeParser
use Rack::Session::Pool, :cookie_only => false, :defer => true

run Web
