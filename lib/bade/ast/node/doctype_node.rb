# frozen_string_literal: true

require_relative '../node'


module Bade
  module AST
    class DoctypeNode < ValueNode
      # @return [String]
      #
      def xml_output
        case value
          when 'xml'
            '<?xml version="1.0" encoding="utf-8" ?>'

          when 'html'
            '<!DOCTYPE html>'

          else
            raise Parser::ParserInternalError 'Unknown doctype type'
        end
      end
    end
  end
end
