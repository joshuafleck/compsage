module WaitHelper
  # Wait for all ajax requests to finish, timing out after the specified number of seconds.
  def wait_for_ajax(timeout = 30)
    start = Time.now
    while true
      connections = @browser.document.js_eval("document.defaultView.Ajax.activeRequestCount").to_i

      raise RuntimeError, "Timed out waiting for Ajax" if Time.now - start > timeout
      break if connections == 0

      sleep(0.1)
    end
  end
end
