require 'fastlane/action'
require_relative '../helper/cocoapods_outdated_helper'

module Fastlane
  module Actions
    module SharedValues
      COCOAPODS_OUTDATED_LIST = :COCOAPODS_OUTDATED_LIST
    end

    class CocoapodsOutdatedAction < Action
      def self.run(params)
        UI.message("The cocoapods_outdated action is working!")

        DependencyManager.config = params

        cmd = []
        cmd << ['bundle exec'] if params[:use_bundle_exec] && shell_out_should_use_bundle_exec?
        cmd << ['pod outdated']
        cmd << "--project-directory=#{params[:project_directory]}" if params[:project_directory]
        cmd << "--no-repo-update" if params[:no_repo_update]
        result = Actions.sh(cmd.join(' '))

        dependencies = Helper::CocoapodsOutdatedHelper.parse(result)

        if dependencies.empty?
          UI.success("No pod updates are available.")
        else
          Actions.lane_context[SharedValues::COCOAPODS_OUTDATED_LIST] = dependencies
          Helper::CocoapodsOutdatedHelper.notify_slack(dependencies)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Check outdated CocoaPods dependencies"
      end

      def self.details
        "Check outdated CocoaPods dependencies"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_directory,
                                       env_name: "DEPENDENCY_MANAGER_PROJECT_DIRECTORY",
                                       description: "The path to the root of the project directory",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                       env_name: "DEPENDENCY_MANAGER_COCOAPODS_USE_BUNDLE_EXEC",
                                       description: "Use bundle exec when there is a Gemfile presented",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :no_repo_update,
                                       env_name: "COCOAPODS_OUTDATED_REPO_UPDATE",
                                       description: "Skip running `pod repo update` before install",
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
          ['COCOAPODS_OUTDATED_LIST', 'List of the outdated pods in the current Podfile.lock'],
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
          'cocoapods_outdated',
          'cocoapods_outdated(
            project_directory: "path/to/xcode/project",
            no_repo_update: true,
            slack_url: "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX",
          )',
        ]
      end
    end
  end
end
