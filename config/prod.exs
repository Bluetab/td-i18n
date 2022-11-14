import Config

config :td_i18n, TdI18nWeb.Endpoint, server: true

config :td_i18n, TdI18n.Scheduler,
  jobs: [
    [
      schedule: "@reboot",
      task: {TdI18n.Locales, :load_from_file!, ["/app/messages.json"]},
      run_strategy: Quantum.RunStrategy.Local
    ]
  ]
