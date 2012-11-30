set :rails_env, "acceptance"

role :app, "107.20.57.67"
role :web, "107.20.57.67", :primary => true
