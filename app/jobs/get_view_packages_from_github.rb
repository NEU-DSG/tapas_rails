class GetViewPackagesFromGithub
  require "net/http"
  require "uri"
  include TapasRails::ViewPackages

  def initialize
  end

  def run
    if File.directory?(Rails.root.join("public/view_packages"))
      puts "directory exists"
      g = Git.open(Rails.root.join("public/view_packages"))
    else
      puts "directory does not exist"
      FileUtils.chmod 0775, Rails.root.join("public")
      g = Git.clone("https://github.com/NEU-DSG/tapas-view-packages.git", Rails.root.join("public/view_packages"))
    end
    g.fetch()
    g.checkout('feature/config-file') #for now TODO change this to develop or master when it is merged in - have it look for the environment - if production then use master, if staging then use develop, if development then use passed in branch or if none then use develop
    FileUtils.cd(Rails.root.join("public/view_packages"))
    system("git pull")
    system("git submodule update --init") #update or initialize any submodules, like tapas-generic
    directories = Dir.glob('*').select {|f| File.directory? f}
    view_packages = ViewPackage.where("").pluck(:dir_name).to_a
    directories.each do |dir_name|
      if view_packages.include?(dir_name)
        view = ViewPackage.where(dir_name: dir_name).first
      else
        view = ViewPackage.create(:dir_name => dir_name)
      end
      FileUtils.cd(Rails.root.join("public/view_packages/#{dir_name}"))
      view.machine_name = dir_name.sub("-","_")
      # look for config file
      puts view.inspect
      if File.exist?("PKG-CONFIG.xml") || File.exist?("CONFIG.xml")
        puts "config file exists"
        if File.exist?("PKG-CONFIG.xml")
          doc = File.open("PKG-CONFIG.xml") { |f| Nokogiri::XML(f) }
        elsif File.exist?("CONFIG.xml")
          doc = File.open("CONFIG.xml") { |f| Nokogiri::XML(f) }
        end
        puts doc
        view.git_branch = doc.css("view_package git_branch").text
        if (!view.git_branch.blank?)
          system("git checkout "+view.git_branch)
          system("git pull origin "+view.git_branch)
        end
        puts `git status`
        view.git_timestamp = `git log -1 --pretty=format:%ai 2>&1`
        view.human_name = doc.css("view_package human_name").text
        view.description = doc.css("view_package description").text
        css_files = []
        doc.css("view_package css_files css_file").each do |file|
          css_files << file.text
        end
        view.css_files = css_files
        js_files = []
        doc.css("view_package js_files js_file").each do |file|
          js_files << file.text
        end
        view.js_files = js_files
        file_types = []
        doc.css("view_package file_types file_type").each do |type|
          file_types << type.text
        end
        view.file_type = file_types
        params = {}
        doc.css("view_package parameters parameter").each do |param|
          params[param["name"].to_sym] = param.text
        end
        view.parameters = params
        process = doc.css("view_package run").first
        view.run_process = {}
        view.run_process[process["type"].to_sym] = process["pgm"]
        view.save!
        puts view
      else
        puts "No config file exists for the view_package #{dir_name}"
        view.delete
      end

    end
  end
end
