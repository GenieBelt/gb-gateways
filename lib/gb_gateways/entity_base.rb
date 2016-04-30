module EntityBase
  class PrototypeNotImplementedError < NoMethodError; end
  def prototype_class_methods(*names)
    names.each do |name|
      clazz = self.is_a?(Class) ? self : self.class
      raise PrototypeNotImplementedError, "#{clazz} - Method #{name} not implemented!" unless clazz.respond_to? name.to_sym
    end
  end

  def prototype_methods(*names)
    if self.is_a? Class
      names.each do |name|
        raise PrototypeNotImplementedError, "#{self} - Method #{name} not implemented!" unless self.instance_methods.include?(name.to_sym)
      end
    else
      names.each do |name|
        raise PrototypeNotImplementedError, "#{self.class} - Method #{name} not implemented!" unless respond_to? name.to_sym
      end
    end
  end

  def self.included(base)
    base.extend self
  end
end
