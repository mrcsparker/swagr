module Swagr
  class Service
    attr_accessor :path
    attr_accessor :verb
    attr_accessor :comment
    attr_accessor :function_name
    attr_accessor :parameters
    attr_accessor :retval

    def initialize(class_name, name, verb, properties)
      @class_name = class_name
      @path = name
      @verb = verb.capitalize
      @parameters = clean_parameters(properties)
      @retval = clean_retval(properties)
      @comment = clean_comment(properties)
      @function_name = properties['operationId'].capitalize_first
    end

    def to_s
      params = @parameters.map { |v| v.to_s }.join(', ')

      o = []

      o << ''
      o << @comment
      o << "func (self #{@class_name}) #{@function_name}(#{params})(#{@retval}) {"
      o << "s := api.Setup()"
      if @retval != ""
        o << "res := #{@retval}{}"
      else
        o << "res := struct{}{}"
      end
      o << "url := \"http://localhost:8080/nifi-api#{@path}\""
      o << "resp, err := s.#{@verb}(url, nil, &res, nil)"
      o << 'if err != nil {'
      o << '        log.Fatal(err)'
      o << '}'
      o << ''
      o << 'if resp.Status() != 200 {'
      o << '        fmt.Println(res)'
      o << '}'
      o << ''
      if @retval != ""
        o << 'return res'
      end
      o << '}'
      o << ''

      o.join("\n")
    end

    private

    def clean_comment(properties)

      o = []
      o << '/**'
      o << " * #{properties['summary']}"
      o << ' *'
      o << " * #{properties['description']}" if properties['description'] != ""
      o << ' *'
      o << " * Tags: #{properties['tags']}"
      o << ' *'

      @parameters.each do |parameter|
        o << " * @param #{parameter.name} #{parameter.comment}"
      end

      o << " * @return #{@retval}"

      o << ' */'
      o.join("\n")
    end

    def clean_parameters(properties)
      return "" unless properties['parameters']

      c = properties['parameters']

      params = []

      c.each do |item|

        parameter = Parameter.new
        parameter.name = item["name"].dash_camelize
        parameter.type = item["type"]
        parameter.comment = item["description"]

        if parameter.type == "ref"
          parameter.type = "string"
        end

        if parameter.type == "boolean"
          parameter.type = "bool"
        end

        if parameter.type == "integer"
          parameter.type = "int"
        end

        if item["schema"] && item["schema"]["$ref"]
          parameter.type = "model.#{item["schema"]["$ref"].split("/")[2]}"
        end

        params << parameter
      end

      params
    end

    def clean_retval(properties)
      r = ""

      if properties["responses"]["200"] && properties["responses"]["200"]["schema"]
        ret = properties["responses"]["200"]["schema"]
        if ret["$ref"]
          r = "model.#{ret["$ref"].split("/")[2]}"
        elsif ret["type"]
          r = ret["type"]
        end
      end

      r
    end
  end
end
