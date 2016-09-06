module Swagr
  class Parameter
    attr_accessor :name
    attr_accessor :type
    attr_accessor :comment

    def to_s
      "#{name} #{type}"
    end
  end
end
