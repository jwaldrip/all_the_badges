class ChangeReposTable < ActiveRecord::Migration
  def up
    change_column :repos, :description, :text
  end

  def down
    change_column :repos, :description, :string
  end
end
