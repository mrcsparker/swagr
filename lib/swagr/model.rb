module Swagr
  class Model
    attr_accessor :name
    attr_accessor :attribute
    attr_accessor :model_items

    def initialize(name, properties)
      @model_items = []

      @name = name
      if properties["xml"]
        @attribute = properties["xml"]["name"]
      end

      generate_model_items(properties['properties'])
    end

    def to_s
      o = []
      o << 'package model'
      o << ''
      o << "// attribute: #{@attribute}" if @attribute
      o << "type #{@name} struct {"
      @model_items.each do |model_item|
        o << model_item.to_s
      end
      o << '}'
      o << "\n"

      o.join("\n")
    end

    private
    def generate_model_items(items)
      return [] unless items
      items.each do |name, properties|
        @model_items << ModelItem.new(name, properties)
      end
    end
  end
end
