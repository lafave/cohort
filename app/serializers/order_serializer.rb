class OrderSerializer < ApplicationSerializer
  # Attributes
  attribute :order_num

  # Relationships
  has_one :user, embed: :objects
end