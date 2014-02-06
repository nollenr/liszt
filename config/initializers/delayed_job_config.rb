Delayed::Worker.sleep_delay = 15
Delayed::Worker.max_attempts = 1
Delayed::Worker.logger = Logger.new(Rails.root.join('log','delayed_jobs.log'))
