Sentry.init do |config|
    config.dsn = 'https://d2267127ff2043d39d17a9819996b4ed@o922112.ingest.sentry.io/5869099'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
    # Set tracesSampleRate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production
    config.traces_sample_rate = 0.5
    # or
    config.traces_sampler = lambda do |context|
      true
    end
  end
  