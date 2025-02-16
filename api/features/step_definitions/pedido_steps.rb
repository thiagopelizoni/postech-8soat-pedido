require 'json'
require 'cucumber/rails'
require 'rspec/expectations'
require 'mongoid'

def convert_special_value(value)
  case value
  when /a string with (\d+) chars/
    'a' * Regexp.last_match(1).to_i
  else
    value
  end
end

Before do
  Pedido.delete_all
end

# --------------------------
# Steps de configuração do Pedido
# --------------------------
Given(/^a pedido with:$/) do |table|
  data = table.rows_hash
  data['produtos'] = data['produtos'] ? JSON.parse(data['produtos'].gsub("'", '"')) : nil
  data['cliente'] = data['cliente'] ? JSON.parse(data['cliente'].gsub("'", '"')) : nil
  data['observacao'] = data['observacao'] ? convert_special_value(data['observacao']) : nil
  data['pagamento'] = data['pagamento']&.strip
  data['status'] = data['status']&.strip
  @pedido = Pedido.new(data)
end

Given(/^an existing pedido with:$/) do |table|
  data = table.rows_hash
  data['produtos'] = data['produtos'] ? JSON.parse(data['produtos'].gsub("'", '"')) : nil
  data['cliente'] = data['cliente'] ? JSON.parse(data['cliente'].gsub("'", '"')) : nil
  data['observacao'] = data['observacao'] ? convert_special_value(data['observacao']) : nil
  data['pagamento'] = data['pagamento']&.strip
  data['status'] = data['status']&.strip
  @pedido = Pedido.create!(data)
end

# --------------------------
# Steps de Validação e Salvamento
# --------------------------
When(/^I validate the pedido$/) do
  @pedido.valid?
end

Then(/^the pedido should be valid$/) do
  expect(@pedido).to be_valid
end

Then(/^the pedido should be invalid$/) do
  expect(@pedido).not_to be_valid
end

Then(/^the error for "([^"]*)" should include "([^"]*)"$/) do |attribute, message|
  expect(@pedido.errors[attribute]).to include(message)
end

When(/^I save the pedido$/) do
  @pedido.save
end

Then(/^the pedido valor should be (\d+\.?\d*)$/) do |expected_value|
  expect(@pedido.valor).to eq(expected_value.to_f)
end

# --------------------------
# Steps para Atualização do Pedido
# --------------------------
Given(/^I update the pedido status to "([^"]*)"$/) do |new_status|
  @pedido.status = new_status
end

When(/^I save the pedido update$/) do
  @update_result = @pedido.save
end

Then(/^the pedido update should fail$/) do
  expect(@update_result).to be false
end

Then(/^the pedido update should succeed$/) do
  expect(@update_result).to be true
end

Then(/^the pedido status should be "([^"]*)"$/) do |expected_status|
  @pedido.reload
  expect(@pedido.status).to eq(expected_status)
end

# --------------------------
# Steps para Integração com Mercado Pago
# --------------------------
Given(/^Mercadopago integration will return:$/) do |table|
  response_data = table.rows_hash

  response_data.transform_values! { |v| convert_special_value(v) }
  @mp_response = {
    status: response_data['status'].to_i,
    response: { 'sandbox_init_point' => response_data['sandbox_init_point'] }
  }

  @mp_sdk_double = instance_double("Mercadopago::SDK")
  @mp_preference_double = instance_double("Mercadopago::Preference")
  expect(Mercadopago::SDK).to receive(:new).with(ENV['MERCADO_PAGO_ACCESS_TOKEN']).and_return(@mp_sdk_double)
  expect(@mp_sdk_double).to receive(:preference).and_return(@mp_preference_double)
  expect(@mp_preference_double).to receive(:create).with(
    hash_including(
      items: kind_of(Array),
      payer: kind_of(Hash),
      external_reference: @pedido.id.to_s,
      notification_url: ENV['MERCADO_PAGO_WEBHOOK_URL'],
      payment_methods: { excluded_payment_types: [{ 'id' => 'ticket' }] }
    )
  ).and_return(@mp_response)
end

When(/^I call the integracao_mercado_pago method on the pedido$/) do
  @integration_result = @pedido.integracao_mercado_pago
end

Then(/^the integration result should be:$/) do |table|
  expected = table.rows_hash
  expected['status'] = expected['status'].to_i
  expect(@integration_result[:status]).to eq(expected['status'])
  expect(@integration_result[:response]['sandbox_init_point']).to eq(expected['sandbox_init_point'])
end

# --------------------------
# Steps para variáveis de ambiente de Mercado Pago
# --------------------------
Given(/^the MERCADO_PAGO_ACCESS_TOKEN is set to "([^"]*)"$/) do |token|
  ENV['MERCADO_PAGO_ACCESS_TOKEN'] = token
end

Given(/^the MERCADO_PAGO_WEBHOOK_URL is set to "([^"]*)"$/) do |url|
  ENV['MERCADO_PAGO_WEBHOOK_URL'] = url
end
