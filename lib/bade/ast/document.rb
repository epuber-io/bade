# frozen_string_literal: true

require_relative 'node'


module Bade
  module AST
    class Document
      # Root node of this document
      #
      # @return [Bade::Node]
      #
      attr_reader :root

      # Path to this document, but only if it is defined from file
      #
      # @return [String, nil]
      #
      attr_reader :file_path

      # @return [Array<Bade::Document>]
      #
      attr_reader :sub_documents

      # @param root [Bade::Node]
      #
      def initialize(root: Node.new(:root), file_path: nil)
        @root = root

        @file_path = file_path.dup.freeze unless file_path.nil?
        @sub_documents = []
      end

      def freeze
        super

        root.freeze
        sub_documents.freeze
        sub_documents.each(&:freeze)
      end

      # @param other [Bade::Document]
      #
      # @return [Bool]
      #
      def ==(other)
        return false unless other.is_a?(Document)

        root == other.root && sub_documents == other.sub_documents
      end
    end
  end
end
