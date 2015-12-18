os.execute ("zip mtxD" ..
   io.open"mtxdoc.ltx":read"*a":match"versionname{(.-)}":gsub("%.","") 
   .. " " .. table.concat(arg," "))
