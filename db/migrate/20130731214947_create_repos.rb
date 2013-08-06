class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.belongs_to :user
      t.string :full_name
      t.string :name
      t.string :default_branch
      t.string :description
      t.string :html_url
      t.string :language
      t.boolean :fork
      t.timestamps
    end
  end
end
