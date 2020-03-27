module CerberusCore
  class BaseModelsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc <<-eos
    Description: 
      Creates the three models (CoreFile, Collection, Community) that are 
      assumed to be the basis for any Cerberus-ish type head.  It will also
      create an empty directory called content_types, in which the content file 
      models required for the head ought to be defined.  It will also also create 
      an empty directory called datastreams, in which any new datastreams/extensions 
      of provided datastreams ought to go.

      WARNING: This generator adds three models to the current project which are 
      NOT namespaced out.      

      Example: 
        rails generate cerberus_core:base_models

      This will create: 
        app/models/core_file.rb
        app/models/collection.rb 
        app/models/community.rb 
        app/models/content_types/
        app/models/content_types/.gitkeep
        app/models/datastreams/
        app/models/datastreams/.gitkeep
      eos

    def copy_core_file 
      puts "Copying over core file model" 
      copy_file "core_file.rb", "#{Rails.root}/app/models/core_file.rb"  
    end

    def copy_collection
      puts "Copying over collection model"
      copy_file "collection.rb", "#{Rails.root}/app/models/collection.rb"
    end

    def copy_community 
      puts "Copying over community model" 
      copy_file "community.rb", "#{Rails.root}/app/models/community.rb"
    end

    def create_content_types_dir
      puts "Creating empty content_files directory" 
      empty_directory "#{Rails.root}/app/models/content_files"
      copy_file ".gitkeep", "#{Rails.root}/app/models/content_files/.gitkeep"
    end

    def create_datastreams_dir 
      puts "Creating empty datastreams directory"
      empty_directory "#{Rails.root}/app/models/datastreams"
      copy_file ".gitkeep", "#{Rails.root}/app/models/datastreams/.gitkeep"
    end
  end 
end 