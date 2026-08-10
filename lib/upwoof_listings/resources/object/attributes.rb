module UpwoofListings::Resources::Object::Attributes
  module ClassMethods
    def attributes
      @attributes ||=
        if superclass.respond_to?(:attributes)
          superclass.attributes.dup
        else
          Hash.new { |hash, key| hash[key] = ::Object }
        end
    end

    # @return [Module] module holding all attribute accessors
    #
    # Included into the class as it is created. Each class gets its own module, and a subclass
    # never runs the `included` hook below, so without the include here the accessors defined
    # into a subclass's module would sit outside its ancestors — leaving every read on every
    # resource in this gem (all of which are subclasses of Object) to go through method_missing
    # on every call rather than the once it is written to cost.
    def attributes_module
      @attributes_module ||= const_set(:AttributeMethods, Module.new).tap { |mod| include(mod) }
    end

    def define_attribute_accessor(name, type = nil)
      type ||= attributes[name.to_sym] || Object
      attributes_module.send(:define_method, name) do
        deserialize_attribute(name, type)
      end
    end

    def attribute(name, type = String)
      attributes[name] = type

      define_attribute_accessor(name, type)
    end

    alias has_many attribute
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, base.attributes_module)
    super
  end

  def attributes
    {}.tap do |result|
      __getobj__.keys.each do |key|
        attribute = key.to_s.downcase
        result[attribute] = public_send(attribute)
      end
    end
  end

  def method_missing(name, *args, &block)
    attribute = name.to_s.downcase
    if __getobj__.key?(attribute)
      self.class.define_attribute_accessor(name)
      deserialize_attribute(name, self.class.attributes[name.to_sym])
    else
      super
    end
  end

  private

  def respond_to_missing?(name, include_all = false)
    __getobj__.key?(name.to_s.downcase) || super(name, include_all)
  end

  # @param [String, Symbol] name
  # @param [Class, #to_s] type
  def deserialize_attribute(name, type)
    raw = __getobj__[name.to_s.downcase]
    self.class.serializer_for(type).deserialize(raw)
  end
end
