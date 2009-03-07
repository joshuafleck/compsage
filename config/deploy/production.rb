set :rails_env, "production"

### Server Settings ###
role :app, "compsage.com"
role :web, "compsage.com"
role :db,  "compsage.com", :primary => true

