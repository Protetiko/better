module Better
  class ValueObject
    def initialize(params = {})
      keys = self.class.fields
      @attributes = {}
      @attributes.merge!(self.class.default_values)
      @attributes.merge!(params.slice(*keys))

      keys.each do |key|
        if (type = self.class.types[key]) && (val = @attributes[key])
          if val.class == Array # Automatic type mapping if assigned an array
            @attributes[key] = val.map{|x| type.new(x) }
          else
            @attributes[key] = type.new(val)
          end
        end

        define_singleton_method(key) { @attributes[key] }
        define_singleton_method("#{key}=") {|value| @attributes[key]=value }
      end
    end

    def self.field(name, **options)
      fields << name

      default_values[name] = options[:default] if options[:default]
      types[name] = options[:type] if options[:type]
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
      @attributes ||= {}
    end

    def to_hash
      hash = @attributes.dup

      hash.each_pair do |key, val|
        if val.kind_of?(Better::ValueObject)
          hash[key] = val.to_h
        elsif val.kind_of?(Array)
          hash[key] = val.map{|x| x.to_h }
        end
      end
      return hash
    end
    alias_method :to_h, :to_hash

    def [](key)
      @attributes[key]
    end

    def []=(key, value)
      @attributes[key] = value if self.class.fields.include?(key)
    end
  end
end































module Better
  class ValueObject2
    #TYPE_DEFAULTS_MAP = {
    #  Hash => {},
    #  Array => [],
    #}

    def initialize(params = {})
      keys = self.class.fields
      values = {}
      values.merge!(self.class.default_values)
      values.merge!(params.slice(*keys))
      @attributes = values

      keys.each do |key|
        define_singleton_method(key) { @attributes[key] }
        define_singleton_method("#{key}=") {|value| @attributes[key]=value }
      end
    end

    def self.field(name, **options)
#      field = options.slice(:default, :validator, :type, :optional)
      fields << name
      if options[:default]
        default_values[name] = options[:default] #if options[:default] #&& !options[:optional]
      #elsif options[:type]
      #  default_values[name] = TYPE_DEFAULTS_MAP[options[:type]]
      end
    end

    def self.default_values
      @default_values ||= {}
    end

    def self.fields
      @fields ||= []
    end

    def attributes
      @attributes ||= {}
    end

    def to_hash
      @attributes
    end
    alias_method :to_h, :attributes

    def [](key)
      @attributes[key]
    end

    def []=(key, value)
      @attributes[key] = value
    end
  end
end
