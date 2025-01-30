require 'faker'

PAGAMENTOS = %w[em_aberto confirmado recusado].freeze
STATUS = %w[recebido em_preparacao pronto finalizado].freeze

PRODUTOS = [
  { id: 1, slug: 'big-mac', nome: 'Big Mac', preco: 20 },
  { id: 2, slug: 'cheeseburger', nome: 'Cheeseburger', preco: 10 },
  { id: 3, slug: 'mcchicken', nome: 'McChicken', preco: 15 },
  { id: 4, slug: 'quarterao-com-queijo', nome: 'Quarterão com Queijo', preco: 18 },
  { id: 5, slug: 'cachorro-quente', nome: 'Cachorro Quente', preco: 10 },
  { id: 6, slug: 'taco', nome: 'Taco', preco: 18 },
  { id: 8, slug: 'batata-frita', nome: 'Batata Frita', preco: 8 },
  { id: 9, slug: 'mcnuggets', nome: 'McNuggets', preco: 12 },
  { id: 10, slug: 'salada', nome: 'Salada', preco: 10 },
  { id: 11, slug: 'salada-caesar', nome: 'Salada Caesar', preco: 12 },
  { id: 12, slug: 'mozzarella-sticks', nome: 'Mozzarella Sticks', preco: 11 },
  { id: 14, slug: 'coca-cola', nome: 'Coca-Cola', preco: 6 },
  { id: 15, slug: 'suco-de-laranja', nome: 'Suco de Laranja', preco: 7 },
  { id: 16, slug: 'milkshake-de-morango', nome: 'Milkshake de Morango', preco: 10 },
  { id: 17, slug: 'suco-natural', nome: 'Suco Natural', preco: 6 },
  { id: 19, slug: 'mcflurry', nome: 'McFlurry', preco: 12 },
  { id: 20, slug: 'torta-de-maca', nome: 'Torta de Maçã', preco: 7 },
  { id: 21, slug: 'sundae-de-chocolate', nome: 'Sundae de Chocolate', preco: 9 },
  { id: 22, slug: 'brownie', nome: 'Brownie', preco: 9 },
  { id: 23, slug: 'cheesecake', nome: 'Cheesecake', preco: 10 }
].freeze

def generate_cliente
  {
    nome: Faker::Name.name,
    email: Faker::Internet.email,
    cpf: Faker::Number.number(digits: 11),
    token: Faker::Alphanumeric.alphanumeric(number: 20)
  }
end

def generate_produtos
  PRODUTOS.sample(rand(1..4))
end

def generate_pagamento_status
  pagamento = PAGAMENTOS.sample
  status = pagamento == 'em_aberto' ? nil : (pagamento == 'confirmado' ? STATUS.sample : nil)
  [pagamento, status]
end

def generate_observacao
  [nil, 'Sem cebola', 'Entregar sem gelo', 'Trocar batata por nuggets', 'Não tocar a campainha'].sample
end

Pedido.delete_all

50.times do
  produtos = generate_produtos
  pagamento, status = generate_pagamento_status

  Pedido.create!(
    cliente: generate_cliente,
    produtos: produtos,
    pagamento: pagamento,
    status: status,
    observacao: generate_observacao
  )
end

puts '50 pedidos gerados com sucesso!'
