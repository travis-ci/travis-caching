require 'travis/caching/app'

describe Travis::Caching::App, :include_sinatra_helpers do

  before(:each) do
    set_app described_class.new
    ENV['TRAVIS_JWT_SECRET'] = 'superduper'
    ENV['TRAVIS_JWT_ISSUER'] = 'test_jwt_issuer'
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
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ0ZXN0X2p3dF9pc3N1ZXIiLCJwYXlsb2FkIjp7InNsdWciOiJ0cmF2aXMtY2kvdHJhdmlzLWNpIiwiYnJhbmNoIjoibWFzdGVyIiwibGFuZ3VhZ2UiOiJydWJ5IiwicHVsbC1yZXF1ZXN0IjpmYWxzZX19.3gLXlo_YrvS8c2YBNV7zPZ8mz2hyuhU7MMNSBBH5mlM'
    }
    let(:payload) {
      {
        'iss' => ENV["TRAVIS_JWT_ISSUER"],
        'payload' => {
          'slug' => 'travis-ci/travis-ci',
          'branch' => 'master',
          'language' => 'ruby',
          'pull-request' => false
        }
      }
    }

    it 'decodes payload correctly' do
      response = get "/cache?token=#{token}"
      expect(response.status).to be == 200
      expect(JSON.parse(response.body)).to eq(payload)
    end

    context 'with token with incorrect issuer' do
      let(:token) {
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmb29iYXIiLCJwYXlsb2FkIjp7InNsdWciOiJ0cmF2aXMtY2kvdHJhdmlzLWNpIiwiYnJhbmNoIjoibWFzdGVyIiwibGFuZ3VhZ2UiOiJydWJ5IiwicHVsbC1yZXF1ZXN0IjpmYWxzZX19.pkjP4Gb9W1OCIvXjvfs8U5dOno8pfb2OnQ070Jlq1So'
      }

      it 'returns status 500' do
        response = get "/cache?token=#{token}"
        expect(response.status).to be == 500
      end
    end
  end
end
