# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name              = 'delayed_job_data_mapper'
  s.summary           = 'DataMapper backend for delayed_job'
  s.version           = '1.0.0.rc'
  s.authors           = 'Brandon Keepers'
  s.date              = Date.today.to_s
  s.email             = 'brandon@collectiveidea.com'
  s.extra_rdoc_files  = ["LICENSE", "README.md"]
  s.files             = Dir.glob("{lib,spec}/**/*") + %w[LICENSE README.md]
  s.homepage          = 'http://github.com/collectiveidea/delayed_job_data_mapper'
  s.rdoc_options      = ['--charset=UTF-8']
  s.require_paths     = ['lib']
  s.test_files        = Dir.glob('spec/**/*')

  s.add_runtime_dependency      'dm-core'
  s.add_runtime_dependency      'dm-observer'
  s.add_runtime_dependency      'dm-aggregates'
  s.add_runtime_dependency      'delayed_job',  '3.0.0.pre2'
  s.add_development_dependency  'rake'
  s.add_development_dependency  'rspec'
  s.add_development_dependency  'dm-migrations'
  s.add_development_dependency  'dm-sqlite-adapter'
end
