module Swagr
  class ModelItem
    attr_accessor :name
    attr_accessor :type
    attr_accessor :attribute
    attr_accessor :comment

    def initialize(name, properties)
      @name = name
      @type = clean_attribute(properties)
      @attribute = "`json:\"#{@name}\"`"
      @comment = clean_comment(properties)
    end

    def to_s
      o = []

      o << @name.capitalize_first
      o << @type
      o << @attribute
      o << @comment

      o.join(" ")
    end

    private

    def clean_comment(c)
      return if c['description'] == ""
      return if c['description'] == nil

      r = []

      r << "//"

      if c['readOnly'] && c['readOnly'] == true
        r << "[Read Only]"
      end

      r << c['description']

      r.join(" ")
    end

    def clean_attribute(c)
      if c["type"] == "string"
        'string'
      elsif c["type"] == "integer"
        gen_integer(c)
      elsif c["type"] == "number" && c["format"] == "double"
        'float64'
      elsif c["type"] == "array"
        gen_array(c)
      elsif c["type"] == "boolean"
        'bool'
      elsif c["type"] == "object"
        gen_object(c)
      elsif c["$ref"]
        gen_ref(c)
      else
        puts "NA: #{@name}: #{c}"
        ""
      end
    end

    def gen_integer(c)
      v = 'int'

      if c['format'] == 'int32'
        v = 'int32'
      end

      if c['format'] == 'int64'
        v = 'int64'
      end

      v
    end

    def gen_array(c)
      type = ""

      if c["items"]["$ref"]
        type = c["items"]["$ref"].split("/")[2]
      elsif c["items"]["type"] == "string"
        type = "string"
      end

      "[]#{type}"
    end

    def gen_ref(c)
      c["$ref"].split("/")[2]
    end

    def gen_object(c)

      type = "interface{}"
      if c['additionalProperties'] && c['additionalProperties']['$ref']
        type = c['additionalProperties']['$ref'].split("/")[2]
      elsif c['additionalProperties'] && c['additionalProperties']['type'] == 'string'
        type = 'string'
      elsif c['additionalProperties'] && c['additionalProperties']['type'] == 'integer'
        type = 'int'
      else
        p c
      end

      type
    end
  end
end
