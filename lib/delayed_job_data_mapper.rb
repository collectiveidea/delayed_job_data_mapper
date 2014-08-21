# encoding: utf-8
require 'dm-core'
require 'dm-active_model' # for persisted? alias for DJ 4.0.1
require 'delayed_job'
require 'delayed/serialization/data_mapper'
require 'delayed/backend/data_mapper'

Delayed::Worker.backend = :data_mapper
