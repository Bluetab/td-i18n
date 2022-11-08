#!/bin/sh

set -o errexit
set -o xtrace

bin/td_i18n eval 'Elixir.TdI18n.Release.migrate()'
bin/td_i18n start
