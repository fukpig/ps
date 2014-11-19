class CreateGroupToEmails < ActiveRecord::Migration
  def change
    create_table :group_to_emails do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :email_account_id

      t.timestamps
    end
  end
end
