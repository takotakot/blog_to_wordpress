require 'rails_helper'

RSpec.describe BlogHelper, type: :helper do
  describe 'is_internal_uri' do
    it 'can distinguish internal/external uris' do
      expect(is_internal_uri('http://www.' + Rails.application.credentials.blog_domain + '/')).to be true
      expect(is_internal_uri('http://www.' + Rails.application.credentials.blog_domain + '/index/')).to be true
      expect(is_internal_uri('http://www.' + Rails.application.credentials.blog_domain + '/file/dir/01.jpg')).to be true
      expect(is_internal_uri('http://subdomain.' + Rails.application.credentials.blog_domain + '/')).to be true
      expect(is_internal_uri('http://example.com/')).to be false
      expect(is_internal_uri('https://example.com/example')).to be false
    end
  end
end
