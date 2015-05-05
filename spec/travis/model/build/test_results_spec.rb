require 'spec_helper'

describe Build, 'TestResults'  do
  include Support::ActiveRecord

  describe :test_case_results_by_test_cases do
    context 'if no results' do
      it 'returns []' do
        build = Factory.create(:build,
          config: {
            env: [
              'MACHINE=Win7',
              'MACHINE=Win8'
            ]
           }
        )
        build.test_case_results_by_test_cases.should eq []
      end
    end

    context "if one job has with one test case" do
      # job1      |
      # ----------|
      #   TC1     |
      it 'returs one test_case with one job' do
          build = Factory.create(:build,
            config: {
              env: [
                'MACHINE=Win7',
              ]
             }
          )
          job = build.matrix.first
          tsr1 = TestStepResult.write_result(
            job_id:     job.id,
            classname:  'TC1',
            name:       'TS1',
            result:     'success'
          )
          tsr2 = TestStepResult.write_result(
            job_id:     job.id,
            classname:  'TC1',
            name:       'TS2',
            result:     'success'
          )

          tc = tsr1.test_step.test_case
          tc.should eq tsr2.test_step.test_case #it is not part of this test

          tcr = tsr1.test_case_result
          tcr.should eq tsr2.test_case_result

          result = [
            [tc, { job => tcr }]

          ]
          build.test_case_results_by_test_cases.should eq result
      end
    end
    context "if two jobs but only one has results" do
      # job1      |     job2
      # ----------x------------
      #   TC1     |
      #   TC2     |
      it 'returs two test_cases, second job as nil' do
          build = Factory.create(:build,
            config: {
              env: [
                'MACHINE=Win7',
                'MACHINE=Win8',
              ]
             }
          )
          build.matrix.count.should eq 2

          job1 = build.matrix.first
          job2 = build.matrix.last
          job1_tsr1 = TestStepResult.write_result(
            job_id: job1.id, classname: 'TC1', name: 'TS1', result: 'success'
          )
          job1_tsr2 = TestStepResult.write_result(
            job_id: job1.id, classname: 'TC2', name: 'TS1', result: 'success'
          )

          tc1 = job1_tsr1.test_step.test_case
          tc2 = job1_tsr2.test_step.test_case


          job1_tcr1 = job1_tsr1.test_case_result
          job1_tcr2 = job1_tsr2.test_case_result

          result = [
            [tc1, { job1 => job1_tcr1, job2 => nil }],
            [tc2, { job1 => job1_tcr2, job2 => nil }]
          ]
          build.test_case_results_by_test_cases.should eq result
      end
    end

    context "if two jobs has exactly same test cases" do
      # job1      |     job2
      # ----------x------------
      #   TC1     |       TC1
      #   TC2     |       TC2
      it 'returs returs two test_cases each with two jobs test_case_results' do
          build = Factory.create(:build,
            config: {
              env: [
                'MACHINE=Win7',
                'MACHINE=Win8',
              ]
             }
          )
          build.matrix.count.should eq 2

          job1 = build.matrix.first
          job2 = build.matrix.last
          job1_tsr1 = TestStepResult.write_result(
            job_id: job1.id, classname: 'TC1', name: 'TS1', result: 'success'
          )
          job1_tsr2 = TestStepResult.write_result(
            job_id: job1.id, classname: 'TC2', name: 'TS1', result: 'success'
          )

          job2_tsr1 = TestStepResult.write_result(
            job_id: job2.id, classname: 'TC1', name: 'TS1', result: 'success'
          )
          job2_tsr2 = TestStepResult.write_result(
            job_id: job2.id, classname: 'TC2', name: 'TS1', result: 'success'
          )

          tc1 = job1_tsr1.test_step.test_case
          tc1.should eq job2_tsr1.test_step.test_case

          tc2 = job1_tsr2.test_step.test_case
          tc2.should eq job2_tsr2.test_step.test_case


          job1_tcr1 = job1_tsr1.test_case_result
          job1_tcr2 = job1_tsr2.test_case_result

          job2_tcr1 = job2_tsr1.test_case_result
          job2_tcr2 = job2_tsr2.test_case_result


          result = [
            [tc1, { job1 => job1_tcr1, job2 => job2_tcr1 }],
            [tc2, { job1 => job1_tcr2, job2 => job2_tcr2 }]
          ]
          build.test_case_results_by_test_cases.should eq result
      end
    end

  end
end


