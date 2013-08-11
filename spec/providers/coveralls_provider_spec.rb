require 'spec_helper'

describe CoverallsProvider, vcr: github_cassette do
  include_context 'provider stub'
end