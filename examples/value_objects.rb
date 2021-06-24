require_relative '../lib/better.rb'

class BaseModel < Better::ValueObject
  field :id, default: ->() { Better::UUID.uuid }
end

class Address < Better::ValueObject
  field :street_address
  field :zip
  field :city
end

class Skill < Better::ValueObject
  field :id
  field :level
end

class User < BaseModel
  field :name, default: "Benny"
  field :age
  field :email
  field :address, type: Address
end

values = [
  User.new(name: "David", age: 40, email: "david@protetiko.com", address: { street_address: '101 Long Street', zip: 10111, city: 'Singular City' }),
  User.new(name: "David", age: 1, email: "david@protetiko.com", address: { street_address: '101 Long Street', zip: 10111, city: 'Singular City' }),
  User.new(address: { street_address: "Bruna gatan 1" }),
  User.new,
]

values.each do |value|
  puts value.to_h
end

class BaseImmutableModel < Better::ImmutableValueObject
  field :id, default: ->() { Better::UUID.uuid }
  field :store_id, default: ->() { Better::UUID.uuid }
end

class Movie < BaseImmutableModel
  field :title
  field :year
end

values = [
  BaseImmutableModel.new,
  Movie.new(title: "Dawn of the Dead", year: 1978),
  Movie.new,
  Movie.new(id: '1'),
]

values.each do |value|
  puts value.attributes
end
