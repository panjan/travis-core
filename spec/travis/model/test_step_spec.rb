require 'spec_helper'

describe TestStep, :type => :model do
  include Support::ActiveRecord

  #it { should belong_to(:test_case) }
  #it { should have_many(:test_step_results) }
end
