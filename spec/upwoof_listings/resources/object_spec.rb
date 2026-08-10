require 'spec_helper'

Serializers = UpwoofListings::Resources::Object::Serializers

describe UpwoofListings::Resources::Object do
  # A fresh subclass per example keeps attribute/serializer memoisation from
  # leaking between tests and from mutating the shared base class.
  let(:klass) { Class.new(described_class) }

  describe 'attribute access' do
    subject(:object) do
      described_class.new('name' => 'Rex', 'date_created_utc' => '2020-01-02T03:04:05Z')
    end

    it 'reads an untyped attribute via method_missing' do
      expect(object.name).to eq('Rex')
    end

    it 'deserializes a Time attribute defined on the base class' do
      expect(object.date_created_utc).to be_a(::Time)
      expect(object.date_created_utc.utc.xmlschema).to eq('2020-01-02T03:04:05Z')
    end

    it 'collects all present keys into an attributes hash' do
      expect(object.attributes.keys).to include('name', 'date_created_utc')
      expect(object.attributes['name']).to eq('Rex')
    end

    it 'responds_to a key that exists in the payload' do
      expect(object).to respond_to(:name)
    end

    it 'does not respond_to an unknown key' do
      expect(object).not_to respond_to(:not_a_key)
    end

    it 'raises NoMethodError for an unknown attribute' do
      expect { object.not_a_key }.to raise_error(NoMethodError)
    end
  end

  describe 'declaring attributes on a subclass' do
    it 'inherits and dups the superclass attributes' do
      parent = UpwoofListings::Resources::User
      subclass = Class.new(parent)
      expect(subclass.attributes).to include(:date_created_utc, :date_updated_utc)
      expect(subclass.attributes).not_to be(parent.attributes)
    end

    it 'defines a typed accessor via .attribute' do
      klass.attribute(:count, Serializers::Object)
      instance = klass.new('count' => 7)
      expect(instance.count).to eq(7)
    end

    it 'aliases has_many to attribute' do
      expect(klass.method(:has_many)).to eq(klass.method(:attribute))
    end

    # The accessor module has to be included into the class that owns it. Each class builds its
    # own, and a subclass never runs the `included` hook, so an accessor defined into a subclass's
    # module used to land outside that subclass's ancestors: the value still read correctly, via
    # method_missing, but the memoisation bought nothing and every resource in this gem paid
    # method_missing on every attribute read.
    it 'includes its accessor module, so a subclass memoises what it defines' do
      subclass = Class.new(described_class)
      # Read the module first: building it is what includes it.
      accessors = subclass.attributes_module
      expect(subclass.ancestors).to include(accessors)
    end

    it 'defines a real method on first read rather than falling through every time' do
      subclass = Class.new(described_class)
      instance = subclass.new('breed' => 'Corgi')

      expect(instance.breed).to eq('Corgi')
      expect(subclass.instance_methods).to include(:breed)
    end

    it 'goes through method_missing only once across repeated reads' do
      calls = 0
      counter = Module.new do
        define_method(:method_missing) do |*args, &block|
          calls += 1
          super(*args, &block)
        end
      end

      subclass = Class.new(described_class) { prepend counter }
      instance = subclass.new('breed' => 'Corgi')
      3.times { expect(instance.breed).to eq('Corgi') }

      expect(calls).to eq(1)
    end
  end

  describe 'serialization' do
    it 'serializes each attribute back to a hash of strings' do
      object = described_class.new('name' => 'Rex', 'date_created_utc' => '2020-01-02T03:04:05Z')
      result = object.serialize
      expect(result['name']).to eq('Rex')
      # serialize resolves the serializer by attribute NAME, not type, so a Time
      # value falls through to the Object serializer and is rendered with to_s.
      expect(result['date_created_utc']).to eq('2020-01-02 03:04:05 UTC')
    end

    it 'serializes via the class-level serialize helper' do
      object = described_class.new('name' => 'Rex')
      expect(described_class.serialize(object)).to eq(object.serialize)
    end
  end

  describe 'inspect' do
    it 'renders the class name and its attributes' do
      object = described_class.new('name' => 'Rex')
      expect(object.inspect).to match(/UpwoofListings::Resources::Object/)
      expect(object.inspect).to include('@name="Rex"')
    end
  end

  describe Serializers::Object do
    it 'serializes any value to a string' do
      expect(described_class.serialize(42)).to eq('42')
    end

    it 'deserializes a scalar unchanged' do
      expect(described_class.deserialize('plain')).to eq('plain')
    end

    it 'deserializes an array element-wise' do
      expect(described_class.deserialize(%w[a b])).to eq(%w[a b])
    end

    it 'wraps a hash in an Object with downcased keys' do
      result = described_class.deserialize('Name' => 'Rex')
      expect(result).to be_a(UpwoofListings::Resources::Object)
      expect(result['name']).to eq('Rex')
    end
  end

  describe Serializers::Time do
    it 'serializes a Time to an xmlschema string' do
      time = ::Time.utc(2020, 1, 2, 3, 4, 5)
      expect(described_class.serialize(time)).to eq('2020-01-02T03:04:05Z')
    end

    it 'deserializes an xmlschema string to a Time' do
      expect(described_class.deserialize('2020-01-02T03:04:05Z')).to eq(::Time.utc(2020, 1, 2, 3, 4, 5))
    end
  end

  describe '.serializer_for' do
    it 'returns a type that already responds to serialize/deserialize' do
      expect(klass.serializer_for(Serializers::Time)).to eq(Serializers::Time)
    end

    it 'resolves a named serializer constant' do
      expect(klass.serializer_for(:Time)).to eq(Serializers::Time)
    end

    it 'resolves a named resource constant' do
      expect(klass.serializer_for(:User)).to eq(UpwoofListings::Resources::User)
    end

    it 'falls back to the Object serializer for anything else' do
      expect(klass.serializer_for(:Unknown)).to eq(Serializers::Object)
    end

    it 'memoises the resolved serializer' do
      first = klass.serializer_for(:Time)
      expect(klass.serializer_for(:Time)).to be(first)
    end
  end

  describe '.deserialize' do
    def response_with(body)
      double('response', body: body, blank?: false)
    end

    it 'raises ArgumentError when the response is blank' do
      blank = double('response', blank?: true)
      expect { described_class.deserialize(blank) }.to raise_error(ArgumentError, 'Response cannot be blank')
    end

    it 'returns a single Object for a hash body' do
      result = described_class.deserialize(response_with({ 'Name' => 'Rex' }.to_json))
      expect(result).to be_a(described_class)
      expect(result['name']).to eq('Rex')
    end

    it 'returns an array of Objects for an array body' do
      result = described_class.deserialize(response_with([{ 'Name' => 'Rex' }].to_json))
      expect(result).to all(be_a(described_class))
      expect(result.first['name']).to eq('Rex')
    end

    it 'logs and returns nil for an unparseable body' do
      allow_any_instance_of(Logger).to receive(:error)
      expect(described_class.deserialize(response_with('not json'))).to be_nil
    end

    it 'is aliased as parse' do
      expect(described_class.method(:parse)).to eq(described_class.method(:deserialize))
    end
  end
end
