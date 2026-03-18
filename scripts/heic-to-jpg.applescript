on adding folder items to theFolder after receiving theFiles
  repeat with theFile in theFiles
    set filePath to POSIX path of theFile
    if filePath ends with ".heic" or filePath ends with ".HEIC" then
      set jpgPath to (text 1 thru -6 of filePath) & ".jpg"
      try
        do shell script "if [ ! -f " & quoted form of jpgPath & " ]; then sips -s format jpeg -s formatOptions 100 " & quoted form of filePath & " --out " & quoted form of jpgPath & "; fi"
      end try
    end if
  end repeat
end adding folder items to
