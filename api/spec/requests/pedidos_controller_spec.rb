require 'rails_helper'

RSpec.describe PedidosController, type: :request do
  let!(:pedido) { create(:pedido) }
  let(:pedido_id) { pedido.id.to_s }

  describe 'GET /pedidos' do
    it 'returns all pedidos' do
      get '/pedidos'
      expect(response).to have_http_status(:ok)
      expect(json.size).to be >= 1
    end
  end

  describe 'GET /pedidos/:id' do
    it 'returns the pedido' do
      get "/pedidos/#{pedido_id}"
      expect(response).to have_http_status(:ok)
      expect(json['id']).to eq(pedido_id)
    end
  end

  describe 'POST /pedidos' do
    let(:valid_attributes) { attributes_for(:pedido) }

    it 'creates a pedido' do
      post '/pedidos', params: { pedido: valid_attributes }
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PUT /pedidos/:id' do
    let(:updated_attributes) { { status: 'pronto' } }

    it 'updates the pedido' do
      put "/pedidos/#{pedido_id}", params: { pedido: updated_attributes }
      expect(response).to have_http_status(:ok)
      expect(pedido.reload.status).to eq('pronto')
    end
  end

  describe 'DELETE /pedidos/:id' do
    it 'marks the pedido as finalizado' do
      delete "/pedidos/#{pedido_id}"
      expect(response).to have_http_status(:ok)
      expect(pedido.reload.status).to eq('finalizado')
    end
  end

  %w[pagamento-confirmado pagamento-em-aberto pagamento-recusado prontos recebidos em-preparacao finalizados].each do |route|
    describe "GET /pedidos/#{route}" do
      it "filters pedidos by #{route}" do
        get "/pedidos/#{route}"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  %w[pagar receber preparar pronto finalizar].each do |action|
    describe "PUT /pedidos/:id/#{action}" do
      it "updates pedido status to #{action}" do
        put "/pedidos/#{pedido_id}/#{action}"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  private

  def json
    JSON.parse(response.body)
  end
end
