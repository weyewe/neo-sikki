class AddMemberIdToPrintError < ActiveRecord::Migration
  def change
  	add_column :print_errors, :member_id, :integer
  end
end
