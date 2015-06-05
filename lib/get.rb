require 'get/builders/base_builder'
require 'get/builders/ancestry_builder'
require 'get/builders/query_builder'
require 'get/builders'
require 'get/configuration'
require 'get/db'
require 'get/errors'
require 'get/parser'
require 'get/run_methods'
require 'horza'

module Get
  extend Get::Configuration

  GET_CLASS_REGEX = /^(.*)(By|From)(.*)/

  class << self
    attr_writer :configuration

    def included(base)
      base.class_eval do
        extend ::Get::RunMethods
      end
    end

    def const_missing(name)
      parser = ::Get::Parser.new(name)
      return super(name) unless parser.match?
      Builders.generate_class(name, parser.method)
    end
  end

  def run
    run!
  rescue ::Get::Errors::Base, Get::Errors::RecordNotFound
  end

  def run!
    call
  rescue *Get.adapter.expected_horza_errors => e
    raise ::Get::Errors::Base.new(e.message)
  end
end
