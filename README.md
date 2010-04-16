# Ritsu

Ritsu helps you with C/C++ software development. It provides you with a
domain specific language to specify a C/C++ project, and then automates
build project generation with the help of CMake.

## Using

### Generate a Project

Run 

    ritsu my_project
     
in command prompt to generate a project.
This will generate directory with the following contents:

    my_project
      build
      meta
        project.rb
      src
        cmake_modules
        --empty--
      Thorfile

### Specifying the Project
      
The file <tt>meta/project.rb</tt> specifies the project, and its
content is initially as follows.

    require 'ritsu'
    
    Ritsu::Project.create('my_project') do |p|
    
      ##################
      # YOUR CODE HERE #
      ##################
    
    end
    
You now can populate the <tt>src</tt> directory with your C/C++ source
and header files. For examples:

    my_project
      build
      meta
        project.rb
      src
        cmake_modules
        my_program
          lib.cpp
          lib.h
          main.cpp
      Thorfile


Then, you can specify targets to build as follows:

    require 'ritsu'
    
    Ritsu::Project.create('my_project') do |p|
      p.add_executable('my_program') do |e|
        e.add_cpp_file 'main.cpp'
        e.add_header_file 'lib.h'
        e.add_cpp_file 'lib.cpp'
      end
    end

As you can see, for each target (an executable or a library), 
you have to create a directory under <tt>src</tt>, which bears the 
same name as the project. The file names used in the <tt>add_cpp_file</tt>
and <tt>add_header_file</tt> commands  are relative to the directory of the target. 
You can bypass this behavior though.

### Building

To build the project, you first need to update the source files and
the <tt>CMakeLists.txt</tt> files for the project and for its targets. 
This is done by running a Thor command in the project directory.

    thor my_project:update_src
    
The source files and <tt>CMakeList</tt> files are generated if they are 
not present. From this point, you can either run cmake to 
generate platform-specific build scripts, or run

    thor my_project:cmake
    
which will create an out-of-source build scripts in the <tt>build</tt> directory.
The action

    thor my_project:update
    
combines the first two steps in one shot. Now, use your platform-specific 
tool to build the project.