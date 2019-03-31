require 'fastlane_core/ui/ui'
require_relative './dependency_manager_outdated_helper'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CocoapodsOutdatedHelper < DependencyManagerOutdatedHelper
      # class methods that you define here become available in your action
      # as `Helper::CocoapodsOutdatedHelper.your_method`
      #

      SEPARATOR = "The following pod updates are available:"
      # ex.)
      # - Fabric 1.7.8 -> 1.9.0 (latest version 1.9.0)
      PATTERN = /^- (\S+) (\S+) -> (\S+) \(latest version (\S+)\)$/

      def self.name
        "CocoaPods"
      end

      def self.message
        SEPARATOR
      end

      def self.parse(str)
        result = str.split(SEPARATOR + "\n")[1]
        libs = result.split("\n")

        results = []
        libs.each do |lib|
          lib.match(PATTERN)
          results << Dependency.new($1, $2, $3, $4)
        end
        results.map { |r| r.to_hash }
      end

    end
  end
end
