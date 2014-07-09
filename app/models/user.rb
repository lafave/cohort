class User < ActiveRecord::Base
  include Elasticsearch::Model

  # Relationships
  has_many :orders

  def as_indexed_json(opts = {})
    UserSerializer.new(self).as_json
  end
end
