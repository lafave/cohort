class User < ActiveRecord::Base
  # Relationships
  has_many :orders
end
