require 'travis/caching/app'

describe Travis::Caching::App, :include_sinatra_helpers do

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

    let(:payload) {
      {
        'iss' => Travis.config.jwt.issuer,
        'payload' => {
          'slug' => 'travis-ci/travis-ci',
          'branch' => 'master',
          'language' => 'ruby',
          'pull-request' => false
        }
      }
    }

    it 'decodes payload correctly' do
      response = get "/cache?token=#{hs256_token}"
      expect(response.status).to be == 200
      expect(JSON.parse(response.body)).to eq(payload)
    end

    context 'with token with incorrect issuer' do
      let(:hs256_token) {
        pl = payload.dup
        pl["iss"] = "foobar"
        JWT.encode pl, Travis.config.jwt.secret, 'HS256'
      }

      it 'returns status 500' do
        response = get "/cache?token=#{hs256_token}"
        expect(response.status).to be == 500
      end
    end

    context 'when token is signed with different algorithm' do
      let(:rs256_token) {
        JWT.encode payload, OpenSSL::PKey::RSA.generate(2048), 'RS256'
      }

      it 'returns status 500' do
        response = get "/cache?token=#{rs256_token}"
        expect(response.status).to be == 500
      end
    end
  end
end
