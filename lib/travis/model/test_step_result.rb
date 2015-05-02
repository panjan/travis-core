# == Schema Information
#
# Table name: test_step_results
#
#  id                  :integer          not null, primary key
#  result              :string(255)      not null
#  position            :integer
#  started_at          :datetime
#  duration            :integer
#  test_case_result_id :integer
#  test_step_id        :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class TestStepResult < Travis::Model::TestResultModel
  belongs_to :test_case_result, inverse_of: :test_step_results
  belongs_to :test_step, inverse_of: :test_step_results
  has_one :test_step_data, inverse_of: :test_step_result, dependent: :destroy
  attr_accessible :position, :result
  # validates :result, include: [:passed, :failed, :pending]
  delegate :name, to: :test_step

  attr_accessible :test_step,
    :test_case,
    :test_step_id,
    :test_case_id,
    :duration,
    :result

  #TODO: for speedup this method is better implement in PL/pgSQL
  def self.write_result(opts)
    tc = TestCase.find_or_create_by_name(opts[:classname])
    ts = tc.test_steps.find_or_create_by_name(opts[:name])

    tcr = tc.test_case_results.find_or_create_by_job_id(opts[:job_id])
    tsr = tcr.test_step_results.create(
      test_step_id: ts.id,
      result: opts[:result],
      duration: opts[:duration]
    )

    tsr.create_test_step_data(opts[:test_data]) if opts[:test_data].present?
    tsr
  end
end
