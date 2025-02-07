Cmsify::Engine.routes.draw do
  scope :cmsify do
    concern :sortable do
      put :sort, on: :collection
    end
    resources :assets
    resources :paginate_assets, :only => [:index]

    scope '/content' do
      Cmsify.config.content_types.each do |n|
        namespace n, path: n.to_s.tableize do
          resources :items, concerns: :sortable
          resources :collections, concerns: :sortable do
            resources :children, controller: :collections
            resources :items
          end
        end
      end
    end

    Cmsify.config.cmsified_resources.each do |n|
      resources n
    end
    resources :urls
    resources :pages do
      resources :children, controller: :pages
    end

    resources :collects, only: [:destroy], concerns: :sortable
    ['content'].each do |p|
      get p, :controller => 'home', :action => p
    end
    root to: 'home#content'
  end

  get '*path', to: 'page_renders#show'
  
end
