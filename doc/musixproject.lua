#!/usr/bin/env texlua  

VERSION = "0.12p"

--[[
     musixproject.lua: processes MusiXTeX, PMX and M-Tx files 
        (and deletes intermediate files)

     (c) Copyright 2012-15 Bob Tennent rdt@cs.queensu.ca

     This program is free software; you can redistribute it and/or modify it
     under the terms of the GNU General Public License as published by the
     Free Software Foundation; either version 2 of the License, or (at your
     option) any later version.

     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
     Public License for more details.

     You should have received a copy of the GNU General Public License along
     with this program; if not, write to the Free Software Foundation, Inc.,
     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

--]]

--[[

  ChangeLog:

     version 0.12p 2015-11-29 DPL
      Process PMX and M-Tx files too

     version 0.12 2015-11-28 RDT
      Process .ltx files with -l implied

     version 0.11 2015-07-16 RDT
      Automatic autosp preprocessing. 

     version 0.10 2015-04-23 RDT
      Add -a option to preprocess using autosp

     version 0.9 2015-02-13 RDT
      Add an additional latex pass to resolve cross-references.
      Add -e0 option to dvips as given in musixdoc.tex
      Add -x option to call makeindex

     version 0.8 2014-05-18 RDT
      Add -g option

     version 0.7  2013-12-11 RDT
      Add -F fmt option

     version 0.6  2012-09-14 RDT
      Add -1 (one-pass [pdf][la]tex processing) option.

     version 0.5  2011-11-28 RDT
      Add -i (retain intermediate files) option.

     version 0.4  2011-04-30 RDT
       Allow multiple basenames (and options).
       Add -f (default) and -l (latex) options.

     version 0.3  2011-04-25 RDT
       Add -d (dvipdfm)  and -s (stop at dvi) options.

     version 0.2  2011-04-21 RDT
       Allow basename.tex as basename.
       Add -p option for pdfetex processing.
       Add standard -v -h options.

--]]

function usage()
  print("Usage:  [texlua] musixtex.lua { option | basename[.tex] | basename[.aspc] basename[.ltx] } ... ")
  print("options: -v  version")
  print("         -h  help")
  print("         -l  latex (or pdflatex) (implied with .ltx extension)")
  print("         -p  pdfetex (or pdflatex)")
  print("         -d  dvipdfm")
  print("         -s  stop at dvi")
  print("         -g  stop at ps")
  print("         -i  retain intermediate files")
  print("         -1  one-pass [pdf][la]tex processing")
  print("         -F fmt  use fmt as the TeX processor")
  print("         -X ext  use ext as default extension")
  print("         -x  run makeindex")
  print("         -a  preprocess using autosp (implied with .aspc extension)")
  print("         -f  restore default processing")
end

function whoami ()
  print("This is musixtex.lua version ".. VERSION .. ".")
end

function exists (filename)
  local f = io.open(filename, "r")
  if f then 
    f:close()
    print("Processing ".. filename )
    return true
  else
    print("No file: " .. filename )
  end
end

whoami()
if #arg == 0 then
  usage()
  os.exit(0)
end

-- defaults:
tex = "etex"  
musixflx = "musixflx"
dvips = "dvips -e0 "
dvi = dvips
ps2pdf = "ps2pdf"
intermediate = 1
passes = 2
index = 0
preprocess = 0
ext = "tex"

