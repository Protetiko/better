require_relative '../lib/better.rb'
require 'dry-validation'

Result = Better::Result

class AgeValidator
  def self.call(data)
    result = Result.new

    result.fail(age: "Must be set") unless data[:age]
    if data[:age].instance_of?(Integer)
      result.fail(age: "Must be over 18") if data[:age] < 18
    else
      result.fail(age: "Must be an integer")
    end

    return result
  end
end

lambda_validator = ->(data) {
  data[:age] < 18 ? Result.fail(age: ["Must be over 18"]) : Result.success
}

class DryUserContract < Dry::Validation::Contract
  json do
	required(:name).filled(:string)
	optional(:age).filled(:integer)
	required(:email).filled(:string)
	optional(:address).maybe(:hash)
  end
end

class DryUserValidator
  def self.call(data)
	result = DryUserContract.new.call(data)
	return Result.new(result.success?, result.errors.to_h)
  end
end

class UserValidator
  class AddressValidator
	def self.call(data)
	  return Result.fail(address: "Must be a Hash") unless data.instance_of?(Hash)
	  return data[:street_address] ? Result.success : Result.fail(street_address: "Must be set")
	end
  end

  EmailValidator = ->(email) {
    return Result.fail(email: "Must be set")      unless email
    return Result.fail(email: "Must be a String") unless email.instance_of?(String)
	return Result.success
  }

  AgeValidator = Proc.new {|age|
	result = Result.new
	if age
	  if age.instance_of?(Integer)
        result.fail(age: "Must be over 18") if age < 18
      else
        result.fail(age: "Must be an integer")
      end
	end
	result
  }

  def self.call(data)
	result = Result.new

    result.fail(name: "Must be set") unless data[:name]
    result.fail(name: "Must be a String") unless data[:name].instance_of?(String)

	result << AgeValidator.call(data[:age])
#    if data[:age]
#	   if data[:age].instance_of?(Integer)
#        result.fail(age: "Must be over 18") if data[:age] < 18
#      else
#        result.fail(age: "Must be an integer")
#      end
#	 end
	result << EmailValidator.call(data[:email])
#    - or -
#    result.fail(email: "Must be set") unless data[:email]
#    result.fail(email: "Must be a String") unless data[:email].instance_of?(String)

	if data[:address]
	  result << AddressValidator.call(data[:address])
	end

	return result
  end
end

class User < Better::ValueObject
  field :name
  field :age
  field :email
  field :address
end

results = [
  AgeValidator.call(age: 19),
  AgeValidator.call(age: 17),
  AgeValidator.call(age: "18"),
  AgeValidator.call(age: nil),
  lambda_validator.call(age: 19),
  lambda_validator.call(age: 17),
  DryUserValidator.call(name: "David", age: 40, email: "david@protetiko.com"),
  DryUserValidator.call({}),
  DryUserContract.new.call(name: "David", age: 40, email: "david@protetiko.com"),
  DryUserContract.new.call({}),
  UserValidator.call(User.new(name: "David", age: 40, email: "david@protetiko.com", address: { street_address: "Gamla gatan 1" })),
  UserValidator.call(User.new(name: "David", age: 1, email: "david@protetiko.com", address: { street_address: "Gamla gatan 1" })),
  UserValidator.call(User.new(address: "Bruna gatan 1")),
  UserValidator.call(User.new()),
]

results.each do |result|
  puts "Success? #{result.success?}"
  puts "Errors: #{result.errors}" unless result.success?
end

