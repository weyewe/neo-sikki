class CreateReimburseAssociations < ActiveRecord::Migration
  def change
    create_table :reimburse_associations do |t|

      t.timestamps
    end
  end
end
