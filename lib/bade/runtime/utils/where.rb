# frozen_string_literal: true

# Inspired by https://gist.github.com/wtaysom/1236979

module Bade
  module Where
    class << self
      # @param [Proc] proc
      # @return [[String, Integer], String]
      def proc?(proc)
        source_location(proc)
      end

      # @param [Class] klass
      # @param [Symbol, String] method_name
      # @return [[String, Integer], String]
      def method?(klass, method_name)
        source_location(klass.method(method_name))
      end

      # @param [Object] klass
      # @param [Symbol, String] method_name
      # @return [[String, Integer], String]
      def instance_method?(klass, method_name)
        source_location(klass.instance_method(method_name))
      end

      def methods?(klass, method_name)
        via_extractor?(:method, klass, method_name)
      end

      def instance_methods?(klass, method_name)
        via_extractor?(:method, klass, method_name)
      end

      # @param [Class] klass
      # @return [[String, Integer], String]
      def class?(klass)
        defined_methods(klass)
          .group_by { |sl| sl[0] }
          .map do |file, sls|
            lines = sls.map { |sl| sl[1] }

            {
              file: file,
              count: lines.size,
              line: lines.min,
            }
          end # rubocop:disable Style/MultilineBlockChain
          .sort_by { |fc| fc[:count] }
          .map { |fc| [fc[:file], fc[:line]] }
      end

      # Raises ArgumentError if klass does not have any Ruby methods defined in it.
      def class_primarily?(klass)
        source_locations = class?(klass)
        if source_locations.empty?
          methods = defined_methods(klass)
          msg = if methods.empty?
                  "#{klass} has no methods"
                else
                  "#{klass} only has built-in methods (#{methods.size} in total)"
                end

          raise ::ArgumentError, msg
        end
        source_locations[0]
      end

      private

      # @param [Method] method
      # @return [[String, Integer], String]
      def source_location(method)
        method.source_location || (
          method.to_s =~ /: (.*)>/
          Regexp.last_match(1)
        )
      end

      def via_extractor?(extractor, klass, method_name)
        klass.ancestors
             .map do |ancestor|
               method = ancestor.send(extractor, method_name)
               source_location(method) if method.owner == ancestor
             end
             .compact
      end

      # @return [Array<Method>]
      def defined_methods(klass)
        methods = klass.methods(false).map { |m| klass.method(m) } +
                  klass.instance_methods(false).map { |m| klass.instance_method(m) }
        methods
          .map(&:source_location)
          .compact
      end
    end
  end

  # @param [Object, Class] klass
  # @param [String, Symbol] method
  # @return [[String, Integer], String]
  def self.where_is(klass, method = nil)
    if method
      begin
        Where.instance_method?(klass, method)
      rescue NameError
        Where.method?(klass, method)
      end
    else
      Where.class_primarily?(klass)
    end
  end
end
