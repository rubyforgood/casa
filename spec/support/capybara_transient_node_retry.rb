# Chrome/CDP intermittently raises
#
#   Selenium::WebDriver::Error::UnknownError:
#     unknown error: unhandled inspector error:
#     {"code":-32000,"message":"Node with given id does not belong to the document"}
#
# when Capybara queries the page while Turbo is swapping the document out from under it. It is
# transient and semantically a stale-element error -- retrying against the new document succeeds --
# but Selenium reports it as a generic UnknownError, and Capybara's retry loop matches by exception
# class (Node::Base#catch_error? -> driver.invalid_element_errors, all `is_a?` checks), so it is
# re-raised immediately and the example fails.
#
# Adding UnknownError to invalid_element_errors would be far too broad -- it is the catch-all for
# real driver failures too. Match on this one message instead, so the retry stays inside Capybara's
# existing synchronize loop: it reloads the node and retries until default_max_wait_time, then
# raises as usual. A genuinely stuck page therefore still fails, just at the wait timeout.
module CapybaraTransientNodeRetry
  DETACHED_NODE_MESSAGE = "Node with given id does not belong to the document"

  def catch_error?(error, errors = nil)
    return true if transient_detached_node?(error)

    super
  end

  private

  def transient_detached_node?(error)
    error.is_a?(::Selenium::WebDriver::Error::UnknownError) &&
      error.message.to_s.include?(DETACHED_NODE_MESSAGE)
  end
end

Capybara::Node::Base.prepend(CapybaraTransientNodeRetry)
