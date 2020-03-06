unit Fexgraph;
{$h-}
{$WARNINGS OFF}
{$A-}
interface

uses
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls;

type
   rgbpal = record
   red,green,blue:byte;
end;


type
   rgbdpal = record
   red,green,blue,dumy:byte;
end;


type
tpaleta = array [0..255] of rgbdpal;
TRGBPALETA = array [0..255] of rgbpal;

     BMP = RECORD
         ANCHO,ALTO:CARDINAL;
         surface:POINTER;
         PALETA    :^trgbpaleta;
         VALIDO:STRING;
END;


     BMP16 = RECORD
         ANCHO,ALTO:CARDINAL;
         surface:POINTER;
END;


Tbmp_list = record
            bitmap:tbitmap;
            num_bmps:integer;
            paleta:pointer;
            bmps : array[1..3100] of bmp;
end;



Tbmp16_list = record
            bitmap:tbitmap;
            num_bmps:integer;
            bmps : array[1..3500] of bmp16;
end;




type
      pfont = ^tfont;
      tfont = RECORD
      ancho,alto :byte;
      LETRA      : array[32..255] of pointer;
END;


var
video:bmp;
cur_fnt:Pfont;

FUNCTION  LOADBMP(name:STRING;var FIGURA:BMP): byte;
PROCEDURE NEWBMP(var NUEVO:BMP;ANC,ALT:longint);
PROCEDURE NullBMP(var NUEVO:BMP;ANC,ALT:longint);

FUNCTION  LOADPAL(name:STRING;var paleta:tpaleta): byte;
FUNCTION  LOADRGBPAL(name:STRING;var paleta:trgbpaleta): byte;

PROCEDURE FREEBMP(var A:BMP);
function validbmp(var origen:bmp):boolean;
function validptr(var origen:bmp):boolean;

PROCEDURE PUTBMP(ORIGEN:BMP;DESTINO:POINTER);OVERLOAD;
PROCEDURE PUTBMP(ORIGEN:BMP; var DESTINO:tbitmap);OVERLOAD;
PROCEDURE PUTBMP(ORIGEN:tbitmap; var DESTINO:bmp);OVERLOAD;


//copiado de bitmaps sin trasparencia.
PROCEDURE PUTBMP(ORIGEN:BMP; DESTINO:BMP);OVERLOAD;
PROCEDURE PUTBMP(var ORIGEN:BMP; var DESTINO:BMP; Rx,Ry:real);OVERLOAD;
PROCEDURE PUTBMP(ORIGEN:BMP; rx1,ry1,rx2,ry2:real; DESTINO:BMP; rm,rn:real);OVERLOAD;
//copiado de bitmaps con trasparencia.
PROCEDURE PUTFIG(ORIGEN:BMP; DESTINO:BMP; col:byte=0);OVERLOAD;
PROCEDURE PUTFIG(ORIGEN:BMP; DESTINO:BMP; Rx,Ry:real;col:byte=0);OVERLOAD;
PROCEDURE PUTFIG(ORIGEN:BMP; rx1,ry1,rx2,ry2:real; DESTINO:BMP; rm,rn:real; col:byte=0);OVERLOAD;
procedure waitretrace2;
//copiado con operadores Or, Xor, And
procedure XorBmp(var ORIGEN:BMP; var DESTINO:BMP; Rx,Ry:real);
procedure OrBmp(var ORIGEN:BMP; var DESTINO:BMP; Rx,Ry:real);
procedure AndBmp(var ORIGEN:BMP; var DESTINO:BMP; Rx,Ry:real);

PROCEDURE CLEARBMP(var destino:bmp; dato:byte=0);
PROCEDURE ROTHORBMP(ORIGEN:BMP; var DESTINO:BMP );
PROCEDURE ROTVERBMP(ORIGEN:bmp; var DESTINO:BMP);

procedure LoadCharset(nom:string; var c:pfont);
PROCEDURE Text(Xpos,Ypos:Word;text:String; var destino:bmp);
PROCEDURE Text2(Xpos,Ypos:Word;text:String; var destino:bmp);

procedure Bmp2Bitmap(var a:bmp; var b:tbitmap);
procedure Bitmap2Bmp(a:tbitmap; var b:bmp);

procedure Pal2Hpal(var pal:Trgbpaleta; var hpal:hpalette);
procedure Hpal2Pal(hpal:hpalette;  var pal:Trgbpaleta);

procedure pset(x,y:integer; color:byte; var d:bmp);
Procedure Linea(a,b,c,d:integer;col:byte;var destino:bmp);

procedure make_grid(ancho,alto:byte; filas,columnas:word; color1,color2:byte; var destino:bmp);
procedure repaint_grid(ancho,alto:byte; filas,columnas:word; color1,color2:byte; var destino:bmp);
//----------------------------------------------------------
procedure add_bmp_list(var bmplist:tbmp_list; var bitmap:bmp); overload;
procedure select_bmp_list(var bmplist:tbmp_list; index:integer);overload;
procedure free_bmplist(var bmplist:tbmp_list);overload;

procedure add_bmp_list(var bmplist:tbmp16_list; var bitmap:bmp16);overload;
procedure select_bmp_list(var bmplist:tbmp16_list; index:integer);overload;
procedure free_bmplist(var bmplist:tbmp16_list);overload;
//------------

procedure xSetBitmapBits(var bitmap:tbitmap; size:longint; buf:pointer);
procedure xGetBitmapBits(var bitmap:tbitmap; size:longint; buf:pointer);

//FLIP BITMAPS;
procedure bitmap_flip_hor(var bitmap:tbitmap);
procedure bitmap_flip_ver(var bitmap:tbitmap);
//------------------------

//convert a 15 bits bitmap data to 16 bit bitmaps data
procedure fix16bitmap(var a:tbitmap);
procedure fix15bitmap(var p:pointer; size:longint);

{**************************************}

implementation

var
fvideomem:pointer;
{**********************************************}



//*****************************************************
function validbmp(var origen:bmp):boolean;
begin
     validbmp:=origen.valido='VALIDO';
end;

{**********************************************}

function validptr(var origen:bmp):boolean;
begin
     validptr:=(origen.surface<>fvideomem);
end;


{**********************************************}
FUNCTION LOADBMP(NAME:STRING;VAR FIGURA:BMP):BYTE;

var
archivo:file;
size:integer;
total:integer;
ancho,alto:integer;
temp:pointer;
ofseT:integer;
k:integer;
anch:integer;
begin
  ASSIGN(archivo,name);
  RESET(archivo,1);
  SEEK(archivo,2);
  BLOCKREAD(archivo,total,4);

  SEEK(archivo,18);
  BLOCKREAD(archivo,ANCHO,4);
  BLOCKREAD(archivo,ALTO,4);

  anch:=((total-1078) div alto);

  size:=ancho*alto;

  SEEK(archivo,$436);

  temp:=allocmem(anch);

  freebmp(figura);
  newbmp(figura,ancho,alto);
{  FIGURA.ANCHO:=ANCHO;
  FIGURA.ALTO:=ALTO;
  figura.valido:='VALIDO';}
  new(figura.paleta);

  ofset:=longint(figura.surface)+((ALTO*ANCHO));

  for K:=1 TO ALTO DO
      BEGIN
         ofset:=ofset-ANCHO;
         blockread(archivo,temp^,anch);
         move(TEMP^,ptr(ofset)^,ANCHO);
      END;


   CLOSE(archivo);
   FREEMEM(TEMP);
   loadrgbpal(name,figura.paleta^);
  loadBMP:=0;
