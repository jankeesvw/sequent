# frozen_string_literal: true

require 'spec_helper'

describe Sequent::Migrations::MigrateEvents do
  module Database
    class MigrateToVersion2
      @@called = false

      def self.called?
        @@called
      end

      def self.reset
        @@called = false
      end

      def initialize(_); end

      def version
        2
      end

      def migrate
        @@called = true
      end
    end

    class MigrateToVersion3
      @@called = false

      def self.called?
        @@called
      end

      def self.reset
        @@called = false
      end

      def initialize(_); end

      def migrate
        @@called = true
      end

      def version
        3
      end
    end

    class MigrateToVersion4
      def initialize(_); end

      def migrate
        fail 'for spec'
      end

      def version
        4
      end
    end
  end

  after :each do
    Database::MigrateToVersion2.reset
  end

  let(:subject) { described_class.new({}) }

  it 'runs when there is nothing to migrate' do
    subject.execute_migrations(0, 1)

    expect(Database::MigrateToVersion2.called?).to be_falsey
  end

  it 'runs a single migration' do
    subject.execute_migrations(1, 2)

    expect(Database::MigrateToVersion2.called?).to be_truthy
  end

  it 'runs all migrations' do
    subject.execute_migrations(1, 3)

    expect(Database::MigrateToVersion2.called?).to be_truthy
    expect(Database::MigrateToVersion3.called?).to be_truthy
  end

  it 'runs the after_hook' do
    @version = 0
    subject.execute_migrations(1, 2) do |version|
      @version = version
    end

    expect(@version).to eq(2)
  end

  it 'always runs the afterhook' do
    @after_hook_ran = false
    begin
      subject.execute_migrations(3, 4) do
        @after_hook_ran = true
      end
    rescue StandardError
      @exception_thrown = true
    end
    expect(@exception_thrown).to be_truthy
    expect(@after_hook_ran).to be_truthy
  end
end
