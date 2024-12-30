# Own HTTP Server Framework

This project is a lightweight and customizable HTTP server framework built in Ruby, designed to work seamlessly with Puma. It provides robust tools for creating and managing web APIs, offering features such as route handling, dynamic parameters, query validation, typed responses, and JSON body parsing, all while processing requests asynchronously.

## Purpose

The goal of this project is to build an HTTP server framework similar to FastAPI but for Ruby, enabling developers to create web applications quickly and effectively.

## Technologies and Libraries

- **Ruby**: Core programming language for the framework.
- **Puma**: High-performance web server used to handle requests.
- **Rack**: Interface between web servers and web applications.
- **JSON**: Parsing and generating JSON responses.

## Implementation Overview

This framework consists of the following main components:

### `App`
The main class responsible for managing routers and handling requests asynchronously.

#### Key Features:
- Adds routers to the application.
- Handles incoming requests and delegates them to appropriate routers.
- Parses JSON bodies and query parameters.
- Generates JSON responses.
- Asynchronous request handling.

```ruby
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
```

### `Router`
Handles route definitions and request matching. Supports dynamic routes, query validation, and request body validation.

#### Key Features:
- Define routes for `GET`, `POST`, `PUT`, and `DELETE` methods.
- Validate query parameters and request bodies.
- Support for dynamic route parameters with type constraints.

```ruby
class Router
  def initialize
    @routes = { GET: {}, POST: {}, PUT: {}, DELETE: {} }
  end

  def get(path, accepted_queries: nil, accepted_body: nil, accepted_response: nil, &block)
    add_route(:GET, path, accepted_queries: accepted_queries, accepted_body: accepted_body, accepted_response: accepted_response, &block)
  end
end
```

### `HTTPResponse`
Encapsulates HTTP responses with status codes, headers, and JSON bodies.

#### Key Features:
- Generates structured responses for the client.
- Based on Rack return standard

```ruby
class HTTPResponse
  def initialize(status, json)
    @status = status
    @headers = { 'Content-Type' => 'application/json' }
    @body = [JSON.generate(json)]
  end

  def to_a
    [@status, @headers, @body]
  end
end
```

## Usage

## Conclusion

This framework offers a clean, Ruby-based solution for building HTTP APIs, complete with dynamic routing, type validation, and asynchronous processing. By leveraging the power of Puma and Rack, it provides a high-performance and scalable foundation for your web applications.

