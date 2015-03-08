
require_relative 'node'


module Bade
  class Document
    # Root node of this document
    #
    # @return [Bade::Node]
    #
    attr_accessor :root

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
    def initialize(root: nil, file_path: nil)
      @root = root || Node.new(:root)
      @root.parent = self

      @file_path = file_path
      @sub_documents = []
    end
  end
end
