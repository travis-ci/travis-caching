require 'travis/caching/app'

describe Travis::Caching::App, :include_sinatra_helpers do

  let(:payload) {
    {
      'iss' => Travis.config.jwt.issuer,
      'exp' => Time.now.to_i + 4 * 60,
      'iat' => Time.now.to_i,
      'payload' => {
        'repo_slug' => 'travis-ci/travis-ci',
        'repo_id' => 123456,
        'branch' => 'master',
        'cache_slug' => 'cache--rvm-default--gemfile-Gemfile',
      }
    }
  }

  before(:each) do
    set_app described_class.new
    header('Content-Type', 'application/json')
  end

  describe '/uptime' do
    it 'returns 204' do
      response = get '/uptime'
      expect(response.status).to be == 204
    end
  end

  describe 'GET /cache' do
    let(:hs256_token) {
      JWT.encode payload, Travis.config.jwt.secret, 'HS256'
    }

    it 'decodes payload correctly' do
      get "/cache?token=#{hs256_token}"
      expect(last_response).to be_redirect
      # we do not test where it redirects to
      # it is tested by backend's specs
    end

    context 'with token with incorrect issuer' do
      let(:hs256_token) {
        pl = payload.dup
        pl["iss"] = "foobar"
        JWT.encode pl, Travis.config.jwt.secret, 'HS256'
      }

      it 'returns status 500' do
        get "/cache?token=#{hs256_token}"
        expect(last_response.status).to be == 500
      end
    end

    context 'when token is signed with different algorithm' do
      let(:rs256_token) {
        JWT.encode payload, OpenSSL::PKey::RSA.generate(2048), 'RS256'
      }

      it 'returns status 500' do
        get "/cache?token=#{rs256_token}"
        expect(last_response.status).to be == 500
      end
    end
  end

  describe 'PUT /cache' do
    let(:hs256_token) {
      JWT.encode payload, Travis.config.jwt.secret, 'HS256'
    }

    it 'decodes payload correctly' do
      put "/cache?token=#{hs256_token}"
      expect(last_response).to be_redirect
      # we do not test where it redirects to
      # it is tested by backend's specs
    end

    context 'with token with incorrect issuer' do
      let(:hs256_token) {
        pl = payload.dup
        pl["iss"] = "foobar"
        JWT.encode pl, Travis.config.jwt.secret, 'HS256'
      }

      it 'returns status 500' do
        put "/cache?token=#{hs256_token}"
        expect(last_response.status).to be == 500
      end
    end

    context 'when token is signed with different algorithm' do
      let(:rs256_token) {
        JWT.encode payload, OpenSSL::PKey::RSA.generate(2048), 'RS256'
      }

      it 'returns status 500' do
        put "/cache?token=#{rs256_token}"
        expect(last_response.status).to be == 500
      end
    end
  end
end
