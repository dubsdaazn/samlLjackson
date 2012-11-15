set :rails_env, "acceptance"

role :app, "172.20.54.111"
role :web, "172.20.54.111", :primary => true
