require "test_helper"

Result = Better::Validator::Result

class ValidatorTest < Minitest::Test

  module Validators
    class AgeValidator < Better::Validator
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



    LambdaAgeValidator = ->(data) {
      data[:age] < 18 ? Result.fail(age: ["Must be over 18"]) : Result.success
    }



    class UserValidator < Better::Validator
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
        result << EmailValidator.call(data[:email])

        if data[:address]
          result << AddressValidator.call(data[:address])
        end

        return result
      end
    end

  end # Validators

  def test_result
    result = Result.new
    assert result.success?
    refute result.failure?
    assert_empty result.errors

    result.fail("error-message")
    refute result.success?
    assert result.failure?
    assert result.errors
    assert_equal 1, result.errors.size
    assert_equal "error-message", result.errors.first

    result.fail("the-second-error")
    refute result.success?
    assert result.failure?
    assert result.errors
    assert_equal 2, result.errors.size
    assert_equal "the-second-error", result.errors.last

    result = Result.success
    assert_instance_of Better::Validator::Result, result
    assert result.success?
    refute result.failure?
    assert_empty result.errors

    result = Result.fail("another-error-message")
    refute result.success?
    assert result.failure?
    assert result.errors
    assert_equal 1, result.errors.size
    assert_equal "another-error-message", result.errors.first
  end

  def test_validator_implementations_success
    [
      Validators::AgeValidator.call(age: 20),
      Validators::LambdaAgeValidator.call(age:20),
      Validators::UserValidator.call(name: "Berra", email: "berra@email.com"),
      Validators::UserValidator.call(name: "Berra", email: "berra@email.com", age: 40),
      Validators::UserValidator.call(name: "Berra", email: "berra@email.com", address: { street_address: "Downtown 1" }),
    ].each do |result|
      assert result.success?
      assert_empty result.errors
    end
  end
end

