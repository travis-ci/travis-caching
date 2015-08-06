require 'travis/caching/backend/s3'

describe Travis::Caching::Backend::S3 do
  let(:config) { Travis.config.backend.s3 }

  let(:subject) {
    described_class.new( config )
  }

  let(:payload) {
    {
      'repo_slug' => 'travis-ci/travis-ci',
      'repo_id' => 123456,
      'branch' => 'master',
      'cache_slug' => 'cache--rvm-default--gemfile-Gemfile',
    }
  }

  let(:url_regexp) {
    region = config.region == 'us-east-1' ? 's3' : "s3-#{config.region}"
    # Note that we do not exactly verify the AWS API signature itself
    Regexp.new "https://#{config.bucket}\.#{region}\.amazonaws\.com/#{payload['repo_id']}/#{payload['branch']}/#{payload['cache_slug']}\.tgz\\?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=#{config.id}%2F\\d{8}%2F#{config.region}%2Fs3%2Faws4_request&X-Amz-Date=\\d{8}T\\d{6}Z&X-Amz-Expires=#{config.expires}&X-Amz-Signature=\[a-f0-9\]\+&X-Amz-SignedHeaders=host"
  }

  describe '#url_for' do
    it 'retruns url that matches expected regexp' do
      expect(subject.url_for(payload.merge({'verb' => 'GET'})).to_s).to match url_regexp
    end
  end
end