require "test_helper"

class CategoriaTest < ActiveSupport::TestCase
  def setup
    @categoria = Categoria.new(nome: "Lanches")
  end

  test "deve ser válida" do
    assert @categoria.valid?
  end

  test "nome deve estar presente" do
    @categoria.nome = ""
    assert_not @categoria.valid?
  end

  test "nome deve ser único" do
    duplicate_categoria = @categoria.dup
    @categoria.save
    assert_not duplicate_categoria.valid?
  end
end