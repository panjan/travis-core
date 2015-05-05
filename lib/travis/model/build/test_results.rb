require 'diff/lcs'

class Build
  module TestResults

    def matrix_by_dimension(env_var_name)
      matrix.group_by do |job|
        job.config_vars_hash[env_var_name]
      end
    end

    # returns array of tupples
    # each TestCase has array of TestCaseResults
    # input:
    #  job1:                 job2:
    #    TC1                   TC1
    #    TC2                   --
    #    --                    TC3
    #    TC4                   TC4
    #
    #  result:
    #  [
    #    [TC1, {job1: TC_RESULT1, job2: TC_RESULT1 }]
    #    [TC2, {job1: TC_RESULT2, job2: TC_RESULT2 }]
    #    [TC3, {job1: TC_RESULT3, job2: TC_RESULT3 }]
    #    [TC4, {job1: TC_RESULT4, job2: TC_RESULT4 }]
    #  ]
    #  note that TC2 and TC3 are mutaly unordered
    def test_case_results_by_test_cases(jobs = self.matrix)
      test_cases_list = test_cases_for_jobs(jobs)

      test_cases_list.map do |test_case|
        [
          test_case,
          Hash[jobs.map { |job|
            [job, TestCaseResult.where(test_case_id: test_case.id, job_id: job.id).first]
          }]
        ]
      end
    end

    # helper method
    # returns ordered list of test_cases for given jobs
    def test_cases_for_jobs(jobs)
      return [] if jobs.empty?

      res = jobs.first.test_cases.to_a
      jobs.each do |job|
        diffs = Diff::LCS.diff(res, job.test_cases.to_a, Diff::LCS::ContextDiffCallbacks)
        deleted = 0
        new_res = res.dup
        diffs.map do |hunk|
          hunk.to_a.map do |seq|
            change = seq.to_a
            deleted += 1 if change[1][1]
            if change[2][1]
              new_res[change[2][0] + deleted,0] = change[2][1]
            end
          end
        end
        res = new_res
      end
      res
    end
    private :test_cases_for_jobs

    def lcs(arrays)
      return [] if arrays.empty?

      res = arrays.first
      arrays.each do |array|
        diffs = Diff::LCS.diff(res, array, Diff::LCS::ContextDiffCallbacks)
        deleted = 0
        new_res = res.dup
        diffs.map do |hunk|
          hunk.to_a.map do |seq|
            change = seq.to_a
            deleted += 1 if change[1][1]
            if change[2][1]
              new_res[change[2][0] + deleted,0] = change[2][1]
            end
          end
        end
        res = new_res
      end
      res
    end
    private :lcs

    # input:
    #   * test_case_results
    # output:
    #   [
    #     { test_step1: [test_step_result_job1, test_step_result_job2, ...] },
    #     { test_step2: [test_step_result_job1, test_step_result_job3, ...] },
    #   ]
    def test_steps_results_by_test_case_results(tcrs)
      arrays = tcrs.map { |tcr| tcr.test_steps.to_a }
      test_step_list = lcs(arrays)

      test_step_list.map do |ts|
        {
          ts => tcrs.find_all { |tcr| tcr.test_step_results.include?(ts) }
        }
      end
    end

  end
end

