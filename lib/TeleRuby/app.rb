# frozen_string_literal: true
require 'puma'
require 'rack'
require 'json'

require_relative 'router'

class App
  def initialize
    @routers = {}
  end

  def add_router(path, router)
    @routers[path] = router
  end

  def call(env)
    # Use a Thread to handle the request asynchronously
    result = nil
    thread = Thread.new do
      result = handle_request(env)
    end
    thread.join # Ensure the thread completes before returning
    result # Return the result from the thread
  end


  def handle_request(env)
    begin
      if env["CONTENT_TYPE"] == "application/json"
        request_body = JSON.parse(env["rack.input"].read)
        env["parsed_body"] = request_body
      end

      query_params = Rack::Utils.parse_query(env["QUERY_STRING"])
      env["query_params"] = query_params

      full_path = env["PATH_INFO"]
      method = env["REQUEST_METHOD"].to_sym

      @routers.each do |base_path, router|
        if full_path.start_with?(base_path)
          sub_path = full_path.sub(base_path, "")
          return router.call(sub_path, method, env, full_path)
        end
      end

      json_response(404, { error: "Not Found" })
    rescue => e
      puts "[ERROR] #{e.message}"
      puts e.backtrace.join("\n")
      json_response(500, { error: "Internal Server Error" })
    end
  end


  def run
    puts "Starting Puma Server..."
    server = Puma::Server.new(self)

    server.add_tcp_listener('127.0.0.1', 3000) # Port setup

    trap(:INT) do
      puts "\nStopping the server..."
      server.stop
    end

    puts "Server successfully started."
    server.run
    server.thread.join # Ensure server blocks the main thread
  end

  private

  def json_response(status, data)
    [
      status,
      { 'Content-Type' => 'application/json' },
      [JSON.generate(data)]
    ]
  end
end
