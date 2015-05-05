# == Schema Information
#
# Table name: test_cases
#
#  id          :integer          not null, primary key
#  description :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class TestCase < Travis::Model::TestResultModel
  has_many :test_steps, inverse_of: :test_case, dependent: :destroy
  has_many :test_case_results, inverse_of: :test_case, dependent: :destroy
  attr_accessible :description

  def result
    test_steps_result.map(&:result)
    return 'failed' if test_steps_result.any? { |r| r == 'failed' }
    return 'pending' if test_steps_result.any? { |r| r == 'pending' }
    return 'skipped' if test_steps_result.any? { |r| r == 'skipped' }
    return 'not_run' if test_steps_result.any? { |r| r == 'not_run' }
    return 'passed' if test_steps_result.all? { |r| r == 'passed' }
    raise 'WTF!'
  end
end
