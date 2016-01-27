class PrettyJson
  def initialize(app)
    @app = app
  end

  
  def call(env)
    @status, @headers, @response = @app.call(env)
    if @headers["Content-Type"] =~ /^application\/json/
      obj = JSON.parse(@response.body)
      @pretty_str = JSON.pretty_unparse(obj)
      @headers["Content-Length"] = Rack::Utils.bytesize(@pretty_str).to_s
    end
    [@status, @headers, self]
  end

  def body
    @pretty_str.to_s
  end

  def each(&block)
      block.call(body)
  end
end