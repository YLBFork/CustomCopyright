require "fileutils"  


def copyFiles

  if File.exist?("product") then
    puts "exists product folder"
    #File.delete("product")
    FileUtils.remove_dir("product")

  end

  FileUtils.makedirs("product")


  Dir.foreach("Template") {|fileName|


    if !fileName.start_with?(".") then
     # puts( fileName)
      FileUtils.cp_r("Template" + "/" + fileName, "product")
    end



  }
end


