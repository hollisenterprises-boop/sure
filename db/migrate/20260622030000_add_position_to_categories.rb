class AddPositionToCategories < ActiveRecord::Migration[7.2]
  def up
    add_column :categories, :position, :integer, null: false, default: 0
    add_index :categories, [ :family_id, :parent_id, :position ]

    execute <<~SQL
      WITH ordered AS (
        SELECT id, row_number() OVER (
          PARTITION BY family_id, parent_id ORDER BY name
        ) - 1 AS new_position
        FROM categories
      )
      UPDATE categories
      SET position = ordered.new_position
      FROM ordered
      WHERE categories.id = ordered.id
    SQL
  end

  def down
    remove_index :categories, [ :family_id, :parent_id, :position ]
    remove_column :categories, :position
  end
end
