unit Regunit;

interface
uses registry;

Procedure OpenIniFile(name:string);
Procedure CloseIniFile;

Procedure WriteIni(Section:string; Varname:string; booldata:boolean);overload;
Procedure WriteIni(Section:string; Varname:string; Integerdata:integer);overload;
Procedure WriteIni(Section:string; Varname:string; Stringdata:string);overload;

Procedure ReadIni(Section:string; Varname:string; var booldata:boolean);overload;
Procedure ReadIni(Section:string; Varname:string; var Integerdata:integer);overload;
Procedure ReadIni(Section:string; Varname:string; var Stringdata:string);overload;



Procedure DeleteInifile;
Procedure DeleteSection(section:string);
Procedure DeleteVar(section:string; varname:string);


implementation
var
inifile:treginifile;

Procedure OpenIniFile(name:string);
begin
     if inifile<>nil then closeinifile;
     inifile:=treginifile.create(name);
end;
//------------------
Procedure Closeinifile;
begin
    if inifile<>nil then inifile.free;
    inifile:=nil;
end;
//-------------------
Procedure DeleteInifile;
var
  Cleanup: TRegistry;
  key: string;
begin
  if inifile=nil then exit;
  key := IniFile.FileName;
  IniFile.Free;
  inifile:=nil;
  // make sure we don't leave junk in the registry behind.
  Cleanup := TRegistry.Create;
  try
    Cleanup.DeleteKey(key);
  finally
    Cleanup.Free;
  end;
end;
//--------------------------------------------------

Procedure WriteIni(Section:string; Varname:string; booldata:boolean);overload;
begin
    if inifile=nil then exit;
    inifile.writebool(section,varname,booldata);
end;
//----------
Procedure WriteIni(Section:string; Varname:string; Integerdata:integer);overload;
begin
    if inifile=nil then exit;
    inifile.writeinteger(section,varname,integerdata);
end;
//----------
Procedure WriteIni(Section:string; Varname:string; Stringdata:string);overload;
begin
    if inifile=nil then exit;
    inifile.writestring(section,varname,stringdata);
end;
//----------

Procedure ReadIni(Section:string; Varname:string; var booldata:boolean);overload;
begin
    if inifile=nil then exit;
    booldata:=inifile.readbool(section,varname,false);
end;
//-------------
Procedure ReadIni(Section:string; Varname:string; var integerData:integer);overload;
begin
   if inifile=nil then exit;
   integerdata:=inifile.readinteger(section,varname,0);
end;
//--------------
Procedure ReadIni(Section:string; Varname:string; var stringdata:string);overload;
begin
    if inifile=nil then exit;
    stringdata:=inifile.readstring(section,varname,'');
end;
//--------------
Procedure DeleteSection(section:string);
begin
    if inifile=nil then exit;
    inifile.EraseSection(section);
end;

Procedure DeleteVar(section:string; varname:string);
begin
    if inifile=nil then exit;
    inifile.DeleteKey(section,varname);
end;

begin
    inifile:=nil;

end.
