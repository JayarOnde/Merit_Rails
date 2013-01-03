require 'merit/rule'
require 'merit/rules_badge_methods'
require 'merit/rules_points_methods'
require 'merit/rules_rank_methods'
require 'merit/controller_extensions'
require 'merit/model_additions'
require 'merit/judge'

module Merit
  # Check rules on each request
  mattr_accessor :checks_on_each_request
  @@checks_on_each_request = true

  # Define ORM
  mattr_accessor :orm
  @@orm = :active_record

  # Define user_model_name
  mattr_accessor :user_model_name
  @@user_model_name = "User"
  def self.user_model
    @@user_model_name.constantize
  end

  # Define current_user_method
  mattr_accessor :current_user_method
  def self.current_user_method
    @@current_user_method || "current_#{@@user_model_name.downcase}".to_sym
  end


  # Load configuration from initializer
  def self.setup
    yield self
  end

  class BadgeNotFound < Exception; end
  class RankAttributeNotDefined < Exception; end

  class Engine < Rails::Engine
    config.app_generators.orm Merit.orm

    initializer 'merit.controller' do |app|
      if Merit.orm == :active_record
        require 'merit/models/active_record/sash'
        require 'merit/models/active_record/badges_sash'
        require 'merit/models/active_record/merit/score'
      elsif Merit.orm == :mongoid
        require "merit/models/mongoid/sash"
      end

      ActiveSupport.on_load(:action_controller) do
        # Load application defined rules on application boot up
        # Test if constant exists (doesn't while installing/generating files)
        if defined? '::Merit::BadgeRules'
          ::Merit::AppBadgeRules = ::Merit::BadgeRules.new.defined_rules
        end
        if defined? '::Merit::PointRules'
          ::Merit::AppPointRules = ::Merit::PointRules.new.defined_rules
        end

        include Merit::ControllerExtensions
      end
    end
  end
end
