require "test_helper"

class ClienteTest < ActiveSupport::TestCase
  def setup
    @cliente = Cliente.new(nome: "João Silva", data_nascimento: "2000-01-01", cpf: "12345678901", email: "joao@example.com", senha: "password")
  end

  test "deve ser válido" do
    assert @cliente.valid?
  end

  test "nome deve estar presente" do
    @cliente.nome = ""
    assert_not @cliente.valid?
  end

  test "nome deve ter pelo menos 6 caracteres" do
    @cliente.nome = "a" * 5
    assert_not @cliente.valid?
  end

  test "nome não deve ter mais de 140 caracteres" do
    @cliente.nome = "a" * 141
    assert_not @cliente.valid?
  end

  test "data_nascimento deve ser de no mínimo 16 anos" do
    @cliente.data_nascimento = 15.years.ago
    assert_not @cliente.valid?
  end

  test "cpf deve estar presente" do
    @cliente.cpf = ""
    assert_not @cliente.valid?
  end

  test "cpf deve ser único" do
    duplicate_cliente = @cliente.dup
    @cliente.save
    assert_not duplicate_cliente.valid?
  end

  test "cpf deve ter 11 dígitos" do
    @cliente.cpf = "12345"
    assert_not @cliente.valid?
  end

  test "email deve estar presente" do
    @cliente.email = ""
    assert_not @cliente.valid?
  end

  test "email deve ser válido" do
    @cliente.email = "invalid_email"
    assert_not @cliente.valid?
  end

  test "email deve ser único" do
    duplicate_cliente = @cliente.dup
    duplicate_cliente.email = @cliente.email.upcase
    @cliente.save
    assert_not duplicate_cliente.valid?
  end

  test "senha deve estar presente" do
    @cliente.senha = ""
    assert_not @cliente.valid?
  end

  test "senha deve ter pelo menos 6 caracteres" do
    @cliente.senha = "a" * 5
    assert_not @cliente.valid?
  end
end
