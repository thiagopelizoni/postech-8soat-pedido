Feature: Validações e Integração do Modelo Pedido
  Para garantir que os pedidos sejam criados e atualizados corretamente
  Como sistema de pedidos
  Quero validar regras de negócio e a integração com o Mercado Pago

  Background:
    # Definindo variáveis de ambiente para integração
    Given the MERCADO_PAGO_ACCESS_TOKEN is set to "mp_access_token"
    And the MERCADO_PAGO_WEBHOOK_URL is set to "http://example.com/webhook"

  # -------------------------------------------------------------------
  # Cenários de Validação do Pagamento e Status
  # -------------------------------------------------------------------

  Scenario: Pedido é válido com pagamento permitido e status adequado
    # Para pagamentos "confirmado", um status válido deve ser informado
    Given a pedido with:
      | pagamento  | confirmado |
      | status     | recebido   |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    When I validate the pedido
    Then the pedido should be valid

  Scenario: Pedido é válido com pagamento "em_aberto" e sem status
    Given a pedido with:
      | pagamento  | em_aberto |
      | status     |          |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    When I validate the pedido
    Then the pedido should be valid

  Scenario: Pedido is invalid when pagamento is unknown
    Given a pedido with:
      | pagamento  | invalid |
      | status     |         |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    When I validate the pedido
    Then the pedido should be invalid
    And the error for "pagamento" should include "is not included in the list"

  Scenario: Pedido com pagamento "confirmado" sem status deve ser inválido
    Given a pedido with:
      | pagamento  | confirmado |
      | status     |          |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    When I validate the pedido
    Then the pedido should be invalid
    And the error for "status" should include "Status é obrigatório quando o Pagamento já tiver sido confirmado"

  Scenario: Pedido com pagamento "confirmado" com status inválido deve ser inválido
    Given a pedido with:
      | pagamento  | confirmado |
      | status     | invalid    |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    When I validate the pedido
    Then the pedido should be invalid
    And the error for "status" should include "is not included in the list"

  Scenario: Pedido com pagamento "em_aberto" e com status informado deve ser inválido
    Given a pedido with:
      | pagamento  | em_aberto |
      | status     | recebido  |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    When I validate the pedido
    Then the pedido should be invalid
    And the error for "status" should include "Não se pode atribuir Status se o Pagamento estiver Em Aberto"

  Scenario: Pedido com pagamento "recusado" e com status informado deve ser inválido
    Given a pedido with:
      | pagamento  | recusado  |
      | status     | pronto    |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    When I validate the pedido
    Then the pedido should be invalid
    And the error for "status" should include "Não se pode atribuir Status se o Pagamento estiver Em Aberto"

  # -------------------------------------------------------------------
  # Cenários de Validação dos Produtos e Observação
  # -------------------------------------------------------------------

  Scenario: Pedido sem produtos é inválido
    Given a pedido with:
      | pagamento  | confirmado |
      | status     | recebido   |
      | produtos   | []         |
    When I validate the pedido
    Then the pedido should be invalid
    And the error for "produtos" should include "can't be blank"

  Scenario: Pedido com observação maior que 500 caracteres é inválido
    Given a pedido with:
      | pagamento   | confirmado |
      | status      | recebido   |
      | produtos    | [{"nome": "Prod1", "preco": 10}] |
      | observacao  | a string with 501 chars |
    When I validate the pedido
    Then the pedido should be invalid
    And the error for "observacao" should include "is too long (maximum is 500 characters)"

  Scenario: Pedido with valid observacao length is valid
    Given a pedido with:
      | pagamento   | confirmado |
      | status      | recebido   |
      | produtos    | [{"nome": "Prod1", "preco": 10}] |
      | observacao  | a string with 500 chars |
    When I validate the pedido
    Then the pedido should be valid

  # -------------------------------------------------------------------
  # Cenários de Callbacks: Calculate Valor e Validate Status Change
  # -------------------------------------------------------------------

  Scenario: Calculate valor as sum of product prices
    Given a pedido with:
      | pagamento  | confirmado |
      | status     | recebido   |
      | produtos   | [{"nome": "Prod1", "preco": 10}, {"nome": "Prod2", "preco": 20}, {"nome": "Prod3", "preco": 30}] |
    When I save the pedido
    Then the pedido valor should be 60.0

  Scenario: Prevent updating status when pagamento is not confirmed
    Given an existing pedido with:
      | pagamento  | em_aberto |
      | status     |          |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    And I update the pedido status to "pronto"
    When I save the pedido update
    Then the pedido update should fail
    And the error for "status" should include "Não se pode atribuir Status se o Pagamento estiver Em Aberto"

  Scenario: Allow updating status when pagamento is confirmed
    Given an existing pedido with:
      | pagamento  | confirmado |
      | status     | recebido   |
      | produtos   | [{"nome": "Prod1", "preco": 10}] |
    And I update the pedido status to "pronto"
    When I save the pedido update
    Then the pedido update should succeed
    And the pedido status should be "pronto"