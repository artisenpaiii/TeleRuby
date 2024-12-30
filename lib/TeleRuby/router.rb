# frozen_string_literal: true
require 'json'

class Router
  def initialize
    @routes = { GET: {}, POST: {}, PUT: {}, DELETE: {} }
  end

  def add_route(method, path, accepted_queries: nil, accepted_body: nil, accepted_response: nil, &block)
    @routes[method][path] = {
      accepted_queries: accepted_queries,
      accepted_body: accepted_body,
      accepted_response: accepted_response,
      handler: block
    }
  end

  def get(path, accepted_queries: nil, accepted_body: nil, accepted_response: nil, &block)
    add_route(:GET, path, accepted_queries: accepted_queries, accepted_body: accepted_body, accepted_response: accepted_response, &block)
  end

  def post(path, accepted_queries: nil, accepted_body: nil, accepted_response: nil, &block)
    add_route(:POST, path, accepted_queries: accepted_queries, accepted_body: accepted_body, accepted_response: accepted_response, &block)
  end

  def call(path, method, env, full_path)
    log_request(method, full_path)

    unless @routes.key?(method)
      log_response(405, "Method Not Allowed")
      return json_response(405, { error: "Method Not Allowed" })
    end

    @routes[method].each do |route_path, route|
      match = match_path(route_path, path)

      if match
        # If there's a match, extract URL parameters (if any)
        if match.is_a?(MatchData)
          env["url_params"] = match.named_captures || {}
        else
          env["url_params"] = {}
        end

        # Validate query parameters
        if route[:accepted_queries] && !validate_queries(route[:accepted_queries], env["query_params"])
          log_response(400, "Invalid Query Parameters")
          return json_response(400, { error: "Invalid Query Parameters" })
        end

        # Validate body parameters
        if route[:accepted_body] && !validate_body(route[:accepted_body], env["parsed_body"])
          log_response(400, "Invalid Body Parameters")
          return json_response(400, { error: "Invalid Body Parameters" })
        end

        # Call the handler block
        result = route[:handler].call(env)

        # Ensure result is an HTTPResponse and validate it
        if result.is_a?(HTTPResponse)
          if route[:accepted_response] && !validate_accepted_response(route[:accepted_response], result.body)
            log_response(500, "Invalid Response Structure")
            return json_response(500, { error: "Invalid Response Structure" })
          end

          log_response(result.status, result.body[0] || result.body[0])

          return result.to_a # Convert HTTPResponse to Rack-compatible response
        else
          log_response(500, "Handler did not return an HTTPResponse")
          return json_response(500, { error: "Handler must return an HTTPResponse" })
        end
      end
    end

    # If no match is found, return 404
    log_response(404, "Not Found")
    json_response(404, { error: "Not Found" })
  end

  private

  def json_response(status, data)
    [
      status,
      { 'Content-Type' => 'application/json' },
      [JSON.generate(data)]
    ]
  end

  def log_request(method, path)
    method_color = case method
                   when :GET then "\e[32m"  # Green for GET
                   when :POST then "\e[34m" # Blue for POST
                   when :PUT then "\e[33m"  # Yellow for PUT
                   when :DELETE then "\e[31m" # Red for DELETE
                   else "\e[37m" # White for others
                   end
    reset = "\e[0m"
    puts "#{method_color}[REQUEST] Method: #{method} | Path: #{path}#{reset}"
  end

  def log_response(status, reason)
    status_color = case status
                   when 200 then "\e[32m"  # Green for success
                   when 400 then "\e[33m"  # Yellow for client errors
                   when 404 then "\e[31m"  # Red for not found
                   when 405 then "\e[31m"  # Red for method not allowed
                   when 500 then "\e[35m"  # Magenta for server errors
                   else "\e[37m" # White for other statuses
                   end
    reset = "\e[0m"
    puts "#{status_color}[RESPONSE] Status: #{status} | Reason: #{reason}#{reset}"
  end

  def match_path(route_path, request_path)
    regex_path = route_path.gsub(/\$\{(\w+)(?::(\w+))?\}/) do |_match|
      param_name = Regexp.last_match(1)
      param_type = Regexp.last_match(2)

      # Handle different types
      case param_type
      when "int"
        "(?<#{param_name}>\\d+)" # Only digits
      when "string", nil
        "(?<#{param_name}>[^/]+)" # Default to any non-slash characters
      else
        raise "Unsupported type: #{param_type}"
      end
    end

    Regexp.new("^#{regex_path}$").match(request_path)
  end


  def validate_accepted_response(accepted_response_class, response_body)
    return false unless response_body.is_a?(Array) && response_body.first.is_a?(String)

    parsed_json = JSON.parse(response_body.first, symbolize_names: true)

    instance = accepted_response_class.new

    parsed_json.each do |key, value|
      return false unless instance.respond_to?("#{key}=")
    end

    true
  end




  def validate_queries(accepted_queries, query_params)
    # Ensure all required queries are present in the query_params
    accepted_queries.all? { |query| query_params.key?(query) }
  end


  def validate_body(accepted_body, parsed_body)

    accepted_body.instance_variables.all? do |var|
      parsed_body.key?(var.to_s.sub('@', ''))
    end
  end
end
