
#!/bin/bash


LOG_FILE=".temp.log"
SOURCE_TYPE="{(swift,h,m}"

removeIfExist() {
    if [ -f $1 ]; then
        rm $1
    fi
}


rename_copyright_method() {

    removeIfExist $LOG_FILE
    touch $LOG_FILE
  
    egrep "Copyright ©" -r $1 --include=*.{swift,h,m} -n >$LOG_FILE

  # echo $LOG_FILE


    cat $LOG_FILE | while read line; do
        # 行号


         lineNum=`echo $line | sed 's/.*:\([0-9]*\):.*/\1/g'`

    #     echo "**** $line *** "


     source=`echo $line |   cut -d ':'  -f 3`
  #   echo "$source #####"


      replaceText=`cat copyright.txt`
      # echo $replaceText



        # echo "lineNum = $lineNum"

        # # 文件路径
         path=${line%%:*}

        # echo "path = $path"

        # 一行可能有多个要替换的子串
       # echo  "${lineNum}s/${source:3}/$replaceText/g "

        sed -i "" "${lineNum}s/${source:3}/$replaceText/g" $path


    done

}

rename_copyright_method $1


