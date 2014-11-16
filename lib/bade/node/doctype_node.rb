
require_relative 'base_node'

module Bade
  class DoctypeNode < Node

    # @return [String]
    #
    def xml_output
      case self.data
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
