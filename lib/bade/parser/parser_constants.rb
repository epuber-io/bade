# frozen_string_literal: true


module Bade
  require_relative '../parser'

  class Parser
    WORD_RE = ''.respond_to?(:encoding) ? '\p{Word}' : '\w'
    NAME_RE_STRING = "(#{WORD_RE}(?:#{WORD_RE}|:|-|_)*)".freeze

    ATTR_NAME_RE_STRING = "\\A\\s*#{NAME_RE_STRING}".freeze
    CODE_ATTR_RE = /#{ATTR_NAME_RE_STRING}\s*&?:\s*/.freeze

    TAG_RE = /\A#{NAME_RE_STRING}/.freeze
    CLASS_TAG_RE = /\A\.#{NAME_RE_STRING}/.freeze
    ID_TAG_RE = /\A##{NAME_RE_STRING}/.freeze
  end
end
