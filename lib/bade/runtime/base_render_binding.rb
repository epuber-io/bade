# frozen_string_literal: true

require 'securerandom'

require_relative 'block'

module Bade
  module Runtime
    class BaseRenderBinding
      # @return [Bade::Runtime::BaseRenderBindingContext]
      #
      attr_accessor :__context

      # Override system function to load ruby files
      #
      # @param [String] filename
      #
      def require_relative(filename)
        filename = "#{filename}.rb" unless filename.end_with?('.rb')
        @__context.load_ruby_file(filename)
      end

      def __get_binding
        binding
      end
    end

    class DepFile
      # @return [String] absolute path to file
      #
      attr_accessor :path

      # @return [Array<Bade::Runtime::GlobalsTracker::Constant>] name of constants created during execution of this file
      #
      attr_accessor :loaded_constants

      # @return [Array<DepFile>] absolute paths to files
      #
      attr_accessor :dependecy_files

      def initialize
        @loaded_constants = []
        @dependecy_files = []
      end
    end

    class BaseRenderBindingContext
      # @return [String, nil]
      #
      attr_reader :id

      # @return [Bade::Runtime::BaseRenderBindingContext, nil]
      #
      attr_reader :parent

      # @return [Hash<String, DepFile>]
      #
      attr_reader :root_files

      # @return [Hash<String, DepFile>]
      #
      attr_reader :files

      # @return [Array<DepFile>]
      #
      attr_reader :current_files

      # @return [Bade::Runtime::BaseRenderBinding]
      #
      attr_accessor :local_binding

      # @param [Bade::Runtime::BaseRenderBindingContext, nil] parent (nil for root)
      # @param [String, nil] id Unique identifier of this binding (nil for root)
      # @param [Bade::Runtime::BaseRenderBinding, nil] local_binding
      #
      def initialize(parent: nil, id: nil, local_binding: nil)
        @id = id
        @parent = parent
        @local_binding = local_binding || BaseRenderBinding.new
        @local_binding.__context = self
        @files = Hash.new
        @current_files = []

        if parent.nil?
          @root_files = Hash.new
        else
          @root_files = parent.root_files
        end
      end

      # @return [Bade::Runtime::BaseRenderBindingContext]
      def child(local_binding: nil)
        self.class.new(parent: self, id: SecureRandom.uuid, local_binding: local_binding)
      end

      # --- Other internal methods

      # @param [String] relative_path
      def load_ruby_file(relative_path)
        abs_path = File.expand_path(relative_path, File.dirname(caller_locations(2, 1).first.absolute_path))

        puts "trying to load #{abs_path}"
        return if ruby_file_loaded?(abs_path)

        puts "actually loading #{abs_path}"

        file = DepFile.new
        file.path = abs_path
        current_files.last&.dependecy_files&.push(file)

        @files[abs_path] = file

        current_files << file

        tracker = GlobalsTracker.new(constants_location_prefixes: [abs_path])
        tracker.catch do
          # rubocop:disable Security/Eval
          eval(File.read(abs_path), local_binding.__get_binding, abs_path)
          # rubocop:enable Security/Eval
        end
        file.loaded_constants = tracker._filtered_constants

        current_files.pop

        puts "loaded #{abs_path}, constants: #{file.loaded_constants}, dependencies: #{file.dependecy_files}"
      end

      def ruby_file_loaded?(abs_path)
        @root_files.has_key?(abs_path) || $LOADED_FEATURES.include?(abs_path)
      end
    end
  end
end
