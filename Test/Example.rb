# frozen_string_literal: true
require_relative '../lib/TeleRuby/app'
require_relative 'Routers/PersonRouter'
app = App.new

app.add_router("/people", $Prouter)

app.run
