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
end
