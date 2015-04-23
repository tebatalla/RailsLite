# Rails Lite!

A lite version of Rails. Features include:
- ActiveRecord Lite! Query a database and create associations with ActiveRecord like methods
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
Require the following files in order to inherit controller actions and model actions respectively
```ruby
require_relative '../lib/controller_base'
require_relative '../ActiveRecordLite/lib/active_record_lite'
```
Use [db_connection.rb](./ActiveRecordLite/lib/db_connection.rb) to create a database connection. `db_connection.rb` is set up to use sqllite3. Simply replace the cat names to create a db.
[cats.sql](./ActiveRecordLite/cats.sql) is a seed file you can use to seed a sample database (of cats).

## Using Rails Lite

Create ActiveRecordLite classes by inheriting from the `ActiveRecordLite` Class. You must call `finalize!` in order to define column methods
```ruby
class Foo < ActiveRecordLite
  
  finalize!
end
```
`ActiveRecordLite` uses meta-programming to create methods based on the column names of your tables. So, if you have a column named `name`, calling `#name` on an `ActiveRecordLite` object will return the name value. Other methods include:
- `#find`
- `#all`
- `#attribute_values`
- `#update`
- `#save`
- `#where`
- `#belongs_to`
- `#has_many`
- `#has_one_through`

Create controller classes by inheriting from `ControllerBase`
```ruby
class FooController < ControllerBase
  def index
    @foo = Foo.all
    render index
  end
end
```
[Session](./lib/session.rb) and [flash](./lib/flash.rb) functionality available.

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