tmp = {}
exit_code = 0
narg = 1
repeat
  this_arg = arg[narg]
  if this_arg == "-v" then
    os.exit(0)
  elseif this_arg == "-h" then
    usage()
    os.exit(0)
  elseif this_arg == "-l" then
    if tex == "pdfetex" then
      tex = "pdflatex"
    else
      tex = "latex"
    end
  elseif this_arg == "-p" then
    if tex == "latex" then
      tex = "pdflatex"
    else
      tex = "pdfetex"
    end
    dvi = ""; ps2pdf = ""
  elseif this_arg == "-d" then
    dvi = "dvipdfm"; ps2pdf = ""
  elseif this_arg == "-s" then
    dvi = ""; ps2pdf = ""
  elseif this_arg == "-i" then
    intermediate = 0
  elseif this_arg == "-1" then
    passes = 1
  elseif this_arg == "-f" then
    tex = "etex"; dvi = dvips; ps2pdf = "ps2pdf"; intermediate = 1; passes = 2; index = 0; preprocess = 0
  elseif this_arg == "-g" then
    dvi = dvips; ps2pdf = ""
  elseif this_arg == "-x" then
    index = 1
  elseif this_arg == "-a" then
    preprocess = 1
  elseif this_arg == "-F" then
    narg = narg+1
    tex = arg[narg]
  elseif this_arg == "-X" then
    narg = narg+1
    ext = arg[narg]
print("Default extension is now "..ext)
  else
    repeat  -- pseudo loop to get effect of "continue" using "break"
      filename = this_arg
      if not filename:match"%." then-- no extension 
        filename = filename .. "." .. ext
      end
      basename = filename:match"(.*)%."
      if not exists(filename) then 
         break -- out of pseudo loop
      end
      if filename:match"%.pmx$" then
        if os.execute("pmxab "..basename)==0 then
          if intermediate==1 then table.insert(tmp,basename) end
        else 
          print("PMX processing of " .. filename " fails.\n")
          exit_code = 2
        end
        break
      end
      if filename:match"%.mtx$" then
        if os.execute("m-tx -t "..basename)==0 then
          if intermediate==1 then table.insert(tmp,basename) end
        else 
          print("M-Tx processing of " .. filename " fails.\n")
          exit_code = 2
        end
        break
      end
      if filename:match"%.aspc$" then
        preprocess = 1
        filename = filename:gsub("%.aspc$",".tex")
      elseif filename:match"%.ltx$" then
        if tex == "pdfetex" then
          tex = "pdflatex"
        else
          tex = "latex"
        end
      end
      if preprocess == 1 and os.execute("autosp " .. basename) ~= 0 then
        print ("Preprocessing fails.")
        break -- out of pseudo loop
      end
      os.remove( basename .. ".mx2" )
      if (passes == 1 or os.execute(tex .. " " .. filename) == 0) and
         (passes == 1 or os.execute(musixflx .. " " .. basename) == 0) and
         (os.execute(tex .. " " .. filename) == 0) and
         ((tex ~= "latex" and tex ~="pdflatex")
           or (index == 0)
           or (os.execute("makeindex -q " .. basename) == 0)) and
         ((tex ~= "latex" and tex ~= "pdflatex")
           or (os.execute(tex .. " " .. filename) == 0)) and
         ((tex ~= "latex" and tex ~= "pdflatex")
           or (os.execute(tex .. " " .. filename) == 0)) and
         ((tex ~= "latex" and tex ~= "pdflatex")
           or (os.execute(tex .. " " .. filename) == 0)) and
         (dvi == "" or  (os.execute(dvi .. " " .. basename) == 0)) and
         (ps2pdf == "" or (os.execute(ps2pdf .. " " .. basename .. ".ps") == 0) )
      then 
        if ps2pdf ~= "" then 
          print(basename .. ".pdf generated by " .. ps2pdf .. ".")
        end
        if intermediate == 1 then -- clean-up:
          os.remove( basename .. ".mx1" )
          os.remove( basename .. ".mx2" )
          if dvi ~= "" then
            os.remove( basename .. ".dvi" )
          end
          if ps2pdf ~= "" then 
            os.remove( basename .. ".ps" )
          end
        end
      else
        print("Musixtex processing of " .. filename " fails.\n")
        exit_code = 2
        --[[ uncomment for debugging
        print("tex = ", tex)
        print("dvi = ", dvi)
        print("ps2pdf = ", ps2pdf)
        --]]
      end
    until true  -- end of pseudo loop    
  end --if this_arg == ...
  narg = narg+1
until narg > #arg 

for _,basename in ipairs(tmp) do os.remove( basename .. ".tex" ) end
os.exit( exit_code )
