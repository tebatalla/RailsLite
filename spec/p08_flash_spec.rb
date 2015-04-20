require 'webrick'
require 'flash'
require 'controller_base'

describe Flash do
  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cook) { WEBrick::Cookie.new('_rails_lite_app_flash_flash', { xyz: 'abc' }.to_json) }

  describe "#store_flash" do
    context "without cookies in request" do
      before(:each) do
        flash = Flash.new(req)
        flash['first_key'] = 'first_val'
        flash.store_flash(res)
      end

      it "adds new cookie with '_rails_lite_app_flash' name to response" do
        cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
        cookie.should_not be_nil
      end

      it "stores the cookie in json format" do
        cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
        JSON.parse(cookie.value).should be_instance_of(Hash)
      end
    end

    context "with cookies in request" do
      before(:each) do
        cook = WEBrick::Cookie.new('_rails_lite_app_flash', { pho: "soup" }.to_json)
        req.cookies << cook
      end

      it "reads the pre-existing cookie data into hash" do
        flash = Flash.new(req)
        JSON.parse(flash.cookie.value)['pho'].should == 'soup'
      end
    end
  end
end

describe ControllerBase do
  before(:all) do
    class CatsController < ControllerBase
    end
  end
  after(:all) { Object.send(:remove_const, "CatsController") }

  let(:req) { WEBrick::HTTPRequest.new(Logger: nil) }
  let(:res) { WEBrick::HTTPResponse.new(HTTPVersion: '1.0') }
  let(:cats_controller) { CatsController.new(req, res) }

  describe "#flash" do
    it "returns a flash instance" do
      expect(cats_controller.flash).to be_a(Flash)
    end

  end

  shared_examples_for "storing flash data" do
    it "should store the flash data and get rid of it on next request" do
      cats_controller.flash['test_key'] = 'test_value'
      cats_controller.send(method, *args)
      cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
      h = JSON.parse(cookie.value)
      expect(h['test_key']).to eq('test_value')
      new_req = WEBrick::HTTPRequest.new(Logger: nil)
      new_res = WEBrick::HTTPResponse.new(HTTPVersion: '1.0')
      cats = CatsController.new(new_req, new_res)
      cats.send(method, *args)
      cookie = new_res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
      h = JSON.parse(cookie.value)
      expect(h['test_key']).to be_nil
    end
  end

  it "shows flash.now but doesn't store it" do
    req = WEBrick::HTTPRequest.new(Logger: nil)
    res = WEBrick::HTTPResponse.new(HTTPVersion: '1.0')
    cats_controller = CatsController.new(req, res)
    cats_controller.flash.now['test_key'] = 'test_value'
    cats_controller.send(:render_content, *['test', 'text/plain'])
    cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
    expect(cookie.expires).to be < (Time.now - 60)
    expect(cats_controller.flash.now['test_key']).to eq('test_value')
  end

  describe "#render_content" do
    let(:method) { :render_content }
    let(:args) { ['test', 'text/plain'] }
    include_examples "storing flash data"
  end

  describe "#redirect_to" do
    let(:method) { :redirect_to }
    let(:args) { ['http://appacademy.io'] }
    include_examples "storing flash data"
  end
end
