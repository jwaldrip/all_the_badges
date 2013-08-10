shared_context 'provider stub' do

  let(:attrs){}
  let(:methods){}
  subject(:provider) do
    repo = FactoryGirl.build(:repo, attrs || {})
    mock_methods = methods || {}
    mock_methods.each { |k,v| allow(repo).to receive(k).and_return(v) }
    described_class.new repo: repo
  end

  it 'should be a subclass of provider' do
    described_class.ancestors.should include Provider
  end

end