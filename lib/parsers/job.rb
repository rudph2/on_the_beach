class Job
  attr_accessor :name, :dependency

  def initialize(job_line)
    job_line.strip!

    splitted_job = job_line.split(/ => ?/)
    splitted_job.each(&:strip!)

    self.name = splitted_job[0]
    self.dependency = splitted_job[1]
  end
end