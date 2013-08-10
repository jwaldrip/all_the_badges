require 'spec_helper'

describe Travis, vcr: github_cassette do
  include_context 'provider stub'
end