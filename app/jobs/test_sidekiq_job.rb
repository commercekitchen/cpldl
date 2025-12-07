class TestSidekiqJob < ApplicationJob
  queue_as :default

  def perform(message = 'hello from TestSidekiqJob')
    logger.info "[TestSidekiqJob] starting with message=#{message}"
    # do a tiny bit of work so you can see timing
    sleep 2
    logger.info '[TestSidekiqJob] finished'
  end
end
