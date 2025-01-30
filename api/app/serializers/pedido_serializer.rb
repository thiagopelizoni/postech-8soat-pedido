class PedidoSerializer < ActiveModel::Serializer
  attributes :id, :cliente, :produtos, :valor, :status, :observacao, :data, :data_status, :pagamento

  def data
    object.created_at.strftime("%d/%m/%Y %H:%m:%S")
  end

  def data_status
    object.updated_at.strftime("%d/%m/%Y %H:%m:%S")
  end
end