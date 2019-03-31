module Fastlane

  module DependencyManager
    class << self
      attr_accessor :config
    end
  end

  class Dependency
    attr_reader :name
    attr_reader :current
    attr_reader :available
    attr_reader :latest

    def initialize(name, current, available, latest)
      @name = name
      @current = current
      @available = available
      @latest = latest
    end

    def to_hash
      instance_variables.each_with_object({}) { |var, hash|
         hash[var.to_s.delete("@").to_sym] = instance_variable_get(var)
      }
    end
  end

end
