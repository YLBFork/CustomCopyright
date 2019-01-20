require 'json'
require "fileutils"
require 'find'
load "FileCopyTools.rb"


class FilesNameUpdateModel

  def initialize() json = File.read('transfer.js')

  dic = JSON.parse(json)

  @parentPath = "product"

  @origin_project_name = "MyProject"

  @origin_APP_name = "MyApp"


  @origin_APP_unit_test_name = "MyUnitTests"
  @origin_APP_ui_test_name = "MyUITests"

  @origin_framework_name = "MyFramework"
  @origin_framework_unitTest_name = "MyFrameworkUnitTests"


  @destination_project_name = dic["projectName"]

  @destination_APP_name = dic["demoAPPName"]
  @destination_APP_unit_test_name = dic["demoAPPName"] + "UnitTests"
  @destination_APP_ui_test_name = dic["demoAPPName"] + "UITests"

  @destination_framework_name = dic["frameworkName"]
  @destination_framework_unitTest_name = dic["frameworkName"] + "UnitTests"


  @files_change_keys = {@origin_APP_name => @destination_APP_name, @origin_APP_unit_test_name => @destination_APP_unit_test_name, @origin_APP_ui_test_name => @destination_APP_ui_test_name, @origin_framework_name => @destination_framework_name, @origin_framework_unitTest_name => @destination_framework_unitTest_name
  }

  $copyright = "//  Copyright © 2019年 HSBC Holdings plc. All rights reserved.
//

//  This software is only to be used for the purpose for which it has been provided. No part of it is to be reproduced,
//  disassembled, transmitted, stored in a retrieval system nor translated in any human or computer language in any way
//  or for any other purposes whatsoever without the prior written consent of HSBC Holdings plc.
"

  end

  def get_files_change_keys()


    return @files_change_keys

  end

  def logDic()


  end

  def renameFile()

    @files_change_keys.each do |key, value|

      File.rename("#{@parentPath}/#{key}", "#{@parentPath}/#{value}")

      if File.exist?("#{@parentPath}/#{value}/#{key}.swift")
        File.rename("#{@parentPath}/#{value}/#{key}.swift", "#{@parentPath}/#{value}/#{value}.swift")
      end

      if File.exist?("#{@parentPath}/#{value}/#{key}.h")
        File.rename("#{@parentPath}/#{value}/#{key}.h", "#{@parentPath}/#{value}/#{value}.h")
      end

      #	FileUtils.mv  "#{@parentPath}/#{key}" , "#{@parentPath}/#{value}"


    end

    #		File.delete "#{@parentPath}/#{@origin_project_name}.xcodeproj"
    # 删掉原来的project
    FileUtils.remove_dir "#{@parentPath}/#{@origin_project_name}.xcodeproj", true

    # 改为rename ,这样可以省略拷贝 IDETemplateMacros.plist 的操作, 失败了有error信息
    #File.rename "#{@parentPath}/#{@origin_project_name}.xcodeproj", #{@parentPath}/#{@destination_project_name}.xcodeproj

    updateProjectsComment

  end


  def updateCopyRight(fileName)

    result = ""
    File.foreach(fileName) {|line|

      if line.include? "//  Copyright ©"
        result += $copyright
      else result += line
      end


    }

    IO.write(fileName, result)
    #  Copyright ©)

  end

  def updateTargetComment(old_target_name, new_target_name) filePath = "#{@parentPath}/#{new_target_name}"

  # 查找当前文件夹的 source code 文件
  Find.find filePath do |path|
    if !File.directory?(path) && (path.include?(".swift") || path.include?(".h"))

      updateComment path, old_target_name, new_target_name


    end


  end


  end

  def updateProjectsComment

    # 替换不同target 文件的文本 （copyright, targetName）
    @files_change_keys.each do |key, value|

      updateTargetComment key, value


    end
  end


# 具体的替换操作
  def updateComment(fileName, old_target_name, new_target_name)

    result = ""
    File.foreach(fileName) do |line|
      new_line = ""
      if line.include? "//  Copyright ©"
        new_line += $copyright
      else new_line += line
      end


      if new_line.include? "@testable import #{@origin_APP_name}"
        new_line = new_line.sub @origin_APP_name, @destination_APP_name
      end

      if new_line.include? "@testable import #{@origin_framework_name}"
        new_line = new_line.sub @origin_framework_name, @destination_framework_name
      end

      result += new_line.sub old_target_name, new_target_name
      #  if line.include? "@testable import #{@origin_APP_name}"
    end

    IO.write(fileName, result)

  end


  public def update_project_yml_file() result = ""

# use transfer.js value replace project.yml related key
  File.foreach("#{@parentPath}/project.yml") do |line|

    temp = line

    temp = temp.sub(@origin_project_name, @destination_project_name)
    temp = temp.sub(@origin_APP_name, @destination_APP_name)
    temp = temp.sub(@origin_framework_name, @destination_framework_name)
    temp = temp.sub(@origin_APP_ui_test_name, @destination_APP_ui_test_name)
    temp = temp.sub(@origin_APP_unit_test_name, @destination_APP_unit_test_name)
    temp = temp.sub(@origin_framework_unitTest_name, @destination_framework_unitTest_name)


    result += temp


  end


  aStringIO = StringIO.new(result)

  IO.write("#{@parentPath}/project.yml", result)
  end

  public def copy_IDETemplateMacros_plist()

    FileUtils.cp_r("IDETemplateMacros.plist", "#{@parentPath}/#{@destination_project_name}.xcodeproj/xcshareddata")

  end

end
