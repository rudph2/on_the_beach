require 'parsers/job'
require 'parsers/job_parser'

class JobParser
  attr_accessor :job_sequence_array

  def self.sort_jobs(job_sequence_string)
    parsed_input = job_sequence_string.split(/\n/).reject(&:empty?)
    job_parser = self.new(parsed_input)
    job_parser.sorted_jobs_string
  end

  def initialize(job_sequence_array)
    self.job_sequence_array = job_sequence_array
  end

  def sorted_jobs_string
    raise ArgumentError, "Jobs can't depend on themselves" if self_dependency_exists?
    raise ArgumentError, "Jobs can't have circular dependencies" if circular_dependency_exists?

    sorted_jobs_array.join
  end

  private
  def sorted_jobs_array
    jobs.reduce([]) do |sequence, job|
      sequence.push(job.name) unless sequence.include?(job.name)

      if job.dependency
        sequence.delete(job.dependency)

        dependent_position = sequence.index(job.name)
        sequence.insert(dependent_position, job.dependency)
      end

      sequence
    end
  end

  def dependent_jobs_for(target, list = [])
    jobs.each do |job|
      next unless job.dependency == target.name
      list.push(job.name)
      list += dependent_jobs_for(job, list) unless list.include?(job.dependency)
    end

    list
  end

  def depends_upon(target, list = [])
    jobs.each do |job|
      next unless job.name == target.dependency
      list.push(job.name)
      list += depends_upon(job, list) unless list.include?(job.dependency)
    end

    list
  end

  def jobs
    self.job_sequence_array.collect { |line| Job.new(line) }
  end

  def self_dependency_exists?
    jobs.any? { |job| job.dependency == job.name }
  end

  def circular_dependency_exists?
    jobs.any? { |job| (dependent_jobs_for(job) & depends_upon(job)).size > 0 }
  end
end