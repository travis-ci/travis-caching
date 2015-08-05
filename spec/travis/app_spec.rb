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
      # payload with no time stamps
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ0ZXN0X2p3dF9pc3N1ZXIiLCJwYXlsb2FkIjp7InNsdWciOiJ0cmF2aXMtY2kvdHJhdmlzLWNpIiwiYnJhbmNoIjoibWFzdGVyIiwibGFuZ3VhZ2UiOiJydWJ5IiwicHVsbC1yZXF1ZXN0IjpmYWxzZX19.3gLXlo_YrvS8c2YBNV7zPZ8mz2hyuhU7MMNSBBH5mlM'
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
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmb29iYXIiLCJwYXlsb2FkIjp7InNsdWciOiJ0cmF2aXMtY2kvdHJhdmlzLWNpIiwiYnJhbmNoIjoibWFzdGVyIiwibGFuZ3VhZ2UiOiJydWJ5IiwicHVsbC1yZXF1ZXN0IjpmYWxzZX19.pkjP4Gb9W1OCIvXjvfs8U5dOno8pfb2OnQ070Jlq1So'
      }

      it 'returns status 500' do
        response = get "/cache?token=#{hs256_token}"
        expect(response.status).to be == 500
      end
    end

    context 'when token is signed with different algorithm' do
      let(:rs256_token) {
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJkYXRhIjoidGVzdCJ9.p0L6b_ueixKXCbODyFqrgvECtuNJl1V5fBFfm8esYC1-Kv7pxo6_aQJumiz2LdH5Lz_tHfFxHTHOsIgUswm_0a1xcUf0rjpQkAGGFsj9gE9Bbl35SpSf_LBwL-WifQni5MD8lw8MC8y2LBcrrloJUqqW4rsZyMlRkhyBxM_tgy_gjRWRjjg2FpXbt-RxWTSfkqzcRAQj1Pcrh1zromm16jUoJg3wyWlelj3UEJwt21bAoaD3c0l4b7KKgGDMv-T-RGu0bvtHEh-RXsfY3MFOTJ1ErL3IxnH4Pec9XfxcADQWxLmO2_0NIpE0dPVliuFxULa0aRydYqm9BWQW3XsIhQ'
      }

      it 'returns status 500' do
        response = get "/cache?token=#{rs256_token}"
        expect(response.status).to be == 500
      end
    end
  end
end
