require_relative '../lib/better.rb'

class User < Better::ValueObject
  field :name, default: "Benny"
  field :age
  field :email
  field :address, default: {}
end

values = [
  User.new(name: "David", age: 40, email: "david@protetiko.com", address: { street_address: "Gamla gatan 1" }),
  User.new(name: "David", age: 1, email: "david@protetiko.com", address: { street_address: "Gamla gatan 1" }),
  User.new(address: { street_address: "Bruna gatan 1" }),
  User.new,
]

values.each do |value|
  puts value.attributes
  puts value.age.inspect
end

# Inheritance not yet supported:

require 'securerandom'

class BaseModel < Better::ValueObject
  field :id, default: SecureRandom.uuid
end

class Movie < BaseModel
  field :title
  field :year
end

values = [
  Movie.new(title: "Dawn of the Dead", year: 1978),
  Movie.new,
]

puts Movie.fields

values.each do |value|
  puts value.attributes
end
