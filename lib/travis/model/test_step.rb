# == Schema Information
#
# Table name: test_steps
#
#  id           :integer          not null, primary key
#  description  :text             not null
#  test_case_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class TestStep < Travis::Model::TestResultModel
  belongs_to :test_case, inverse_of: :test_steps
  has_many :test_step_results, inverse_of: :test_step, dependent: :destroy
  attr_accessible :description
end
