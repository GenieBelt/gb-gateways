require 'spec_helper'
require 'gb_gateways/abstract_gateway'

describe AbstractGateway do
  class AbstractGateway
    def self.reset!
      @gateway = nil
      @entity_class = nil
      @@load_paths = []
    end
  end

  class FooGateway < AbstractGateway; end
  class BarGateway < AbstractGateway; end
  class Base
    def self.test
      :base
    end
  end

  after(:all){
    undefine_class :FooGateway
    undefine_class :BarGateway
    undefine_class :'Foo::BarGateway'
    undefine_class :Base
  }

  context 'private' do
    it 'get proper gateway name' do
      expect(AbstractGateway.send :gateway_name).to eq 'Abstract'
      expect(FooGateway.send :gateway_name).to eq 'Foo'
      expect(BarGateway.send :gateway_name).to eq 'Bar'
    end

    it 'get proper gaetway name namespaced class' do
      class Foo
        class BarGateway < AbstractGateway
        end
      end
      expect(Foo::BarGateway.send :gateway_name).to eq 'Foo::Bar'
    end
  end

  context 'entity class' do
    before(:each) do
      BarGateway.reset!
      undefine_class :Bar
    end
    context 'creation' do

      it 'should create proper class' do
        expect(defined?(Bar)).to be_falsey
        expect { BarGateway.gateway = Base }.not_to raise_error
        expect(defined?(Bar)).to be_truthy
        expect(Bar.test).to eq :base
      end

      it 'should not load any files if load_path not specified' do
        expect(AbstractGateway.load_paths).to be_empty
        expect(defined?(Bar)).to be_falsey
        expect { BarGateway.gateway = Base }.not_to raise_error
        expect(defined?(Bar)).to be_truthy
        expect(defined?(Bar.bar)).to be_falsey
      end

      it 'should load proper files if load path defined' do
        AbstractGateway.load_paths << "#{ROOT}/spec/load_fixtures"
        expect(defined?(Bar)).to be_falsey
        expect { BarGateway.gateway = Base }.not_to raise_error
        expect(defined?(Bar)).to be_truthy
        expect(Bar.bar).to eq :bar
      end

      it 'should load proper files if load path defined and file name defined' do
        AbstractGateway.load_paths << "#{ROOT}/spec/load_fixtures"
        BarGateway.file_name = 'custom_bar.rb'
        expect(defined?(Bar)).to be_falsey
        expect { BarGateway.gateway = Base }.not_to raise_error
        expect(defined?(Bar)).to be_truthy
        expect(Bar.bar).to eq :custom_bar
      end

      it 'should not reload class if the same gateway specified' do
        expect(defined?(Bar)).to be_falsey
        expect { BarGateway.gateway = Base }.not_to raise_error
        expect(defined?(Bar)).to be_truthy
        Bar.class_eval do
          def self.custom_test
            :passed
          end
        end
        expect { BarGateway.gateway = Base }.not_to raise_error
        expect(defined?(Bar.custom_test)).to be_truthy
        expect(Bar.custom_test).to eq :passed
      end
    end

    context 'class' do
      it 'should return proper class' do
        expect(AbstractGateway.load_paths).to be_empty
        expect(defined?(Bar)).to be_falsey
        expect { BarGateway.gateway = Base }.not_to raise_error
        expect(defined?(Bar)).to be_truthy
        expect(BarGateway.entity_class).to eq Bar
      end
    end
  end


  def undefine_class(name)
    if Object.constants.include?(name.to_sym)
      Object.send(:remove_const, name.to_sym)
    end
  end
end