class StepResult < Travis::Model
  attr_accessible :data, :job_id

  serialize :data, JSON
end
