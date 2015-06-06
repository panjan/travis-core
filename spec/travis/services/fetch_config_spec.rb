require 'spec_helper'

describe Travis::Services::FetchConfig do
  include Support::Redis
  include Support::ActiveRecord

  let(:body)      { { 'content' => ['foo: Foo'].pack('m') } }
  let(:repo)      { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:request)  { Factory(:request, :repository => repo) }
  let(:service)   { described_class.new(nil, request: request) }
  let(:result)    { service.run }
  let(:exception) { GH::Error.new }

  before :each do
    content_url = GH.full_url("repos/#{repo.owner_name}/#{repo.name}/contents/.travis.yml?ref=#{request.commit.commit}").to_s
    GH.stubs(:[]).with(content_url).returns(body)
  end

  describe 'config' do
    it 'returns a hash' do
      result.should be_a(Hash)
    end

    it 'yaml parses the response body if the response is successful' do
      result['foo'].should == 'Foo'
    end

    it "merges { '.result' => 'configured' } to the actual configuration" do
      result['.result'].should == 'configured'
    end

    it "returns { '.result' => 'not_found' } if a 404 is returned" do
      exception.stubs(info: { response_status: 404 })
      GH.stubs(:[]).raises(exception)
      result['.result'].should == 'not_found'
    end

    it "returns { '.result' => 'server_error' } if a 500 is returned" do
      exception.stubs(info: { response_status: 500 })
      GH.stubs(:[]).raises(exception)
      result['.result'].should == 'server_error'
    end

    it "returns { '.result' => 'parse_error' } if the .travis.yml is invalid" do
      GH.stubs(:[]).returns({ "content" => ["\tfoo: Foo"].pack("m") })
      result['.result'].should == 'parse_error'
    end

    it "returns the error message for an invalid .travis.yml file" do
      GH.stubs(:[]).returns({ "content" => ["\tfoo: Foo"].pack("m") })
      result[".result_message"].should match(/line 1 column 1/)
    end

    it "converts non-breaking spaces to normal spaces" do
      GH.stubs(:[]).returns({ "content" => ["foo:\n\xC2\xA0\xC2\xA0bar: Foobar"].pack("m") })
      result["foo"].should eql({ "bar" => "Foobar" })
    end

    context "when the repository has the template_selection feature enabled" do
      before do
        Travis::Features.activate_repository(:template_selection, request.repository)
      end

      it "passes the 'group' config key through" do
        GH.stubs(:[]).returns({ "content" => ["group: latest"].pack("m") })
        result["group"].should eql("latest")
      end

      it "passes the 'dist' config key through" do
        GH.stubs(:[]).returns({ "content" => ["dist: latest"].pack("m") })
        result["dist"].should eql("latest")
      end
    end

    context "when the repository doesn't have the template_selection feature enabled" do
      it "doesn't pass the 'group' config key through" do
        GH.stubs(:[]).returns({ "content" => ["group: latest"].pack("m") })
        result.has_key?("group").should be false
      end

      it "doesn't pass the 'dist' config key through" do
        GH.stubs(:[]).returns({ "content" => ["dist: latest"].pack("m") })
        result.has_key?("dist").should be false
      end
    end
  end
end
