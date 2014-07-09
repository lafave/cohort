# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "csv"

date_time_format = "%m/%d/%Y %H:%M:%S"

# Import users
puts "importing users..."
CSV.read("#{Dir.pwd}/db/users.csv", headers: true).each do |user|
  User.create! \
    :created_at => DateTime.strptime(user["created_at"], date_time_format),
    :id         => user["id"],
    :updated_at => DateTime.strptime(user["updated_at"], date_time_format)
end

# Import orders
puts "importing orders..."
CSV.read("#{Dir.pwd}/db/orders.csv", headers: true).each do |order|
  Order.create! \
    :created_at => DateTime.strptime(order["created_at"], date_time_format),
    :id         => order["id"],
    :order_num  => order["order_num"],
    :updated_at => DateTime.strptime(order["updated_at"], date_time_format),
    :user_id    => order["user_id"]
end