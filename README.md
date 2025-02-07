# Cmsify

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cmsify'
```

And then execute:

```console
$ bundle install
```

Install and run the migrations

```console
$ rails cmsify:install:migrations
$ rake db:migrate
```

## Usage

Mount routes in `config/routes.rb`

```ruby
mount Cmsify::Engine => "/cmsify"
```

Create a `config/initializers/cmsify.rb` file similar to the following:

```ruby
Cmsify.setup do |config|
  config.app_name = "Dealer Portal CMS"
  config.stylesheet = 'https://example.com/path/to/stylesheet.css'
  config.branding = %(<i class="icomoon-superfeet "></i>
    <div class="uk-margin-small-left">#{ config.app_name }</div>)
  config.sign_out_path = '/admins/sign_out'
  config.asset_store_dir = 'some-folder-name'
  config.schema = {
    content_block: {
      name: { type: :string, required: true },
      body: { type: :text },
      background_image: { type: :attachment }
    },
    news: {
      name: { type: :string, required: true },
      published_at: { type: :datetime, required: true, label: "Publish Date" },
      excerpt: { type: :text, required: true, hint: "Character limit: 140" },
      body: { type: :text },
      hero_image: { type: :attachment }
    },
    resource: {
      name: { type: :string, required: true },
      thumbnail_image: { type: :image },
      download: { type: :attachment }
    }
  }
end
```

Generate admin panels for any existing ActiveRecord classes

```ruby
class Admin < ApplicationRecord
  cmsify
end
```

NOTE: currently the `cmsify` class method only supports non-namespaced model definitions. (ie. `Admin` and not `Dealer::Admin`)

### Authentication

Cmsify makes as few assumptions as possible about your authentication and resource authorization configuration. You are free to implement the authentication layer best suited to your app. You can then protect Cmsify behind an authentication layer in one of two main ways:

1. Extend `Cmsify::AuthenticatedController` (`app/controllers/cmsify/authenticated_controller.rb`)

    ```ruby
    class Cmsify::AuthenticatedController < ActionController::Base
      before_action :authenticate_admin!
    end
    ```

2. Place a constraint on the mounted engine routes.

    ```ruby
    is_admin = lambda do |request|
      current_user = request.env['warden'].user
      current_user.present? && current_user.is_a?(Admin)
    end

    constraints is_admin do
      mount Cmsify::Engine => "/cmsify"
    end

    constraints !is_admin do
      get '/cmsify', to: redirect('/admins/sign_in')
    end
    ```

3. Ensure your authentication views are using the correct layout.

    ```ruby
    Rails.application.config.to_prepare do
      Devise::SessionsController.layout proc { |controller| "cmsify/authenticated" }
      Devise::PasswordsController.layout proc { |controller| "cmsify/authenticated" }
      Devise::RegistrationsController.layout proc { |controller| "cmsify/authenticated" }
    end
    ```

### Content Permissions

1. Install and run the ActsAsTaggableOn migrations.

   ```
   rake acts_as_taggable_on_engine:install:migrations
   rake db:migrate
   ```

2. Ensure that a `current_user` helper exists which returns the currently logged in user.

    ```ruby
    helper_method :current_user

    def current_user
      get_current_user
    end
    ```

3. Define access tags schema. You can have one or more access factors by grouping different sets of tags.

    ```ruby
    Cmsify.setup do |config|
      config.access_tags = {
        language: [
          "Chinese - Mainland",
          "English - UK",
          "English - US",
          "French",
          "German",
          "Hungarian",
          "Japanese",
          "Korean",
          "Russian",
          "Spanish"
        ],
        level_of_access: [
          "Sales Materials",
          "Training",
          "Marketing Materials"
        ],
        market_segments: [
          "Education",
          "Healthcare",
          "Church",
          "Hospitals"
        ]
      }
    end
    ```

4. Using the ActsAsTaggableOn gem, tag content items with contexts prefixed with `cmsify_access_tags_` (ie. `cmsify_access_tags_level_of_access`).

5. Define a method on the user model called `access_tags` that returns a list of all tags which that user should have access to.

    ```ruby
    def access_tags
      { language: ["English"], level_of_access: ["Sales Materials"], market_segments: ["Healthcare", "Education"] }
    end
    ```

6. The user will now only see content which matches their defined `access_tags`. When using multi-factor tag groups, the user will need to have a matching tag among each group in order to access the content.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cmsify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
