require 'spec_helper'

# use class with EnvHelpers included in it
describe Travis::Model::EnvHelpers do

  class Helper
    include Travis::Model::EnvHelpers
  end

  it "converts enviroment settings to hash" do
    helper = Helper.new
    vars = helper.send(:vars2hash,
      "VAR1=value1 VAR2=value2 SECURE VAR3=SECURE",
    )
    result = {
      'VAR1' => 'value1',
      'VAR2' => 'value2'
    }
    vars.should eq result
  end
end
