require 'stash-client'

module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        class StashPush
          attr_reader :data, :ref

          def initialize(data)
            @data = data
            @ref = data["refChange"]["refId"]
          end

          def event
            return @event if defined? @event

            stash_client ||= Travis::Stash.authenticated(payload_user)
            repo = stash_client.repository(
              data["repository"]["project"]["key"],
              data["repository"]["slug"]
            )

            commits = stash_client.commits_for(
              repo,
              since: data["refChange"]["fromHash"],
              :until => data["refChange"]["toHash"]
            )

            @event = {
              'repository' => repo,
              'commits' => commits,
            }
          end

          def payload_user
            if owner_name = data['owner_name']
              User.where(login: owner_name).first
            elsif user_name = (data['repository']['project']['owner'] && data['repository']['project']['owner']['name'])
              User.where(login: owner_name).first
            elsif user_stash_id = data['repository']['owner_stash_id']
              User.where(stash_id: user_stash_id).first
            end
            #elsif login = data['repository']['project']['key']
            #  #Organization.where(login: login).first
            #  #User.where(login: login).first
            #end
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
              #description:     repo_data['description'],
              #url:             repo_data['url'],
              private:         !repo_data['public'],

              type:            project_data['type'] == 'PERSONAL' ? 'User' : 'Organization',
              owner_stash_id:  project_owner_stash_id,
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

            def project_owner_stash_id
              (project_owner['type'] == 'PERSONAL') &&
                project_owner['owner'] &&
                project_owner['owner']['id']
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
