unit xopengl;
interface
uses opengl12,memlist,fexopgl;

//-----procedures ---------

procedure Xstart_buffer;
procedure xglbindtexture(target,texture:cardinal);
procedure xglloadname(name:integer);

procedure xset_perspective_correct(perspective_correct:boolean);
procedure xglbegin(mode:cardinal);
procedure xgltexcoord2f(mx,my:extended);
procedure xglcolor3ub(r,g,b:byte);
procedure xglVertex3f(x,y,z:glfloat);
procedure xglend;
procedure xend_buffer;
procedure xselect_mode(mode:integer);
//------------------
var
xselect_enabled:boolean;
implementation

type
txprimitive = record
  mode   :cardinal;
  texture:integer;
  name   : integer;
  perspective_correct:boolean;
  x,y,z : glfloat;
  mx,my :extended;
  color_r,color_g,color_b :integer;
end;

var
xprimitive:^txprimitive;
xbuffer:tlistmem;
xnum_primitives:integer;

xmode:cardinal;
xname:integer;
xtexture:integer;
xcolor_r:integer;
xcolor_g:integer;
xcolor_b:integer;
xperspective_correct:boolean;
xmx,xmy:extended;
xcorrelative:integer;

//*****************

procedure xstart_buffer;
begin
    xnum_primitives:=0;
    xcorrelative:=0;
    xtexture:=-1;
    xperspective_correct:=false;
    xcolor_r:=-1;
    xcolor_g:=-1;
    xcolor_b:=-1;
end;
//--------
procedure xglbindtexture(target,texture:cardinal);
begin
   xtexture:=texture;
end;
//----------

procedure xglloadname(name:integer);
begin
   xname:=name;
end;


procedure xset_perspective_correct(perspective_correct:boolean);
begin
    xperspective_correct:=perspective_correct;
end;

//------------
procedure xglbegin(mode:cardinal);
begin
    xmode:=mode;
end;
//------------

procedure xgltexcoord2f(mx,my:extended);
begin
  xmx:=mx;
  xmy:=my;
end;
//-------------
procedure xglcolor3ub(r,g,b:byte);
begin
    xcolor_r:=r;
    xcolor_g:=g;
    xcolor_b:=b;
end;
//---------------

procedure xglVertex3f(x,y,z:glfloat);
begin
     new(xprimitive);
     xprimitive^.mode:=xmode;
     xprimitive^.texture:=xtexture;
     xprimitive^.name:=xname;
     xprimitive^.perspective_correct:=xperspective_correct;
     xprimitive^.mx:=xmx;
     xprimitive^.my:=xmy;
     xprimitive^.color_r:=xcolor_r;
     xprimitive^.color_g:=xcolor_g;
     xprimitive^.color_b:=xcolor_b;
     xprimitive^.x:=x;
     xprimitive^.y:=y;
     xprimitive^.z:=z;
     //--add the record to the table;
     xbuffer.Add( vals(xmode)+vals(xname)+vals(xtexture)+vals(xcorrelative),xprimitive);
     inc(xcorrelative);
     //reset the textures coordinates.
     xmx:=-99;
     xmy:=-99;

end;

procedure xglend;
begin
    //do nothing.
end;
//----------------
procedure xend_buffer2;
var
name,texture,mode:integer;
k:integer;
r,g,b:byte;
color:word;
begin
  GlPolygonMode(GL_FRONT_AND_BACK,GL_line);
  GLdisable(gl_texture_2d);
  glshademodel(gl_flat);

 xbuffer.Sort;
 k:=0;

 while k<xbuffer.count do
 begin
      xprimitive:=xbuffer.Records[k];
      mode:=xprimitive^.mode;
      name:=xprimitive^.name; //if name<0 then name:=0;
      if name>=0 then glloadname(name);
      //start the real begin
      GlBegin(mode);
      while (mode=xprimitive^.mode) and (name=xprimitive^.name) do
      begin
           name:=xprimitive^.name; if name<0 then name:=0;
           glvertex3f(xprimitive^.x,xprimitive^.y,xprimitive^.z);
           inc(k);
           if k>=xbuffer.count then break; //if there is no more records then exit.
           xprimitive:=xbuffer.Records[k]; //read next record
      end; //end one complete real opengl begin end.
      GlEnd;
 end;//end all vertices records.
 //---clear the primitive table---
  xbuffer.clear;
  xbuffer.pack;
 //--------
end;

//------------------
procedure xend_buffer;
var
name,texture,mode:integer;
k:integer;
r,g,b:integer;

begin
 //draw all records in a optimized way.
 //for making me the life easier i am going to build another rendering
 //when in select mode.
 if xselect_enabled then begin xend_buffer2;exit;end;

 k:=0;

 xbuffer.Sort;

 while k<xbuffer.count do
 begin
      xprimitive:=xbuffer.Records[k];
      name:=xprimitive^.name;
      texture:=xprimitive^.texture;
      mode:=xprimitive^.mode;
      //colors
      r:=-99;g:=-99;b:=-99;
      //start the real begin
      if name>=0 then glloadname(name);
      if texture>=0 then begin glbindtexture(gl_texture_2d,texture);set_perspective_correct(xprimitive^.perspective_correct);end;
      GlBegin(mode);
      while (name=xprimitive^.name) and (texture=xprimitive^.texture) and (mode=xprimitive^.mode) do
      begin
          //need to change color?
          if (r<>xprimitive^.color_r) or (g<>xprimitive^.color_g) or (b<>xprimitive^.color_b) then begin r:=xprimitive^.color_r;g:=xprimitive^.color_g;b:=xprimitive^.color_b;end;
          r:=xprimitive^.color_r;g:=xprimitive^.color_g;b:=xprimitive^.color_b;
          if (r>=0) and (g>=0) and (b>=0) then glcolor3ub(r,g,b);
           //there are texture coordinates?
           if (xprimitive^.mx<>-99) and (xprimitive^.my<>-99) then gltexcoord2f(xprimitive^.mx,xprimitive^.my);
           glvertex3f(xprimitive^.x,xprimitive^.y,xprimitive^.z);
           inc(k);
           if k>=xbuffer.count then break; //if there is no more records then exit.
           xprimitive:=xbuffer.Records[k]; //read next record
      end; //end one complete real opengl begin end.
      GlEnd;
 end;//end all vertices records.
 //---clear the primitive table---
  xbuffer.clear;
  xbuffer.pack;
  //------
end;


procedure xselect_mode(mode:integer);
begin
    if mode=0 then xselect_enabled:=false else xselect_enabled:=true;
end;

//********************
initialization
xbuffer:=tlistmem.create;
xbuffer.sorted:=false;
xprimitive:=nil;
xnum_primitives:=0;
xperspective_correct:=false;
xcolor_r:=-1;
xcolor_g:=-1;
xcolor_b:=-1;
xmx:=-99;
xmy:=-99;

xselect_enabled:=false;

finalization
xbuffer.Free;

end.
