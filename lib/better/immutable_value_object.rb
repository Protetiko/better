module Better
  class ImmutableValueObject
    def initialize(params = {})
      keys   = self.class.fields
      values = self.class.default_values
      values.merge!(params.slice(*keys))
      values.each_pair do |k, v|
        instance_variable_set("@#{k}", v)
      end
      @attributes = values
    end

    def self.field(name, **options)
      fields << name
      default_values[name] = options[:default]
      attr_reader name
    end

    def self.default_values
      @default_values ||= {}
    end

    def self.fields
      @fields ||= []
    end

    def attributes
      @attributes
    end
    alias_method :to_hash, :attributes
    alias_method :to_h, :attributes

    def [](key)
      @attributes[key]
    end
  end
end
