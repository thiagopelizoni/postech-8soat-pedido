require 'rails_helper'

RSpec.describe Pedido, type: :model do
  describe 'fields' do
    it { is_expected.to have_field(:cliente).of_type(Hash) }
    it { is_expected.to have_field(:produtos).of_type(Array).with_default_value_of([]) }
    it { is_expected.to have_field(:observacao).of_type(String) }
    it { is_expected.to have_field(:valor).of_type(Float).with_default_value_of(0.0) }
    it { is_expected.to have_field(:pagamento).of_type(String).with_default_value_of('em_aberto') }
    it { is_expected.to have_field(:status).of_type(String) }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:pagamento).in_array(%w[em_aberto confirmado recusado]) }
    it { is_expected.to validate_length_of(:observacao).is_at_most(500) }
    it { is_expected.to validate_presence_of(:produtos) }

    context 'when pagamento is confirmado' do
      it 'requires status to be in allowed list' do
        pedido = build(:pedido, pagamento: 'confirmado', status: 'invalido')
        pedido.valid?
        expect(pedido.errors[:status]).to include('is not included in the list')
      end
    end

    context 'when pagamento is em_aberto or recusado' do
      it 'does not allow status to be present' do
        pedido = build(:pedido, pagamento: 'em_aberto', status: 'recebido')
        pedido.valid?
        expect(pedido.errors[:status]).to include('Não se pode atribuir Status se o Pagamento estiver Em Aberto')
      end
    end

    context 'when pagamento is confirmado' do
      it 'requires status to be present' do
        pedido = build(:pedido, pagamento: 'confirmado', status: nil)
        pedido.valid?
        expect(pedido.errors[:status]).to include('Status é obrigatório quando o Pagamento já tiver sido confirmado')
      end
    end
  end

  describe 'callbacks' do
    describe '#calculate_valor' do
      it 'calculates total order value before save' do
        pedido = build(:pedido, produtos: [{ 'preco' => 10 }, { 'preco' => 15 }])
        pedido.produtos ||= []
        pedido.save!
        expect(pedido.valor).to eq(25.0)
      end
    end

    describe '#validate_status_change' do
      it 'prevents status update unless pagamento is confirmado' do
        pedido = create(:pedido, pagamento: 'em_aberto')
        expect { pedido.update!(status: 'pronto') }.to raise_error(Mongoid::Errors::Validations)
      end
    end
  end
end
