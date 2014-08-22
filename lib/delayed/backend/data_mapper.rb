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
          never_failed &
          never_run &
          (locked_by(worker_name) | expired(max_run_time))
        end

        def self.expired(max_run_time = Worker.max_run_time)
          (
            all(:locked_at => nil) | # never locked
            all(:locked_at.lt => db_time_now - max_run_time) # lock expired
          )
        end

        def self.locked_by(worker_name)
          all(:locked_by => worker_name)
        end

        def self.never_run
          (all(:run_at => nil) | all(:run_at.lte => db_time_now))
        end

        def self.never_failed
          all(:failed_at => nil)
        end

        def self.find_available(worker_name, limit = 5, max_run_time = Worker.max_run_time)
          simple_conditions = {:limit => limit, :order => [:priority.asc, :run_at.asc]}
          simple_conditions[:priority.gte] = Worker.min_priority if Worker.min_priority
          simple_conditions[:priority.lte] = Worker.max_priority if Worker.max_priority
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
            self.class.expired(max_run_time).never_run.all(:id => id)
          else
            self.class.locked_by(worker).all(:id => id)
          end

          attributes = collection.model.new(:locked_at => now, :locked_by => worker).dirty_attributes
          affected_rows = self.repository.update(attributes, collection)

          if affected_rows == 1
            reload # pick up the updates above
            true
          else
            # does this mean > 1 was locked, or none?
            false
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
