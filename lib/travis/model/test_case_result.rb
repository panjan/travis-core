# == Schema Information
#
# Table name: test_case_results
#
#  id           :integer          not null, primary key
#  position     :integer
#  job_id       :integer
#  test_case_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class TestCaseResult < Travis::Model::TestResultModel
  belongs_to :job, inverse_of: :test_case_results
  belongs_to :test_case, inverse_of: :test_case_results
  has_many :test_step_results, inverse_of: :test_case_result, dependent: :destroy
  attr_accessible :position, :result

  # valides :result, inlcude: [:failed, :passed, :pending]
  delegate :description, to: :test_case
end
