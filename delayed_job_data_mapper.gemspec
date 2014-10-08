# coding: utf-8

Gem::Specification.new do |s|
  s.name              = 'delayed_job_data_mapper'
  s.summary           = 'DataMapper backend for delayed_job'
  s.version           = '1.0.0'
  s.authors           = 'Brandon Keepers'
  s.email             = 'brandon@collectiveidea.com'
  s.extra_rdoc_files  = %w[LICENSE.md README.md]
  s.files             = %w[LICENSE.md README.md] + Dir['{lib}/**/*']
  s.homepage          = 'http://github.com/collectiveidea/delayed_job_data_mapper'
  s.licenses          = ['MIT']
  s.rdoc_options      = ['--charset=UTF-8']
  s.require_paths     = ['lib']

  s.add_runtime_dependency      'delayed_job',  '~> 4.0'
  s.add_runtime_dependency      'dm-core',  '~> 1.0'
  s.add_runtime_dependency      'dm-active_model',  '~> 1.0'
  s.add_runtime_dependency      'i18n'
  s.add_runtime_dependency      'tzinfo'
  s.add_development_dependency  'rake'
  s.add_development_dependency  'rspec'
  s.add_development_dependency  'dm-migrations'
  s.add_development_dependency  'dm-sqlite-adapter'
end
