require 'mercadopago'

class Pedido
  include Mongoid::Document
  include Mongoid::Timestamps

  field :cliente, type: Hash
  field :produtos, type: Array, default: []
  field :observacao, type: String
  field :valor, type: Float, default: 0.0
  field :pagamento, type: String, default: 'em_aberto'
  field :status, type: String

  PAGAMENTOS = %w[em_aberto confirmado recusado].freeze
  STATUS = %w[recebido em_preparacao pronto finalizado].freeze

  validates :pagamento, inclusion: { in: PAGAMENTOS }
  validates :status, inclusion: { in: STATUS }, if: -> { pagamento == 'confirmado' }
  validates :produtos, presence: true
  validates :observacao, length: { maximum: 500 }
  validate :status_presence_based_on_pagamento

  before_save :calculate_valor
  before_update :validate_status_change

  def integracao_mercado_pago
    sdk = Mercadopago::SDK.new(ENV['MERCADO_PAGO_ACCESS_TOKEN'])

    itens = produtos.map do |produto|
      {
        title: produto['nome'],
        quantity: 1,
        unit_price: produto['preco'].to_f
      }
    end
  
    preference_data = {
      items: itens,
      payer: {
        name: cliente['nome'],
        email: cliente['email']
      },
      external_reference: id.to_s,
      notification_url: ENV['MERCADO_PAGO_WEBHOOK_URL'],
      payment_methods: {
        excluded_payment_types: [
          { id: 'ticket' }
        ]
      }
    }
  
    preference_response = sdk.preference.create(preference_data)
    preference_response
  end

  private

  def calculate_valor
    self.valor = produtos.sum { |produto| produto['preco'] }
  end

  def validate_status_change
    return unless status_changed? && pagamento != 'confirmado'

    errors.add(:status, 'Status não pode ser alterado a menos que o Pagamento esteja como confirmado')
    throw :abort
  end

  def status_presence_based_on_pagamento
    if ['em_aberto', 'recusado'].include?(pagamento) && status.present?
      errors.add(:status, 'Não se pode atribuir Status se o Pagamento estiver Em Aberto')
    end

    if pagamento == 'confirmado' && status.blank?
      errors.add(:status, 'Status é obrigatório quando o Pagamento já tiver sido confirmado')
    end
  end

end
