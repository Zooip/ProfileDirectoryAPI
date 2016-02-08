class CatchJsonParseErrors


  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue ActionDispatch::ParamsParser::ParseError => error
      if env['HTTP_ACCEPT'] =~ /^application\/vnd\.api\+json/
        error_output = "There was a problem in the JSON you submitted: #{error}"
        return [
          400, { "Content-Type" => "application/json" },
          [ { errors:[{code: 400, title: 'Unprocessable JSON', detail: error_output}] }.to_json ]
        ]
      else
       raise error
      end
    end
  end
end