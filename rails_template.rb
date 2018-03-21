russian     = yes? 'Will we use russian? ( yes/no || y/n )'
devise      = yes? 'Will we use devise? ( yes/no || y/n )'
rails_admin = yes? 'Will we use rails_admin? ( yes/no || y/n )'
paperclip   = yes? 'Will we use paperclip? ( yes/no || y/n )'
ckeditor    = yes? 'Will we use ckeditor? ( yes/no || y/n )'

rails_command 'db:setup'

gem 'unicorn'
gem 'rspec-rails'
gem 'apipie-rails'

gem 'russian' if russian
gem 'rails_admin' if rails_admin
gem 'devise' if devise

gem 'paperclip' if paperclip
gem 'ckeditor' if ckeditor

run 'bundle install'

generate 'rspec:install'
generate 'apipie:install'

application "config.i18n.default_locale = :ru" if russian

generate 'rails_admin:install' if rails_admin

generate 'devise:install' if devise
generate 'devise Admin' if devise

rails_command 'db:migrate' if devise

generate 'ckeditor:install --orm=active_record --backend=paperclip' if ckeditor

create_file "spec/test_spec.rb", "
require 'rails_helper'
# RSpec.describe SomeController, :type => :controller do
#   describe 'responds to' do
#     it 'displays something' do
#       get :index
#       json = JSON.parse(response.body)
#       expect(json['status']).to eql('ok')
#     end
#   end
# end"

inject_into_file 'config/initializers/apipie.rb', before: "end" do <<-'RUBY'
  config.translate = false
RUBY
end

initializer 'rails_admin.rb' do "
RailsAdmin.config do |config|
### Popular gems integration
  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true
  config.actions do
      dashboard                     # mandatory
      index                         # mandatory
      new
      export
      bulk_delete
      show
      edit
      delete
      show_in_app
  end
end"
end if rails_admin

inject_into_file 'app/assets/javascripts/application.js', before: "//= require_tree ." do <<-'RUBY'
//= require ckeditor/init
RUBY
end if ckeditor

root_controller = yes? 'Will we need a root controller?'
if root_controller
  root_controller_name = ask("What is my root controllers name?").underscore
  generate :controller, "#{root_controller_name} index"
  route "root to: '#{root_controller_name}\#index'"
end

append_file '.gitignore', "/.idea\n"
append_file '.gitignore', '/public/system'

run "git init"
run "git add ."
run "git commit -m 'Initial commit'"
repository = ask("Enter repository name: ")
run "git remote add origin #{repository}"
run "git push -u origin master"


