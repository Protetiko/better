require 'better/uuid'

module Better
  class Store
    IncrementalKeyGenerator = ->(last_index) {
      last_index ||= 0
      last_index + 1
    }

    UUIDKeyGenerator = ->(last_index) {
      last_index = Better::UUID.uuid
      last_index
    }

    def initialize(data: nil, generator: IncrementalKeyGenerator, **options)
      @database = Hash.new
      @options = options
      @generator = generator
      @last_index = nil

      load(data) if data
    end

    def create(data)
      record = data.dup

      id = record[:id] || generate_id
      record[:id] = id

      @database[id] = record

      return record
    end

    def update(id, data)
      return nil unless (record = find(id))
      @database[id] = record.merge!(data)

      return record
    end

    def delete!(id)
      @database.delete(id)
    end

    def each(&block)
      @database.values.each(&block)
    end

    def find(id)
      @database[id]
    end

    def find_by(query)
      @database.values.find{|record| match?(record, query) }
    end

    def where(query)
      @database.values.select{|record| match?(record, query) }
    end

    def all
      @database.values
    end

    def size
      @database.size
    end

    def load(data)
      data.each do |set|
        create(set)
      end
    end

    private

    def match?(record, query)
      query.reduce(true){|acc, (k, v)|
        case v
        when Regexp then acc && (field = record[k]) && field.match?(v)
        else acc && record[k] == v
        end
      }
    end

    def generate_id
      @last_index = @generator.call(@last_index)
      return @last_index
    end

    def set(id, record)
      record[:id] = id
      @database[id] = record
    end
  end
end
