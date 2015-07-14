module Travis
  module Requests
    module Services
      class Receive < Travis::Services::Base
        class StashApi
          attr_reader :data

          def initialize(data)
            @data = data
          end

          def event
            return @event if defined? @event

            stash_client ||= if (data['repository'] && data['repository']['public'])
              Travis::Stash.client
            else
              Travis::Stash.authenticated(payload_user)
            end
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

          def ref
            data['refChange']['refId']
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
              private:         !repo_data['public'],

              owner_type:      project_data['type'] == 'PERSONAL' ? 'User' : 'Organization',
              owner_stash_id:  project_owner_stash_id,
              owner_name:      project_data['key'], #slug of project or user
              stash_id:        repo_data['id']
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
              committed_at:    Time.at(commit_data['authorTimestamp'].to_i/1000).utc.iso8601,
              author_name:     commit_data['author']['name']
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
              owner = project_data['owner']
              return nil if owner.nil? or (project_data['type'] != 'PERSONAL')
              owner['id']
            end

            def commit_data
              @commit_data ||= (last_unskipped_commit || commits.first)
              @commit_data['committer'] ||= {}
              @commit_data['author'] ||= {}
              @commit_data
            end

            def last_unskipped_commit
              commits.find { |commit| !skip_commit?(commit) }
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
