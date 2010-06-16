require 'test_helper'

class UseFilterMatcherTest < ActionController::TestCase # :nodoc:
  
  ["before", "after", "around"].each do |filter_kind|
    context "a controller that uses no #{filter_kind} filters" do
      setup do
        @controller = define_controller(:examples).new
      end
      
      should "reject using a #{filter_kind} filter for :show" do
        assert_rejects send("use_#{filter_kind}_filter", :filter_name).for(:show), @controller
      end
    end
    
    context "a controller that uses a #{filter_kind} filter" do
      setup do
        @controller = define_controller :examples do
          send("#{filter_kind}_filter", :filter_name)
          
          def filter_name
            true # dummy
          end
        end.new
      end
      
      should "accept using a #{filter_kind} filter for :show" do
        assert_accepts send("use_#{filter_kind}_filter", :filter_name).for(:show), @controller
      end
    end
    
    context "a controller that uses a #{filter_kind} filter with :only conditions" do
      setup do
        @controller = define_controller :examples do
          send("#{filter_kind}_filter", :filter_name, {:only => :show})
          
          def filter_name
            true # dummy
          end
        end.new
      end
      
      should "accept using a #{filter_kind} filter for :show" do
        assert_accepts send("use_#{filter_kind}_filter", :filter_name).for(:show), @controller
      end
      
      should "reject using a #{filter_kind} filter for :index" do
        assert_rejects send("use_#{filter_kind}_filter", :filter_name).for(:index), @controller
      end
    end
    
    context "a controller that uses a #{filter_kind} filter with :except conditions" do
      setup do
        @controller = define_controller :examples do
          send("#{filter_kind}_filter", :filter_name, {:except => :index})
          
          def filter_name
            true # dummy
          end
        end.new
      end
      
      should "accept using a #{filter_kind} filter for :show" do
        assert_accepts send("use_#{filter_kind}_filter", :filter_name).for(:show), @controller
      end
      
      should "reject using a #{filter_kind} filter for :index" do
        assert_rejects send("use_#{filter_kind}_filter", :filter_name).for(:index), @controller
      end
    end
  end
end