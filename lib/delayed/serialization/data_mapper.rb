DataMapper::Resource.class_eval do
  yaml_as "tag:ruby.yaml.org,2002:DataMapper"

  def self.yaml_new(klass, tag, val)
    klass.get!(val['id'])
  end

  def to_yaml_properties
    ['@id']
  end
end
