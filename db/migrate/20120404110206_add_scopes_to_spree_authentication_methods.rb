class AddScopesToSpreeAuthenticationMethods < ActiveRecord::Migration
  def change
    add_column :spree_authentication_methods, :scopes, :string
  end
end
