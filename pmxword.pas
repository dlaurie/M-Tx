type 

  pParsing = ^Parsing;
  
  Parsing = object  
    start, stop: integer;
    link: pParsing;
  constructor init(k1, k2: integer);
  destructor quit;
  procedure print(s: string);
  end;
  
  ParsedString = object
    s, expecting: string;
    p: pParsing;
    last: char;
    constructor init(s0: string);
    destructor quit;
    procedure print;
    procedure show(q: pParsing; tag: string);
    function expect(legal, target: string; k: integer): integer;
    procedure unexpected;
  end;

  ParsedNote = object(ParsedString)
    name, duration, octave, shortcut: pParsing;
    constructor init(s0: string);
    destructor quit;
  end;   

constructor Parsing.init(k1, k2: integer);
begin start:=k1; stop:=k2; link:=NIL end;

destructor Parsing.quit;
begin if link<>NIL then dispose(link,quit)
end;

procedure Parsing.print(s: string);
begin write(copy(s,start,stop-start),' ') end;

constructor ParsedString.init(s0: string);
begin s:=s0; p:=NIL end;

destructor ParsedString.quit;
begin if p<>NIL then dispose(p,quit) end;

procedure ParsedString.show(q: pParsing; tag: string);
begin if q<>NIL then begin q^.print(s); writeln(' => ',tag) end
end;

procedure ParsedString.print;
  var q: pParsing;
begin write(s,': '); q:=p;
  while q<>NIL do begin q^.print(s); q:=q^.link end;
  writeln
end;

function ParsedString.expect(legal, target: string; k: integer): integer;
  var j: integer;
begin expecting:=legal; if k<=length(target) then last:=target[k]
  else begin expect:=0; exit end;
  for j:=1 to length(legal) do if expecting[j]=last 
    then begin expect:=j; exit end else expect:=0;
end;

procedure ParsedString.unexpected;
begin writeln('Expecting "',expecting,'" but finding "',last,'"'); halt(10) end;

constructor ParsedNote.init(s0: string);
  var i, j: integer;
      old, now: pParsing;
begin ParsedString.init(s0); 
  name:=NIL; duration:=NIL; octave:=NIL; shortcut:=NIL; 
  j:=1; i:=expect('abcdefg',s,j); if i>0 then 
    begin new(now,init(j,j+1)); p:=now; name:=now; old:=now; j:=j+1 end
    else unexpected;
  i:=expect('02481369',s,j); if i>0 then 
    begin new(now,init(j,j+1)); duration:=now; old^.link:=now; old:=now; j:=j+1 end;
  i:=expect('1234567',s,j); if i>0 then 
    begin new(now,init(j,j+1)); octave:=now; old^.link:=now; old:=now; j:=j+1 end;
  while j<length(s) do 
  begin i:=expect('.,',s,j); if i>0 then
    begin new(now,init(j,length(s)+1)); old^.link:=now; shortcut:=now; break end
    else j:=j+1
  end;
  show(name,'name'); show(octave,'octave'); show(duration,'duration');
  show(shortcut,'shortcut');
end;

destructor ParsedNote.quit;
begin ParsedString.quit end;

var s: string;
    ps: parsedNote;

begin  
  repeat
    readln(s); ps.init(s); ps.print; if s='' then exit;
  until false
end.
