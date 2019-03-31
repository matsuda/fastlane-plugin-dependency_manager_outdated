require 'fastlane/action'
require_relative '../helper/carthage_outdated_helper'

module Fastlane
  module Actions
    module SharedValues
      CARTHAGE_OUTDATED_LIST = :CARTHAGE_OUTDATED_LIST
      CARTHAGE_REPOSITORY_LIST = :CARTHAGE_REPOSITORY_LIST
    end

    class CarthageOutdatedAction < Action
      def self.run(params)
        UI.message("The carthage_outdated action is working!")

        DependencyManager.config = params

        cmd = ["carthage outdated"]
        cmd << "--project-directory #{params[:project_directory]}" if params[:project_directory]
        cmd << "--use-ssh" if params[:use_ssh]
        result = Actions.sh(cmd.join(' '))

        dependencies = Helper::CarthageOutdatedHelper.parse(result)

        repos = Helper::CarthageOutdatedHelper.resolved(params[:project_directory])
        Actions.lane_context[SharedValues::CARTHAGE_REPOSITORY_LIST] = repos

        dependencies.each do |lib|
          if repository = repos[lib[:name]]
            lib[:repository] = repository
          end
        end
        Actions.lane_context[SharedValues::CARTHAGE_OUTDATED_LIST] = dependencies

        Helper::CarthageOutdatedHelper.notify_slack(dependencies)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Check outdated Carthage dependencies"
      end

      def self.details
        "Check outdated Carthage dependencies"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_directory,
                                       env_name: "DEPENDENCY_MANAGER_PROJECT_DIRECTORY",
                                       description: "The path to the root of the project directory",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :use_ssh,
                                       env_name: "DEPENDENCY_MANAGER_CARTHAGE_USE_SSH",
                                       description: "Use SSH for downloading GitHub repositories",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),

          # slack
          FastlaneCore::ConfigItem.new(key: :slack_url,
                                       short_option: "-i",
                                       env_name: "DEPENDENCY_MANAGER_SLACK_URL",
                                       sensitive: true,
                                       description: "Create an Incoming WebHook for your Slack group to post results there",
                                       optional: true,
                                       verify_block: proc do |value|
                                         if !value.to_s.empty? && !value.start_with?("https://")
                                           UI.user_error!("Invalid URL, must start with https://")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :slack_channel,
                                       short_option: "-e",
                                       env_name: "DEPENDENCY_MANAGER_SLACK_CHANNEL",
                                       description: "#channel or @username",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :slack_username,
                                       env_name: "DEPENDENCY_MANAGER_SLACK_USERNAME",
                                       description: "Overrides the webhook's username property if slack_use_webhook_configured_username_and_icon is false",
                                       default_value: "fastlane",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :slack_icon_url,
                                       env_name: "DEPENDENCY_MANAGER_SLACK_ICON_URL",
                                       description: "Overrides the webhook's image property if slack_use_webhook_configured_username_and_icon is false",
                                       default_value: "https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :skip_slack,
                                       env_name: "DEPENDENCY_MANAGER_SKIP_SLACK",
                                       description: "Don't publish to slack, even when an URL is given",
                                       is_string: false,
                                       default_value: false),
        ]
      end

      def self.output
        [
          ['CARTHAGE_OUTDATED_LIST', 'List of the outdated dependencies in the current Cartfile.resolved'],
          ['CARTHAGE_REPOSITORY_LIST', 'List of dependencies in the current Cartfile.resolved'],
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        ["matsuda"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'carthage_outdated',
          'carthage_outdated(
            project_directory: "path/to/xcode/project",
            slack_url: "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX",
          )',
        ]
      end
    end
  end
end
