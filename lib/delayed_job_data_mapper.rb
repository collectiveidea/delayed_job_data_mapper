require 'dm-core'
require 'dm-observer'
require 'dm-aggregates'
# require 'dm-validations'
require 'delayed_job'
require 'delayed/serialization/data_mapper'
require 'delayed/backend/data_mapper'

Delayed::Worker.backend = :data_mapper
