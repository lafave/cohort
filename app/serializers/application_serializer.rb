class ApplicationSerializer < ActiveModel::Serializer
  self.root = false

  # Attributes
  attribute :id
  attribute :created_at
  attribute :updated_at
end