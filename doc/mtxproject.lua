#! /usr/bin/env texlua
-- mtxproject.lua  © Dirk Laurie 2015   MIT license
-- Build PDF file from LaTeX, PMX and M-Tx source

local log = load""

local sys = function(command)
   log(command)
   return os.execute(command)
-- WARNING: Assuming pre-5.3 return codes for os.execute, which is still
--   the case for luatex as I write. THIS MAY CHANGE!
end

local version = "0.1"

local show_version = function()
   print (("This is mtxproject.lua version %s."):format(version))
end

local give_help = function()
   show_version()
   print[[
Usage:  [texlua] mtxproject.lua { option | filename } ... 
options: -v  version
         -h  help
         -i  retain intermediate and log files
         -x  delete intermediate and log files without rebuilding project
         -l  write log on standard output

The first filename ending in `.tex` is the main file, which will be 
processed by the usual multipass method using the `musixtex` script
with the `latex` option selected.

Before doing so, all filenames ending in `.mtx` or `.pmx` will be
processed to obtain the corresponding `tex` files. Filenames with
no extension are treated as if having extension `.mtx`.

Exit codes (useful when called in a script)
   1  Error in M-Tx file
   2  Error in PMX file
   3  No main file
   4  .ltx extension for main file is unsupported
   5  Error in main file
]]
end

local logfile = io.stdout

local delete_debris = function(arg,mainfile)
   for _,v in ipairs(arg) do 
      local basename =  v:match"(.*)%.mtx$" or v:match"(.*)%.pmx$" or
         (not v:match"%." and v)
      if basename then
         for ext in ("pml,tex"):gmatch"[^,]+" do 
            command = ("rm %s.%s"):format(basename,ext)
            sys(command)
         end
      end
   end
   mainfile = mainfile:match"(.*)%.tex$"
   for ext in ("aux,log,toc"):gmatch"[^,]+" do 
      sys(("rm %s.%s"):format(mainfile,ext))
   end
end

local obtain_mainfile = function(arg)
   for _,v in ipairs(arg) do
      if v:match"(.*)%.ltx$" or v:match"(.*)%.tex$" then
         log("Main file: ",v) 
         return v 
      end
   end
end

local process_files = function(arg)
   for _,v in ipairs(arg) do 
      if v:match"(.*)%.mtx$" or not v:match"%." then
         local command = ("m-tx -t %s"):format(v)
         if not sys(command) then return false,1 end
      elseif v:match"(.*)%.pmx$" then
         local command = ("pmxab -t %s"):format(v)
         if not sys(command) then return false,2 end
      end
   end 
   return true
end

local get_options = function (arg)
   local options,_arg = {},{}
   for k,v in ipairs(arg) do
      local option,value = v:match"^%-(.*)=(.*)"
      if not option then option=v:match"^%-(.*)" end
      if option then options[option]=value or true 
      else _arg[#_arg+1] = v
      end
   end
   return options,_arg
end

-- Main program

if type(arg)~='table' or not arg[1] or arg[1]=="-h" then
   give_help()
   return
end

local options
options, arg = get_options(arg)

if options.v or options.l then
   show_version()
end

if options.l then 
   if type(options.l)=="string" then logfile=io.open(options.l,"a+") end
   log = function(...) logfile:write(...); logfile:write"\n" end
end

local mainfile = obtain_mainfile(arg)
if not mainfile then
   print"No main file found!"
   os.exit(3) 
elseif mainfile:match"%.ltx$" then
   print ".ltx extension currently unsupported"
   os.exit(4)
end

if options.x then 
   delete_debris(arg,mainfile)
   return
end

local ok,code = process_files(arg) 
if not ok then os.exit(code) end

local command = ("musixtex -l -p %s"):format(mainfile)
if not sys(command) then os.exit(5) end
 
if not options.i then delete_debris(arg,mainfile) end

