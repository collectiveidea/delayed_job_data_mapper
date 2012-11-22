require 'bundler/setup'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec'
require 'delayed_job_data_mapper'
require 'delayed/backend/shared_spec'
require 'dm-migrations'
DataMapper.setup(:default, "sqlite3::memory:")

class Story
  include DataMapper::Resource
  property :id, Serial
  property :text, String
  def tell; text; end
  def whatever(n, _); tell*n; end
  def self.count; end
  def update_attributes(attributes)
    attributes.each do |k,v|
      self[k] = v
    end
    self.save
  end

  handle_asynchronously :whatever
end

DataMapper.auto_migrate!

