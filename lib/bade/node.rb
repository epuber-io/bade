
require_relative 'parser'
require_relative 'ruby_extensions/object'


module Bade
  class Node
    require_relative 'node/key_value_node'
    require_relative 'node/tag_node'
    require_relative 'node/mixin_node'
    require_relative 'node/doctype_node'

    # @return [Symbol]
    #
    attr_reader :type


    # @return [Int] line number
    #
    attr_accessor :lineno

    # @return [String]
    #
    attr_accessor :data


    # @return [Node]
    #
    attr_accessor :parent

    # @return [Array<Node>]
    #
    attr_accessor :childrens

    # @return [TrueClass, FalseClass]
    #
    attr_accessor :escaped

    # @param [Symbol] type
    # @param [Node] parent
    #
    def initialize(type, parent = nil)
      @type = type
      @childrens = []

      if parent
        parent << self
      end
    end

    # @param [Node] node
    #
    def << (node)
      node.parent = self
      @childrens << node

      self
    end





    # @return [Hash<Symbol, Class>]
    def self.registered_types
      @@registered_types ||= {}
    end

    # @param [Symbol] type
    # @param [Class] klass  registering class
    #
    def self.register_type(type, klass = self)
      raise StandardError, "Class #{klass} should be subclass of #{self}" unless klass <= Node

      registered_types[type] = klass
    end




    def self.create(type, parent)
      klass = registered_types[type]

      if klass.nil?
        raise Parser::ParserInternalError, "undefined node type #{type.inspect}"
      end

      klass.new(type, parent)
    end

  end

  Node.register_type :text
  Node.register_type :newline
  Node.register_type :ruby_code

  Node.register_type :comment
  Node.register_type :html_comment

  TagNode.register_type :tag
  KeyValueNode.register_type :tag_attribute

  Node.register_type :output

  Node.register_type :mixin_param
  Node.register_type :mixin_block_param
  Node.register_type :mixin_block

  MixinCallNode.register_type :mixin_call
  MixinDeclarationNode.register_type :mixin_declaration
  KeyValueNode.register_type :mixin_key_param

  DoctypeNode.register_type :doctype

  Node.register_type :import
end
