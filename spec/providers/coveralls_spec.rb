require 'spec_helper'

describe Coveralls, vcr: github_cassette do
  include_context 'provider stub'
end