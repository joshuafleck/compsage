set :rails_env, "staging"

### Server Settings ###
role :app, "dev.huminsight.com"
role :web, "dev.huminsight.com"
role :db,  "dev.huminsight.com", :primary => true