end;

{**********************************************}

PROCEDURE FREEBMP(var A:BMP);
BEGIN
    IF (A.VALIDO='VALIDO') and (validptr(a)) THEN
    BEGIN
        FREEMEM(A.surface);
        a.ancho:=0;
        a.alto:=0;
        a.surface:=nil;
        a.valido:='';
        if a.paleta<>nil then dispose(a.paleta);
    END;
END;


procedure NEWBMP(var NUEVO:BMP;ANC,ALT:longint);
BEGIN
    if validptr(nuevo) then
    begin
    freebmp(nuevo);
    nuevo.surface:=allocmem(anc*alt);
    nuevo.ancho:=ANC;
    nuevo.alto:=alt;
    nuevo.valido:='VALIDO';
    nuevo.paleta:=nil;
    end;
END;

//---------------------------------------------------
procedure NullBMP(var NUEVO:BMP;ANC,ALT:longint);
BEGIN
    if validptr(nuevo) then
    begin
    freebmp(nuevo);
    nuevo.surface:=nil;
    nuevo.ancho:=ANC;
    nuevo.alto:=alt;
    nuevo.valido:='VALIDO';
    nuevo.paleta:=nil;
    end;
END;

{**********************************************}
FUNCTION LOADPAL(name:STRING;var paleta: tpaleta): byte;

var
archivo:file;
x:word;
xpaleta: array [0..255] of rgbdpal;
begin
  ASSIGN(archivo,name);
  RESET(archivo,1);
  SEEK(archivo,54);
  for x:=0 to 255 do
  begin
      BLOCKREAD(archivo,xpaleta[x],4);
      paleta[x].red  := xpaleta[x].red;
      paleta[x].green:= xpaleta[x].green;
      paleta[x].blue := xpaleta[x].blue;

  end;

CLOSE(archivo);
LOADPAL:=0;
end;

{**********************************************}
FUNCTION LOADrgbPAL(name:STRING;var paleta: trgbpaleta): byte;

var
archivo:file;
x:word;
xpaleta: array [0..255] of rgbdpal;
begin
  ASSIGN(archivo,name);
  RESET(archivo,1);
  SEEK(archivo,54);
  for x:=0 to 255 do
  begin
      BLOCKREAD(archivo,xpaleta[x],4);
      paleta[x].red  := xpaleta[x].blue shr 2;
      paleta[x].green:= xpaleta[x].green shr 2;
      paleta[x].blue := xpaleta[x].red shr 2;
  end;
CLOSE(archivo);
LOADrgbPAL:=0;
end;



{******************************************************}
PROCEDURE PUTBMP(ORIGEN:BMP;DESTINO:POINTER);
var
size:longint;
resto:word;
BEGIN
IF (NOT VALIDBMP(ORIGEN)) THEN EXIT;
size:=(origen.ancho*origen.alto)div 4;
resto:=(origen.ancho*origen.alto) mod 4;
asm
   push es
   mov ecx,size
   mov ax,ds
   mov edi,destino
   mov esi,origen.surface
   mov es,ax
   cld
   rep movsd
   cmp resto,0
   je @fin
   mov ecx,0
   mov cx,resto
   rep movsb
   @fin:
   pop es
end;

END;

{******************************************************}
PROCEDURE PUTBMP(ORIGEN:BMP; DESTINO:BMP);OVERLOAD;
var
size,size2:CARDINAL;
resto:word;
BEGIN
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
size2:=(origen.ancho*origen.alto);
if size2>(destino.ancho*destino.alto) then size2:=(destino.ancho*destino.alto);
size:=size2 div 4;
resto:=size2 mod 4;
asm
   push es
   mov ecx,size
   mov ax,ds
   mov edi,destino.surface
   mov esi,origen.surface
   mov es,ax
   cld
   rep movsd
   cmp resto,0
   je @fin
   mov ecx,0
   mov cx,resto
   rep movsb
   @fin:
   pop es
end;

END;


{******************************************************}
PROCEDURE PUTBMP(var ORIGEN:BMP; var DESTINO:BMP; Rx,Ry:real);OVERLOAD;

var
OFSETORI,OFSETDEST:cardinal;
DESPORI,LONGITUD:cardinal;
ALTO,ANCHO:CARDINAL;
XSI,XDI:cardinal;
IZQ,DER:cardinal;
TI:word;
AUX:CARDINAL;
X,Y:INTEGER;

BEGIN
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
X:=TRUNC(RX);
Y:=TRUNC(RY);

IF ((X+ORIGEN.ANCHO)<0) OR (X>(DESTINO.ANCHO)) OR ((Y+ORIGEN.ALTO)<0) OR (Y>(DESTINO.Alto)) THEN EXIT;

   OFSETORI:=CARDINAL(ORIGEN.SURFACE);

   ALTO:=ORIGEN.ALTO;
   ANCHO:=ORIGEN.ANCHO;

   IF (Y+ALTO)>DESTINO.ALTO THEN ALTO:=ALTO-((y+ALTO)-destino.alto);

   IF Y<0 THEN
   BEGIN
       TI:=ABS(Y);
       Y:=0;
   END
   ELSE
      TI:=0;

    IF TI>=ALTO THEN EXIT ELSE ALTO:=ALTO-TI;

    OFSETORI:=OFSETORI+(TI*ANCHO);


   IF X<0 THEN
      BEGIN
          DESPORI:=ABS(X);
          X:=0;
       END
    ELSE
        DESPORI:=0;

    if despori>ancho then exit;

    OFSETDEST:=CARDINAL(DESTINO.SURFACE);
    OFSETDEST:=OFSETDEST+((Y*DESTINO.ANCHO)+X);

    IF (X+ANCHO)>DESTINO.ANCHO THEN LONGITUD:=(DESTINO.ANCHO-X) ELSE LONGITUD:=ANCHO;

    LONGITUD:=LONGITUD-DESPORI;

    IZQ:=DESTINO.ANCHO-(X+LONGITUD);
    DER:=X;

    XSI:=OFSETORI;
    XDI:=OFSETDEST;

    AUX:=LONGITUD MOD 4;
    LONGITUD:=LONGITUD DIV 4;

   ASM

   PUSH ES
   MOV AX,DS
   MOV ES,AX
   MOV ECX,ALTO
   MOV EDI,XDI
   CLD

   @1:
   MOV ESI,XSI
   ADD ESI,DESPORI
   PUSH ECX
   MOV ECX,LONGITUD

   REP MOVSD

   CMP AUX,0
   JE @1B
   MOV ECX,AUX
   REP MOVSB

   @1B:

   POP ECX

   MOV EAX,XSI
   ADD EAX,ANCHO
   MOV XSI,EAX

   ADD EDI,IZQ
   ADD EDI,DER

   LOOP @1

   POP ES

  END;

end;


{******************************************************}
PROCEDURE PUTBMP( ORIGEN:BMP; rx1,ry1,rx2,ry2:real; DESTINO:BMP; rm,rn:real);OVERLOAD;

VAR
START,ANCHOT,ALTOT:cardinal;
xoff:cardinal;
ancho,alto:cardinal;
x1,y1,x2,y2,x3,y3:integer;
long,resto:cardinal;
BEGIN
//son el origen y destino bmps validos?
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
//truncar los decimales
x1:=trunc(rx1);
y1:=trunc(ry1);
x2:=trunc(rx2);
y2:=trunc(ry2);
x3:=trunc(rm);
y3:=trunc(rn);

//destino fuera de la pantalla?;
IF X3>(DESTINO.ANCHO) THEN exit;
IF Y3>(DESTINO.ALTO) THEN exit;

