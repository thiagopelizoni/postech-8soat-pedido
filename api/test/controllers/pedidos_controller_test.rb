require "test_helper"

class PedidosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pedido = pedidos(:one)
    @produto1 = produtos(:one)
    @produto2 = produtos(:two)
    @cliente = clientes(:one)
  end

  test "should get index" do
    get pedidos_url
    assert_response :success
  end

  test "should get new" do
    get new_pedido_url
    assert_response :success
  end

  test "should create pedido" do
    assert_difference('Pedido.count') do
      post pedidos_url, params: { pedido: { cliente_id: @cliente.id, produtos: [@produto1.id, @produto2.id], observacao: 'Teste', status: :recebido } }
    end

    assert_redirected_to pedido_url(Pedido.last)
  end

  test "should show pedido" do
    get pedido_url(@pedido)
    assert_response :success
  end

  test "should get edit" do
    get edit_pedido_url(@pedido)
    assert_response :success
  end

  test "should update pedido" do
    patch pedido_url(@pedido), params: { pedido: { cliente_id: @cliente.id, produtos: [@produto1.id, @produto2.id], observacao: 'Teste atualizado', status: :em_preparacao } }
    assert_redirected_to pedido_url(@pedido)
  end

  test "should finalize pedido" do
    assert_no_difference('Pedido.count') do
      delete pedido_url(@pedido)
    end

    assert_redirected_to pedidos_url
    assert_equal 'finalizado', @pedido.reload.status
  end
end