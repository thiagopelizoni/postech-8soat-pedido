class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def mercado_pago
    if params[:type] == 'payment'
      payment = MercadoPago::SDK::Payment.find_by_id(params[:data][:id])

      pedido = Pedido.find_by(external_reference: payment[:external_reference])
      if payment[:status] == 'approved'
        pedido.update(pagamento: 'confirmado')
      elsif payment[:status] == 'rejected'
        pedido.update(pagamento: 'recusado')
      end
    end
    head :ok
  end
end