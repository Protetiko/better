module Better
  class ImmutableValueObject
    def initialize(params = {})
      keys   = self.class.fields
      @attributes = {}
      @attributes.merge!(self.class.default_values)
      @attributes.merge!(params.slice(*keys))

      @attributes.each_pair do |key, val|
        if val
          if val.is_a? Proc
            val = val.call
          end

          if (type = self.class.types[key])
            if val.class == Array
              # Automatic type mapping if assigned an array
              # val.each_with_index{|x, i|
              #   v = type.new(x)
              #   ap v.class
              #   val[i] = v
              #   ap val[i].class
              #   values[key][i] = v.to_h
              # }
              # ap values[key][0].class
              val = val.map{|x| type.new(x) }
              @attributes[key] = val.map{|x| x.to_h }
            else
              val = type.new(val)
              @attributes[key] = val.kind_of?(Better::ImmutableValueObject) ? val.to_h : val
            end
          else
            @attributes[key] = val
          end

          instance_variable_set("@#{key}", val)
        end
      end
    end

    def self.inherited(base)
      self.fields.each do |field|
        params = {}
        params[:default] = self.default_values[field] if self.default_values[field]
        params[:type] = self.types[field] if self.types[field]
        base.field(field, **params)
      end
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
