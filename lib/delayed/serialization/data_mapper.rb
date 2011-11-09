# encoding: utf-8
if YAML.parser.class.name =~ /syck/i
  DataMapper::Resource.class_eval do
    yaml_as "tag:ruby.yaml.org,2002:DataMapper"

    def self.yaml_new(klass, tag, val)
      klass.get!(val['attributes']['id'])
    end

    def to_yaml_properties
      ['@attributes']
    end
  end
else
  DataMapper::Resource.class_eval do
    def encode_with(coder)
      coder["attributes"] = @attributes
      coder.tag = ['!ruby/DataMapper', self.class.name].join(':')
    end
  end
end
