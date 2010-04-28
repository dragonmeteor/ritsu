require File.dirname(__FILE__) + "/../test_helpers"

class TargetTest < Test::Unit::TestCase
  include Ritsu
  include Ritsu::Targets
  include Ritsu::SetupProjectAndClearEverythingElse
  
  must "contruct instances and keep track of them correctly" do
    Executable.new("abc")
    SharedLibrary.new("def")
    StaticLibrary.new("ghi")
    
    assert_equal 3, Target.instances.length
    
    assert Target.instances.any? {|x| x.name =='abc'}
    assert Target.instances.any? {|x| x.name == 'def'}
    assert Target.instances.any? {|x| x.name == 'ghi'}
    
    assert Target.instances.any? {|x| x.kind_of?(Executable)}
    assert Target.instances.any? {|x| x.kind_of?(SharedLibrary)}
    assert Target.instances.any? {|x| x.kind_of?(StaticLibrary)}
  end
  
  must "set the project to the default project if none is explicitly specified" do
    abc = Executable.new('abc')
    assert_equal @project, abc.project
  end
  
  must "upon creation, add the target to the given project" do
    abc = Executable.new('abc', :project => @project)
    assert_equal 1, @project.targets.length
    assert @project.targets.any? {|x| x.name == 'abc'}
  end
  
  def setup_abcd_dependency_tree
    @a = SharedLibrary.new('a')
    @b = SharedLibrary.new('b')
    @c = SharedLibrary.new('c')
    @d = StaticLibrary.new('d')

    @b.dependency_targets << @a
    @c.dependency_targets << @b
    @d.dependency_targets << @a
    
    @nodes = {:a => @a, :b => @b, :c => @c, :d => @d}
  end
  
  must "be able to determine which target it depends directly on" do
    setup_abcd_dependency_tree
    
    [[:b,:a], [:c,:b], [:d,:a]].each do |u,v|
      assert @nodes[u].depends_directly_on_target?(@nodes[v]), 
        "#{u} must depend directly on #{v}"
    end
    
    [[:c,:a], [:a,:b], [:b,:b], [:b,:d]].each do |u,v|
      assert !(@nodes[u].depends_directly_on_target?(@nodes[v])),
        "#{u} must not depend directly on #{v}"
    end    
  end
  
  must "be able to determine which target it depends on, even not directly, on" do
    setup_abcd_dependency_tree
    
    [[:b,:a], [:c,:b], [:c,:b], [:d,:a]].each do |u,v|
      assert @nodes[u].depends_on_target?(@nodes[v]), 
        "#{u} must depend on #{v}"
    end
    
    [[:a,:a], [:a,:b], [:a,:c], [:a,:d], [:b,:d], [:b,:c], [:c,:d], [:d,:c]].each do |u,v|
      assert !(@nodes[u].depends_on_target?(@nodes[v])), 
        "#{u} must not depend on #{v}"
    end
  end
  
  must "compute topological orders correctly" do
    setup_abcd_dependency_tree
    
    Target.compute_topological_orders
    
    [[:b,:a], [:c,:b], [:d,:a]].each do |u,v|
      assert @nodes[u].topological_order > @nodes[v].topological_order,
        "#{u} should come after #{v} in topological ordering"
    end
  end
  
  must "src_dir" do
    abc = Executable.new('abc')
    assert_equal "abc", abc.src_dir
  end
    
  must "compute src_path correctly" do
    abc = Executable.new('abc')
    assert_equal "abc/temp.cpp", abc.compute_src_path("temp.cpp")
  end
  
  must "compute src_path correctly relative to src" do
    abc = Executable.new('abc')
    assert_equal "xyz/temp.cpp", abc.compute_src_path("xyz/temp.cpp", :relative_to => :src)
  end
  
  must "compute src_path correct when the input is absolute" do
    abc = Executable.new('abc')
    assert_equal "../temp.cpp", abc.compute_src_path(@project.project_dir + "/temp.cpp", :relative_to => :absolute)
  end
end