if x3<0 then begin x1:=x1+abs(x3);x3:=0;end;
if y3<0 then begin y1:=y1+abs(y3);y3:=0;end;

altoT:=origen.ALTO;
anchoT:=origen.ANCHO;

//hacer validas las cordenadas si estan fuera de rango
IF X1>(ANCHOT) THEN X1:=(ANCHOT);
IF X2>(ANCHOT) THEN X2:=(ANCHOT);
if y1>(altot) then y1:=(altot);
if y2>(altot) then y2:=(altot);

ANCHO:=abs(X2-X1)+1;
ALTO:=ABS(Y2-Y1)+1;

IF ANCHO>(DESTINO.ANCHO-X3) THEN ANCHO:=(DESTINO.ANCHO-X3);
IF ALTO>(DESTINO.ALTO-Y3) THEN ALTO:=(DESTINO.ALTO-Y3);


//start y xoff son las direcciones lineales del origen y destino
XOFF:=cardinal(DESTINO.surface)+(Y3*DESTINO.ANCHO)+X3;
START:=cardinal(origen.surface)+(Y1*ANCHOT)+X1;
long:=ancho div 4;
resto:=ancho mod 4;

ASM
   push es
   mov ax,ds
   mov es,ax
   mov ecx,alto
   cld
   @uno:
   mov esi,start
   mov edi,xoff
   push ecx
   mov ecx,long
   rep movsd
   cmp resto,0
   je @dos
   mov ecx,resto
   rep movsb
   @dos:
   mov eax,start
   add eax,anchot
   mov start,eax
   mov eax,xoff
   add eax,destino.ancho
   mov xoff,eax
   pop ecx
   loop @uno
   pop es

END;

END;

{******************************************************}
//putfig 1
PROCEDURE PUTFIG(ORIGEN:BMP; DESTINO:BMP; col:byte=0);OVERLOAD;
var
size,size2:CARDINAL;
BEGIN
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
size2:=(origen.ancho*origen.alto);
if size2>(destino.ancho*destino.alto) then size2:=(destino.ancho*destino.alto);

size:=size2+1;

asm
    mov eax,0
    push es
    mov ax,ds
    mov es,ax

    mov edi,origen.surface
    mov ecx,size

    cld

    @inicio:
    mov al,col
   //Buscar la primer posicion en memoria donde comienza un color<>col
    clc
    repe scasb

   //Preguntar si se detubo el REPE porque ecx=0 ó porque
   //encontró un color<>col
    cmp ecx,0
    je @fin

   //Se encontro un color<>col, salvar en EBX en que posicion se encontró
    mov ebx,edi
    dec ebx

   //ahora contar cuantos colores<>col consecutivos hay, buscando en
   //memoria donde empieza un color=col otravez.

    repne scasb

   //ok, ahora calcular la longitud del bloque de colores<>0 y guardarlo
   //en edx.

    mov edx,edi
    dec edx
    sub edx,ebx


   //Ok. ahora tenemos un bloque de memoria a transferir de EDX longitud
   //en EBX; hay que moverlo a DESTINO.SURFACE+DESPLAZAMIENTO.

    push ecx
    push edi

    mov ecx,edx //longitud
    mov esi,ebx //el origen

    sub ebx,origen.surface //obtener desplasamiento.
    mov edi,destino.surface //el destino.
    add edi,ebx //agregar el desplasamiento.

//*************************************************************************
//  se usa REP MOVSD para mayor velocidad.
     mov eax,edx
     mov edx,0
     mov ecx,4
     div ecx  //dividir la longitud en multiplos de 4.

     mov ecx,eax //cociente en eax, resto en edx.
     rep movsd
     cmp edx,0
     je @ok
     mov ecx,0
     mov cx,dx
     rep movsb
//************************************************************************
    @ok:

//  ok. ya se movio el bloque, ahora buscar el siguiente bloque.
    pop edi
    pop ecx
    add ecx,1
    loop @inicio
    @fin:
    pop es

end;

END;

{******************************************************}
{putfig2}
PROCEDURE PUTFIG(ORIGEN:BMP; DESTINO:BMP; Rx,Ry:real; COL:BYTE=0);OVERLOAD;

var
OFSETORI,OFSETDEST:cardinal;
DESPORI,LONGITUD:cardinal;
ALTO,ANCHO:CARDINAL;
XSI,XDI:cardinal;
IZQ,DER:cardinal;
TI:WORD;

X,Y:INTEGER;

XESI,XEDI:cardinal;

BEGIN
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
X:=TRUNC(RX);
Y:=TRUNC(RY);

IF ((X+ORIGEN.ANCHO)<0) OR (X>(DESTINO.ANCHO)) OR ((Y+ORIGEN.ALTO)<0) OR (Y>(DESTINO.Alto)) THEN EXIT;

   OFSETORI:=CARDINAL(ORIGEN.SURFACE);

   ALTO:=ORIGEN.ALTO;
   ANCHO:=ORIGEN.ANCHO;

   IF (Y+ALTO)>DESTINO.ALTO THEN ALTO:=ALTO-((y+ALTO)-destino.alto);

   IF Y<0 THEN
   BEGIN
       TI:=ABS(Y);
       Y:=0;
   END
   ELSE
      TI:=0;

    IF TI>=ALTO THEN EXIT ELSE ALTO:=ALTO-TI;

    OFSETORI:=OFSETORI+(TI*ANCHO);


   IF X<0 THEN
      BEGIN
          DESPORI:=ABS(X);
          X:=0;
       END
    ELSE
        DESPORI:=0;

    if despori>ancho then exit;

    OFSETDEST:=CARDINAL(DESTINO.SURFACE);
    OFSETDEST:=OFSETDEST+((Y*DESTINO.ANCHO)+X);

    IF (X+ANCHO)>DESTINO.ANCHO THEN LONGITUD:=(DESTINO.ANCHO-X) ELSE LONGITUD:=ANCHO;

    LONGITUD:=LONGITUD-DESPORI;

    IZQ:=DESTINO.ANCHO-(X+LONGITUD);
    DER:=X;

    XSI:=OFSETORI;
    XDI:=OFSETDEST;


   ASM

   PUSH ES
   MOV AX,DS
   MOV ES,AX
   MOV ECX,ALTO
   MOV EDI,XDI
   CLD

   @1:
   MOV ESI,XSI
   ADD ESI,DESPORI
   PUSH ECX
   MOV ECX,LONGITUD
//***** AQUI MUEVE UNA LINEA DE ECX LONGITUD
//SALVAR LOS REGISTROS DE ESTE PROCESO.
   MOV XESI,ESI
   MOV XEDI,EDI
 //===========================================
//===========================================
    inc ecx
    mov edi,esi

    @inicio:
    mov al,col
   //Buscar la primer posicion en memoria donde comienza un color<>col
    clc
    repe scasb

   //Preguntar si se detubo el REPE porque ecx=0 ó porque
   //encontró un color<>col
    cmp ecx,0
    je @fin

   //Se encontro un color<>col, salvar en EBX en que posicion se encontró
    mov ebx,edi
    dec ebx

   //ahora contar cuantos colores<>col consecutivos hay, buscando en
   //memoria donde empieza un color=col otravez.

    repne scasb

   //ok, ahora calcular la longitud del bloque de colores<>0 y guardarlo
   //en edx.

    mov edx,edi
    dec edx
    sub edx,ebx


   //Ok. ahora tenemos un bloque de memoria a transferir de EDX longitud
   //en EBX; hay que moverlo a DESTINO.SURFACE+DESPLAZAMIENTO.

    push ecx
    push edi

    mov ecx,edx //longitud
    mov esi,ebx //el origen

    sub ebx,XESI //obtener desplasamiento.
    mov edi,XEDI //el destino.
    add edi,ebx //agregar el desplasamiento.
