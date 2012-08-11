# enconding: utf-8
require 'rubygems'
require 'psych'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'thor/rake_compat'
require 'rake/testtask'
require 'rake'
begin
  require 'yard'
rescue LoadError
end

GEM_NAME = 'ritsu'
EXTRA_RDOC_FILES = FileList.new('*') do |list|
  list.exclude(/(^|[^.a-z])[a-z]+/)
  list.exclude('TODO')
end.to_a + ['Thorfile']

class Default < Thor
  include Thor::RakeCompat
      
  Rake::TestTask.new do |t|
    t.libs << 'lib'
    test_files = FileList['test/**/*_test.rb']
    t.test_files = test_files
    t.verbose = true
  end

  #if defined?(RDoc)
  #  RDoc::Task.new do |rdoc|
  #    rdoc.main = "README.rdoc"
  #    rdoc.rdoc_dir = "rdoc"
  #    rdoc.title = GEM_NAME
  #    rdoc.rdoc_files.include(*EXTRA_RDOC_FILES)
  #    rdoc.rdoc_files.include('lib/**/*.rb')
  #    rdoc.options << '--line-numbers' << '--inline-source'
  #  end
  #end
  
  #YARD::Rake::YardocTask.new do |t|
  #  t.files = FileList.new('lib/**/*.rb').to_a + EXTRA_RDOC_FILES
  #  t.options << '--incremental' if Rake.application.top_level_tasks.include?('redoc')
  #  #t.options += FileList.new(scope('yard/*.rb')).to_a.map {|f| ['-e', f]}.flatten
  #  files = FileList.new('doc-src/*').to_a.sort_by {|s| s.size} + %w[VERSION]
  #  t.options << '--files' << files.join(',')
  #  #t.options << '--template-path' << scope('yard')
  #  t.options << '--title' << ENV["YARD_TITLE"] if ENV["YARD_TITLE"]
  #end
  
  #desc "doc", "Generate YARD Documentation"
  #def doc
  #  yard
  #end
  
  begin
    require 'jeweler'
    Jeweler::Tasks.new do |s|
      s.name = GEM_NAME
      s.version = File.read(File.dirname(__FILE__) + '/VERSION').strip
      s.rubyforge_project = "ritsu"
      s.platform = Gem::Platform::RUBY
      s.summary = "A code generation system that facilitates building C/C++ software with the help of CMake"
      s.email = "dragonmeteor@gmail.com"
      s.homepage = "http://github.com/dragonmeteor/ritsu"
      s.description = "Ritsu is a tool to help generate CMakeLists.txt and other source code files in a C++ software project."
      s.authors = ['dragonmeteor']
      
      #s.has_rdoc = true
      #s.extra_rdoc_files = EXTRA_RDOC_FILES
      #s.rdoc_options += [
      #  '--title', 'Ritsu',
      #  '--main', 'README.md',
      #  '--line-numbers',
      #  '--inline-source'
      #]
      
      s.require_path = 'lib'
      s.bindir = "bin"
      s.executables = %w( ritsu define_cpp_string )
      s.files = s.extra_rdoc_files + Dir.glob("{bin,lib}/**/*")
      #s.test_files.include 'test/**/*'
      #s.test_files.exclude 'test/**/output/**'
    end

    Jeweler::GemcutterTasks.new
    
    desc "fast_install", "Install gem without RI and RDoc"
    def fast_install
      build
      version = File.read(File.dirname(__FILE__) + '/VERSION').strip
      sh "gem install pkg/ritsu-#{version}.gem --no-ri --no-rdoc"
    end
  rescue LoadError
    puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
  end
end