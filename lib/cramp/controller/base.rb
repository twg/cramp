module Cramp
  module Controller
    class Base
      ASYNC_RESPONSE = [-1, {}, []]

      DEFAULT_STATUS = 200
      DEFAULT_HEADERS =  { 'Content-Type' => 'text/html' }

      def self.call(env)
        controller = new(env).process
      end

      def self.set_default_response(status = 200, headers = DEFAULT_HEADERS)
        @@default_status = 200
        @@default_headers = headers
      end

      def self.default_status
        defined?(@@default_status) ? @@default_status : DEFAULT_STATUS
      end

      def self.default_headers
        defined?(@@default_headers) ? @@default_headers : DEFAULT_HEADERS
      end

      def initialize(env)
        @env = env
      end

      def process
        EM.next_tick { before_start }
        ASYNC_RESPONSE
      end

      def request
        @request ||= Rack::Request.new(@env)
      end

      def params
        @params ||= @env['usher.params']
      end

      def render(body)
        @body.call(body)
      end

      def send_initial_response(response_status, response_headers, response_body)
        EM.next_tick { @env['async.callback'].call [response_status, response_headers, response_body] }
      end

      def finish
        EM.next_tick { @body.succeed }
      end

      def before_start
        continue
      end

      def halt(status, headers = self.class.default_headers, halt_body = '')
        send_initial_response(status, headers, halt_body)
      end

      def continue
        init_async_body
        send_initial_response(self.class.default_status, self.class.default_headers, @body)

        EM.next_tick { start }
      end

      def init_async_body
        @body = Body.new
        @body.callback { on_finish }
        @body.errback { on_finish }
      end

      def on_finish
      end

    end
  end
end