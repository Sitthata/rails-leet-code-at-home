class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.text :code
      t.string :status
      t.text :result

      t.timestamps
    end
  end
end
