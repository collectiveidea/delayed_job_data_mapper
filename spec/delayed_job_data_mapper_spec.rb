require 'helper'

describe Delayed::Backend::DataMapper::Job do
  it_should_behave_like 'a delayed_job backend'
end
