require "test_helper"

class StoreTest < Minitest::Test
  let(:data) {
    [
      { name: 'Biff Tannen', first_apperance: 'Back to the Future Part I' },
      { name: 'Clara Clayton', first_apperance: 'Back to the Future Part II' },
      { name: 'Dave McFly', first_apperance: 'Back to the Future Part I' },
      { name: 'Emmett "Doc" Brown' },
      { name: 'George McFly', first_apperance: 'Back to the Future Part I' },
      { name: 'Gerald Strickland' },
      { name: 'Jennifer Parker' },
      { name: 'Kid Tannen' },
      { name: 'Linda McFly', first_apperance: 'Back to the Future Part I' },
      { name: 'Lorraine Baines-McFly', first_apperance: 'Back to the Future Part I' },
      { name: 'Lou Caruthers' },
      { name: 'Mad Dog Tannen',first_apperance: 'Back to the Future Part III' },
      { name: 'Marty McFly Jr', first_apperance: 'Back to the Future Part II' },
      { name: 'Marty McFly' },
    ]
  }
  let(:missing_data) {
    {
     griff:     { id: 'abc', name: 'Griff Tannen', first_apperance: 'Back to the Future Part II' },
     marty:     { first_apperance: 'Back to the Future Part I' },
     caruthers: { first_apperance: 'Back to the Future Part I' },
    }
  }
  def test_store
    user_store = Better::Store.new(data: data, index: Better::Store::UUIDKeyGenerator)
    assert_equal 14, user_store.size

    user = user_store.create(missing_data[:griff])
    assert_equal missing_data[:griff], user
    assert_equal 15, user_store.size

    user = user_store.find_by(name: 'Marty McFly')
    user = user_store.update(user[:id], missing_data[:marty])
    assert_equal missing_data[:marty][:first_apperance], user[:first_apperance]

    user = user_store.find_by(name: /Caruthers/)
    user = user_store.update(user[:id], missing_data[:caruthers])
    assert_equal missing_data[:caruthers][:first_apperance], user[:first_apperance]


    users = user_store.where(name: /McFly/)
    assert_equal 6, users.size
    users = user_store.where(name: /McFly/, first_apperance: /Part I$/)
    assert_equal 5, users.size
    users = user_store.where(name: /Tannen/, first_apperance: 'Back to the Future Part II')
    assert_equal 1, users.size

    user_store.each { |record|
      assert_instance_of Hash, record
    }

    assert_instance_of Array, user_store.all
    assert_equal 15, user_store.all.size
  end
end
