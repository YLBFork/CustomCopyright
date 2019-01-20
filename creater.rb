require 'json'


load "FileCopyTools.rb"
load "FilesNameUpdateModel.rb"




copyFiles()


manager = FilesNameUpdateModel.new()
manager.renameFile
manager.update_project_yml_file



system "xcodegen --spec product/project.yml"

manager.copy_IDETemplateMacros_plist


