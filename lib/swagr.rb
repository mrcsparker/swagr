require 'json'
require 'pp'

require 'swagr/parameter'

module Swagr
  class Generator

    attr_accessor :models
    attr_accessor :services

    def initialize
      @models = []
      @services = {}
      @json = JSON.parse(File.read('swagger.json'))
    end

    def run
      generate_models
      write_models

      generate_services
      write_services
    end

    private
    def generate_models
      definitions = @json['definitions']
      definitions.each do |name, properties|
        @models << Model.new(name, properties)
      end

      @models
    end

    def generate_services

      paths = @json['paths']
      paths.each do |name, properties|
        base_name = name.split("/")[1]
        o = []
        base_name.split("-").each do |c|
          o << c.capitalize
        end
        class_name = o.join
        unless services[class_name]
          @services[class_name] = []
        end

        properties.each do |action, property|
          @services[class_name] << Service.new(class_name, name, action, property)
        end
      end
    end

    def write_models
      @models.each do |model|
        file_name = "model/#{model.name.downcase}.go"
        File.open(file_name, "w") do |f|
          f.write model.to_s
        end

        `gofmt -w #{file_name}`
      end
    end

    def write_services
      @services.each do |name, services|
        file_name = "service/#{name.downcase}.go"

        File.open(file_name, "w") do |f|
          o = []

          o << 'package service'

          o << 'import ('
          o << '"fmt"'
          o << '"github.com/mrcsparker/ifin/api"'
          o << '"github.com/mrcsparker/ifin/model"'
          o << '"log"'
          o << ')'

          o << ''

          o << "type #{name} struct {"
          o << '}'
          o << ''

          services.each do |service|
            o << service.to_s
          end

          f.write o.join("\n")
        end

        `gofmt -w #{file_name}`
      end
    end
  end
end

generator = Generator.new
generator.run
