require_relative "test_helper"

class AddIndex < ActiveRecord::Migration
  def self.up
    add_index :users, :name
  end
end

class AddIndexChange < ActiveRecord::Migration
  def change
    add_index :users, :name
  end
end

class AddIndexSafe < ActiveRecord::Migration
  def self.up
    add_index :users, :name, algorithm: :concurrently
  end
end

class AddIndexSafetyAssured < ActiveRecord::Migration
  def self.up
    safety_assured { add_index :users, :name, name: "boom" }
  end
end

class AddIndexSchema < ActiveRecord::Schema
  def self.up
    add_index :users, :name, name: "boom2"
  end
end

class AddColumnDefault < ActiveRecord::Migration
  def self.up
    add_column :users, :nice, :boolean, default: true
  end
end

class AddColumnDefaultSafe < ActiveRecord::Migration
  def self.up
    add_column :users, :nice, :boolean
    change_column_default :users, :nice, false
  end
end

class AddColumnJson < ActiveRecord::Migration
  def self.up
    add_column :users, :properties, :json
  end
end

class ChangeColumn < ActiveRecord::Migration
  def self.up
    change_column :users, :properties, :bad_name
  end
end

class RenameColumn < ActiveRecord::Migration
  def self.up
    rename_column :users, :properties, :bad_name
  end
end

class RenameTable < ActiveRecord::Migration
  def self.up
    rename_table :users, :bad_name
  end
end

class RemoveColumn < ActiveRecord::Migration
  def self.up
    remove_column :users, :name
  end
end

class StrongMigrationsTest < Minitest::Test
  def test_add_index
    assert_unsafe AddIndex
  end

  def test_add_index_change
    assert_unsafe AddIndexChange
  end

  def test_add_index_safety_assured
    assert_safe AddIndexSafetyAssured
  end

  def test_schema
    assert_safe AddIndexSchema
  end

  def test_add_index_safe
    assert_safe AddIndexSafe
  end

  def test_add_column_default
    assert_unsafe AddColumnDefault
  end

  def test_add_column_default_safe
    assert_safe AddColumnDefaultSafe
  end

  def test_add_column_json
    assert_unsafe AddColumnJson
  end

  def test_change_column
    assert_unsafe ChangeColumn
  end

  def test_rename_column
    assert_unsafe RenameColumn
  end

  def test_rename_table
    assert_unsafe RenameTable
  end

  def test_remove_column
    assert_unsafe RemoveColumn
  end

  def assert_unsafe(migration)
    assert_raises(StrongMigrations::UnsafeMigration) { migrate(migration) }
  end

  def assert_safe(migration)
    assert migrate(migration)
  end
end
