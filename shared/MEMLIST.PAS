unit memlist;

interface

uses
Windows,SysUtils,Classes;


{  Unit listmem, por Turbo Pascal.
   esta unidad es utilizada para manejar tablas de datos en
   memoria, los registros son ordenados y encontrados rapidamente.

 * Se crea una variable tipo Tlistmem.
    - lista:=tlistmem.create;
 * Se usa el metodo lista.add(keyindex,datapointer);
   keyindex es la llave que se usara para ordenar, es caracter,
   se puede usar la funcion Vals(numero) para comvertir numeros a string alineados
   los cuales son usados para indexar usando numeros.
   datapointer es un puntero a un registro.

 * use <delete> para borrar el contenido de un registro, el registro queda disponible
   y la posicion de los demas registros no son afectados.
 * use <sort> para ordenar la lista. si el campo logico
   "sorted" es verdadero los registros se ordenan automaticamente.
   Por defecto sorted es falso.
 * use <insert> para insertar registros en la tabla.
 * use <move> para mover un registro hacia otra pocicion.
 * use exchange para intercambiar las posiciones de 2 registros.
 * use <Find> para localizar un registro por su keyindex.
 * use clear para borrar el contenido de todos los registros, los registros permanecen
   todavia en la tabla.
 * use pack para eliminar los registros.

 - El property <count> devuelve la cantidad de registros en la tabla
 - El property Records[registro] devuelve un puntero a los datos del registro via numero de registro.
 - El property Indexed[keyindex] devuelve un puntero a los datos del registro via el indice.
}
type
pnode = ^tnode;
tnode = record
        key:string;
        data:pointer;
end;


  Tlistmem = class
  public
    constructor Create;
    destructor Destroy; override;
  private
    FList: Tlist;
    { private methods }
  protected
    { property access }
    function GetData(const s: string): Pointer;
    procedure SetData(const s: string; p: Pointer);
    function GetCount:integer;
    function GetData2(const i: integer): Pointer;
    procedure SetData2(const i: integer; p: Pointer);

  public
    sorted:boolean;
    { public methods }
    procedure Add(const s: string; const p: Pointer);
    procedure delete(const i: integer);
    function  Find(const s: string): integer;
    procedure Clear;
    procedure Sort;
    procedure Exchange(const i1,i2:integer);
    procedure insert(const i:integer; const s: string; const p: Pointer);
    procedure Move(const i1,i2:integer);
    procedure pack;
    { properties }
    property count :integer read getcount;
    property indexed[const s: string]: Pointer read GetData write SetData;
    property Records[const i: integer]: Pointer read GetData2 write SetData2;default;

  end;

Function Vals(i:integer; long:integer=6):string;overload;
Function Vals(i:real; long:integer=8;decimals:integer=2):string;overload;


implementation

function comparefunc(item1,item2:pointer):integer;
begin
   if tnode(item1^).key<tnode(item2^).key then result:=-1 else
   if tnode(item1^).key=tnode(item2^).key then result:=0 else result:=1;
end;



constructor Tlistmem.Create;
begin
   flist:=tlist.create;
   flist.capacity:=1024; //tentantativamente.
   sorted:=false;
end;

destructor Tlistmem.Destroy;
begin
  inherited Destroy;
end;

function Tlistmem.Getcount: integer;
begin
   result:=flist.count;
end;


function Tlistmem.GetData(const s: string): Pointer;
var
i:integer;
begin
  i:=find(s);
  if (i>=0) then
    Result := tnode(flist.list[i]^).data
  else
    Result := nil;
end;

function Tlistmem.GetData2(const i: integer): Pointer;
begin

  if (i>=0) and (i<flist.count) then
    Result := tnode(flist.list[i]^).data
  else
    Result := nil;
end;


procedure Tlistmem.SetData(const s: string; p: Pointer);
var
i:integer;
begin
  i:=find(s);
  if (i>=0) then
      tnode(flist.list[i]^).data:=p
   else Add(s,p);
end;

procedure Tlistmem.SetData2(const i: integer; p: Pointer);
begin
  if (i>=0) and (i<=flist.count) then
      tnode(flist.list[i]^).data:=p;
end;


procedure tlistmem.Add(const s: string; const p: Pointer);
var
node:pnode;
begin
    new(node);
    node^.key:=s;
    node^.data:=p;
    flist.expand;
    flist.Add(node);
    if sorted then flist.Sort(comparefunc);
end;

procedure tlistmem.Sort;
begin
   flist.Sort(comparefunc);
end;

Function tlistmem.find(const s:string):integer;
var
primero,ultimo,central:integer;
posicion:integer;
begin
   posicion:=-1;
   if count=0 then begin find:=posicion;exit;end;
   if count=1 then begin if s=tnode(flist.Items[0]^).key then find:=0 else find:=-1;exit;end;

   if s=tnode(flist.Items[0]^).key then begin find:=0;exit;end;


   primero:=0;
   ultimo:=flist.count-1;


   repeat
      central:=(Primero + Ultimo) div 2;
      if s<tnode(flist.Items[central]^).key
         then
             ultimo:=central-1
         else
             if s>tnode(flist.Items[central]^).key
                then
                    primero:=central+1;
   until (s=tnode(flist.Items[central]^).key) or (primero>ultimo);
   if s = tnode(flist.Items[central]^).key
      then
         begin
              dec(central);
              while (s=tnode(flist.Items[central]^).key) do begin dec(central);if central<0 then break;end;
              posicion:=central+1;
         end;
   result:=posicion;
end;


procedure tlistmem.clear;
begin
   flist.clear;
end;

procedure tlistmem.delete(const i:integer);
begin
   flist.delete(i);
end;

procedure tlistmem.Exchange(const i1,i2:integer);
begin
   flist.exchange(i1,i2);
end;

procedure tlistmem.insert(const i:integer; const s: string; const p: Pointer);
var
node:pnode;
begin
    new(node);
    node^.key:=s;
    node^.data:=p;
    flist.expand;
    flist.insert(i,node);
end;

procedure tlistmem.Move(const i1,i2:integer);
begin
    flist.move(i1,i2);
end;

procedure tlistmem.pack;
begin
    flist.pack;
end;


Function Vals(i:integer; long:integer=6):string;overload;
var
s:string;
begin
   Str(I:long,s);
   result:=s;
end;

Function Vals(i:real; long:integer=8;decimals:integer=2):string;overload;
var
s:string;
begin
   Str(I:long:decimals,s);
   result:=s;
end;


end.
