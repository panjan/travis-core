module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        class StashPush
          attr_reader :event

          def initialize(event)
            #TODO - somehow fetch data about repo from stash
            @event = event
          end

          def accept?
            true
          end

          def validate!
            if event['repository'].nil?
              raise PayloadValidationError, "Repository data is not present in payload"
            end
          end

          def action
            nil
          end

          def repository
            @repository ||= repo_data && {
              name:            repo_data['name'],
              description:     repo_data['description'],
              url:             repo_data['url'],
              private:         !!repo_data['private'],
              repository_id:   repo_data['repository_id'],
              owner_name:   repo_data['owner_name']
            }
          end

          def request
            @request ||= {}
          end

          def commit
            @commit ||= commit_data && {
              commit:          commit_data['sha'],
              message:         commit_data['message'],
              branch:          event['ref'].split('/', 3).last,
              ref:             event['ref'],
              committed_at:    commit_data['date'],
              committer_name:  commit_data['committer']['name'],
              committer_email: commit_data['committer']['email'],
              author_name:     commit_data['author']['name'],
              author_email:    commit_data['author']['email'],
              compare_url:     event['compare']
            }
          end

          private

            def repo_data
              event['repository']
            end

            def commit_data
              @commit_data ||= (last_unskipped_commit || commits.last || event['head_commit'])
              @commit_data['committer'] ||= {}
              @commit_data['author'] ||= {}
              @commit_data
            end

            def last_unskipped_commit
              commits.reverse.find { |commit| !skip_commit?(commit) }
            end

            def commits
              event['commits'] || []
            end

            def skip_commit?(commit)
              Travis::CommitCommand.new(commit['message']).skip?
            end
        end
      end
    end
  end
end
