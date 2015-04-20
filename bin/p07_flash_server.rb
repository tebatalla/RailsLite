require 'webrick'
require_relative '../lib/controller_base'
require 'byebug'

$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]

$toggle = false

class Statuses1Controller < ControllerBase
  def index
    statuses = $statuses.select do |s|
      s[:cat_id] == Integer(params[:cat_id])
    end

    render_content(statuses.to_s, "text/html")
  end
end

class Cats3Controller < ControllerBase
  def index
    flash[:errors] = ["whaaaat"] if $toggle
    render_content($cats.to_s, "text/html")
    $toggle = !$toggle
    # redirect_to('/cats/1/statuses')
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), Cats3Controller, :index
  get Regexp.new("^/cats/(?<cat_id>\\d+)/statuses$"), Statuses1Controller, :index
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
