Elasticsearch::Model.client = case ENV["RAILS_ENV"]
                              when "development", "test"
                                Elasticsearch::Client.new
                              when "production"
                                Elasticsearch::Client.new host: ENV["SEARCHBOX_SSL_URL"]
                              end