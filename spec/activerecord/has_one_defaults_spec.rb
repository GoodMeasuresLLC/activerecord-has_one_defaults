require "spec_helper"

RSpec.describe Activerecord::HasOneDefaults do
  it "has a version number" do
    expect(Activerecord::HasOneDefaults::VERSION).not_to be nil
  end

  conn = { adapter: 'sqlite3', database: ':memory:' }

  ActiveRecord::Base.establish_connection(conn)

  class User < ActiveRecord::Base
    connection.create_table :users, force: true do |t|
      t.string :name, :email
      t.timestamps
    end

    has_one :head,    :default => {:eyes => 4, :ears => 6, :noses => 3}
    has_one :neck,    :default => true
    has_one :address, :default => false

    has_one :profile

    has_one :left_foot, :default => {:side => :left}, :class_name => "Foot"
    has_one :right_foot, :default => {:side => :right}, :class_name => "Foot"

    accepts_nested_attributes_for :left_foot
    accepts_nested_attributes_for :right_foot
  end

  class Head < ActiveRecord::Base
    connection.create_table :heads, force: true do |t|
      t.integer :eyes, :default => 2
      t.integer :ears, :default => 2
      t.integer :noses, :default => 1

      t.integer :user_id

      t.timestamps
    end

    belongs_to :user
  end

  class Neck < ActiveRecord::Base
    connection.create_table :necks, force: true do |t|
      t.integer :user_id
      t.timestamps
    end

    belongs_to :user
  end

  class Foot < ActiveRecord::Base
    connection.create_table :feet, force: true do |t|
      t.integer :user_id
      t.string :side
      t.float  :size
      t.timestamps
    end


    self.table_name = "feet"
    belongs_to :user
  end

  class Address < ActiveRecord::Base
    connection.create_table :addresses, force: true do |t|
      t.integer :user_id
      t.timestamps
    end

    belongs_to :user
  end

  class Profile < ActiveRecord::Base
    connection.create_table :profiles, force: true do |t|
      t.integer :user_id
      t.timestamps
    end

    belongs_to :user
  end

  it "Head has defaults" do
    expect(Head.new.eyes).to eq(2)
    expect(Head.new.ears).to eq(2)
    expect(Head.new.noses).to eq(1)
  end
  it "User has a head by default" do
    expect(User.new.head).to be_kind_of(Head)
    expect(User.new.head.eyes).to eq(4)
    expect(User.new.head.ears).to eq(6)
    expect(User.new.head.noses).to eq(3)
  end

  it "User has a neck" do
    expect(User.new.neck).to be_kind_of(Neck)
  end


  it "User does not have a address" do
    expect(User.new.address).to be_nil
  end

  it "User does not have a profile" do
    expect(User.new.profile).to be_nil
  end

  it "User has a left foot" do
    expect(User.new.left_foot.side).to eq("left")
  end

  it "builds with attributes" do
    u = User.new
    u.left_foot_attributes = {:size => 12.0}
    expect(u.left_foot.size).to eq(12.0)
  end
end
