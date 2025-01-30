# test/models/pedido_test.rb
require "test_helper"

class PedidoTest < ActiveSupport::TestCase
  setup do
    @produto1 = produtos(:one)
    @produto2 = produtos(:two)
    @cliente = clientes(:one)
    @pedido = Pedido.new(cliente: @cliente, produtos: [@produto1.id, @produto2.id], status: :recebido, observacao: 'Teste de observação')
  end

  test "should calculate valor" do
    @pedido.save
    assert_equal @produto1.preco + @produto2.preco, @pedido.valor
  end

  test "should have status" do
    @pedido.status = nil
    assert_not @pedido.valid?
  end

  test "should not exceed observation length" do
    @pedido.observacao = 'a' * 501
    assert_not @pedido.valid?
  end
end
