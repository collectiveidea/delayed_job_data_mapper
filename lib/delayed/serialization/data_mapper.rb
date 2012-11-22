# encoding: utf-8
if YAML.parser.class.name =~ /syck/i
  DataMapper::Resource.class_eval do
    yaml_as "tag:ruby.yaml.org,2002:DataMapper"

    def self.yaml_new(klass, tag, val)
      begin
        primary_keys = klass.properties.select { |p| p.key? }
        key_names = primary_keys.map { |p| p.name.to_s }
        klass.get!(*key_names.map { |k| val[k] })
      rescue DataMapper::ObjectNotFoundError
        raise Delayed::DeserializationError
      end
    end

    def to_yaml_properties
      primary_keys = self.class.properties.select { |p| p.key? }
      primary_keys.map { |p| "@#{p.name}" }
    end

  end
else
  DataMapper::Resource.class_eval do
    def encode_with(coder)
      coder["attributes"] = attributes.stringify_keys
      coder.tag = ['!ruby/DataMapper', self.class.name].join(':')
    end
  end
end
