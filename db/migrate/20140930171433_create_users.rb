class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :cellphone
      t.string :password_digest
      t.string :name
      t.string :email
      t.integer :user_credential_id
      t.boolean :activated, :default=> false
      t.boolean :locked, :default=> false
      t.string :confirmation_hash

      t.timestamps
    end
  end
end
