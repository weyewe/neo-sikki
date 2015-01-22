class CreateValidCombs < ActiveRecord::Migration
  def change
    create_table :valid_combs do |t|

      t.timestamps
    end
  end
end