//   mov test,ebx

//*************************************************************************
//  se usa REP MOVSD para mayor velocidad.
     mov eax,edx
     mov edx,0
     mov ecx,4
     div ecx  //dividir la longitud en multiplos de 4.
     mov ecx,eax //cociente en eax, resto en edx.
     rep movsd
     cmp edx,0
     je @ok
     mov ecx,0
     mov cx,dx
     rep movsb
//************************************************************************
    @ok:

//  ok. ya se movio el bloque, ahora buscar el siguiente bloque.
    pop edi
    pop ecx
    add ecx,1
    loop @inicio
    @fin:


//==========================================
//==========================================
   MOV ESI,XESI
   MOV EDI,XEDI

   ADD EDI,LONGITUD


   POP ECX

   MOV EAX,XSI
   ADD EAX,ANCHO
   MOV XSI,EAX

   ADD EDI,IZQ
   ADD EDI,DER

   LOOP @1

   POP ES

  END;

end;


{******************************************************}
//putfig3
PROCEDURE PUTFIG(ORIGEN:BMP; rx1,ry1,rx2,ry2:real; DESTINO:BMP; rm,rn:real; col:byte=0);OVERLOAD;

VAR
START,ANCHOT,ALTOT:cardinal;
xoff:cardinal;
ancho,alto:cardinal;
x1,y1,x2,y2,x3,y3:integer;
XESI,XEDI:cardinal;
BEGIN
//son el origen y destino bmps validos?
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
//truncar los decimales
x1:=trunc(rx1);
y1:=trunc(ry1);
x2:=trunc(rx2);
y2:=trunc(ry2);
x3:=trunc(rm);
y3:=trunc(rn);

//destino fuera de la pantalla?;
IF X3>(DESTINO.ANCHO) THEN exit;
IF Y3>(DESTINO.ALTO) THEN exit;

if x3<0 then begin x1:=x1+abs(x3);x3:=0;end;
if y3<0 then begin y1:=y1+abs(y3);y3:=0;end;

altoT:=origen.ALTO;
anchoT:=origen.ANCHO;

//hacer validas las cordenadas si estan fuera de rango
IF X1>(ANCHOT) THEN X1:=(ANCHOT);
IF X2>(ANCHOT) THEN X2:=(ANCHOT);
if y1>(altot) then y1:=(altot);
if y2>(altot) then y2:=(altot);

ANCHO:=abs(X2-X1)+1;
ALTO:=ABS(Y2-Y1)+1;

IF ANCHO>(DESTINO.ANCHO-X3) THEN ANCHO:=(DESTINO.ANCHO-X3);
IF ALTO>(DESTINO.ALTO-Y3) THEN ALTO:=(DESTINO.ALTO-Y3);

//start y xoff son las direcciones lineales del origen y destino
XOFF:=cardinal(DESTINO.surface)+(Y3*DESTINO.ANCHO)+X3;
START:=cardinal(origen.surface)+(Y1*ANCHOT)+X1;
//alto:=alto-1; // necesario porque se usara base 0.

ASM
   mov eax,0
   push es
   mov ax,ds
   mov es,ax
   mov ecx,alto
   cld
   @uno:
   mov esi,start
   mov edi,xoff
   push ecx
   mov ecx,ancho
//***** AQUI MUEVE UNA LINEA DE ECX LONGITUD
//SALVAR LOS REGISTROS DE ESTE PROCESO.
   MOV XESI,ESI
   MOV XEDI,EDI
 //===========================================
//===========================================
    inc ecx
    mov edi,esi

    @inicio:
    mov al,col
   //Buscar la primer posicion en memoria donde comienza un color<>col
    clc
    repe scasb

   //Preguntar si se detubo el REPE porque ecx=0 ó porque
   //encontró un color<>col
    cmp ecx,0
    je @fin

   //Se encontro un color<>col, salvar en EBX en que posicion se encontró
    mov ebx,edi
    dec ebx

   //ahora contar cuantos colores<>col consecutivos hay, buscando en
   //memoria donde empieza un color=col otravez.

    repne scasb

   //ok, ahora calcular la longitud del bloque de colores<>0 y guardarlo
   //en edx.

    mov edx,edi
    dec edx
    sub edx,ebx


   //Ok. ahora tenemos un bloque de memoria a transferir de EDX longitud
   //en EBX; hay que moverlo a DESTINO.SURFACE+DESPLAZAMIENTO.

    push ecx
    push edi

    mov ecx,edx //longitud
    mov esi,ebx //el origen

    sub ebx,XESI //obtener desplasamiento.
    mov edi,XEDI //el destino.
    add edi,ebx //agregar el desplasamiento.
//   mov test,ebx

//*************************************************************************
//  se usa REP MOVSD para mayor velocidad.
     mov eax,edx
     mov edx,0
     mov ecx,4
     div ecx  //dividir la longitud en multiplos de 4.
     mov ecx,eax //cociente en eax, resto en edx.
     rep movsd
     cmp edx,0
     je @ok
     mov ecx,0
     mov cx,dx
     rep movsb
//************************************************************************
    @ok:

//  ok. ya se movio el bloque, ahora buscar el siguiente bloque.
    pop edi
    pop ecx
    add ecx,1
    loop @inicio
    @fin:


//==========================================
//==========================================
     MOV ESI,XESI
     MOV EDI,XEDI

   mov eax,start
   add eax,anchot
   mov start,eax
   mov eax,xoff
   add eax,destino.ancho
   mov xoff,eax
   pop ecx
   loop @uno
   pop es

END;

END;

{******************************************************}

//-------------------------------------
PROCEDURE XORBMP(var ORIGEN:BMP; var DESTINO:BMP; Rx,Ry:real);

var
OFSETORI,OFSETDEST:cardinal;
DESPORI,LONGITUD:cardinal;
ALTO,ANCHO:CARDINAL;
XSI,XDI:cardinal;
IZQ,DER:cardinal;
TI:word;
AUX:CARDINAL;
X,Y:INTEGER;

BEGIN
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
X:=TRUNC(RX);
Y:=TRUNC(RY);

