require 'get/adapters/abstract_adapter'
require 'get/adapters/active_record'
require 'get/builders/base_builder'
require 'get/builders/ancestry_builder'
require 'get/builders/query_builder'
require 'get/core_extensions/string'
require 'get/entities/single'
require 'get/entities/collection'
require 'get/builders'
require 'get/configuration'
require 'get/db'
require 'get/entities'
require 'get/entity_factory'
require 'get/errors'
require 'get/run_methods'

module Get
  extend Get::Configuration

  ASK_CLASS_REGEX = /^(.*)(By|From)(.*)/


  class << self
    attr_writer :configuration

    def included(base)
      base.class_eval do
        extend ::Get::RunMethods
      end
    end

    def const_missing(name)
      return super(name) unless name.to_s.match(ASK_CLASS_REGEX)
      Builders.generate_class(name)
    end
  end

  def run
    run!
  rescue ::Get::Errors::Base, Get::Errors::RecordNotFound
  end

  def run!
    call
  rescue *Get.adapter.expected_errors => e
    raise ::Get::Errors::Base.new(e.message)
  end
end
