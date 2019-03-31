require 'fastlane/action'
require_relative '../helper/dependency_manager_outdated_helper'

module Fastlane
  module Actions
    class DependencyManagerOutdatedAction < Action
      def self.run(params)
        UI.message("The dependency_manager_outdated plugin is working!")
      end

      def self.description
        "Fastlane plugin to check project's outdated dependencies"
      end

      def self.authors
        ["matsuda"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Check outdated outdated CocoaPods and Carthage dependencies in project and notify to slack them"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "DEPENDENCY_MANAGER_OUTDATED_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
