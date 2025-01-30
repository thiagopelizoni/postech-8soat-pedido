require 'swagger_helper'

RSpec.describe 'Pedidos API', type: :request do
  path '/pedidos' do
    get 'Listar Pedidos' do
      parameter name: :page, in: :query, type: :integer, description: 'Número da página'
      parameter name: :per_page, in: :query, type: :integer, description: 'Número de itens por página'
      tags 'Pedidos'
      produces 'application/json'
      
      response '200', 'pedidos encontrados' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/pedido' }
        run_test!
      end
    end

    post 'Criação de Pedido' do
      tags 'Pedidos'
      consumes 'application/json'
      parameter name: :pedido, in: :body, schema: {
        type: :object,
        properties: {
          cliente_id: { type: :integer, nullable: true },
          produtos: { type: :array, items: { type: :integer } },
          observacao: { type: :string, nullable: true },
          pagamento: { type: :string, enum: ['confirmado', 'em_aberto'] },
          status: { type: :string, enum: ['recebido', 'em_preparacao', 'pronto', 'finalizado'] }
        },
        required: ['produtos']
      }
  
      response '201', 'pedido criado' do
        schema '$ref' => '#/components/schemas/pedido'
        let(:pedido) { { produtos: [1, 2], observacao: 'Sem cebola', pagamento: 'em_aberto', status: 'recebido' } }
        run_test!
      end
  
      response '422', 'parâmetros inválidos' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   additionalProperties: { type: :array, items: { type: :string } }
                 }
               }
        let(:pedido) { { produtos: [], observacao: 'Observacao muito longa' * 100, pagamento: 'confirmado', status: 'invalido' } }
        run_test!
      end
    end
  end

  path '/pedidos/{id}' do
    get 'Exibir Pedido' do
      tags 'Pedidos'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'pedido encontrado' do
        schema '$ref' => '#/components/schemas/pedido'
        let(:id) { Pedido.create!(valor: 10.0, status: 'recebido', observacao: 'test', pagamento: 'em_aberto').id }
        run_test!
      end

      response '404', 'pedido não encontrado' do
        let(:id) { 'invalid' }
        run_test!
      end
    end

    put 'Atualização de Pedido' do
      tags 'Pedidos'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :pedido, in: :body, schema: {
        type: :object,
        properties: {
          cliente_id: { type: :integer, nullable: true },
          produtos: { type: :array, items: { type: :integer } },
          observacao: { type: :string, nullable: true },
          pagamento: { type: :string, enum: ['confirmado', 'em_aberto'] },
          status: { type: :string, enum: ['recebido', 'em_preparacao', 'pronto', 'finalizado'] }
        },
        required: ['produtos']
      }
  
      response '200', 'pedido atualizado' do
        schema '$ref' => '#/components/schemas/pedido'
        let(:id) { Pedido.create!(produtos: [1, 2], observacao: 'Sem cebola', pagamento: 'em_aberto', status: 'recebido').id }
        let(:pedido) { { produtos: [3, 4], observacao: 'Com molho', pagamento: 'confirmado', status: 'pronto' } }
        run_test!
      end
  
      response '422', 'parâmetros inválidos' do
        schema type: :object,
               properties: {
                 errors: {
                   type: :object,
                   additionalProperties: { type: :array, items: { type: :string } }
                 }
               }
        let(:id) { Pedido.create!(produtos: [1, 2], observacao: 'Sem cebola', pagamento: 'em_aberto', status: 'recebido').id }
        let(:pedido) { { produtos: [], observacao: 'Observacao muito longa' * 100, pagamento: 'confirmado', status: 'invalido' } }
        run_test!
      end
    end
  end

  path '/pedidos/pagamento-em-aberto' do
    get 'GET Pedidos sem Pagamento confirmado' do
      parameter name: :page, in: :query, type: :integer, description: 'Número da página'
      parameter name: :per_page, in: :query, type: :integer, description: 'Número de itens por página'
      tags 'Pedidos'
      produces 'application/json'

      response '200', 'pedidos encontrados' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/pedido' }
        run_test!
      end
    end
  end

  path '/pedidos/pagamento-confirmado' do
    parameter name: :page, in: :query, type: :integer, description: 'Número da página'
    parameter name: :per_page, in: :query, type: :integer, description: 'Número de itens por página'
    get 'GET Pedidos com Pagamentos Confirmados' do
      tags 'Pedidos'
      produces 'application/json'

      response '200', 'pedidos encontrados' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/pedido' }
        run_test!
      end
    end
  end

  path '/pedidos/pagamento-recusado' do
    parameter name: :page, in: :query, type: :integer, description: 'Número da página'
    parameter name: :per_page, in: :query, type: :integer, description: 'Número de itens por página'
    get 'GET Pedidos com Pagamento Recusado' do
      tags 'Pedidos'
      produces 'application/json'

      response '200', 'pedidos encontrados' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/pedido' }
        run_test!
      end
    end
  end

  path '/pedidos/{id}/pagar' do
    put 'Atualiza o pagamento do pedido para "confirmado"' do
      tags 'Pedidos'
      parameter name: :id, in: :path, type: :integer

      response '200', 'pagamento confirmado' do
        let(:pedido) { create(:pedido, pagamento: 'confirmado') }
        let(:id) { pedido.id }
        run_test!
      end

      response '422', 'parâmetros inválidos' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/pedidos/recebidos' do
    parameter name: :page, in: :query, type: :integer, description: 'Número da página'
    parameter name: :per_page, in: :query, type: :integer, description: 'Número de itens por página'
    get 'GET Pedidos Recebidos' do
      tags 'Pedidos'
      produces 'application/json'

      response '200', 'pedidos encontrados' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/pedido' }
        run_test!
      end
    end
  end

  path '/pedidos/{id}/receber' do
    put 'Atualiza o status do pedido para "Recebido"' do
      tags 'Pedidos'
      parameter name: :id, in: :path, type: :integer

      response '200', 'pedido recebido' do
        let(:pedido) { create(:pedido, status: 'em_preparacao') }
        let(:id) { pedido.id }
        run_test!
      end

      response '422', 'parâmetros inválidos' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/pedidos/em-preparacao' do
    get 'GET Pedidos em Preparação' do
      parameter name: :page, in: :query, type: :integer, description: 'Número da página'
      parameter name: :per_page, in: :query, type: :integer, description: 'Número de itens por página'
      tags 'Pedidos'
      produces 'application/json'

      response '200', 'pedidos encontrados' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/pedido' }
        run_test!
      end
    end
  end

  path '/pedidos/{id}/preparar' do
    put 'Atualiza o status do pedido para "Em Preparação"' do
      tags 'Pedidos'
      parameter name: :id, in: :path, type: :integer

      response '200', 'pedido em preparação' do
        let(:pedido) { create(:pedido, status: 'recebido') }
        let(:id) { pedido.id }
        run_test!
      end

      response '422', 'parâmetros inválidos' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/pedidos/prontos' do
    get 'GET Pedidos Prontos' do
      parameter name: :page, in: :query, type: :integer, description: 'Número da página'
      parameter name: :per_page, in: :query, type: :integer, description: 'Número de itens por página'
      tags 'Pedidos'
      produces 'application/json'

      response '200', 'pedidos encontrados' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/pedido' }
        run_test!
      end
    end
  end

  path '/pedidos/{id}/pronto' do
    put 'Atualiza o status do pedido para "Pronto"' do
      tags 'Pedidos'
      parameter name: :id, in: :path, type: :integer

      response '200', 'pedido pronto' do
        let(:pedido) { create(:pedido, status: 'em_preparacao') }
        let(:id) { pedido.id }
        run_test!
      end

      response '422', 'parâmetros inválidos' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/pedidos/finalizados' do
    get 'GET Pedidos Finalizados' do
      parameter name: :page, in: :query, type: :integer, description: 'Número da página'
      parameter name: :per_page, in: :query, type: :integer, description: 'Número de itens por página'
      tags 'Pedidos'
      produces 'application/json'

      response '200', 'pedidos encontrados' do
        schema type: :array,
               items: { '$ref' => '#/components/schemas/pedido' }
        run_test!
      end
    end
  end

  path '/pedidos/{id}/finalizar' do
    put 'Atualiza o status do pedido para "Finalizado"' do
      tags 'Pedidos'
      parameter name: :id, in: :path, type: :integer

      response '200', 'pedido finalizado' do
        let(:pedido) { create(:pedido, status: 'pronto') }
        let(:id) { pedido.id }
        run_test!
      end

      response '422', 'parâmetros inválidos' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/pedidos/{id}/qr-code' do
    get 'Obtém a URL para pagamento de um pedido junto ao Mercado Pago' do
      tags 'Pedidos'
      parameter name: :id, in: :path, type: :integer

      response '422', 'parâmetros inválidos' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end