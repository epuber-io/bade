# frozen_string_literal: true

require 'psych'

module Bade
  class Precompiled
    # @return [String]
    #
    attr_accessor :code_string

    # @return [String]
    #
    attr_accessor :source_file_path

    # # @return [Proc]
    # #
    # attr_accessor :lambda_instance

    # @param [String, File] file  file instance or path to file
    #
    def self.from_yaml_file(file)
      file = File.new(file, 'r') if file.is_a?(String)

      hash = if Gem::Version.new(Psych::VERSION) >= Gem::Version.new('3.0')
               Psych.safe_load(file, filename: file.path, permitted_classes: [Symbol])
             else
               Psych.safe_load(file, [Symbol])
             end
      raise LoadError, 'YAML file is not in valid format' unless hash.is_a?(Hash)

      file_path = hash[:source_file_path]
      content = hash[:code_string]

      new(content, file_path)
    end

    # @param [String] code
    #
    def initialize(code, source_file_path = nil)
      @code_string = code
      @source_file_path = source_file_path
    end

    # @param [String, File] file  file instance or path to file
    #
    def write_yaml_to_file(file)
      file = File.new(file, 'w') if file.is_a?(String)

      content = {
        source_file_path: source_file_path,
        code_string: code_string,
      }.to_yaml

      file.write(content)
      file.flush
    end
  end
end
