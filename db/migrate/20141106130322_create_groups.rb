class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :email
      t.integer :domain_id

      t.timestamps
    end
  end
end
