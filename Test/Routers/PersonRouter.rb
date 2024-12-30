# frozen_string_literal: true

require_relative '../../lib/TeleRuby/router'
require_relative '../../lib/TeleRuby/http_response'

$Prouter = Router.new

# Route 1: Static Route
$Prouter.get("/") do |_env|
  HTTPResponse.new(200, { message: "Static People Route!" })
end

# Route 2: Dynamic Route
$Prouter.get("/${id:int}") do |env|
  id = env["url_params"]["id"]
  HTTPResponse.new(200, { message: "Dynamic People Route!", id: id })
end

# Route 3: Query Parameters - Valid
$Prouter.get("/query/validate", accepted_queries: ["query1", "query2"]) do |env|
  query = env["query_params"]
  HTTPResponse.new(200, { message: "Valid Query Parameters!", query1: query["query1"], query2: query["query2"] })
end

# Route 4: POST Body - Valid
class AcceptedBody
  attr_accessor :body1, :body2
end

$Prouter.post("/body/validate", accepted_body: AcceptedBody) do |env|
  body = env["parsed_body"]
  HTTPResponse.new(200, { message: "Valid Body Parameters!", body1: body["body1"], body2: body["body2"] })
end

# Route 5: POST Body - Missing Fields
$Prouter.post("/body/invalid") do |env|
  body = env["parsed_body"]
  if body["body1"]
    HTTPResponse.new(400, { error: "Missing Fields in Body" })
  else
    HTTPResponse.new(400, { error: "Invalid Body Parameters" })
  end
end

# Route 6: Route that does not return an HTTPResponse
$Prouter.get("/noresponse") do |_env|
  "This is not an HTTPResponse"
end

# Route 7: Invalid Path
$Prouter.get("/unknown") do |_env|
  HTTPResponse.new(404, { error: "Not Found" })
end

# Complex Route 1: Dynamic Path with Query Validation
$Prouter.get("/search/${type:string}", accepted_queries: ["q"]) do |env|
  type = env["url_params"]["type"]
  query = env["query_params"]
  if query["q"]
    HTTPResponse.new(200, { message: "Search Successful", type: type, query: query["q"] })
  else
    HTTPResponse.new(400, { error: "Missing Search Query" })
  end
end

# Complex Route 2: Dynamic Path with Query and Body Validation
class UserBody
  attr_accessor :name, :age
end

$Prouter.post("/user/${id:int}", accepted_queries: ["active"], accepted_body: UserBody) do |env|
  id = env["url_params"]["id"]
  query = env["query_params"]
  body = env["parsed_body"]

  if query["active"] && body["name"] && body["age"]
    HTTPResponse.new(200, { message: "User Updated Successfully", id: id, active: query["active"], name: body["name"], age: body["age"] })
  else
    HTTPResponse.new(400, { error: "Missing Query or Body Parameters" })
  end
end

# Complex Route 3: Query Validation with Optional Body
$Prouter.post("/update", accepted_queries: ["id"]) do |env|
  query = env["query_params"]
  body = env["parsed_body"]

  if query["id"]
    response = { message: "Update Received", id: query["id"] }
    response[:body] = body if body
    HTTPResponse.new(200, response)
  else
    HTTPResponse.new(400, { error: "Missing Query Parameter 'id'" })
  end
end

class AcceptedResponse
  attr_accessor :firstName, :lastName
end

$Prouter.get("/validate_response", accepted_response: AcceptedResponse) do |env|
  HTTPResponse.new("200", {firstName: "Bryan", lastName: "Ramirez"})
end

$Prouter.get("/validate_response2", accepted_response: AcceptedResponse) do |env|
  HTTPResponse.new("200", {firstNme: "Bryan", lastName: "Ramirez"})
end
