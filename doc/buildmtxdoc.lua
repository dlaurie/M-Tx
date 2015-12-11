#! /usr/bin/texlua
-- buildmtxdoc.lua   © Dirk Laurie 2015  MIT license
-- Build M-Tx documentation from scratch.

local project = {halleluja = "-t kroonhom loofnou -f -q -p halleluja";
kanons = "-t viva dona sanctus -f -q -p kanons";
mtxdoc = "-t borup chord dertod dwoman macro"..
" melisma1 melisma2 melisma3 melisma4 melisma5 melisma6"..
" meter mozart mozart0 netfirst netsoos1 netsoos2 psalm42 title title1 volta"..
" -f -x -q -p mtxdoc"}

local sys = function(...)
   print(...)
   return(os.execute(...))
end

local cat = function(target,...)
   local result = io.open(target,'w')
   for k=1,select('#',...) do
      for line in io.open((select(k,...))):lines() do
         result:write(line,"\n")
      end
   end
   result:close()
end

local make_examples = function()
   cat("dwoman.mtx","dwoman.mta","dwoman.mtb")
   for k=1,2 do
      mtxname = ("netsoos%d.mtx"):format(k)
      cat(mtxname,"netsoos.mta",("netsoos%d.mtb"):format(k))
   end
   for k=1,6 do
      mtxname = ("melisma%d.mtx"):format(k)
      cat(mtxname,"melisma.mta",("melisma%d.mtb"):format(k))
   end
end

local build_project = function(target)
   if target == "mtxdoc" then 
      make_examples() 
   end
   sys("musixtex -q "..project[target])
end   

-- Main program

if type(arg)~='table' or not arg[1] then build_project"mtxdoc"
elseif project[arg[1]] then build_project(arg[1])
else print[[
This is buildmtxdoc version 0.1.
Usage:  [texlua] buildmtx.lua [project] 
Projects:
   mtxdoc
   halleluja
   kanons

If no project is specified, "mtxdoc" is built.]]
end