IF ((X+ORIGEN.ANCHO)<0) OR (X>(DESTINO.ANCHO)) OR ((Y+ORIGEN.ALTO)<0) OR (Y>(DESTINO.Alto)) THEN EXIT;

   OFSETORI:=CARDINAL(ORIGEN.SURFACE);

   ALTO:=ORIGEN.ALTO;
   ANCHO:=ORIGEN.ANCHO;

   IF (Y+ALTO)>DESTINO.ALTO THEN ALTO:=ALTO-((y+ALTO)-destino.alto);

   IF Y<0 THEN
   BEGIN
       TI:=ABS(Y);
       Y:=0;
   END
   ELSE
      TI:=0;

    IF TI>=ALTO THEN EXIT ELSE ALTO:=ALTO-TI;

    OFSETORI:=OFSETORI+(TI*ANCHO);


   IF X<0 THEN
      BEGIN
          DESPORI:=ABS(X);
          X:=0;
       END
    ELSE
        DESPORI:=0;

    if despori>ancho then exit;

    OFSETDEST:=CARDINAL(DESTINO.SURFACE);
    OFSETDEST:=OFSETDEST+((Y*DESTINO.ANCHO)+X);

    IF (X+ANCHO)>DESTINO.ANCHO THEN LONGITUD:=(DESTINO.ANCHO-X) ELSE LONGITUD:=ANCHO;

    LONGITUD:=LONGITUD-DESPORI;

    IZQ:=DESTINO.ANCHO-(X+LONGITUD);
    DER:=X;

    XSI:=OFSETORI;
    XDI:=OFSETDEST;

    AUX:=LONGITUD MOD 4;
    LONGITUD:=LONGITUD DIV 4;

   ASM

   PUSH ES
   MOV AX,DS
   MOV ES,AX
   MOV ECX,ALTO
   MOV EDI,XDI
   CLD

   @1:
   MOV ESI,XSI
   ADD ESI,DESPORI
   PUSH ECX
   MOV ECX,LONGITUD
   //mover ecx cantidad de bytes a Edi
   @1A:
     LODSD  //EAX tiene 4 bytes desde Esi
     XOR [edi],Eax
     ADD Edi,4
   LOOP @1A

   //--------
   CMP AUX,0
   JE @1B
   MOV ECX,AUX
   //mover el resto de los bytes pendientes
   @1Aa:
     LODSb  //Al tiene 1 bytes desde Esi
     XOR [edi],al
     ADD Edi,1
   LOOP @1Aa

   @1B:

   POP ECX

   MOV EAX,XSI
   ADD EAX,ANCHO
   MOV XSI,EAX

   ADD EDI,IZQ
   ADD EDI,DER

//   LOOPD @1
   LOOP @1

   POP ES

  END;

end;

//-------------------------------------
PROCEDURE ORBMP(var ORIGEN:BMP; var DESTINO:BMP; Rx,Ry:real);

var
OFSETORI,OFSETDEST:cardinal;
DESPORI,LONGITUD:cardinal;
ALTO,ANCHO:CARDINAL;
XSI,XDI:cardinal;
IZQ,DER:cardinal;
TI:word;
AUX:CARDINAL;
X,Y:INTEGER;

BEGIN
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
X:=TRUNC(RX);
Y:=TRUNC(RY);

IF ((X+ORIGEN.ANCHO)<0) OR (X>(DESTINO.ANCHO)) OR ((Y+ORIGEN.ALTO)<0) OR (Y>(DESTINO.Alto)) THEN EXIT;

   OFSETORI:=CARDINAL(ORIGEN.SURFACE);

   ALTO:=ORIGEN.ALTO;
   ANCHO:=ORIGEN.ANCHO;

   IF (Y+ALTO)>DESTINO.ALTO THEN ALTO:=ALTO-((y+ALTO)-destino.alto);

   IF Y<0 THEN
   BEGIN
       TI:=ABS(Y);
       Y:=0;
   END
   ELSE
      TI:=0;

    IF TI>=ALTO THEN EXIT ELSE ALTO:=ALTO-TI;

    OFSETORI:=OFSETORI+(TI*ANCHO);


   IF X<0 THEN
      BEGIN
          DESPORI:=ABS(X);
          X:=0;
       END
    ELSE
        DESPORI:=0;

    if despori>ancho then exit;

    OFSETDEST:=CARDINAL(DESTINO.SURFACE);
    OFSETDEST:=OFSETDEST+((Y*DESTINO.ANCHO)+X);

    IF (X+ANCHO)>DESTINO.ANCHO THEN LONGITUD:=(DESTINO.ANCHO-X) ELSE LONGITUD:=ANCHO;

    LONGITUD:=LONGITUD-DESPORI;

    IZQ:=DESTINO.ANCHO-(X+LONGITUD);
    DER:=X;

    XSI:=OFSETORI;
    XDI:=OFSETDEST;

    AUX:=LONGITUD MOD 4;
    LONGITUD:=LONGITUD DIV 4;

   ASM

   PUSH ES
   MOV AX,DS
   MOV ES,AX
   MOV ECX,ALTO
   MOV EDI,XDI
   CLD

   @1:
   MOV ESI,XSI
   ADD ESI,DESPORI
   PUSH ECX
   MOV ECX,LONGITUD
   //mover ecx cantidad de bytes a Edi
   @1A:
     LODSD  //EAX tiene 4 bytes desde Esi
     OR [edi],Eax
     ADD Edi,4
   LOOP @1A

   //--------
   CMP AUX,0
   JE @1B
   MOV ECX,AUX
   //mover el resto de los bytes pendientes
   @1Aa:
     LODSb  //Al tiene 1 bytes desde Esi
     OR [edi],al
     ADD Edi,1
   LOOP @1Aa

   @1B:

   POP ECX

   MOV EAX,XSI
   ADD EAX,ANCHO
   MOV XSI,EAX

   ADD EDI,IZQ
   ADD EDI,DER

   //LOOPD @1
   LOOP @1

   POP ES

  END;

end;

//-------------------------------------
PROCEDURE ANDBMP(var ORIGEN:BMP; var DESTINO:BMP; Rx,Ry:real);

var
OFSETORI,OFSETDEST:cardinal;
DESPORI,LONGITUD:cardinal;
ALTO,ANCHO:CARDINAL;
XSI,XDI:cardinal;
IZQ,DER:cardinal;
TI:word;
AUX:CARDINAL;
X,Y:INTEGER;

BEGIN
IF (NOT VALIDBMP(ORIGEN)) OR (NOT VALIDBMP(DESTINO)) THEN EXIT;
X:=TRUNC(RX);
Y:=TRUNC(RY);

IF ((X+ORIGEN.ANCHO)<0) OR (X>(DESTINO.ANCHO)) OR ((Y+ORIGEN.ALTO)<0) OR (Y>(DESTINO.Alto)) THEN EXIT;

   OFSETORI:=CARDINAL(ORIGEN.SURFACE);

   ALTO:=ORIGEN.ALTO;
   ANCHO:=ORIGEN.ANCHO;

   IF (Y+ALTO)>DESTINO.ALTO THEN ALTO:=ALTO-((y+ALTO)-destino.alto);

   IF Y<0 THEN
   BEGIN
       TI:=ABS(Y);
       Y:=0;
   END
   ELSE
      TI:=0;

    IF TI>=ALTO THEN EXIT ELSE ALTO:=ALTO-TI;

    OFSETORI:=OFSETORI+(TI*ANCHO);


   IF X<0 THEN
      BEGIN
          DESPORI:=ABS(X);
          X:=0;
       END
    ELSE
        DESPORI:=0;

    if despori>ancho then exit;

    OFSETDEST:=CARDINAL(DESTINO.SURFACE);
    OFSETDEST:=OFSETDEST+((Y*DESTINO.ANCHO)+X);

    IF (X+ANCHO)>DESTINO.ANCHO THEN LONGITUD:=(DESTINO.ANCHO-X) ELSE LONGITUD:=ANCHO;

    LONGITUD:=LONGITUD-DESPORI;

    IZQ:=DESTINO.ANCHO-(X+LONGITUD);
    DER:=X;

    XSI:=OFSETORI;
    XDI:=OFSETDEST;

    AUX:=LONGITUD MOD 4;
    LONGITUD:=LONGITUD DIV 4;

   ASM

   PUSH ES
   MOV AX,DS
   MOV ES,AX
   MOV ECX,ALTO
   MOV EDI,XDI
   CLD

   @1:
   MOV ESI,XSI
   ADD ESI,DESPORI
   PUSH ECX
   MOV ECX,LONGITUD
   //mover ecx cantidad de bytes a Edi
   @1A:
     LODSD  //EAX tiene 4 bytes desde Esi
     AND [edi],Eax
     ADD Edi,4
   LOOP @1A

   //--------
   CMP AUX,0
   JE @1B
   MOV ECX,AUX
   //mover el resto de los bytes pendientes
   @1Aa:
     LODSb  //Al tiene 1 bytes desde Esi
     AND [edi],al
     ADD Edi,1
   LOOP @1Aa

   @1B:

   POP ECX

   MOV EAX,XSI
   ADD EAX,ANCHO
   MOV XSI,EAX

   ADD EDI,IZQ
   ADD EDI,DER

   //LOOPD @1
   LOOP @1

   POP ES

  END;

