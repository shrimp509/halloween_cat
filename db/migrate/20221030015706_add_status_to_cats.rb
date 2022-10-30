class AddStatusToCats < ActiveRecord::Migration[7.0]
  def change
    add_column :cats, :status, :integer, default: 0
  end
end
