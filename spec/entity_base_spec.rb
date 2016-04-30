require 'spec_helper'
require 'gb_gateways/entity_base'

describe EntityBase do
  let (:clazz) do
    clazz = Class.new do
      def self.foo
        :foo
      end

      def bar
        :bar
      end
    end
    clazz
  end

  context 'class scope' do
    it 'should be able to make class prototype methods' do
      clazz.include EntityBase
      expect { clazz.prototype_class_methods :foo }.not_to raise_error
      expect { clazz.prototype_class_methods :bar }.to raise_error EntityBase::PrototypeNotImplementedError
    end

    it 'should prototype methods' do
      clazz.include EntityBase

      expect { clazz.prototype_methods :bar }.not_to raise_error
      expect { clazz.prototype_methods :foo }.to raise_error EntityBase::PrototypeNotImplementedError
    end
  end

  context 'instance scope' do
    it 'should be able to make class prototype methods' do
      clazz.include EntityBase
      expect { clazz.new.prototype_class_methods :foo }.not_to raise_error
      expect { clazz.new.prototype_class_methods :bar }.to raise_error EntityBase::PrototypeNotImplementedError
    end

    it 'should prototype methods' do
      clazz.include EntityBase

      expect { clazz.new.prototype_methods :bar }.not_to raise_error
      expect { clazz.new.prototype_methods :foo }.to raise_error EntityBase::PrototypeNotImplementedError
    end
  end
end