require_relative "../spec_helper"
require 'json'

CONFIG.urls_that_should_redirect.each do |url|
  describe "https://#{url}" do
    let(:response) { get_https_response("https://#{url}/#{PAGE}") }
    it_should_redirect_to_secure_url.call
  end
end

CONFIG.urls_that_should_load_secure_page.each do |url|
  describe "https://#{url}" do
    let(:response) { get_https_response("https://#{url}/#{PAGE}") }
    it_should_be_pingable.call
  end
end


(CONFIG.urls_that_should_redirect + CONFIG.urls_that_should_load_secure_page).each do |url|
  describe "http://#{url}" do
    let(:response) { get_http_response("http://#{url}/#{PAGE}") }
    it_should_redirect_to_secure_url.call
  end
end

CONFIG.urls_that_should_load_page_with_non_matching_ssl_certificates.each do |url|
  describe "https://#{url}" do
    let(:response) { get_https_response("https://#{url}/#{PAGE}", false) }
    it_should_be_pingable.call
  end
end

CONFIG.urls_that_should_load_insecure_page.each do |url|
  describe "http://#{url}" do
    let(:response) { get_http_response("http://#{url}/#{PAGE}") }
    it_should_be_pingable.call
  end
end
