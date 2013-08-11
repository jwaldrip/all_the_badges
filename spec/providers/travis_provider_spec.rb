require 'spec_helper'

describe TravisProvider, vcr: github_cassette do
  include_context 'provider stub'
end