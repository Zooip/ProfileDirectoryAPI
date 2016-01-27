class ResponseTimer

  #Use to append  

  def initialize(app)
    @app = app
  end
  
  def call(env)
    dup._call(env)
  end

  def _call(env)
    @start = Time.now
    @status, @headers, @response = @app.call(env)
    @stop = Time.now
    if @headers["Content-Type"] =~ /^application\/json/ and @headers["X-Debug-Time"] == "true"
      obj = JSON.parse(@response.body)
      obj["debug"]||=Hash.new
      obj["debug"]["execution_time"]="#{@stop-@start}"
      @res_body= obj.to_json
      @headers["Content-Length"] = Rack::Utils.bytesize(@res_body).to_s
    else
      @res_body=@response.body
    end

    

    [@status, @headers, self]
  end

  def body
    @res_body.to_s
  end

  def each(&block)
    block.call(body)
  end


end