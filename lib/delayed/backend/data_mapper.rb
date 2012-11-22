# encoding: utf-8
module Delayed
  module Backend
    module DataMapper
      class Job
        include ::DataMapper::Resource
        include Delayed::Backend::Base

        storage_names[:default] = 'delayed_jobs'

        property :id,          Serial
        property :priority,    Integer,   :default => 0,  :index => :run_at_priority
        property :attempts,    Integer,   :default => 0
        property :handler,     Text,      :lazy => false
        property :run_at,      DateTime,  :index => :run_at_priority
        property :locked_at,   DateTime,  :index => true, :lazy => false
        property :locked_by,   Text,      :lazy => false
        property :failed_at,   DateTime,  :lazy => false
        property :last_error,  Text,      :lazy => false
        property :queue,       String

        before :save, :set_default_run_at

        def self.db_time_now
          Time.now.utc.to_datetime
        end

        def self.lockable(worker_name, max_run_time = Worker.max_run_time)
          all(:failed_at => nil) & (all(:locked_by => worker_name) | expired(max_run_time))
        end

        def self.expired(max_run_time = Worker.max_run_time)
          now = db_time_now

          (
            all(:run_at => nil) |
            all(:run_at.lte => now)
          ) &
          (
            all(:locked_at => nil) | # never locked
            all(:locked_at.lt => Time.at(now.to_i - max_run_time.to_i).utc) # expired
          )
        end

        def self.find_available(worker_name, limit = 5, max_run_time = Worker.max_run_time)
          simple_conditions = {:limit => limit, :order => [:priority.asc, :run_at.asc]}
          simple_conditions[:priority.gte] = Worker.min_priority if Worker.min_priority # these seem
          simple_conditions[:priority.lte] = Worker.max_priority if Worker.max_priority # reversed to me
          simple_conditions[:queue] = Worker.queues if Worker.queues.any?

          lockable(worker_name, max_run_time).all(simple_conditions)
        end

        # When a worker is exiting, make sure we don't have any locked jobs.
        def self.clear_locks!(worker_name)
          all(:locked_by => worker_name).update(:locked_at => nil, :locked_by => nil)
        end

        # Lock this job for this worker.
        # Returns true if we have the lock, false otherwise.
        def lock_exclusively!(max_run_time, worker = worker_name)
          now = self.class.db_time_now

          # FIXME - this is a bit gross
          # DM doesn't give us the number of rows affected by a collection update
          # so we have to circumvent some niceness in DM::Collection here
          collection = if locked_by != worker
            self.class.all(:id => id) & self.class.expired(max_run_time)
          else
            self.class.all(:id => id, :locked_by => worker)
          end

          attributes = collection.model.new(:locked_at => now, :locked_by => worker).dirty_attributes
          affected_rows = self.repository.update(attributes, collection)

          if affected_rows == 1
            self.locked_at = now
            self.locked_by = worker
            return true
          else
            return false
          end
        end

        def reschedule_at
          payload_object.respond_to?(:reschedule_at) ?
            payload_object.reschedule_at(self.class.db_time_now, attempts) :
            self.class.db_time_now + ((attempts ** 4) + 5).seconds
        end

        # these are common to the other backends, so we provide an implementation
        def self.delete_all
          Delayed::Job.auto_migrate!
        end

        def self.find id
          get id
        end

        def update_attributes(attributes)
          attributes.each do |k,v|
            self[k] = v
          end
          self.save
        end

        def reload(*args)
          reset
          super
        end

        def ==(other)
          id == other.id
        end
      end
    end
  end
end
