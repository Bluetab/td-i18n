import Config

config :td_i18n, TdI18nWeb.Endpoint, server: true

config :td_i18n, TdI18n.Scheduler,
  jobs: [
    [
      schedule: "@reboot",
      task:
        {TdI18n.Messages, :delete_deprecated_messages,
         [
           [
             "ruleImplementations.upload.failed.misssing_required_columns",
             "rules.upload.failed.misssing_required_columns"
           ],
           [
             "Error en {name} atributo: {key} mensaje: {message} "
           ]
         ]},
      run_strategy: Quantum.RunStrategy.Local
    ],
    [
      schedule: "@reboot",
      task: {TdI18n.Locales, :load_messages_from_file!, ["/app/messages.json"]},
      run_strategy: Quantum.RunStrategy.Local
    ],
    [
      schedule: "@reboot",
      task: {TdI18n.Locales, :load_locales_from_file!, ["/app/locales.json"]},
      run_strategy: Quantum.RunStrategy.Local
    ]
  ]
