unit zfiles;

interface
uses zlib;

type
TZfile = record
        filename     :string;
        f            :file;
        compress     :boolean;
        data         :pointer;
        size         :longint;
        position     :longint;
        internal_size:longint;
        recsize      :word;
end;

Procedure zAssignFile(var f:tzfile; filename:string);
Procedure zReset(var f:tzfile; recsize:word=128);
Procedure zRewrite(var f:tzfile; recsize:word=128);
Procedure zBlockRead(var f:tzfile; var Buff; count:longint);
Procedure zBlockWrite(var f:tzfile; var Buff; count:longint);
Procedure zSeek(var f:tzfile; pos:longint);
Function zFilePos(var f:tzfile):longint;
Function zFileSize(var f:tzfile):longint;
Procedure zCloseFile(var f:tzfile; update:boolean=true);
Procedure zFlush(var f:tzfile);
Function zEof(var f:tzfile):boolean;
Procedure zTruncate(var f:tzfile; newsize:longint);
//------zlib compress & uncompress;

Procedure Zlib_compress_file(var f:file; buf:Pointer; size:longint);
Function Zlib_Uncompress_file(var f:file; var buf:Pointer; var size:longint):boolean;



implementation

Procedure zassignfile(var f:tzfile; filename:string);
begin
    f.filename:=filename;
    f.compress:=false;
    system.assignfile(f.f,filename);
end;

Procedure zReset(var f:tzfile; recsize:word=128);
begin
    system.reset(f.f,1);
    f.recsize:=recsize;
    f.position:=0;
    //Leer a memoria todo el archivo.
    //si zlib compressed leer con zlib.
    f.compress:=Zlib_Uncompress_file(f.f, f.data, f.size);
    f.internal_size:=f.size;
end;

Procedure zRewrite(var f:tzfile; recsize:word=128);
begin
    system.rewrite(f.f,1);
    f.size:=0;
    f.position:=0;
    f.recsize:=recsize;

    //crear buffer temporal;
    getmem(f.data,64*1024);
    f.internal_size:=64*1024;
end;


Procedure zBlockRead(var f:tzfile; var Buff; count:longint);
var
pos:longint;
begin
    count:=count*f.recsize;

    pos:=longint(f.data)+f.position;
    //si se desea leer mas bytes de los disponibles
    if count>(f.size-f.position) then count:=(f.size-f.position);
    move( pointer(pos)^, buff, count);
    f.position:=f.position+count;
end;

Procedure zBlockWrite(var f:tzfile; var Buff; count:longint);
var
pos:longint;
begin

    count:=count*f.recsize;

    pos:=longint(f.data)+f.position;
    //si se escriben mas bytes que el tama¤o disponible en buffer alloc mas memoria

    if count>(f.size-f.position) then f.size:=f.size+(count-(f.size-f.position));
    if count>(f.internal_size-f.position) then
    begin
       f.internal_size:=f.internal_size+(count-(f.internal_size-f.position))+(64*1024);
        reallocmem(f.data,f.internal_size);
        pos:=longint(f.data)+f.position;
    end;
    move( buff,pointer(pos)^,count);
    f.position:=f.position+count;
end;


Procedure zSeek(var f:tzfile; pos:longint);
begin
    if pos>f.size then pos:=f.size;
    f.position:=pos;
end;


Function zFilePos(var f:tzfile):longint;
begin
    zFilepos:=f.position;
end;


Function zFileSize(var f:tzfile):longint;
begin
   zFileSize:=f.size;
end;

Procedure zFlush(var f:tzfile);
begin
    if f.compress then zlib_compress_file(f.f, f.data, f.size)
    else
    begin
       system.seek(f.f,0);
       system.truncate(f.f);
       system.blockwrite(f.f,f.data^,f.size);
    end;
end;

Procedure zCloseFile(var f:tzfile; update:boolean=true);
begin

if update then
begin
    if f.compress then zlib_compress_file(f.f, f.data, f.size)
    else
    begin
       system.seek(f.f,0);
       system.truncate(f.f);
       system.blockwrite(f.f,f.data^,f.size);
    end;
end; //si update
    system.closefile(f.f);
    freemem(f.data);
    f.size:=0;
    f.position:=0;
    f.internal_size:=0;
end;

Function zEof(var f:tzfile):boolean;
begin
    zeof:=f.position=f.size;
end;

Procedure zTruncate(var f:tzfile; newsize:longint);
begin
  if newsize>f.internal_size then
  begin
     f.internal_size:=newsize+(64*1024);
     reallocmem(f.data,f.internal_size);
  end;
  f.size:=newsize;
  if f.position>f.size then f.position:=f.size;
end;


Procedure Zlib_Compress_File(var f:file; buf:Pointer; size:longint);
var
temp:pointer;
size2:integer;
signature:longint;
begin
    system.seek(f,0);
    system.truncate(f);
    Zlib_Compress(Buf, size, temp, size2);
    signature:=1112099930; // 'ZLIB'
    system.blockwrite(f,signature,4);
    system.blockwrite(f,size2,4);
    system.blockwrite(f,size,4);
    system.blockwrite(f,temp^,size2);
    freemem(temp);
end;


function Zlib_Uncompress_file(var f:file; var buf:Pointer; var size:longint):boolean;
var
temp:pointer;
size2:integer;
signature:longint;
zlib:boolean;
begin
    system.seek(f,0);
    zlib:=false;
    signature:=0;

    if system.filesize(f)>12 then system.blockread(f,signature,4);
    if signature=1112099930 then
    begin
         system.blockread(f,size2,4); //compressed size
         system.blockread(f,size,4); //uncompressed size
         getmem(temp,size2);
         system.blockread(f,temp^,size2);
         Zlib_decompress(temp, size2, size,buf, size);
         freemem(temp);
         zlib:=true;
    end;

    if not zlib then
    begin
        system.seek(f,0);
        size:=system.filesize(f);
        getmem(buf,size);
        system.blockread(f,buf^,size);
    end;

    Zlib_Uncompress_file:=zlib;

end;





end.


