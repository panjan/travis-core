class ExecutionLog < ActiveRecord::Base
  attr_accessible :timestamp, :position, :message
  belongs_to :build
end
