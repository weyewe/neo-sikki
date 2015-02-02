class AddOfficeToGroupLoan < ActiveRecord::Migration
  def change
    add_column :group_loans, :office_id  , :integer
  end
end
