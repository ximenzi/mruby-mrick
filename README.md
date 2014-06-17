mruby-mrick
===========

Pure Ruby Webserver GEM for mruby.

**very alpha!!**

## Features

* GET HTTP Method
* POST HTTP Method
* Servlet Container

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

## License

The MIT License (MIT)

Copyright (c) 2014 Daniel Bovensiepen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
