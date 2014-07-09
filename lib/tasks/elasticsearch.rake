namespace :elasticsearch do
  desc "Import all orders from the database to elasticsearch"
  task :import_orders => :environment do
    Order.import
  end

  desc "Import all users from the database to elasticsearch"
  task :import_users => :environment do
    User.import
  end
end