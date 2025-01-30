class PedidoSerializer < ActiveModel::Serializer
  attributes :id, :valor, :status, :observacao, :data, :data_status, :pagamento
  belongs_to :cliente, serializer: ClienteSerializer
  has_many :produtos, serializer: ProdutoSerializer

  def produtos
    object.produtos.map { |produto_id| Produto.find(produto_id) }
  end

  def data
    object.created_at.strftime("%d/%m/%Y %H:%m:%S")
  end

  def data_status
    object.updated_at.strftime("%d/%m/%Y %H:%m:%S")
  end
end