end;



procedure WPORT(P:WORD;I,V:BYTE);
BEGIN
asm
   mov   dx, P
   mov   al, I
   out   dx, al

   inc   dx
   mov   al, V
   out   dx, al

end;
END;


procedure set_active_page(pag:byte);
var
x:word;
begin
if pag=0 then x:=0 else x:=16464;
WPORT($3D4,$0D,lo(x));
WPORT($3D4,$0c,hi(x));
end;

//================================
procedure WaitRetrace2;
begin
asm
      mov dx,3dah
@l1:
    in al,dx
    and al,8
    jnz @l1
@l2:
   in al,dx
   and al,8
   jz  @l2
end;
end;

procedure SetVga256;
begin

asm
  //mode 013h lineal
  mov dx,03c4h
  mov al,4
  out dx,al
  inc dx
  mov al,00001000b //poner modo lineal  4to bit=1 para lineal, 3er bit3=0 plano 0&2.
  out dx,al

  mov dx,03c4h
  mov al,2
  out dx,al
  inc dx
  mov al,00001111b //seleccionar todos los planos.
  out dx,al
  //****************

  mov dx,03d4h
  mov al,17h
  out dx,al
  inc dx
  in al,dx
  and al,10111111b //selecionar modo word.
  out dx,al

  //****************
  mov dx,03d4h
  mov al,14h
  out dx,al
  inc dx
  in al,dx
  or al,01000000b //selecionar modo doubleword.
  out dx,al
  //****************
 //ajustar el ancho y alto.
   mov   dx, 3d4h
   mov   al, 13h
   out   dx, al
   inc   dx
   mov   al, 40
   out   dx, al

  // seleccionar  banco de 128K
  mov dx,03ceh
  mov al,5
  out dx,al
  inc dx
  in al,dx
  mov al,01010000b
  out dx,al

end;
end;

//*****************************************************
PROCEDURE CLEARBMP(var destino:bmp; dato:byte=0);
var
ofse:pointer;
size:longword;
RESTO:WORD;
_eax:array [1..4] of byte;
BEGIN

if not validbmp(destino) then exit;
ofse:=destino.surface;
size:=(destino.ancho*destino.alto) DIV 4;
RESTO:=(destino.ancho*destino.alto) MOD 4;
FILLCHAR(_EAX,4,DATO);

ASM
  CLD
  MOV EDI,ofse
  MOV EAX,_EAX
  MOV ECX,size
  REP STOSD
  CMP RESTO,0
  JE @FIN
  MOV CX,RESTO
  STOSB
@FIN:

END;


END;


//*******************************************************

PROCEDURE ROTHORBMP(ORIGEN:BMP; VAR DESTINO:BMP );

VAR
ANC,ALT,SIZE,DIROFS1,DIROFS2:LONGINT;
TEMP:BMP;
ANC2:LONGINT;
AUX:BYTE;

BEGIN;


if NOT VALIDBMP(ORIGEN) then exit;

IF DESTINO.SURFACE<>ORIGEN.SURFACE THEN
BEGIN
   FREEBMP(DESTINO);
   NEWBMP(DESTINO,ORIGEN.ANCHO,ORIGEN.ALTO);
END
ELSE
BEGIN
    NEWBMP(TEMP,ORIGEN.ANCHO,ORIGEN.ALTO);
    PUTBMP(ORIGEN,TEMP);
    NEWBMP(DESTINO,TEMP.ANCHO,TEMP.ALTO);
    ORIGEN:=TEMP;
END;

DIROFS1:=LONGINT(ORIGEN.SURFACE);
DIROFS2:=LONGINT(DESTINO.SURFACE);
SIZE:=DESTINO.ALTO*DESTINO.ANCHO;
ALT:=ORIGEN.ALTO;
ANC:=ORIGEN.ANCHO;
DIROFS1:=DIROFS1+ANC-2;

AUX:=ANC MOD 2;
ANC2:=ANC DIV 2;

ASM

   MOV ECX,ALT
   MOV ESI,DIROFS1
   MOV EDI,DIROFS2

  @1:
   PUSH ECX
   MOV ECX,ANC2
   MOV EAX,0

   CMP ECX,0
   JE @NON

   @2:
   MOV AH,[ESI]
   MOV AL,[ESI+1]
   MOV [EDI],AX
    ADD EDI,2
    SUB ESI,2
  LOOP @2

   @NON:
   CMP AUX,0
   JE @FIN1
   MOV AL,[ESI]
   MOV [EDI],AL
   INC EDI
   DEC ESI

   @FIN1:
   POP ECX

   ADD ESI,ANC
   ADD ESI,ANC
   LOOP @1

END;

FREEBMP(TEMP);

END;

//********************************************************
PROCEDURE ROTVERBMP(ORIGEN:bmp; VAR DESTINO:BMP);

VAR
ANC,ALT,SIZE:LONGINT;
DIROFS1,DIROFS2:LONGINT;
TEMP:BMP;
ANC2:LONGINT;
AUX:BYTE;

BEGIN;

if NOT VALIDBMP(ORIGEN) then exit;

IF DESTINO.SURFACE<>ORIGEN.SURFACE THEN
BEGIN
   FREEBMP(DESTINO);
   NEWBMP(DESTINO,ORIGEN.ANCHO,ORIGEN.ALTO);
END
ELSE
BEGIN
    NEWBMP(TEMP,ORIGEN.ANCHO,ORIGEN.ALTO);
    PUTBMP(ORIGEN,TEMP);
    NEWBMP(DESTINO,TEMP.ANCHO,TEMP.ALTO);
    ORIGEN:=TEMP;
END;

DIROFS1:=LONGINT(ORIGEN.SURFACE);
DIROFS2:=LONGINT(DESTINO.SURFACE);
SIZE:=DESTINO.ALTO*DESTINO.ANCHO;
ALT:=ORIGEN.ALTO;
ANC:=ORIGEN.ANCHO;
DIROFS1:=DIROFS1+size-2;

AUX:=ANC MOD 2;
ANC2:=ANC DIV 2;

ASM

   MOV ECX,SIZE
   MOV ESI,DIROFS1
   MOV EDI,DIROFS2

   MOV EAX,0

   @1:
    MOV AL,[ESI]
    MOV [EDI],AL
    INC EDI
    dec ESI
    LOOP @1

END;

FREEBMP(TEMP);

END;

{************************************************}
procedure LoadCharset(nom:string; var c:pfont);
var
f:file;
x:word;
k:byte;

id:string[3];
letras:byte;
ancho,alto:word;


begin

    assign(f,nom);
    reset(f,1);

blockread(f,id,sizeof(id));
blockread(f,letras,sizeof(letras));
blockread(f,ancho,sizeof(ancho));
blockread(f,alto,sizeof(alto));

c^.ancho:=trunc(ancho);
c^.alto:= trunc(alto);


k:=32;

    for x:=1 to letras do
    begin
        getmem( c^.letra[k],ancho*alto);

