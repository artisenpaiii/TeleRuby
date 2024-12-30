# frozen_string_literal: true

class HTTPResponse

  attr_accessor :status, :headers, :body

  def initialize(status, json)
    @status = status
    @headers = { 'Content-Type' => 'application/json' }
    @body = [JSON.generate(json)]
  end

  def to_a
    [@status, @headers, @body]
  end
end

