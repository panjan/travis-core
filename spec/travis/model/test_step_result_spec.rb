require 'spec_helper'

describe TestStepResult, :type => :model do
  include Support::ActiveRecord

  #it { should belong_to(:test_case_result) }
  #it { should belong_to(:test_step) }
  #it { should have_one(:test_step_data) }

  let(:data) { {
    job_id:     1,
    classname:  'TestCaseName',
    name:       'TestStepName',
    result:     'success',
    duration:    123
  } }

  describe "#write_results" do
    it "creates test_case and test_step" do
      tsr = TestStepResult.write_result(data)
      tsr.test_step.name.should eq('TestStepName')
      tsr.test_step.test_case.name.should eq('TestCaseName')
      tsr.duration.should eq(123)
      tsr.result.should eq('success')
    end

    it "use existing test_case_result for same job_id and classname" do
      tsr1 = TestStepResult.write_result(data)
      tsr2 = TestStepResult.write_result(data.update(name: 'TestStep2'))
      tsr1.test_case_result.should eq(tsr2.test_case_result)
    end

    it "use existing test_case and test_step" do
      tsr1 = TestStepResult.write_result(data)
      tsr2 = TestStepResult.write_result(data.update(job_id: 2))
      tsr1.test_step.should eq(tsr2.test_step)
      tsr1.test_case_result.should_not eq(tsr2.test_case_result)
    end

  end
end
