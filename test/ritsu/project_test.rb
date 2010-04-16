require File.dirname(__FILE__) + "/../test_helpers"

class ProjectTest < Test::Unit::TestCase  
  def setup
    Ritsu::Target.instances.clear
    Ritsu::SrcFile.instances.clear
    Ritsu::ExternalLibrary.instances.clear
  end

  must "create correctly" do
    hello = Ritsu::Project.create('hello')
    assert_equal 'hello', hello.name 
    assert_equal Set.new, hello.targets
    assert_equal Set.new, hello.external_libraries
  end
  
  ['53k', 'abc def', '???'].each do |project_name|
    must "raise exception if project name is #{project_name} (i.e., not a C name)" do
      assert_raises(ArgumentError) do
        Ritsu::Project.create(project_name)
      end
    end
  end
  
  ['mio', 'MikuMikuDance', '_Something'].each do |project_name|
    must "not raise exception if project name is #{project_name} (i.e., a valid C name)" do
      assert_nothing_raised do
        Ritsu::Project.create(project_name)
      end
    end
  end
  
  must "be able to add external libraries" do
    hello = Ritsu::Project.create('hello') do |p|
      p.add_external_library 'qt_core' do |e|
        e.cmake_name '${QT_LIBRARIES}'
        e.cmake_find_script <<-CMAKE
FIND_PACKAGE(Qt4 REQUIRED)
CMAKE
        e.cmake_depend_script <<-CMAKE
INCLUDE_DIRECTORIES(${QT_INCLUDE_DIR})
SET(QT_DONT_USE_QTGUI TRUE)
CMAKE
      end
      p.add_external_library 'qt_core_gui' do |e|
        e.cmake_name '${QT_LIBRARIES}'
        e.cmake_find_script <<-CMAKE
FIND_PACKAGE(Qt4 REQUIRED)
CMAKE
        e.cmake_depend_script <<-CMAKE
INCLUDE_DIRECTORIES(${QT_INCLUDE_DIR})
CMAKE
      end
      p.add_external_library 'qt_core_gui_opengl' do |e|
        e.cmake_name '${QT_LIBRARIES}'
        e.cmake_find_script <<-CMAKE
FIND_PACKAGE(Qt4 REQUIRED)
CMAKE
        e.cmake_depend_script <<-CMAKE
INCLUDE_DIRECTORIES(${QT_INCLUDE_DIR})
SET(QT_USE_OPENGL TRUE)
CMAKE
      end
    end
    
    assert_equal 3, hello.external_libraries.length
    assert hello.external_libraries.any? { |x| x.name == 'qt_core' }
    assert hello.external_libraries.any? { |x| x.name == 'qt_core_gui' }
    assert hello.external_libraries.any? { |x| x.name == 'qt_core_gui_opengl' }
  end
  
  must "be able to add targets" do
    hello = Ritsu::Project.create('hello') do |p|
      p.add_executable 'abc'
      p.add_shared_library 'def'
      p.add_static_library 'ghi'
    end
    
    assert_equal 3, hello.targets.length
    assert hello.targets.any? { |x| x.name == 'abc' }
    assert hello.targets.any? { |x| x.name == 'def' }
    assert hello.targets.any? { |x| x.name == 'ghi' }
  end
end