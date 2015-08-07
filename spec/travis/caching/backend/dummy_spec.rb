require 'travis/caching/backend'

module Travis::Caching::Backend
  class Dummy < Base
  end
end

describe Travis::Caching::Backend::Dummy do
  let(:subject) {
    described_class.new( nil )
  }

  describe 'unimplemented #url_for' do
    it 'raises RuntimeError' do
      expect { subject.url_for( Object.new ) }.to raise_error RuntimeError
    end
  end
end
