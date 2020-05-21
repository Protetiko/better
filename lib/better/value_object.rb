module Better
  class ValueObject
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
