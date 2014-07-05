class Order < ActiveRecord::Base
  include Elasticsearch::Model

  # Relationships
  belongs_to :user

  def as_indexed_json(opts = {})
    OrderSerializer.new(self).as_json
  end
end
