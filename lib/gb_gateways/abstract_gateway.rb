require 'active_support/core_ext/string'
class AbstractGateway
  # noinspection RubyClassVariableUsageInspection
  @@load_paths = nil

  class << self
    attr_accessor :file_name, :file_path
    attr_reader :entity_class

    def gateway=(clazz)
      raise ArgumentError, 'Gateway have to be a class!' unless clazz.is_a? Class
      if clazz != @gateway
        undefine_old_gateway
        define_new_gateway(clazz)
        load_model
        @gateway = clazz
      end
      @gateway
    end

    def new(*args)
      @entity_class.new(*args)
    end

    # Load paths for entities class
    # @return [Array<String>]
    # noinspection RubyClassVariableUsageInspection
    def load_paths
      unless @@load_paths
        @@load_paths = []
        if defined?(Rails)
          @@load_paths << "#{Rails.root}/app/models/".freeze
          @@load_paths << "#{Rails.root}/app/entities/".freeze
        end
      end
      @@load_paths
    end

    private

    def load_model
      if self.file_path
        load file_path
        return
      end
      file_name = self.file_name || "#{gateway_name.underscore}.rb"
      load_paths.each do |path|
        Dir["#{path}/#{file_name}"].each { |file| load file }
      end
    end

    def method_missing(id, *args)
      @entity_class.send(id, *args)
    end

    def define_new_gateway(clazz)
      @entity_class = Class.new(clazz)
      (class_namespace || Object).const_set(gateway_class_name, @entity_class)
    end

    def undefine_old_gateway
      namespace = class_namespace || Object
      if namespace.constants.include?(gateway_class_name.to_sym)
        namespace.send(:remove_const, gateway_class_name.to_sym)
      end
    end

    def gateway_name
      unless @gateway_name
        class_name = name.split('::').last
        namespace = name.split('::')
        namespace.pop
        namespace = nil if namespace.empty?
        name_array = class_name.underscore.split('_')
        name_array.pop() #remove Gateway part
        class_name = name_array.join('_').camelcase
        @gateway_class_name = class_name
        if namespace
          @gateway_name = (namespace + [class_name]).join('::')
          @namespace = Object.const_get namespace
        else
          @gateway_name = class_name
        end
        @gateway_class_name.freeze
        @gateway_name.freeze
      end
      @gateway_name
    end

    def gateway_class_name
      gateway_name
      @gateway_class_name
    end

    def class_namespace
      gateway_name
      @namespace
    end
  end
end