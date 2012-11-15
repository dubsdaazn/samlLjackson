set :rails_env, "qa"

role :app, "172.20.53.111"
role :web, "172.20.53.111", :primary => true
