namespace :elasticsearch do
  desc "Import all orders from the database to elasticsearch"
  task :import_orders => :environment do
    Order.import
  end
end