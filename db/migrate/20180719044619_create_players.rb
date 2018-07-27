class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :username, null: false, index: true
      t.string :platform, null: false, index: true
      t.string :title, null: false, index: true
      t.json :data

      t.timestamps
    end
  end
end
