# encoding: utf-8
require 'dm-core'
require 'delayed_job'
require 'delayed/serialization/data_mapper'
require 'delayed/backend/data_mapper'

Delayed::Worker.backend = :data_mapper
