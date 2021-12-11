class AddDisplayNameToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :display_name, :string, after: :email
  end
end
