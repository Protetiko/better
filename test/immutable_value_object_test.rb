require "test_helper"

class ImmutableValueObjectTest < Minitest::Test
  let(:user_data) {
    { name: 'Don', age: 101, email: 'don@myemail.com' }
  }
  let(:address) {
    { street_address: '101 Long Street', zip: 10111, city: 'Singular City' }
  }
  let(:skills) {
    [
      { id: 'hide_in_shadow', level: 'amazing' },
      { id: 'ninja_roll',     level: 'god_like' },
      { id: 'smoke_screen',   level: 'amazing' }
    ]
  }

  class Address < Better::ImmutableValueObject
    field :street_address
    field :zip
    field :city
  end

  class Skill < Better::ValueObject
    field :id
    field :level
  end

  class User < Better::ImmutableValueObject
    field :name, default: 'Benny'
    field :age
    field :email
    field :address, type: Address
    field :is_active, default: true
    field :skills, type: Skill # Automatic type mapping if assigned an array
  end

  def test_value_object
    # user = User.new(user_data)
    # assert_instance_of User, user
    # assert_kind_of Better::ImmutableValueObject, user
    # assert_equal({ **user_data, is_active: true }.sort, user.to_h.sort)
    # assert_nil user.address

    # user_with_address = User.new(**user_data, address: address)
    # assert_instance_of User, user_with_address
    # assert_kind_of Better::ImmutableValueObject, user_with_address
    # assert_instance_of Address, user_with_address.address
    # assert_equal({ **user_data, is_active: true, address: address }.sort, user_with_address.to_h.sort)

    user_with_skills = User.new(**user_data, skills: skills)
    assert_instance_of Array, user_with_skills.skills
    assert_instance_of Skill, user_with_skills.skills[0]
    assert_instance_of Array, user_with_skills.to_h[:skills]
    assert_instance_of Hash,  user_with_skills.to_h[:skills][0]
    assert_equal skills.sort{|l, r| l.sort <=> r.sort }, user_with_skills.to_h[:skills].sort{|l, r| l.sort <=> r.sort }

    # assert_equal user_data[:name],  user.name
    # assert_equal user_data[:age],   user.age
    # assert_equal user_data[:email], user.email
    # assert_equal user_data[:name],  user[:name]
    # assert_equal user_data[:age],   user[:age]
    # assert_equal user_data[:email], user[:email]

    # assert_raises NoMethodError do
    #   user.name = 'Jimbob'
    # end

    # assert_raises NoMethodError do
    #   user.not_a_field
    # end

    # assert_raises NoMethodError do
    #   user.not_a_field = 'not a value'
    # end

    # assert_raises NoMethodError do
    #   user[:not_a_field] = 'not a value'
    # end

    # assert_nil user[:not_a_field]
  end
end

