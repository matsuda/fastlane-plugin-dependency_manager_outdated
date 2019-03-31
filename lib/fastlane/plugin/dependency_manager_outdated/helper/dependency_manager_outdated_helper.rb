require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class DependencyManagerOutdatedHelper
      # class methods that you define here become available in your action
      # as `Helper::DependencyManagerOutdatedHelper.your_method`
      #
      def self.name
        ""
      end

      def self.message
        ""
      end

      def self.notify_slack(libs)
        require 'slack-notifier'

        options = DependencyManager.config

        return if options[:skip_slack]
        return if options[:slack_url].to_s.empty?

        ######################
        # see https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/slack.rb
        ######################

        if options[:slack_channel].to_s.length > 0
          channel = options[:slack_channel]
          channel = ('#' + options[:slack_channel]) unless ['#', '@'].include?(channel[0]) # send message to channel by default
        end

        attachements = generate_slack_attachments(libs)

        notifier = Slack::Notifier.new(options[:slack_url], channel: channel, username: options[:slack_username])
        text = "[#{name}] #{message}"

        begin
          results = notifier.ping(text, icon_url: options[:slack_icon_url], attachments: attachements)
        rescue => exception
          UI.error("Exception: #{exception}")
        ensure
          result = results.first if results
          if !result.nil? && result.code.to_i == 200
            UI.success('Successfully sent Slack notification')
          else
            UI.verbose(result) unless result.nil?
            message = "Error pushing Slack message, maybe the integration has no permission to post on this channel? Try removing the channel parameter in your Fastfile, this is usually caused by a misspelled or changed group/channel name or an expired SLACK_URL"
            UI.error(message)
          end
        end
      end

      # def self.generate_slack_attachments(libs)
      #   attachements = []
      #   libs.each do |lib|
      #     attachement = {title: lib[:name]}
      #     if lib[:repository]
      #       attachement[:title_link] = lib[:repository]
      #     end
      #
      #     fields = []
      #
      #     current = lib[:current]
      #     available = lib[:available]
      #
      #     if current == available
      #       attachement[:color] = "warning"
      #     else
      #       available = "*#{available}*"
      #       attachement[:color] = "danger"
      #     end
      #     # field[:value] = "#{current} -> #{available} (#{lib[:latest]})"
      #     # attachement[:fields] = [field]
      #
      #     fields << {title: "current", value: current, short: true}
      #     fields << {title: "available", value: "#{available} (Latest: #{lib[:latest]})", short: true}
      #     attachement[:fields] = fields
      #     attachements << attachement
      #   end
      #   attachements
      # end

      def self.generate_slack_attachments(libs)
        attachements = []
        libs.each do |lib|
          attachement = {title: lib[:name]}
          if lib[:repository]
            attachement[:title_link] = lib[:repository]
          end

          current = lib[:current]
          available = lib[:available]

          if current == available
            attachement[:color] = "warning"
          else
            available = "*#{available}*"
            attachement[:color] = "danger"
          end
          attachement[:text] = "#{current} -> #{available} (Latest: #{lib[:latest]})"
          attachements << attachement
        end
        attachements
      end

    end
  end
end
