require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'normalize_uri' do
    it 'normalizes uri' do
      uri1 = 'http://www.example.com/'
      expect(normalize_uri(uri1)).to eq(uri1)

      uri2 = 'http://www.example.com/path/abc (p) [2].jpg'
      uri2_normalized = 'http://www.example.com/path/abc%20(p)%20%5B2%5D.jpg'
      expect(normalize_uri(uri2)).to eq(uri2_normalized)

      # ref: https://webtan.impress.co.jp/e/2017/03/21/25304
      data_uri = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII='
      expect(normalize_uri(data_uri)).to eq(data_uri)

      uri3 = 'http://example.com/8･153.JPG'
      uri3 = 'http://example.com/8%EF%BD%A5153.JPG'
      expect(normalize_uri(uri3)).to eq(uri3)
    end
  end
end
