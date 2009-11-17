module WaitHelper
  # Wait for all ajax requests to finish, timing out after the specified number of seconds.
  def wait_for_ajax(timeout = 30)
    wait_for(timeout) { @browser.document.js_eval("document.defaultView.Ajax.activeRequestCount").to_i == 0 }
  end

  # Wait for all javascript effects to finish, timing out after the specified number of seconds.
  def wait_for_effects(timeout = 30)
    wait_for(timeout) { @browser.document.js_eval("document.defaultView.Effect.Queue.size()").to_i == 0 }
  end

  # Wait for both effects and ajax. If effects toggle ajax when the effects finish, this will not wait for them.
  def wait_for_javascript(timeout = 30)
    wait_for_ajax(timeout)
    wait_for_effects(timeout)
  end

  # Waits until the specified process is found to be executing
  def wait_for_process(process_name, timeout = 60)
    wait_for(timeout) do
      system "ps aux | grep -e '#{process_name}' | grep -v grep 1>/dev/null"
      $?.exitstatus == 0
    end
  end
  
  private


  # Waits for the block to become true, up until the specified timeout, at which time a runtime exception will be
  # raised.
  def wait_for(timeout = 30, &block)
    start = Time.now
    while true
      raise RuntimeError, "Timed out waiting for event" if Time.now - start > timeout

      break if yield

      sleep(0.1)
    end
  end
end
