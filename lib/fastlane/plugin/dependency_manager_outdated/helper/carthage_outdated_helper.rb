require 'fastlane_core/ui/ui'
require_relative './dependency_manager_outdated_helper'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class CarthageOutdatedHelper < DependencyManagerOutdatedHelper
      # class methods that you define here become available in your action
      # as `Helper::CarthageOutdatedHelper.your_method`

      MESSAGE = "The following dependencies are outdated:"
      # ex.)
      # Alamofire "4.7.3" -> "4.7.3" (Latest: "4.8.2")
      PATTERN = /^(\S+) "(\S+)" -> "(\S+)" \(Latest: "(\S+)"\)$/

      # ex.)
      # github "Alamofire/Alamofire" "4.7.3"
      RESOLVED_PATTERN = /^(\S+) "(\S+)" "(\S+)"$/

      def self.name
        "Carthage"
      end

      def self.message
        MESSAGE
      end

      def self.parse(str)
        result = str.split(MESSAGE + "\n")[1]
        libs = result.split("\n")

        results = []
        libs.each do |lib|
          lib.match(PATTERN)
          results << Dependency.new($1, $2, $3, $4)
        end
        results.map { |r| r.to_hash }
      end

      # {"Alamofire"=>"https://github.com/Alamofire/Alamofire", "RxSwift"=>"https://github.com/ReactiveX/RxSwift"}
      def self.resolved(dir)
        lock_file = "Cartfile.resolved"
        dir ||= '.'
        # dir = File.dirname(File.expand_path(__FILE__))
        file = File.join(dir, lock_file)

        results = {}
        File.open(file) do |f|
          f.each_line do |lib|
            lib.match(RESOLVED_PATTERN)
            origin = $1
            repo = $2

            url = nil
            name = nil
            if origin == "github"
              url = "https://github.com/#{repo}"
              name = repo.split("/")[1]
            end
            if origin == "git"
              url = repo
              name = repo.split("/").last
            end
            if name && !name.empty?
              results[name] = url
            end
          end
        rescue => e
          UI.message e
        end
        results
      end
    end
  end
end
