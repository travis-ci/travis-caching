require 'spec_helper'
require 'travis/caching/app'

describe Travis::Caching::App, :include_sinatra_helpers do

  before(:each) do
    set_app described_class.new
    ENV['TRAVIS_JWT_SECRET'] = 'superduper'
    header('Content-Type', 'application/json')
  end

  describe '/uptime' do
    it 'returns 204' do
      response = get '/uptime'
      expect(response.status).to be == 204
    end
  end

  describe 'GET /cache' do
    let(:token) {
      # payload with no time stamps
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJUcmF2aXMgQ0ksIEdtYkgiLCJjb250ZXh0Ijp7InNsdWciOiJ0cmF2aXMtY2kvdHJhdmlzLWNpIiwiYnJhbmNoIjoibWFzdGVyIiwibGFuZ3VhZ2UiOiJydWJ5In19.FcN-ncXaziPZZHJectxTUkX2pjrIcQi9Tmcxugtrufo'
    }

    it 'decodes payload correctly' do
      response = get "/cache?token=#{token}"
      expect(response.status).to be == 200
    end
  end
end
