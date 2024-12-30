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

```ruby
class App
  def initialize
    @routers = {}
  end

  def add_router(path, router)
    @routers[path] = router
  end

  def call(env)
    result = nil
    thread = Thread.new do
      result = handle_request(env)
    end
    thread.join
    result
  end

  def run
    server = Puma::Server.new(self)
    server.add_tcp_listener('127.0.0.1', 3000)
    server.run
  end
end
```

### `Router`
Handles route definitions and request matching. Supports dynamic routes, query validation, and request body validation.

#### Key Features:
- Define routes for `GET`, `POST`, `PUT`, and `DELETE` methods.
- Validate query parameters and request bodies.
- Support for dynamic route parameters with type constraints.
- Asynchronous request handling.

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

### Example
Below is an example demonstrating how to use the framework:

#### `Usage/Example.rb`
```ruby
require_relative '../lib/app'
require_relative '../lib/router'
require_relative '../lib/http_response'

router = Router.new

router.get('/greet/${name:string}') do |env|
  name = env["url_params"]["name"]
  HTTPResponse.new(200, { message: "Hello, #{name}!" })
end

app = App.new
app.add_router('/api', router)
app.run
```

### Features Explained

1. **Dynamic Routes**
   Routes can include dynamic segments with type constraints:

   ```ruby
   '/user/${id:int}'
   ```

   This matches paths like `/user/123` and validates that `id` is an integer.

2. **Query Parameters**
   Validate required query parameters:

   ```ruby
   router.get('/search', accepted_queries: ['q']) do |env|
     q = env['query_params']['q']
     HTTPResponse.new(200, { results: "Search results for #{q}" })
   end
   ```

3. **Request Body**
   Validate the structure of incoming JSON payloads:

   ```ruby
   router.post('/submit', accepted_body: { name: String, age: Integer }) do |env|
     body = env['parsed_body']
     HTTPResponse.new(200, { status: "Received data for #{body['name']}" })
   end
   ```

4. **Typed Responses**
   Ensure that the response conforms to an expected schema:

   ```ruby
   router.get('/info', accepted_response: MyResponseClass) do |_env|
     HTTPResponse.new(200, { info: "Sample info" })
   end
   ```

5. **Asynchronous Processing**
   Each request is processed in a new thread for non-blocking operations.

### Testing

#### `Usage/testfile.sh`
```bash
#!/bin/bash
curl -X GET "http://127.0.0.1:3000/api/greet/John"
curl -X GET "http://127.0.0.1:3000/api/search?q=example"
curl -X POST -H "Content-Type: application/json" -d '{"name": "Alice", "age": 30}' "http://127.0.0.1:3000/api/submit"
```

## Conclusion

This framework offers a clean, Ruby-based solution for building HTTP APIs, complete with dynamic routing, type validation, and asynchronous processing. By leveraging the power of Puma and Rack, it provides a high-performance and scalable foundation for your web applications.

