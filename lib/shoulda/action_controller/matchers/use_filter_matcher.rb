module Shoulda # :nodoc:
  module ActionController # :nodoc:
    module Matchers
      
      # Ensures that a before filter is used for the specified action
      #
      # Example:
      #
      #   it { should use_before_filter(:authenticated_user).for(:update) }
      def use_before_filter(filter_method)
        UseFilterMatcher.new(:before, filter_method)
      end
      
      # Ensures that an after filter is used for the specified action
      #
      # Example:
      #
      #   it { should use_after_filter(:authenticated_user).for(:update) }
      def use_after_filter(filter_method)
        UseFilterMatcher.new(:after, filter_method)
      end
      
      # Ensures that an around filter is used for the specified action
      #
      # Example:
      #
      #   it { should use_around_filter(:authenticated_user).for(:update) }
      def use_around_filter(filter_method)
        UseFilterMatcher.new(:around, filter_method)
      end
      
      class UseFilterMatcher # :nodoc:
        class ControllerActionFacade
          attr_reader :action_name
          
          def initialize(controller_instance, action_name)
            @controller_instance = controller_instance
            @action_name = action_name.to_s
          end
          
          def method_missing(meth, *args)
            @controller_instance.send(meth, *args)
          end
        end
        
        def initialize(kind, filter_method)
          @kind = kind.to_sym
          @filter_method = filter_method.to_sym
        end
        
        def for(action_name)
          @action = action_name.to_s
          self
        end
        
        def matches?(controller)
          @controller = controller
          
          is_rails_3? ? rails_3_uses_filter? : rails_2_uses_filter?
        end
        
        def failure_message
          "Expected the #{@kind} filter :#{@filter_method} to be used for the #{@action} action"
        end
        
        def negative_failure_message
          "Did not expect the #{@kind} filter :#{@filter_method} to be used for the #{@action} action"
        end
        
        def description
          "use the #{@kind} filter :#{@filter_method} for the #{@action} action"
        end
        
        private
        
        def is_rails_3?
          defined?(Rails::Railtie)
        end
        
        def rails_2_uses_filter?
          potential_filters = @controller.class.filter_chain.select do |filter| 
            filter.send("#{@kind.to_s}?".to_sym) && filter.method == @filter_method.to_sym
          end
          return false if potential_filters.empty?
          potential_filters.first.send(:should_run_callback?, ControllerActionFacade.new(@controller, @action))
        end
        
        def rails_3_uses_filter?
          @controller.instance_variable_set(:@_action_name, @action)
          possibles = @controller.class._process_action_callbacks.select { |c| c.matches?(@kind, @filter_method) }
          return false if possibles.empty?
          possibles.find { |c| @controller.send("_one_time_conditions_valid_#{c.instance_variable_get(:@callback_id)}?") }
        end
      end
    end
  end
end
