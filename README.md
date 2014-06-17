mruby-mrick
===========

## Usage

```ruby
s = HTTP::Server.new 80

class IndexServlet < HTTP::Servlet
  def do_GET(req, res)
    res['Content-Type'] = ['text/html; charset=utf-8']
    res.body = "Hello World"
  end
end
class NotFoundServlet < HTTP::Servlet
  def do(req, res)
    res['Content-Type'] = ['text/html; charset=utf-8']
    res.body = "Not found"
  end
end

s.mount(404, NotFoundServlet)
s.mount('/', IndexServlet)
s.start
```
