require 'stash-client'

module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        class StashPush
          attr_reader :event, :ref

          def initialize(event)
            url = Travis.config.stash.api_url
            stash_client = Stash::Client.new({url: url}.update(Travis.config.stash.connection || {}))

            repo = stash_client.repository(
              event["repository"]["project"]["key"],
              event["repository"]["slug"]
            )
            @ref = event["refChange"]["refId"]
            commits = stash_client.commits_for(
              repo,
              #TODO
              # where is documentation for Stash payload?
              # based on expediments, the array has only one element.
              since: event["refChange"]["fromHash"],
              :until => event["refChange"]["toHash"]
            )
            @event = {
              'repository' => repo,
              'commits' => commits,
            }
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
              repository_id:   project_data['repository_id'],
              #TODO: provider_id:   project_data['id'],
              type:            project_data['type'],
              owner_name:      project_owner
            }
          end

          def request
            @request ||= {}
          end

          def commit
            @commit ||= commit_data && {
              commit:          commit_data['id'],
              message:         commit_data['message'],
              branch:          ref.split('/', 3).last,
              ref:             ref,
              committed_at:    Time.at(commit_data['authorTimestamp']),
              #committer_name:  commit_data['committer']['name'],
              #committer_email: commit_data['committer']['email'],
              author_name:     commit_data['author']['name'],
              author_email:    commit_data['author']['email'],
              #compare_url:     event['compare']
            }
          end

          private

            def repo_data
              event['repository']
            end

            def project_data
              repo_data['project']
            end

            def project_owner
              project_data['owner'] && project_data['owner']['name'] || project_data['name']
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
