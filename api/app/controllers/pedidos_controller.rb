class PedidosController < ApplicationController
  before_action :set_pedido, only: %i[show update destroy pagar preparar receber pronto finalizar qr_code]

  def index
    @pedidos = Pedido.order_by(updated_at: :desc)
    render json: @pedidos
  end

  def show
    render json: @pedido
  end

  def create
    @pedido = Pedido.new(pedido_params)

    if @pedido.save
      render json: @pedido, status: :created
    else
      render json: @pedido.errors, status: :unprocessable_entity
    end
  end

  def update
    if @pedido.update(pedido_params)
      render json: @pedido
    else
      render json: @pedido.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @pedido.update(status: 'finalizado')
    render json: { message: 'Pedido foi finalizado com sucesso.' }
  end

  def search
    pedidos = Pedido.all

    pedidos = pedidos.select { |pedido| pedido.cliente['email'] == params[:email] } if params[:email].present?
    pedidos = pedidos.select { |pedido| pedido.cliente['cpf'] == params[:cpf] } if params[:cpf].present?
    
    if params[:produto].present?
      pedidos = pedidos.select { |pedido| pedido.produtos.any? { |p| p['nome'].downcase.include?(params[:produto].downcase) } }
    end

    pedidos = pedidos.where(cliente: nil) if params[:cliente_nulo].present? && params[:cliente_nulo] == 'true'
    pedidos = pedidos.where(status: params[:status]) if params[:status].present?
    pedidos = pedidos.where(pagamento: params[:pagamento]) if params[:pagamento].present?

    render json: pedidos
  end

  def pagamento_confirmado
    params[:pagamento] = 'confirmado'
    search
  end

  def pagamento_em_aberto
    params[:pagamento] = 'em_aberto'
    search
  end

  def pagamento_recusado
    params[:pagamento] = 'recusado'
    search
  end

  def prontos
    params[:status] = 'pronto'
    search
  end

  def recebidos
    params[:status] = 'recebido'
    search
  end

  def em_preparacao
    params[:status] = 'em_preparacao'
    search
  end

  def finalizados
    params[:status] = 'finalizado'
    search
  end

  def pagar
    if @pedido.update(pagamento: 'confirmado', status: 'recebido')
      render json: @pedido, status: :ok
    else
      render json: @pedido.errors, status: :unprocessable_entity
    end
  end

  def receber
    if @pedido.update(status: 'recebido')
      render json: @pedido, status: :ok
    else
      render json: @pedido.errors, status: :unprocessable_entity
    end
  end

  def preparar
    if @pedido.update(status: 'em_preparacao')
      render json: @pedido, status: :ok
    else
      render json: @pedido.errors, status: :unprocessable_entity
    end
  end

  def pronto
    if @pedido.update(status: 'pronto')
      render json: @pedido, status: :ok
    else
      render json: @pedido.errors, status: :unprocessable_entity
    end
  end

  def finalizar
    if @pedido.update(status: 'finalizado')
      render json: @pedido, status: :ok
    else
      render json: @pedido.errors, status: :unprocessable_entity
    end
  end

  # GET /pedidos/:id/qr-code
  def qr_code
    preference_response = @pedido.integracao_mercado_pago

    if preference_response[:status] == 201
      qr_code_url = preference_response[:response]['sandbox_init_point'] #'init_point' para produção
      render json: { pedido: @pedido, link_pagamento: qr_code_url }
    else
      render json: { error: "Erro ao criar a preferência: #{preference_response[:response]['message']}" }, status: :unprocessable_entity
    end
  end

  private

  def set_pedido
    @pedido = Pedido.find(params[:id])
  end

  def pedido_params
    params.require(:pedido).permit(:valor, :status, :observacao, :pagamento, cliente: {}, produtos: [])
  end
end
