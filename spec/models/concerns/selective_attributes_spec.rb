require 'spec_helper'

describe SelectiveAttributes do

  subject(:model){
    Class.new do
      include ActiveModel::Model
      include SelectiveAttributes
      attr_accessor :foo, :bar, :baz

      def attributes
        instance_variables.reduce(HashWithIndifferentAccess.new) do |hash, var|
          hash.merge "#{var}".sub(/^@/, '') => instance_variable_get(var)
        end
      end
    end
  }

  describe '#initialize' do
    it 'should call extract_valid_attributes with the params' do
      attrs = { foo: 1, bar: 2, baz: 3, raz: 4 }
      expect_any_instance_of(model).to receive(:extract_valid_attributes).with(attrs)
      model.new attrs
    end

    it 'should initialize with the proper attributes' do
      instance = model.new(foo: 1, bar: 2, baz: 3, raz: 4)
      instance.attributes.should include foo: 1, bar: 2, baz: 3
      instance.attributes.should_not include raz: 4
    end
  end

  describe '.extract_valid_attributes' do
    it 'should only extract attributes it can assign' do
      attributes = model.extract_valid_attributes foo: 1, bar: 2, baz: 3, raz: 4
      attributes.should include foo: 1, bar: 2, baz: 3
      attributes.should_not include raz: 4
    end
  end

  describe '.fields' do

    context 'given an active_record model' do
      subject(:model) do
        Class.new do
          def self.ancestors
            super + [ActiveRecord::Base]
          end

          def self.column_names
            %w{foo}
          end
          include SelectiveAttributes
        end
      end

      it 'should be an array of columns' do
        model.fields.should be_an Array
        model.fields.should_not be_empty
      end

    end

    context 'given an active_model model' do
      subject(:model) do
        Class.new do
          include SelectiveAttributes
        end
      end
      it 'should be an empty array' do
        model.fields.should be_an Array
        model.fields.should be_empty
      end
    end

  end

end