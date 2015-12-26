# frozen_string_literal: true

class Object
  def self.attr_forw_accessor(name, forw_name)
    define_method(name) {
      self.send(forw_name)
    }
    define_method(name.to_s + '=') { |*args|
      self.send(forw_name.to_s + '=', *args)
    }
  end
end
