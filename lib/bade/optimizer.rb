# frozen_string_literal: true


module Bade
  class Optimizer
    # @param [Bade::AST::Node] root_node
    #
    def initialize(root_node)
      @root_node = root_node

      @new_root = Marshal.load(Marshal.dump(root_node))
    end

    # @return [Bade::Node]
    #
    def optimize
      optimize_static_texts

      @root_node
    end

    def optimize_static_texts
      traverse(@root_node) do |tr_node|
        iterate(tr_node) do |node, previous_node, _parent|
          if previous_node && previous_node.type == :static_text && node.type == :static_text
            previous_node.value += node.value
            true
          end
        end
      end
    end

    # @param [Bade::AST::Node] node
    #
    def traverse(node, &block)
      yield node

      node.children.each do |subnode|
        traverse(subnode, &block)
      end
    end

    # @param [Bade::AST::Node] node
    #
    def iterate(node)
      previous = nil

      node.children.delete_if do |subnode|
        returned = yield subnode, previous, node

        previous = subnode unless returned

        returned
      end
    end
  end
end
