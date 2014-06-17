module HTTP
  LINE_BREAK = "\r\n"
  CONTENT_LENGTH = 'CONTENT-LENGTH'
  CONTENT_TYPE = 'CONTENT-TYPE'

  class Servlet
    def do_GET(req, res); self.do(req, res); end
    def do_POST(req, res); self.do(req, res); end
    def do(req, res); raise NotImplementedError.new; end
  end

  class Request
    attr_reader :uri

    def initialize client
      @data = {}
      @http_method, @uri, @protocol = '', '', ''

      while line = client.gets
        break if line == LINE_BREAK
        add line
      end

      add_post_data(client)
    end

    def [](key); @data[key]; end

    def content_length
      if @data.has_key? CONTENT_LENGTH
        @data[CONTENT_LENGTH]
      else
        0
      end
    end

    def content_type
      if @data.has_key? CONTENT_TYPE
        @data[CONTENT_TYPE]
      else
        0
      end
    end

    def post?; @http_method == 'POST'; end
    def get?; @http_method == 'GET'; end

    private

    def add line
      t = line.strip
      param = t.split(' ')
      case param[0].upcase
      when 'GET'
        set_http_method(t)
      when 'POST'
        set_http_method(t)
      else
        # request header
        request_header_line = t.split(' ')
        request_header_line.map {|x| x.strip}
        key = request_header_line[0].sub(':', '').upcase
        value = request_header_line[1..-1].join
        @data[key] = value.split(',')
      end
    end

    def add_post_data client
      client.read(content_length) unless content_length == 0
    end
    
    def set_http_method line
      @http_method, @uri, @protocol = line.split(' ')
      @http_method = @http_method.upcase
    end
  end

  class Response
    attr_reader :body

    def initialize
      @header = {}
      @body = ''
      @header['Content-Type'] = ['text/html; charset=utf-8']
    end

    def []=(key, value); @header[key] = value; end
    def body=(content); @body = content; end
    def header
      @header.merge({'Content-Length' => [@body.length]}) 
    end
  end

  class Server
    def initialize(port)
      @port = port
      @server = nil
      @servlets = {}
    end

    def mount uri, servlet
      raise ArgumentError.new("URI '#{uri}' already mounted.") if @servlets.has_key? uri
      @servlets[uri] = servlet
    end

    def start
      @server = TCPServer.new(@port)
      while c = @server.accept
        res = Response.new
        req = Request.new(c)
        begin
          code = "200 OK"
          if @servlets[req.uri].nil?
            # No Servlet available
            code = "404 Not Found"
            if @servlets[404].nil?
              res.body = 'Not found'
              res['Content-Type'] = ['text/plain']
            else
              servlet = @servlets[404].new
              servlet.do(req, res)
            end
          else
            # Instancing Servlet and choosing HTTP Method
            begin
              servlet = @servlets[req.uri].new
              if req.get?
                servlet.do_GET(req, res)
              elsif req.post?
                servlet.do_POST(req, res)
              end
            rescue Exception => e
              # An Error occured during executing the Servlet
              code = '500 Internal Server Error'
              if @servlets[500].nil?
                res.body = <<TEXT
Internal Server Error

Error: #{e.message}
Backtrace:
  #{e.backtrace.join("\r\n  ")}
TEXT
                res['Content-Type'] = ['text/plain']
              else
                servlet = @servlets[500].new
                servlet.do(req, res)
              end
            end
          end

          c.print "HTTP/1.1 #{code}#{LINE_BREAK}"
          c.print res.header.map {|v| "#{v[0]}: #{v[1].join(', ')}"}.join(LINE_BREAK)
          c.print LINE_BREAK * 2
          c.print res.body
        ensure
          c.close
        end
      end
    end

    def shutdown; @server.close; end
  end
end
