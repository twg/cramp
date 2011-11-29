require 'active_support'
require 'active_support/test_case'

module Cramp
  class TestCase < ::ActiveSupport::TestCase
    
    setup :create_request

    def create_request
      @request = Rack::MockRequest.new(app)
    end
    
    %w(get post put delete).each do |verb|
      define_method verb do |*args, &block|
        request(verb, *args, &block)
      end
      define_method "#{verb}_body" do |*args, &block|
        request_body(verb, *args, &block)
      end
      define_method "#{verb}_body_chunks" do |*args, &block|
        request_body_chunks(verb, *args, &block)
      end
    end
    
    def request(method, path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      headers = headers.merge('async.callback' => callback)

      EM.run do
        catch(:async) { @request.request(method, path, headers) }
      end
    end
    
    def request_body(method, path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      response_callback = proc {|response| response[-1].each {|chunk| callback.call(chunk) } }
      headers = headers.merge('async.callback' => response_callback)

      EM.run do
        catch(:async) { @request.request(method, path, headers) }
      end
    end

    def request_body_chunks(method, path, options = {}, headers = {}, &block)
      callback = options.delete(:callback) || block
      count = options.delete(:count) || 1

      stopping = false
      chunks = []

      request_body(method, path, options, headers) do |body_chunk|
        chunks << body_chunk unless stopping

        if chunks.count >= count
          stopping = true
          callback.call(chunks) if callback
          EM.next_tick { EM.stop }
        end
      end
    end

    def app
      raise "Please define a method called 'app' returning an async Rack Application"
    end

    def stop
      EM.stop
    end
  end
end