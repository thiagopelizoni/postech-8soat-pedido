# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
  'v1/swagger.yaml' => {
    openapi: '3.0.1',
    info: {
      title: 'API V1',
      version: 'v1'
    },
    paths: {},
    components: {
      schemas: {
        produto: {
          type: :object,
          properties: {
            id: { type: :integer },
            nome: { type: :string },
            descricao: { type: :string },
            preco: { type: :number },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'nome', 'descricao', 'preco']
        },
        categoria: {
          type: :object,
          properties: {
            id: { type: :integer },
            nome: { type: :string },
            descricao: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'nome', 'descricao']
        },
        cliente: {
          type: :object,
          properties: {
            id: { type: :integer },
            nome: { type: :string },
            data_nascimento: { type: :string, format: 'date' },
            cpf: { type: :string },
            email: { type: :string },
            senha: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          },
          required: ['id', 'nome', 'data_nascimento', 'cpf', 'email', 'senha', 'created_at', 'updated_at']
        },
        pedido: {
          type: :object,
          properties: {
            id: { type: :integer },
            valor: { type: :number },
            status: { type: :string, enum: ['recebido', 'em_preparacao', 'pronto', 'finalizado'] },
            observacao: { type: :string, nullable: true },
            data: { type: :string, format: 'date-time' },
            data_status: { type: :string, format: 'date-time' },
            pagamento: { type: :string, enum: ['efetuado', 'em_aberto'] },
            cliente: { '$ref' => '#/components/schemas/cliente' },
            produtos: {
              type: :array,
              items: { '$ref' => '#/components/schemas/produto' }
            }
          },
          required: ['id', 'valor', 'status', 'data', 'data_status', 'pagamento', 'cliente', 'produtos']
        }
      }
    }
  }
}


  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