//        IF c^.letra[k]=NIL THEN BEGIN SCREEN0;writeln('Error Cargando las letras.');halt;end;
        blockread(f,c^.letra[k]^,ancho*alto);
        k:=k+1;
    end;
    close(f);
    cur_fnt:=C;
end;

{************************************************}



PROCEDURE Text(Xpos,Ypos:Word;text:String; var destino:bmp);
var
L:bmp;
i:byte;

BEGIN
    l.ancho:=cur_fnt^.ancho;
    l.alto :=cur_fnt^.alto;
    l.VALIDO:='VALIDO';

  for i:=1 to length(Text) do
      begin
        l.surface:=cur_fnt^.letra[ord(text[i])];
        putFIG(l,destino,xpos,ypos);
        xpos:=xpos+l.ancho;
   end;


END;

//***************************
PROCEDURE Text2(Xpos,Ypos:Word;text:String; var destino:bmp);
var
L:bmp;
i:byte;

BEGIN
    l.ancho:=cur_fnt^.ancho;
    l.alto :=cur_fnt^.alto;
    l.VALIDO:='VALIDO';

  for i:=1 to length(Text) do
      begin
        l.surface:=cur_fnt^.letra[ord(text[i])];
        putbmp(l,destino,xpos,ypos);
        xpos:=xpos+l.ancho;
   end;


END;

//***********************

procedure Bmp2Bitmap(var a:bmp; var b:tbitmap);
var
plog : PLogPalette;
x:integer;
pp:tagpaletteentry;
begin
  if a.paleta=nil then exit;
  plog:=nil;
  GetMem(plog, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);
  plog.palVersion := $300;
  plog.palNumEntries := 256;

  for x:=0 to 255 do
  begin
     plog.palPalEntry[x].peRed :=a.paleta^[x].red shl  2;
     plog.palPalEntry[x].peGreen:=a.paleta^[x].green shl 2;
     plog.palPalEntry[x].peBlue :=a.paleta^[x].blue shl 2;
     plog.palPalEntry[x].peflags:=0;



  end;
  b.Width:=a.ancho;
  b.height:=a.alto;
  b.PixelFormat:=pf8bit;
  b.Palette := CreatePalette(plog^);
  SetBitmapBits(b.handle, a.ancho*a.alto, a.surface);
  freemem(plog);
end;
//----------------------------------------
procedure Bitmap2Bmp(a:tbitmap; var b:bmp);
begin
  b.ancho:=a.Width;
  b.alto:=a.height;
  xgetBitmapBits(a, b.ancho*b.alto, b.surface);
end;

//--------------------------------------
PROCEDURE PUTBMP(ORIGEN:BMP; var DESTINO:tbitmap);OVERLOAD;
begin
  xSetBitmapBits(destino, origen.ancho*origen.alto, origen.surface);
end;

//-------------------------------------
PROCEDURE PUTBMP(ORIGEN:tbitmap; var DESTINO:bmp);OVERLOAD;
begin
  xgetBitmapBits(origen, destino.ancho*destino.alto, destino.surface);
end;

//--------------------------------------------
procedure Pal2Hpal(var pal:Trgbpaleta; var hpal:hpalette);
var
plog : PLogPalette;
x:integer;
begin
  plog:=nil;
  GetMem(plog, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);
  plog.palVersion := $300;
  plog.palNumEntries := 256;

  for x:=0 to 255 do
  begin
     plog.palPalEntry[x].peRed :=pal[x].red shl  2;
     plog.palPalEntry[x].peGreen:=pal[x].green shl 2;
     plog.palPalEntry[x].peBlue :=pal[x].blue shl 2;
     plog.palPalEntry[x].peflags:=0;
  end;
  hpal := CreatePalette(plog^);
  freemem(plog);
end;

//---------------------------------------------------------
procedure Hpal2Pal(hpal:hpalette; var pal:Trgbpaleta);
begin

end;


{**************************************}
procedure pset(x,y:integer; color:byte; var d:bmp);
begin
  if (x<0) or (X>d.ancho-1) OR (Y<0) OR (Y>d.alto-1) then exit;
  byte(ptr(cardinal(d.surface)+(y*d.ancho)+x)^):=color;
end;

{**************************************}
Procedure Linea(a,b,c,d:integer;col:byte;var destino:bmp);
  { This draws a solid line from a,b to c,d in colour col }
  function sgn(a:real):integer;
  begin
       if a>0 then sgn:=+1;
       if a<0 then sgn:=-1;
       if a=0 then sgn:=0;
  end;
var i,s,d1x,d1y,d2x,d2y,u,v,m,n:integer;

begin
     u:= c - a;
     v:= d - b;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := m shr 1;
     FOR i := 0 TO m DO
     BEGIN
         pset(a,b,col,destino);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               a:= a + d1x;
               b := b + d1y;
          END
          ELSE
          BEGIN
               a := a + d2x;
               b := b + d2y;
          END;
     end;
END;


{**************************************}
procedure make_grid(ancho,alto:byte; filas,columnas:word; color1,color2:byte; var destino:bmp);
var
f,c:byte;
x,y:integer;
begin
    newbmp(destino,ancho*columnas+2, alto*filas+2);
    clearbmp(destino,color2);
    x:=0;
    y:=0;
    for f:=0 to filas do
    begin
        linea(x,y, destino.ancho-1,y,color1, destino);
        y:=y+alto;
    end;

    x:=0;
    y:=0;
    for c:=0 to columnas do
    begin
        linea(x,y, x,destino.alto-1,color1, destino);
        x:=x+ancho;
    end;

end;
{**************************************}

procedure Repaint_grid(ancho,alto:byte; filas,columnas:word; color1,color2:byte; var destino:bmp);
var
f,c:byte;
x,y:integer;
begin
    clearbmp(destino,color2);
    x:=0;
    y:=0;
    for f:=0 to filas do
    begin
        linea(x,y, destino.ancho-1,y,color1, destino);
        y:=y+alto;
    end;

    x:=0;
    y:=0;
    for c:=0 to columnas do
    begin
        linea(x,y, x,destino.alto-1,color1, destino);
        x:=x+ancho;
    end;

end;
//.....................
procedure add_bmp_list(var bmplist:tbmp_list; var bitmap:bmp);
begin
   if bmplist.num_bmps<3100 then
   begin
       bmplist.num_bmps:=bmplist.num_bmps+1;
       newbmp( bmplist.bmps[bmplist.num_bmps],bitmap.ancho,bitmap.alto);
       putbmp(bitmap,bmplist.bmps[bmplist.num_bmps]);
       bmplist.bmps[bmplist.num_bmps].paleta:=bmplist.paleta;
   end;
end;
//.................................
procedure select_bmp_list(var bmplist:tbmp_list; index:integer);
begin
    //se supone que el bitmap ya esta creado y es valido.
    if (index>0) and (index<=bmplist.num_bmps) then
    begin
       if (bmplist.bmps[index].ancho=bmplist.bitmap.width) and (bmplist.bmps[index].alto=bmplist.bitmap.height)
       then
           putbmp( bmplist.bmps[index],bmplist.bitmap)
       else
           bmp2bitmap(bmplist.bmps[index],bmplist.bitmap);
    end;//end si select
end;

//------------------
procedure free_bmplist(var bmplist:tbmp_list);
var
k:word;
begin
    for k:=1 to bmplist.num_bmps do begin bmplist.bmps[k].paleta:=nil;freebmp( bmplist.bmps[k]);end;
    bmplist.num_bmps:=0;
    if bmplist.paleta<>nil then freemem(bmplist.paleta,256*3);

