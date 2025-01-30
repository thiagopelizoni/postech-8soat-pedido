require "test_helper"

class ProdutoTest < ActiveSupport::TestCase
  def setup
    @categoria = categorias(:one)
    @produto = Produto.new(nome: "Produto Teste", descricao: "Descrição do produto", preco: 10.0, categoria: @categoria)
  end

  test "deve ser válido" do
    assert @produto.valid?
  end

  test "nome deve estar presente" do
    @produto.nome = ""
    assert_not @produto.valid?
  end

  test "deve ter um preço" do
    @produto.preco = nil
    assert_not @produto.valid?
  end

  test "preco deve ser não negativo" do
    @produto.preco = -1
    assert_not @produto.valid?
  end

  test "categoria deve estar presente" do
    @produto.categoria = nil
    assert_not @produto.valid?
  end
end