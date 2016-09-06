module Swagr
  class String
    def capitalize_first
      "#{self[0].upcase}#{self[1..-1]}"
    end

    def dash_camelize
      o = []
      self.split('-').each_with_index do |c, i|
        if i > 0
          o << c.capitalize
        else
          o << c
        end
      end
      o.join
    end
  end
end