end;
//--------16 bit

procedure add_bmp_list(var bmplist:tbmp16_list; var bitmap:bmp16);
var
width,height:integer;
b,c:tbitmap;
begin

   if bmplist.num_bmps<3500 then
   begin
//---------------------------------------------
//hacer la dimension power of 2.
  width:=bitmap.ancho;
  height:=bitmap.alto;

   if ((width<>8) and (width<>16) and (width<>32) and (width<>64) and (width<>128) and (width<>256)) or
      ((height<>8) and (height<>16) and (height<>32) and (height<>64) and (height<>128) and (height<>256)) then
   begin
       b:=tbitmap.create;c:=tbitmap.create;
       b.pixelformat:=pf24bit;
       b.width:=width;
       b.height:=height;
       xsetbitmapbits(b,width*height*3,bitmap.surface);
       freemem(bitmap.surface);
       c.pixelformat:=pf24bit;
       c.width:=64;
       c.height:=64;
       c.canvas.StretchDraw( rect(0,0,65,65), b);
       getmem(bitmap.surface,64*64*3);
       xgetbitmapbits(c,64*64*3,bitmap.surface);
       bitmap.ancho:=64;
       bitmap.alto:=64;
       b.free;
       c.free;
   end; //strech
//---------------------------------------------
       bmplist.num_bmps:=bmplist.num_bmps+1;
       bmplist.bmps[bmplist.num_bmps].ancho:=bitmap.ancho;
       bmplist.bmps[bmplist.num_bmps].alto:=bitmap.alto;
       bmplist.bmps[bmplist.num_bmps].surface:=bitmap.surface;
   end;
end;
//.................................
procedure select_bmp_list(var bmplist:tbmp16_list; index:integer);
begin
    //se supone que el bitmap ya esta creado y es valido.
    if (index>0) and (index<=bmplist.num_bmps) then
    begin
       if (bmplist.bmps[index].ancho=bmplist.bitmap.width) and (bmplist.bmps[index].alto=bmplist.bitmap.height)
       then
           //solo el setbitmapbits.
           xsetbitmapbits(bmplist.bitmap, bmplist.bmps[index].ancho*bmplist.bmps[index].alto*3, bmplist.bmps[index].surface)
       else
        begin
           //recrear bitmap.
           bmplist.bitmap.width:=bmplist.bmps[index].ancho;
           bmplist.bitmap.height:=bmplist.bmps[index].alto;
           bmplist.bitmap.pixelformat:=pf24bit;
           xsetbitmapbits(bmplist.bitmap, (bmplist.bmps[index].ancho*bmplist.bmps[index].alto)*3, bmplist.bmps[index].surface);
        end;
    end;//end si select
end;

//------------------
procedure free_bmplist(var bmplist:tbmp16_list);
var
k:word;
begin
    for k:=1 to bmplist.num_bmps do freemem(bmplist.bmps[k].surface);
    bmplist.num_bmps:=0;
end;
//------------------------------------
procedure xSetBitmapBits(var bitmap:tbitmap; size:longint; buf:pointer);
var
p:pointer;
bpp:integer;
lsize:integer;
y,k:integer;
buf2:longint;

begin

    bpp:=2;
    case bitmap.pixelformat of
       pf8bit          : bpp:=1;
       pf15bit,pf16bit: bpp:=2;
       pf24bit         : bpp:=3;
       pf32bit         : bpp:=4;
    end;
    lsize:=bitmap.width*bpp;
    k:=size div lsize; if k=0 then k:=1;
    if lsize>size then lsize:=size;
    buf2:=longint(buf);

    for y:=1 to k do
    begin
        p:=bitmap.scanline[y-1];
        move(pointer(buf2)^,p^,lsize);
        buf2:=buf2+lsize;
    end;


end;


procedure xGetBitmapBits(var bitmap:tbitmap; size:longint; buf:pointer);
var
p:pointer;
bpp:integer;
lsize:integer;
y,k:integer;
buf2:longint;

begin

    bpp:=2;
    case bitmap.pixelformat of
       pf8bit          : bpp:=1;
       pf15bit,pf16bit: bpp:=2;
       pf24bit         : bpp:=3;
       pf32bit         : bpp:=4;
    end;
    lsize:=bitmap.width*bpp;
    k:=size div lsize; if k=0 then k:=1;
    if lsize>size then lsize:=size;
    buf2:=longint(buf);

    for y:=1 to k do
    begin
        p:=bitmap.scanline[y-1];
        move(p^,pointer(buf2)^,lsize);
        buf2:=buf2+lsize;
    end;


end;
//----------------
procedure bitmap_flip_hor(var bitmap:tbitmap);
var
row,column:longint;
a:tbitmap;
begin
  a:=tbitmap.create;
  a.pixelformat:=bitmap.PixelFormat;
  a.width:=bitmap.width;
  a.height:=bitmap.height;
  a.canvas.CopyRect(rect(0,0,a.width,a.height),bitmap.canvas,rect(0,0,a.width,a.height));
  for row:=0 to a.height-1 do
  for column:=0 to a.Width-1 do bitmap.Canvas.Pixels[column,row]:=a.Canvas.Pixels[a.width-column-1,row];
  a.free;
end;


procedure bitmap_flip_ver(var bitmap:tbitmap);
var
row,column:longint;
a:tbitmap;
begin
  a:=tbitmap.create;
  a.pixelformat:=bitmap.PixelFormat;
  a.width:=bitmap.width;
  a.height:=bitmap.height;
  a.canvas.CopyRect(rect(0,0,a.width,a.height),bitmap.canvas,rect(0,0,a.width,a.height));
  for row:=0 to a.height-1 do
  for column:=0 to a.Width-1 do bitmap.Canvas.Pixels[column,row]:=a.Canvas.Pixels[column,a.height-row-1];
  a.free;
end;


procedure fix16bitmap(var a:tbitmap);
var
p:pointer;
r,g,b:word;
k:integer;
i:longint;
begin
   getmem(p, a.width*a.height*2);
   xgetbitmapbits(a, a.width*a.height*2,p);
   i:=longint(p);
   for k:=1 to a.width*a.height do
   begin
        r:=0;g:=0;b:=0;
        r:=word(pointer(i)^) and 31  ;

        g:=(word(pointer(i)^) and 992) shr 5 ;
        b:=(word(pointer(i)^) and 31744) shr 10;

        word(pointer(i)^):=0;
        word(pointer(i)^):=(r) or (g shl 6) or (b shl 11);
        i:=i+2;


   end;
   xsetbitmapbits(a, a.width*a.height*2,p);
   freemem(p);

end;

procedure fix15bitmap(var p:pointer; size:longint);
var
k:integer;
i:longint;
r,g,b:word;
begin
    i:=longint(p);
    r:=0;g:=0;b:=0;
    for k:=1 to size div 2 do
    begin
        r:=0;g:=0;b:=0;
        r:=word(pointer(i)^) and 63 ;
        g:=(word(pointer(i)^) and 1984) shr 6 ;
        b:=(word(pointer(i)^) and 63488) shr 11;

        word(pointer(i)^):=0;
        word(pointer(i)^):=(r) or (g shl 5) or (b shl 10);
        i:=i+2;
    end;//end fix all data


end;


{******************************************************}
initialization
video.surface:=ptr($a0000);
fvideomem:=video.surface;
video.ANCHO:=320;
video.alto:=200;
video.valido:='VALIDO';
cur_fnt:=nil;

end.



