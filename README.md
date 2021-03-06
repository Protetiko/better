# Better

Better is a collection of solutions to common Ruby programming problems, solved in a simple and efficient way. No bells and whistles. The library is intended to be used in part or whole, but with little to no interdependencies between modules of Better. Use the parts you need and skip the rest.

The initial inspiration behind starting Better was after looking at a simple value object implementation with simple field definitions. All excisting popular solutions where either too bloated, too slow to too complex. `Better::ValueObject` was created as a response to this, landing at a featherweight 44 lines in it's initial implementation. I'm not claiming `Better::ValueObject` is the best ValueObject implementation out there. There are certainly libraries with more features, but if you need something fast, simple, foolproof written in a way you easily understand, then Better is for You! 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'better', :git => "git://github.com/protetiko/better.git"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install better

## Usage

- `Better::ValueObject` - The simple value object
- `Better::ImmutableValueObject` - ValueObject with faster reads
- `Better::Result` - Simple Result object for validations etc
- `Better::Context` - Dead simple context object
- `Better::UUID` - Correctly generated UUIDs
- `Better::Store` - Dead simple in memory database

### Better::ValueObject

```ruby
class Person < Better::ValueObject
  field :name
end

class Movie < Better::ValueObject
  field :title
  field :year
  field :genre, default: 'horror'
  field :director, type: Person
  field :actors, type: Person
end

movie = Movie.new(
  title: 'The Godfather',
  year: 1972,
  director: { name: "Francis Ford Coppola" },
  actors: [
    { name: "Marlon Brando" },
    { name: "Al Pacino" },
    { name: "James Caan" },
  ]
)
movie.title # => 'The Godfather'
movie.to_h
# { title: "The Godfather", year: 1972, genre: 'horror', director: { name: "Francis Ford Coppola"}, actors: [ { name: "Marlon Brando" }, { name: "Al Pacino" }, { name: "James Caan" }] }
movie.genre = 'crime'
movie.genre # => 'crime'
movie.director.class # => 'Person < Better::ValueObject'
movie.actor[0].class # => 'Person < Better::ValueObject'
```

### Better::ImmutableValueObject

An immutable version of the ValueObject. Somewhat slower on create, but much faster reads and hash convertions.

```ruby
class Person < Better::ImmutableValueObject
  field :name
end

class Movie < Better::ImmutableValueObject
  field :title
  field :year
  field :genre, default: 'horror'
  field :director, type: Person
  field :actors, type: Person
end

#...
```

### Better::Result

A simple and intuitive `Result` class. Get structure on your validator results, or you method context success/failure status.

```ruby
result = Better::Result.new
result.success? # true
result.failure? # false

result.fail("with an error")
result.success? # false
result.failure? # true
result.errors   # ["with an error"]

result = Better::Result.fail(data: "The data must be there")
result.success? # false
result.failure? # true
result.errors   # [data: "The data must be there")]
result.fail("Another error")
result.errors   # [{data: "The data must be there")}, "Another error"]
result << Better::Result.fail("concat a failure")
result.errors   # [{data: "The data must be there")}, "Another error", "concat a failure"]

result = Better::Result.new
result << Better::Result.new.fail("Lets concat a failure an a success")
result.success? # false
result.failure? # true
result.errors   # ["Lets concat a failure an a success"]
```

```ruby
class UserValidator < Better::Validator
  Result = Better::Result # Type less code
  
  class AddressValidator
    def self.call(data)
      return Result.fail(address: "Must be a Hash") unless data.instance_of?(Hash)
      return data[:street_address] ? Result.success : Result.fail(street_address: "Must be set")
    end
  end

  EmailValidator = ->(email) {
    return Result.fail(email: "Must be set") unless email
    return Result.fail(email: "Must be a String") unless email.instance_of?(String)
    return Result.success
  }

  AgeValidator = Proc.new {|age|
    result = Result.new
    if age # Age is optional
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

    if data[:address] # Address is optional
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

user = User.new(name: "Benny", age: 110, email: "ben@jerrys.com", address: { street_address: "Gamla gatan 1" })

result = UserValidator.call(user)
result.success? # => true
result.errors   # => []

user = User.new()
result = UserValidator.call(user)
result.success? # => false
result.errors
# [{:name=>"Must be set"}, {:name=>"Must be a String"}, {:email=>"Must be set"}]
```

### Better::Context

A simple efficient context.


### Better::UUID

```ruby
Better::UUID.uuid # => generates random uuid
Better::UUID.uuid_v4 # => generates random uuid
Better::UUID.uuid_v5(Better::UUID::DNS_NAMESPACE, 'example.com') # => generates namespaces, non-random, uuid
```

### Better::Store
A simple memory store that support queries.

```ruby
movie_store = Better::Store.new
movie_store.create(title: 'The Godfather', year: 1972)
movie = movie_store.create(title: 'The Godfather Part II', year: 1974)
movie_store.create(title: 'The Godfather Part III', year: 1990)
movie
# {id: 2, title: "The Godfather Part II", year: 1974}
movie_store.find(movie[:id]) # => {id: 2, title: "The Godfather Part II", year: 1974} // id match
movie_store.find_by(title: "The Godfather Part II") # => {id: 2, title: "The Godfather Part II", year: 1974}
movie_store.find_by(title: /Godfather/) # => {id: 1, title: "The Godfather", year: 1972} // first match
movie_store.find_by(title: /Godfather/, year: 1974) # => {id: 2, title: "The Godfather Part II", year: 1974}
movie_store.where(title: /Godfather/) # [{id: 1, title: "The Godfather", year: 1972}, {id: 2, title: "The Godfather Part II", year: 1974}, {title: 'The Godfather Part III', year: 1990}]
movie_store.each do |movie|
  movie_store.update(movie[:id], actors: ['Al Pacino'])
end

movie_store.all(title: /Godfather/) # [{id: 1, title: "The Godfather", year: 1972, actors: ["Al Pacino"]}, {id: 2, title: "The Godfather Part II", year: 1974, actors: ["Al Pacino"]}, {title: 'The Godfather Part III', year: 1990, actors: ["Al Pacino"]}]

movie_store.delete(movie[:id])
movie_store.all # [{id: 1, title: "The Godfather", year: 1972, actors: ["Al Pacino"]}, {title: 'The Godfather Part III', year: 1990, actors: ["Al Pacino"]}]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dsennerlov/better.
