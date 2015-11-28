#! /usr/bin/texlua
-- buildmtxdoc.lua   © Dirk Laurie 2015  MIT license
-- Build M-Tx documentation from scratch.

local papersize = "a4 "
-- papersize = ""  -- letter paper

local project = {halleluja = "kroonhom loofnou halleluja.tex";
kanons = "viva dona sanctus kanons.tex";
mtxdoc = "borup chord dertod dwoman macro"..
" melisma1 melisma2 melisma3 melisma4 melisma5 melisma6"..
" meter mozart mozart0 netfirst netsoos1 netsoos2 psalm42 title title1 volta"..
" mtxdoc.tex"}

local sys = os.execute

local cat = function(target,...)
   local result = io.open(target,'w')
   for k=1,select('#',...) do
      for line in io.open((select(k,...))):lines() do
         result:write(line,"\n")
      end
   end
   result:close()
end

local exists = function(filename)
   local f = io.open(filename)
   if f then f:close(); return true end
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

local build_project = function(target,options)
   options = options or ''
   if target == "mtxdoc" then make_examples() end
   sys("texlua mtxproject.lua "..options.." "..project[target])
end   

local mtx_pdf = function(papersize)
   build_project("mtxdoc","-i ")
   sys"makeindex mtxdoc" 
   sys"musixtex -1 -l -p mtxdoc"
   sys"musixtex -1 -l -p mtxindex"
   sys("texlua mtxproject.lua -x "..project.mtxdoc)
   if sys("pdftk mtxdoc.pdf mtxindex.pdf output mtx.pdf") ~= 0 then
      print"Can't find 'pdftk'. Doing this with 'gs', Please wait ..."    
      sys("gs -sPAPERSIZE="..papersize..
       " -q -dNOPAUSE-dBATCH -dSAFER -sDEVICE=pdfwrite "..
       "-sOutputFile -o mtx.pdf mtxdoc.pdf mtxindex.pdf")
   end
end

-- Main program

if type(arg)~='table' or not arg[1] then mtx_pdf(papersize)
elseif project[arg[1]] then build_project(arg[1])
else print[[
This is buildmtxdoc version 0.1.
Usage:  [texlua] buildmtx.lua [project] 
Projects:
   mtxdoc
   halleluja
   kanons

If no project is specified, "mtx.pdf" is built.]]
end
