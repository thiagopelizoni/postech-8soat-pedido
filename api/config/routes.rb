Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  root "pedidos#index"

  resources :pedidos do
    collection do
      get 'prontos', to: 'pedidos#prontos'
      get 'recebidos', to: 'pedidos#recebidos'
      get 'em-preparacao', to: 'pedidos#em_preparacao'
      get 'finalizados', to: 'pedidos#finalizados'
      get 'pagamento-confirmado', to: 'pedidos#pagamento_confirmado'
      get 'pagamento-em-aberto', to: 'pedidos#pagamento_em_aberto'
      get 'pagamento-recusado', to: 'pedidos#pagamento_recusado'
    end

    member do
      put 'pagar', to: 'pedidos#pagar'
      put 'receber', to: 'pedidos#receber'
      put 'preparar', to: 'pedidos#preparar'
      put 'pronto', to: 'pedidos#pronto'
      put 'finalizar', to: 'pedidos#finalizar'
      get 'qr-code', to: 'pedidos#qr_code'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
