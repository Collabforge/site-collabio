# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)

# Redirect to non-www address (https://github.com/tylerhunt/rack-canonical-host)
use Rack::CanonicalHost, 'localhost'
run Loomio::Application
