module Better
  class ImmutableValueObject
    def initialize(params = {})
      keys   = self.class.fields
      values = self.class.default_values
      values.merge!(params.slice(*keys))
      values.each_pair do |key, val|
        if val
          if (type = self.class.types[key])
            if val.class == Array # Automatic type mapping if assigned an array
              val = val.map{|x| type.new(x) }
              values[key] = val.map{|x| x.to_h }
            else
              val = type.new(val)
              values[key] = val.kind_of?(Better::ImmutableValueObject) ? val.to_h : val
            end
          end

          instance_variable_set("@#{key}", val)
        end
      end
      @attributes = values
    end

    def self.field(name, **options)
      fields << name
      default_values[name] = options[:default] if options[:default]
      types[name]          = options[:type]    if options[:type]
      attr_reader name
    end

    def self.default_values
      @default_values ||= {}
    end

    def self.fields
      @fields ||= []
    end

    def self.types
      @types ||= {}
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
