# Rails Lite!

A lite version of Rails. Features include:
- Template rendering and redirects
- Session cookies
- Route parameters
- A few RESTful routes by default (`:get, :post, :put, :delete`)

## Installation
Use `WEBrick` to start a simple server
```ruby
server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
```

Create controller classes by inheriting from `ControllerBase`
```ruby
class FooController < ControllerBase
  def index
    render index
  end
end
```

Use the `Router` class to create routes for your controllers
```ruby
router = Router.new
router.draw do
  get Regexp.new("^/foo$"), FooController, :index
end
```

Create views for your controller actions by creating views in `{controller_name}/{action}`, using ERB.
```html_ruby
<h1>Foos</h1>
<pre><%= @foos %></pre>
<a href="/foos/new">New foo!</a>
```
