require 'rspec'
require 'net/http'
require 'json'
require 'yaml'

PAGE = 'assets/ping.json'

class Configuration
  ATTRIBUTES = [:urls_that_should_redirect, :redirect_destination, :urls_that_should_load_secure_page, :urls_that_should_load_page_with_non_matching_ssl_certificates, :urls_that_should_load_insecure_page]
  attr_reader *ATTRIBUTES
  def initialize
    config = YAML.load File.open('config.yml')
    ATTRIBUTES.each { |attr| instance_variable_set("@#{attr}", config[attr.to_s]) }
    @urls_that_should_load_secure_page += [redirect_destination]
  end
end

CONFIG = Configuration.new

def get_http_response(uri)
  uri = URI.escape(uri)
  url = URI.parse(uri)
  http = Net::HTTP.new(url.host, url.port)
  yield http if block_given?
  http.request(Net::HTTP::Get.new(uri))
end

def get_https_response(uri, verify_peer=true)
  get_http_response(uri) do |http|
    http.use_ssl = true
    http.verify_mode = verify_peer ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
  end
end

def it_should_be_pingable
  proc{
    let(:body) { JSON.parse(response.body) }
    it "should be ping-able" do
      response.should be_a(Net::HTTPOK)
      body.should == { 'status' => 'ok' }
    end
  }
end

def it_should_redirect_to_secure_url
  proc{
    it "should redirect to secure site" do
      response.should be_a(Net::HTTPMovedPermanently)
      response.header['location'].should == "https://#{CONFIG.redirect_destination}/#{PAGE}"
    end
  }
end

RSpec.configure do |config|
  config.order = :random
end
