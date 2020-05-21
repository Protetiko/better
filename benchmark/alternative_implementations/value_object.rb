class ValueObject
  #attr_accessor :attributes

  def initialize(params = {})
	keys = self.class.fields.keys
	values = self.class.default_values
	values.merge!(params.slice(*keys))
	value_struct = Struct.new(*keys, keyword_init: true)
	@attributes = value_struct.new(values)
  end

  def self.field(name, **options)
	field = options.slice(:default, :optional, :validator, :type)
	field[:name] = name
	fields[name] = field

	default_values[name] = field[:default]
  end

  def self.default_values
	@default_values ||= {}
  end

  def self.fields
	@fields ||= {}
  end

  def fields
	self.class.fields
  end

  def attributes
	@attributes.to_h
  end
  alias_method :to_hash, :attributes
  alias_method :to_h, :attributes

  def [](key)
	@attributes[key]
  end

  def method_missing(method, *args)
	@attributes.send(method, *args)
  end
end

class ValueObject2
  def initialize(params = {})
    keys = self.class.fields
	values = self.class.default_values
	values.merge!(params.slice(*keys))
	@attributes = values

    keys.each do |key|
      define_singleton_method(key) { @attributes[key] }
      define_singleton_method("#{key}=") {|value| @attributes[key]=value }
    end
  end

  def self.field(name, **options)
    fields << name
	default_values[name] = options[:default]
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
  alias_method :to_hash, :attributes
  alias_method :to_h, :attributes

  def [](key)
	@attributes[key]
  end

  def []=(key, value)
    @attributes[key] = value
  end
end

class ValueObject3
  def initialize(params = {})
    keys   = self.class.fields
	values = self.class.default_values
	values.merge!(params.slice(*keys))
    values.each_pair { |k, v| send("#{k}=", v) }
    @attributes = values
  end

  def self.field(name, **options)
    fields << name
	default_values[name] = options[:default]
    attr_accessor name.to_sym
  end

  def self.default_values
	@default_values ||= {}
  end

  def self.fields
	@fields ||= []
  end

  def attributes
    @attributes = Hash[instance_variables.reject{|k| k == :@attributes}.map{|v| [v.to_s.delete("@").to_sym, instance_variable_get(v)] }]
  end
  alias_method :to_hash, :attributes
  alias_method :to_h, :attributes

  def [](key)
	attributes[key]
    self.send("#{key}")
  end

  def []=(key, value)
    self.send("#{key}=", value)
  end
end


class ValueObject4
  def initialize(params = {})
    keys   = self.class.fields
	values = self.class.default_values
	values.merge!(params.slice(*keys))
    @attributes = values
    keys.each do |key|
      define_singleton_method("#{key}=") {|value|
        @attributes[key] = value
        instance_variable_set("@#{key}", value)
        #self.send("#{key}=", value)
      }
    end
  end

  def self.field(name, **options)
    fields << name
	default_values[name] = options[:default]
    attr_reader name.to_sym
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
  alias_method :to_hash, :attributes
  alias_method :to_h,    :attributes

  def [](key)
	@attributes[key]
  end

  def []=(key, value)
    self.send("#{key}=", value)
  end
end

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

