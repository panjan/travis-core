# == Schema Information
#
# Table name: test_step_data
#
#  id                  :integer          not null, primary key
#  name                :string(255)      not null
#  message             :text
#  crashed             :boolean          default(FALSE), not null
#  test_step_result_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class TestStepData < Travis::Model::TestResultModel
  belongs_to :test_step_result, inverse_of: :test_step_data
  attr_accessible :crashed, :message
end
