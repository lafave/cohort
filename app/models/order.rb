class Order < ActiveRecord::Base
  # Relationships
  belongs_to :user
end
