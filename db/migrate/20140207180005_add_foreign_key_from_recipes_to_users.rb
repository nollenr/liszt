class AddForeignKeyFromRecipesToUsers < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE recipes ADD CONSTRAINT recipes_fk_001 FOREIGN KEY (user_id) REFERENCES users(id)'
  end

  def down
    execute 'ALTER TABLE recipes DROP CONSTRAINT recipes_fk_001'
  end
end
