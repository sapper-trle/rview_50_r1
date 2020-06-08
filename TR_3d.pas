unit TR_3d;

interface

uses
geometry,Windows, extctrls,Messages, SysUtils, Classes,forms,graphics,controls,opengl12,fexopgl,trunit2,fexgraph,dialogs;

//-------------

//OPENGL cordenadas:
//
//  -X<---------0--------->X+
//
//            +Y
//             |
//             |
//             0
//             |
//             |
//            -Y
//
//
// (away from the screen)  +Z<-------0--------->Z- (close to the screen)
//
//
{ ****** Uso de esta unidad ******
}


const
max_meshes = 255;
max_rectangles= 4000;

//--------------
//desendiente de tescene para TR direct render.
 type
  tr_scene = class(Tglfigure)
   protected
   procedure DoRender; override;
   procedure render_wireframe(nmesh:integer);
   procedure render_shade(nmesh:integer);
   procedure render_solid(nmesh:integer);
   procedure render_textured(nmesh:integer);
   procedure render_ornaments(room:integer);
   procedure render_source_lights(room:integer);
  public
   L:ttrlevel;
   tabla_texture:^ttabla_textures;
   render1,
   render2:integer;
   meshes:^tmesh_list;
   wireframe_color:tcolor;
   solid_bitmap:integer;
   rectan_list : array[1..2] of  tstringlist;
   trian_list  : array[1..2] of  tstringlist;
   light_enabled:boolean;
   render_tipo:trender_tipo;
   current:byte;
   current_only:boolean;
   current_zone:integer;
   texture_mode:byte;
   buffer_size:byte;
   perspective_correct_enabled:boolean;
   hide_static_mesh:boolean;
   hide_source_light:boolean;
   source_light_enabled:boolean;
   current_source_light:integer;

  constructor Create; override;
  destructor Destroy; override;
  function center:glfloat;
  procedure sort_textures; overload;
  procedure sort_textures(room:integer);overload;

  procedure change_texture(index,textura,replicate:integer);//index es obtenido from scene.selection
  function tr_get_texture(index:integer):word; //index es obtenido from scene.selection
  procedure Render_level(from_room,to_room:integer);
 end;
// independientes de la clase
function tr_loadTextures(var l:ttrlevel; buffer_size:byte; var vp:tglviewport):word;
function fmin(v1,v2:single):single;
function fmax(v1,v2:single):single;
function find_normalx(v1,v2,v3,v4:single):integer;
function find_normalz(v1,v2,v3,v4:single):integer;
//------------
var
sphere:pgluquadric;

implementation
//****************************
//----tr direct---------------
//****************************

function fmin(v1,v2:single):single;
begin
    if v1<v2 then fmin:=v1 else fmin:=v2;
end;

function fmax(v1,v2:single):single;
begin
    if v1>v2 then fmax:=v1 else fmax:=v2;
end;


function find_normalx(v1,v2,v3,v4:single):integer;
begin
    if ((v1-v2)<0) and ((v4-v3)<0) then begin find_normalx:=-1;exit;end;
    if ((v4-v1)<0) and ((v3-v2)<0) then begin find_normalx:=-1;exit;end;
    if ((v3-v4)>0) and ((v2-v1)>0) then begin find_normalx:=-1;exit;end;
    if ((v2-v3)<0) and ((v1-v4)<0) then begin find_normalx:=-1;exit;end;
    find_normalx:=1;
end;


function find_normalz(v1,v2,v3,v4:single):integer;
begin
    if ((v1-v2)<0) and ((v4-v3)<0) then begin find_normalz:=1;exit;end;
    if ((v4-v1)<0) and ((v3-v2)<0) then begin find_normalz:=1;exit;end;
    if ((v3-v4)>0) and ((v2-v1)>0) then begin find_normalz:=1;exit;end;
    if ((v2-v3)<0) and ((v1-v4)<0) then begin find_normalz:=1;exit;end;
    find_normalz:=-1;
end;



constructor tr_scene.Create;
var
k:integer;
begin
   inherited create;
   //agregar default values.
   L:=nil;
   tabla_texture:=nil;
   current:=0;
   current_only:=false;
   current_zone:=1;
   render1:=0;
   render2:=0;
   solid_bitmap:=0;
   light_enabled:=false;
   render_tipo:=rtwireframe;
   texture_mode:=0;
   buffer_size:=16;
   perspective_correct_enabled:=false;
   hide_static_mesh:=false;
   hide_source_light:=false;
   source_light_enabled:=false;
   current_source_light:=0;

   for k:=1 to 2 do rectan_list[k]:=tstringlist.create;
   for k:=1 to 2 do trian_list[k]:=tstringlist.create;

end;
//-------------------------

destructor tr_scene.Destroy;
var
  k:Integer;
begin
   for k:=1 to 2 do rectan_list[k].Free;
   for k:=1 to 2 do trian_list[k].Free;
  inherited;
end;

procedure tr_scene.DoRender;
var
k:integer;
begin
  if L<>nil then //if TRlevel assigned
  begin
           case render_tipo of
                rtwireframe:begin wireframe_color:=claqua;if render1<>0 then render_wireframe(render1);wireframe_color:=clgreen;if (render2<>0) and (render2<>render1) then render_wireframe(render2);end; //wireframe
                rtshaded:begin wireframe_color:=claqua;if render1<>0 then render_shade(render1);wireframe_color:=clgreen;if (render2<>0) and (render2<>render1) then render_shade(render2);end; //shade.
                rtsolid :begin if render1<>0 then render_solid(render1);if (render2<>0) and (render2<>render1) then render_solid(render2);end; //solid one texture
                rttextured:begin if render1<>0 then render_textured(render1);if (render2<>0) and (render2<>render1) then render_textured(render2);end; //multi-textured;
           end; //endcase
  end;//fin si TRlevel assigned
end;
//--------------------
procedure tr_scene.Render_wireframe(nmesh:integer);
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4,
xpos,zpos:glfloat;
room:integer;
begin
  //---AQUI ADECUAR LOS ESTADOS DE ESTE MESH
   GlPolygonMode(GL_FRONT_AND_BACK,GL_line);
   GLdisable(gl_texture_2d);
   glshademodel(gl_flat);
  //-----------------------------------

  room:=nmesh;
  if room>l.num_rooms then exit;
  if current_only and (room<>render1) then exit;

  room:=room-1; //ahora acomodarlo a base 0.
  glcolor3f(twcolor(wireframe_color).r, twcolor(wireframe_color).g, twcolor(wireframe_color).b);
  xpos:=((l.rooms[room].room_info.xpos_room)/1000);
  zpos:=((l.rooms[room].room_info.zpos_room)/1000)*-1;

  //draw rectangles first
  for k:=1 to l.rooms[room].quads.num_quads do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p1+1].x;
       y1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p1+1].y;
       z1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p1+1].z;

       x2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p2+1].x;
       y2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p2+1].y;
       z2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p2+1].z;

       x3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p3+1].x;
       y3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p3+1].y;
       z3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p3+1].z;

       x4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p4+1].x;
       y4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p4+1].y;
       z4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p4+1].z;

       x1:=(x1/1000);y1:=(y1/1000)*-1;z1:=(z1/1000)*-1;
       x2:=(x2/1000);y2:=(y2/1000)*-1;z2:=(z2/1000)*-1;
       x3:=(x3/1000);y3:=(y3/1000)*-1;z3:=(z3/1000)*-1;
       x4:=(x4/1000);y4:=(y4/1000)*-1;z4:=(z4/1000)*-1;

    if (room+1)=render1 then GlLoadname(k) else GlLoadname(0);
    glBegin(GL_quads);
            glVertex3f(xpos+x1,y1,zpos+z1);
            glVertex3f(xpos+x2,y2,zpos+z2);
            glVertex3f(xpos+x3,y3,zpos+z3);
            glVertex3f(xpos+x4,y4,zpos+z4);
   glEnd;
   end;//end for (rectangles);
//draw triangles;

   for k:=1 to l.rooms[room].triangles.num_triangles do
   begin
       x1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p1+1].x;
       y1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p1+1].y;
       z1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p1+1].z;

       x2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p2+1].x;
       y2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p2+1].y;
       z2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p2+1].z;

       x3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p3+1].x;
       y3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p3+1].y;
       z3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p3+1].z;

       x1:=(x1/1000);y1:=(y1/1000)*-1;z1:=(z1/1000)*-1;
       x2:=(x2/1000);y2:=(y2/1000)*-1;z2:=(z2/1000)*-1;
       x3:=(x3/1000);y3:=(y3/1000)*-1;z3:=(z3/1000)*-1;

     if (room+1)=render1 then GlLoadname(l.rooms[room].quads.num_quads+k) else GlLoadname(0);
     glBegin(GL_triangles);
            glVertex3f(xpos+x1,y1,zpos+z1);
            glVertex3f(xpos+x2,y2,zpos+z2);
            glVertex3f(xpos+x3,y3,zpos+z3);
     glEnd;

   end;//end for (triangles);

   meshes.draw_mode:=0;
   if not hide_static_mesh then render_ornaments(room);
   if not hide_source_light then render_source_lights(room);

end;
//------------------------
procedure tr_scene.Render_shade(nmesh:integer); //zone editor mode

const
clt : array[0..7] of tcolor = (clwhite, clgreen, claqua, clyellow, clred, clblue, clpurple, clgray );
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4:real;
room:integer;
i,ntexture,cur_texture:integer;
xpos,zpos:real;
xxpos:integer;
xroom:integer;
w_color:tcolor;
zindex:smallint;
sectorx,sectorz:currency;
isector:integer;
vx,vz,vminx,vminz,vmaxx,vmaxz:real;
nx,nz:integer;
mx1,my1,mx2,my2,mx3,my3,mx4,my4:integer;

begin
  //-------------
   GlPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
   GLenable(gl_texture_2d);
   glshademodel(gl_flat);
  //------------

  room:=nmesh;

  if room>l.num_rooms then exit;
  if room<>render1 then exit;

  room:=room-1;

  xpos:=((l.rooms[room].room_info.xpos_room)/1000);
  zpos:=((l.rooms[room].room_info.zpos_room)/1000)*-1;

  cur_texture:=-1;

  if (room+1)=render1 then xroom:=1 else xroom:=2;

  //draw rectangles first
  for k:=1 to l.rooms[room].quads.num_quads do
  begin
     //draw the rectangle
//seleccionar la textura,
     //averiguar que rectangulo sigue en la lista ordenada de rectangulos.
      xxpos:=pos('=',rectan_list[xroom].strings[k-1]);
      ntexture:=strToint(copy(rectan_list[xroom].strings[k-1],1,xxpos-1));
      i:=strToint(copy(rectan_list[xroom].strings[k-1],xxpos+1,100));
      ntexture:=(l.rooms[room].quads.quad[i].texture and $7fff);
     if cur_texture<>ntexture then
     begin
        case texture_mode of
         0:if ntexture<=tabla_texture^.num_tiles then glbindtexture(gl_texture_2d, ntexture+1)
           else glbindtexture(gl_texture_2d, solid_bitmap);

         1: if ntexture<=tabla_texture^.num_tiles then
                  begin
                    trunit2.tr_Get_texture(ntexture,tabla_texture^,false);
                    Opgl_Define_Texture(1, tabla_texture^.cur_tile,buffer_size);
                   end
                  else glbindtexture(gl_texture_2d, solid_bitmap);
         end;//end
         set_perspective_correct(perspective_correct_enabled);
         cur_texture:=ntexture;
     end; //si necesario cambiar textura

     //sacar las cordenadas;
       x1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p1+1].x;
       y1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p1+1].y;
       z1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p1+1].z;

       x2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p2+1].x;
       y2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p2+1].y;
       z2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p2+1].z;

       x3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p3+1].x;
       y3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p3+1].y;
       z3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p3+1].z;

       x4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p4+1].x;
       y4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p4+1].y;
       z4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p4+1].z;


//---averiguar el tile sector de este face
// averiguar el normal x y z

nx:=0;
nz:=0;
zindex:=0;

TRY
if (x1=x2) and (x2=x3) and (x3=x4) then nx:=find_normalx(z1,z2,z3,z4);
if (z1=z2) and (z2=z3) and (z3=z4) then nz:=find_normalz(x1,x2,x3,x4);


  vminx:=fmin(x1,x2);vminx:=fmin(vminx,x3);vminx:=fmin(vminx,x4);
  vminz:=fmin(z1,z2);vminz:=fmin(vminz,z3);vminz:=fmin(vminz,z4);
  vmaxx:=fmax(x1,x2);vmaxx:=fmax(vmaxx,x3);vmaxx:=fmax(vmaxx,x4);
  vmaxz:=fmax(z1,z2);vmaxz:=fmax(vmaxz,z3);vmaxz:=fmax(vmaxz,z4);

  vx:=(vmaxx-((vmaxx-vminx) / 2))+nx;
  vz:=(vmaxz-((vmaxz-vminz) / 2))+nz;

 sectorx:= int(vx/1024);
 sectorz:= int(vz/1024);
 isector:=trunc(((sectorx*l.rooms[room].sectors.largo)+sectorz)+1);

//-----sacar el color de cada face, usando la zona.
if (isector>0) and (isector<=(l.rooms[room].sectors.ancho*l.rooms[room].sectors.largo)) then
   zindex:=l.rooms[room].sectors.sector[isector].box_index
   else zindex:=-1;
   if (l.tipo>=vtr3) and (zindex<>-1) then zindex:=zindex shr 4;
   if zindex=-16 then zindex:=-1;
EXCEPT
zindex:=-1;
END;

if zindex>=0 then
begin
case current_zone of
    1:zindex:=l.nground_zone1[zindex];
    2:zindex:=l.nground_zone2[zindex];
    3:zindex:=l.nground_zone3[zindex];
    4:zindex:=l.nground_zone4[zindex];
    5:zindex:=l.nfly_zone[zindex];
end;//end case current zone
end //end si el box_index no es -1
else zindex:=0;

if zindex>6 then zindex:=7; //si es zona mayor que 6 (de los niveles originales);
if (l.tipo<vtr2) and (current_zone>2) and (current_zone<>5) then zindex:=0; //si tr1/tub funcionar solo con zona 1,2 y 5.
w_color:=clt[zindex];

     //acomomodar a opengl cordinates.
       x1:=(x1/1000);y1:=(y1/1000)*-1;z1:=(z1/1000)*-1;
       x2:=(x2/1000);y2:=(y2/1000)*-1;z2:=(z2/1000)*-1;
       x3:=(x3/1000);y3:=(y3/1000)*-1;z3:=(z3/1000)*-1;
       x4:=(x4/1000);y4:=(y4/1000)*-1;z4:=(z4/1000)*-1;


    //GET TEXTURE MAP
    mx1:=0;my1:=0;
    mx2:=1;my2:=0;
    mx3:=1;my3:=1;
    mx4:=0;my4:=1;

    if ntexture<l.Num_Textures then
    begin
      if l.textures[ntexture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[ntexture].my1<=1 then my1:=0 else my1:=1;
      if l.textures[ntexture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[ntexture].my2<=1 then my2:=0 else my2:=1;
      if l.textures[ntexture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[ntexture].my3<=1 then my3:=0 else my3:=1;
      if l.textures[ntexture].mx4<=1 then mx4:=0 else mx4:=1;if l.textures[ntexture].my4<=1 then my4:=0 else my4:=1;
    end;
    //--------------------------

       if (room+1)=render1 then GlLoadname(i) else GlLoadname(0);
       glBegin(gl_quads);
            glcolor3f(twcolor(w_color).r, twcolor(w_color).g, twcolor(w_color).b);

            gltexcoord2f(mx1,my1);
            glVertex3f(xpos+x1,y1,zpos+z1);

            gltexcoord2f(mx2,my2);
            glVertex3f(xpos+x2,y2,zpos+z2);

            gltexcoord2f(mx3,my3);
            glVertex3f(xpos+x3,y3,zpos+z3);

            gltexcoord2f(mx4,my4);
            glVertex3f(xpos+x4,y4,zpos+z4);

     glEnd;
   end;//end for (rectangles);
//draw triangles;

   for k:=1 to l.rooms[room].triangles.num_triangles do
   begin
//seleccionar la textura,
     //averiguar que triangulo sigue en la lista ordenada de triangulos
      xxpos:=pos('=',trian_list[xroom].strings[k-1]);
      ntexture:=strToint(copy(trian_list[xroom].strings[k-1],1,xxpos-1));
      i:=strToint(copy(trian_list[xroom].strings[k-1],xxpos+1,100));
      ntexture:=(l.rooms[room].triangles.triangle[i].texture and $7fff);
     if cur_texture<>ntexture then
     begin
        case texture_mode of
         0:if ntexture<=tabla_texture^.num_tiles then glbindtexture(gl_texture_2d, ntexture+1)
           else glbindtexture(gl_texture_2d, solid_bitmap);

         1: if ntexture<=tabla_texture^.num_tiles then
                  begin
                    trunit2.tr_Get_texture(ntexture,tabla_texture^,false);
                    Opgl_Define_Texture(1, tabla_texture^.cur_tile,buffer_size);
                   end
                  else glbindtexture(gl_texture_2d, solid_bitmap);
         end;//end
         set_perspective_correct(perspective_correct_enabled);
         cur_texture:=ntexture;
     end; //si necesario cambiar textura

       x1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p1+1].x;
       y1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p1+1].y;
       z1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p1+1].z;

       x2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p2+1].x;
       y2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p2+1].y;
       z2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p2+1].z;

       x3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p3+1].x;
       y3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p3+1].y;
       z3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p3+1].z;

       x4:=x3;y4:=y3;z4:=z3;

//---averiguar el tile sector de este face
// averiguar el normal x y z

nx:=0;
nz:=0;
zindex:=0;

//TRY
if (x1=x2) and (x2=x3) and (x3=x4) then nx:=find_normalx(z1,z2,z3,z4);
if (z1=z2) and (z2=z3) and (z3=z4) then nz:=find_normalz(x1,x2,x3,x4);

  vminx:=fmin(x1,x2);vminx:=fmin(vminx,x3);vminx:=fmin(vminx,x4);
  vminz:=fmin(z1,z2);vminz:=fmin(vminz,z3);vminz:=fmin(vminz,z4);
  vmaxx:=fmax(x1,x2);vmaxx:=fmax(vmaxx,x3);vmaxx:=fmax(vmaxx,x4);
  vmaxz:=fmax(z1,z2);vmaxz:=fmax(vmaxz,z3);vmaxz:=fmax(vmaxz,z4);

  vx:=(vmaxx-((vmaxx-vminx) / 2))+nx;
  vz:=(vmaxz-((vmaxz-vminz) / 2))+nz;

 sectorx:= int(vx/1024);
 sectorz:= int(vz/1024);
 isector:=trunc(((sectorx*l.rooms[room].sectors.largo)+sectorz)+1);

if (isector>0) and (isector<=(l.rooms[room].sectors.ancho*l.rooms[room].sectors.largo)) then
   zindex:=l.rooms[room].sectors.sector[isector].box_index
   else zindex:=-1;
   if (l.tipo>=vtr3) and (zindex<>-1) and (zindex>0) then zindex:=zindex shr 4;
   if zindex=-16 then zindex:=-1;

//EXCEPT
//  zindex:=-1;
//END;

if zindex>=0 then
begin
case current_zone of
    1:zindex:=l.nground_zone1[zindex+1];
    2:zindex:=l.nground_zone2[zindex+1];
    3:zindex:=l.nground_zone3[zindex+1];
    4:zindex:=l.nground_zone4[zindex+1];
    5:zindex:=l.nfly_zone[zindex+1];
end;//end case current zone
end //end si el box_index no es -1
else zindex:=0;

if zindex>6 then zindex:=7; //si es zona mayor que 6 (de los niveles originales);
if (l.tipo<vtr2) and (current_zone>2) and (current_zone<>5) then zindex:=0; //si tr1/tub funcionar solo con zona 1,2 y 5.
w_color:=clt[zindex];

     //acomodar a opengl cordinates
       x1:=(x1/1000);y1:=(y1/1000)*-1;z1:=(z1/1000)*-1;
       x2:=(x2/1000);y2:=(y2/1000)*-1;z2:=(z2/1000)*-1;
       x3:=(x3/1000);y3:=(y3/1000)*-1;z3:=(z3/1000)*-1;

    //GET TEXTURE MAP
    mx1:=0;my1:=0;
    mx2:=1;my2:=0;
    mx3:=1;my3:=1;
    mx4:=0;my4:=1;

    if ntexture<l.Num_Textures then
    begin
      if l.textures[ntexture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[ntexture].my1<=1 then my1:=0 else my1:=1;
      if l.textures[ntexture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[ntexture].my2<=1 then my2:=0 else my2:=1;
      if l.textures[ntexture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[ntexture].my3<=1 then my3:=0 else my3:=1;
      if l.textures[ntexture].mx4<=1 then mx4:=0 else mx4:=1;if l.textures[ntexture].my4<=1 then my4:=0 else my4:=1;
    end;
    //--------------------------


     if (room+1)=render1 then GlLoadname(l.rooms[room].quads.num_quads+i) else GlLoadname(0);
     glBegin(GL_quads);
            glcolor3f(twcolor(w_color).r, twcolor(w_color).g, twcolor(w_color).b);

            gltexcoord2f(mx1,my1);
            glVertex3f(xpos+x1,y1,zpos+z1);

            gltexcoord2f(mx2,my2);
            glVertex3f(xpos+x2,y2,zpos+z2);

            gltexcoord2f(mx3,my3);
            glVertex3f(xpos+x3,y3,zpos+z3);

            gltexcoord2f(mx4,my4);
            glVertex3f(xpos+x3,y3,zpos+z3);
     glEnd;
   end;//end for (triangles);

end;

//------------------
procedure tr_scene.Render_solid(nmesh:integer);
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4:glfloat;
room:integer;
r1,g1,b1,
r2,g2,b2,
r3,g3,b3,
r4,g4,b4:glfloat;
color8:byte;
color16:word;
xpos,zpos:glfloat;
begin
  //---AQUI ADECUAR LOS ESTADOS DE ESTE MESH
   GlPolygonMode(GL_FRONT_AND_BACK,GL_fill);
   GLenable(gl_texture_2d);
   glshademodel(gl_flat);
  //-----------------------------------

  room:=nmesh;
  if room>l.num_rooms then exit;
  if current_only and (room<>render1) then exit;
  room:=room-1;

  xpos:=((l.rooms[room].room_info.xpos_room)/1000);
  zpos:=((l.rooms[room].room_info.zpos_room)/1000)*-1;

  glbindtexture(gl_texture_2d, solid_bitmap);
  set_perspective_correct(perspective_correct_enabled);

  glcolor3ub(255,255,255);
  //draw rectangles first
  for k:=1 to l.rooms[room].quads.num_quads do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p1+1].x;
       y1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p1+1].y;
       z1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p1+1].z;

       x2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p2+1].x;
       y2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p2+1].y;
       z2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p2+1].z;

       x3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p3+1].x;
       y3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p3+1].y;
       z3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p3+1].z;

       x4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p4+1].x;
       y4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p4+1].y;
       z4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[k].p4+1].z;

       x1:=(x1/1000);y1:=(y1/1000)*-1;z1:=(z1/1000)*-1;
       x2:=(x2/1000);y2:=(y2/1000)*-1;z2:=(z2/1000)*-1;
       x3:=(x3/1000);y3:=(y3/1000)*-1;z3:=(z3/1000)*-1;
       x4:=(x4/1000);y4:=(y4/1000)*-1;z4:=(z4/1000)*-1;
//---------------

     if (room+1)=render1 then GlLoadname(k) else GlLoadname(0);
     glBegin(GL_quads);
            gltexcoord2f(0,0);
            glVertex3f(xpos+x1,y1,zpos+z1);

            gltexcoord2f(1,0);
            glVertex3f(xpos+x2,y2,zpos+z2);

            gltexcoord2f(1,1);
            glVertex3f(xpos+x3,y3,zpos+z3);

            gltexcoord2f(0,1);
            glVertex3f(xpos+x4,y4,zpos+z4);

     glEnd;
   end;//end for (rectangles);
//draw triangles;

   for k:=1 to l.rooms[room].triangles.num_triangles do
   begin
       x1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p1+1].x;
       y1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p1+1].y;
       z1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p1+1].z;

       x2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p2+1].x;
       y2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p2+1].y;
       z2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p2+1].z;

       x3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p3+1].x;
       y3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p3+1].y;
       z3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[k].p3+1].z;

       x1:=(x1/1000);y1:=(y1/1000)*-1;z1:=(z1/1000)*-1;
       x2:=(x2/1000);y2:=(y2/1000)*-1;z2:=(z2/1000)*-1;
       x3:=(x3/1000);y3:=(y3/1000)*-1;z3:=(z3/1000)*-1;

     if (room+1)=render1 then GlLoadname(l.rooms[room].quads.num_quads+k) else GlLoadname(0);
     glBegin(GL_quads);
            gltexcoord2f(0,0);
            glVertex3f(xpos+x1,y1,zpos+z1);

            gltexcoord2f(1,0);
            glVertex3f(xpos+x2,y2,zpos+z2);

            gltexcoord2f(1,1);
            glVertex3f(xpos+x3,y3,zpos+z3);

            gltexcoord2f(0,1);
            glVertex3f(xpos+x3,y3,zpos+z3);
     glEnd;
   end;//end for (triangles);

end;

//---------------------------
procedure tr_scene.Render_textured(nmesh:integer);
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4:glfloat;
room:integer;
r1,g1,b1,
r2,g2,b2,
r3,g3,b3,
r4,g4,b4:integer;
color8:byte;
color16:word;
i,ntexture,cur_texture:integer;
xpos,zpos:glfloat;
xxpos:integer;
xroom:integer;
mx1,my1,mx2,my2,mx3,my3,mx4,my4:integer;
begin
  //-------------
   GlPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
   GLenable(gl_texture_2d);
  //------------

  if light_enabled then glshademodel(gl_smooth) else glshademodel(gl_flat);

  room:=nmesh;

  if room>l.num_rooms then exit;
  if current_only and (room<>render1) then exit;

  room:=room-1;

  xpos:=((l.rooms[room].room_info.xpos_room)/1000);
  zpos:=((l.rooms[room].room_info.zpos_room)/1000)*-1;

  cur_texture:=-1;

  if (room+1)=render1 then xroom:=1 else xroom:=2;

  //draw rectangles first
  for k:=1 to l.rooms[room].quads.num_quads do
  begin
     //draw the rectangle
//seleccionar la textura,
     //averiguar que rectangulo sigue en la lista ordenada de rectangulos.
      xxpos:=pos('=',rectan_list[xroom].strings[k-1]);
      ntexture:=strToint(copy(rectan_list[xroom].strings[k-1],1,xxpos-1));
      i:=strToint(copy(rectan_list[xroom].strings[k-1],xxpos+1,100));
      ntexture:=(l.rooms[room].quads.quad[i].texture and $7fff);
     if cur_texture<>ntexture then
     begin
        case texture_mode of
         0:if ntexture<=tabla_texture^.num_tiles then glbindtexture(gl_texture_2d, ntexture+1)
           else glbindtexture(gl_texture_2d, solid_bitmap);

         1: if ntexture<=tabla_texture^.num_tiles then
                  begin
                    trunit2.tr_Get_texture(ntexture,tabla_texture^,false);
                    Opgl_Define_Texture(1, tabla_texture^.cur_tile,buffer_size);
                   end
                  else glbindtexture(gl_texture_2d, solid_bitmap);
         end;//end
         cur_texture:=ntexture;
         set_perspective_correct(perspective_correct_enabled);
     end; //si necesario cambiar textura

     //sacar las cordenadas;
       x1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p1+1].x;
       y1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p1+1].y;
       z1:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p1+1].z;

       x2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p2+1].x;
       y2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p2+1].y;
       z2:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p2+1].z;

       x3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p3+1].x;
       y3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p3+1].y;
       z3:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p3+1].z;

       x4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p4+1].x;
       y4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p4+1].y;
       z4:=l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p4+1].z;

       x1:=(x1/1000);y1:=(y1/1000)*-1;z1:=(z1/1000)*-1;
       x2:=(x2/1000);y2:=(y2/1000)*-1;z2:=(z2/1000)*-1;
       x3:=(x3/1000);y3:=(y3/1000)*-1;z3:=(z3/1000)*-1;
       x4:=(x4/1000);y4:=(y4/1000)*-1;z4:=(z4/1000)*-1;
//-----sacar el color de cada face, si tr1/tub/tr2 usar el
//campo de intensidad, si Tr3 usar el rgb de cada face.
   if l.tipo>=vtr3 then
   begin
       color16:=l.rooms[room].vertices.vertice2[ l.rooms[room].quads.quad[i].p1+1].light2;
       r1:=(color16 and 31744) shr 10;g1:=(color16 and 992) shr 5;b1:=color16 and 31;

       color16:=l.rooms[room].vertices.vertice2[ l.rooms[room].quads.quad[i].p2+1].light2;
       r2:=(color16 and 31744) shr 10;g2:=(color16 and 992) shr 5;b2:=color16 and 31;

       color16:=l.rooms[room].vertices.vertice2[ l.rooms[room].quads.quad[i].p3+1].light2;
       r3:=(color16 and 31744) shr 10;g3:=(color16 and 992) shr 5;b3:=color16 and 31;

       color16:=l.rooms[room].vertices.vertice2[ l.rooms[room].quads.quad[i].p4+1].light2;
       r4:=(color16 and 31744) shr 10;g4:=(color16 and 992) shr 5;b4:=color16 and 31;

   end //fin si es tr3 rgb color mode.
   else
   begin
       color8:=31-l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p1+1].light;
       r1:=color8;g1:=color8;b1:=color8;
       //....
       color8:=31-l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p2+1].light;
       r2:=color8;g2:=color8;b2:=color8;
       //....
       color8:=31-l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p3+1].light;
       r3:=color8;g3:=color8;b3:=color8;
       //....
       color8:=31-l.rooms[room].vertices.vertice[ l.rooms[room].quads.quad[i].p4+1].light;
       r4:=color8;g4:=color8;b4:=color8;
       //....
    end;//end si phd/tub/tr2 just intensities mode.


      if not light_enabled then
      begin
          r4:=31;g4:=31;b4:=31;
      end;


      r1:=((r1+1)*6)+63; g1:=((g1+1)*6)+63; b1:=((b1+1)*6)+63;
      r2:=((r2+1)*6)+63; g2:=((g2+1)*6)+63; b2:=((b2+1)*6)+63;
      r3:=((r3+1)*6)+63; g3:=((g3+1)*6)+63; b3:=((b3+1)*6)+63;
      r4:=((r4+1)*6)+63; g4:=((g4+1)*6)+63; b4:=((b4+1)*6)+63;


    //GET TEXTURE MAP
    mx1:=0;my1:=0;
    mx2:=1;my2:=0;
    mx3:=1;my3:=1;
    mx4:=0;my4:=1;

    if ntexture<l.Num_Textures then
    begin
      if l.textures[ntexture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[ntexture].my1<=1 then my1:=0 else my1:=1;
      if l.textures[ntexture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[ntexture].my2<=1 then my2:=0 else my2:=1;
      if l.textures[ntexture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[ntexture].my3<=1 then my3:=0 else my3:=1;
      if l.textures[ntexture].mx4<=1 then mx4:=0 else mx4:=1;if l.textures[ntexture].my4<=1 then my4:=0 else my4:=1;
    end;
    //--------------------------

       if (room+1)=render1 then GlLoadname(i) else GlLoadname(0);
       glBegin(gl_quads);
            glcolor3ub(r1,g1,b1);
            gltexcoord2f(mx1,my1);
            glVertex3f(xpos+x1,y1,zpos+z1);

            glcolor3ub(r2,g2,b2);
            gltexcoord2f(mx2,my2);
            glVertex3f(xpos+x2,y2,zpos+z2);

            glcolor3ub(r3,g3,b3);
            gltexcoord2f(mx3,my3);
            glVertex3f(xpos+x3,y3,zpos+z3);

            glcolor3ub(r4,g4,b4);
            gltexcoord2f(mx4,my4);
            glVertex3f(xpos+x4,y4,zpos+z4);

   glEnd;
   end;//end for (rectangles);
//draw triangles;

   for k:=1 to l.rooms[room].triangles.num_triangles do
   begin
//seleccionar la textura,
     //averiguar que triangulo sigue en la lista ordenada de triangulos
      xxpos:=pos('=',trian_list[xroom].strings[k-1]);
      ntexture:=strToint(copy(trian_list[xroom].strings[k-1],1,xxpos-1));
      i:=strToint(copy(trian_list[xroom].strings[k-1],xxpos+1,100));
      ntexture:=(l.rooms[room].triangles.triangle[i].texture and $7fff);
     if cur_texture<>ntexture then
     begin
        case texture_mode of
         0:if ntexture<=tabla_texture^.num_tiles then glbindtexture(gl_texture_2d, ntexture+1)
           else glbindtexture(gl_texture_2d, solid_bitmap);

         1: if ntexture<=tabla_texture^.num_tiles then
                  begin
                    trunit2.tr_Get_texture(ntexture,tabla_texture^,false);
                    Opgl_Define_Texture(1, tabla_texture^.cur_tile,buffer_size);
                   end
                  else glbindtexture(gl_texture_2d, solid_bitmap);
         end;//end
         cur_texture:=ntexture;
         set_perspective_correct(perspective_correct_enabled);
     end; //si necesario cambiar textura

       x1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p1+1].x;
       y1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p1+1].y;
       z1:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p1+1].z;

       x2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p2+1].x;
       y2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p2+1].y;
       z2:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p2+1].z;

       x3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p3+1].x;
       y3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p3+1].y;
       z3:=l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p3+1].z;

       x1:=(x1/1000);y1:=(y1/1000)*-1;z1:=(z1/1000)*-1;
       x2:=(x2/1000);y2:=(y2/1000)*-1;z2:=(z2/1000)*-1;
       x3:=(x3/1000);y3:=(y3/1000)*-1;z3:=(z3/1000)*-1;

//-----sacar el color de cada face, si tr1/tub/tr2 usar el
//campo de intensidad, si Tr3 usar el rgb de cada face.
   if l.tipo>=vtr3 then
   begin
       color16:=l.rooms[room].vertices.vertice2[ l.rooms[room].triangles.triangle[i].p1+1].light2;
       r1:=(color16 and 31744) shr 10;g1:=(color16 and 992) shr 5;b1:=color16 and 31;

       color16:=l.rooms[room].vertices.vertice2[ l.rooms[room].triangles.triangle[i].p2+1].light2;
       r2:=(color16 and 31744) shr 10;g2:=(color16 and 992) shr 5;b2:=color16 and 31;

       color16:=l.rooms[room].vertices.vertice2[ l.rooms[room].triangles.triangle[i].p3+1].light2;
       r3:=(color16 and 31744) shr 10;g3:=(color16 and 992) shr 5;b3:=color16 and 31;

   end //fin si es tr3 rgb color mode.
   else
   begin
       color8:=31-l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p1+1].light;
       r1:=color8;g1:=color8;b1:=color8;
       //....
       color8:=31-l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p2+1].light;
       r2:=color8;g2:=color8;b2:=color8;
       //....
       color8:=31-l.rooms[room].vertices.vertice[ l.rooms[room].triangles.triangle[i].p3+1].light;
       r3:=color8;g3:=color8;b3:=color8;
       //....
    end;//end si phd/tub/tr2 just intensities mode.

      if not light_enabled then
      begin
          r3:=31;g3:=31;b3:=31;
      end;


      r1:=((r1+1)*6)+63; g1:=((g1+1)*6)+63; b1:=((b1+1)*6)+63;
      r2:=((r2+1)*6)+63; g2:=((g2+1)*6)+63; b2:=((b2+1)*6)+63;
      r3:=((r3+1)*6)+63; g3:=((g3+1)*6)+63; b3:=((b3+1)*6)+63;


    //GET TEXTURE MAP
    mx1:=0;my1:=0;
    mx2:=1;my2:=0;
    mx3:=1;my3:=1;
    mx4:=0;my4:=1;

    if ntexture<l.Num_Textures then
    begin
      if l.textures[ntexture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[ntexture].my1<=1 then my1:=0 else my1:=1;
      if l.textures[ntexture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[ntexture].my2<=1 then my2:=0 else my2:=1;
      if l.textures[ntexture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[ntexture].my3<=1 then my3:=0 else my3:=1;
      if l.textures[ntexture].mx4<=1 then mx4:=0 else mx4:=1;if l.textures[ntexture].my4<=1 then my4:=0 else my4:=1;
    end;
    //--------------------------

     if (room+1)=render1 then GlLoadname(l.rooms[room].quads.num_quads+i) else GlLoadname(0);
     glBegin(GL_quads);
           glcolor3ub(r1,g1,b1);
           gltexcoord2f(mx1,my1);
           glVertex3f(xpos+x1,y1,zpos+z1);

            glcolor3ub(r2,g2,b2);
            gltexcoord2f(mx2,my2);
            glVertex3f(xpos+x2,y2,zpos+z2);

            glcolor3ub(r3,g3,b3);
            gltexcoord2f(mx3,my3);
            glVertex3f(xpos+x3,y3,zpos+z3);

            glcolor3ub(r3,g3,b3);
            gltexcoord2f(mx3,my3);
            glVertex3f(xpos+x3,y3,zpos+z3);
     glEnd;
   end;//end for (triangles);
   //render static mesh.
   meshes.draw_mode:=2;
   if not hide_static_mesh then render_ornaments(room);
   GLdisable(gl_texture_2d);
   if not hide_source_light then render_source_lights(room);
end;
//------------------------------

procedure tr_scene.render_ornaments(room:integer);

function found_static_mesh(var l:ttrlevel; meshid:integer):integer;
var
i:integer;
k:integer;
begin
    i:=-1;
    for k:=1 to l.num_Static_table do
    begin
        if meshid=l.Static_table[k-1].Idobj then begin i:=k;break;end;
    end;
    found_static_mesh:=i;
end;

type
tword =
 record
      b2:byte;
      b1:byte;
 end;

var
k:integer;
nmesh:integer;
x,y,z:glfloat;
angle:integer;
rr,gg,bb:integer;
high:integer;
row,column:integer;
//---------------
base,base2,front,back,left,right:integer;
p1,p2,p3,p4:real;
aligment:byte;
xpos,zpos:real;
begin
    for k:=1 to l.rooms[room].Statics.num_static do
    begin

        if l.tipo>=vtr2 then
        begin
          nmesh:=l.rooms[room].Statics.static2[k].obj;
          angle:=tword(l.rooms[room].Statics.static2[k].angle).b1;
          x:=l.rooms[room].Statics.static2[k].x/1000;
          y:=(l.rooms[room].Statics.static2[k].y/1000)*-1;
          z:=(l.rooms[room].Statics.static2[k].z/1000)*-1;
          if l.tipo=vtr2 then begin rr:=tword(l.rooms[room].statics.static2[k].light1).b1;if rr>31 then rr:=31; rr:=31-rr;gg:=rr;bb:=rr;end;
          if l.tipo>vtr2 then
          begin
               //sacar rgb de static mesh.
               rr:=l.rooms[room].statics.static2[k].light1 and $1f;
               gg:=(l.rooms[room].statics.static2[k].light1 and $3e0) shr 5;
               bb:=(l.rooms[room].statics.static2[k].light1 and $7c00) shr 10;
          end;

       end
       else
        begin
          nmesh:=l.rooms[room].Statics.static[k].obj;
          angle:=tword(l.rooms[room].Statics.static[k].angle).b1;
          x:=l.rooms[room].Statics.static[k].x/1000;
          y:=(l.rooms[room].Statics.static[k].y/1000)*-1;
          z:=(l.rooms[room].Statics.static[k].z/1000)*-1;
          rr:=tword(l.rooms[room].statics.static[k].light1).b1;
          if rr>31 then rr:=31;
          rr:=31-rr;
          gg:=rr;
          bb:=rr;
       end;

    if light_enabled then glcolor3ub(rr*8,gg*8,bb*8) else glcolor3ub(255,255,255);

    if angle<>0 then
     begin
      angle:=angle div 32;
      angle:=angle*45;if angle<>0 then angle:=360-angle;
     end;

    //find the mesh
    nmesh:=found_static_mesh(l,nmesh);
    if nmesh>=0 then
              nmesh:=meshes.mesh_pointers[ l.static_table[nmesh-1].mesh]
        else nmesh:=0;

        glloadname(0);
        glshademodel(gl_smooth);
        Draw_mesh3(meshes^, l, nmesh, x,y,z, angle, 0.10, false, perspective_correct_enabled,false);
        glshademodel(gl_flat);

    end;
end;

//----render source lights ---------------
procedure tr_scene.render_source_lights(room:integer);
const
r = 0.16;
var
k:integer;
x,y,z:glfloat;
begin
    for k:=1 to l.rooms[room].Source_lights.num_sources do
    begin
        if l.tipo<vtr2 then
        begin
          x:=l.rooms[room].source_lights.source_light[k].x/1000;
          y:=(l.rooms[room].source_lights.source_light[k].y/1000)*-1;
          z:=(l.rooms[room].source_lights.source_light[k].z/1000)*-1;
        end;

        if (l.tipo=vtr3) or (l.tipo=vtr2) then
        begin
          x:=l.rooms[room].source_lights.source_light2[k].x/1000;
          y:=(l.rooms[room].source_lights.source_light2[k].y/1000)*-1;
          z:=(l.rooms[room].source_lights.source_light2[k].z/1000)*-1;
        end;

        if l.tipo=vtr4 then
        begin
          x:=l.rooms[room].source_lights.source_light3[k].x/1000;
          y:=(l.rooms[room].source_lights.source_light3[k].y/1000)*-1;
          z:=(l.rooms[room].source_lights.source_light3[k].z/1000)*-1;
        end;

        if l.tipo=vtr5 then
        begin
          x:=l.rooms[room].source_lights.source_light4[k].x/1000;
          y:=(l.rooms[room].source_lights.source_light4[k].y/1000)*-1;
          z:=(l.rooms[room].source_lights.source_light4[k].z/1000)*-1;
        end;


        if (k=current_source_light) and (source_light_enabled) then glcolor3ub(128,128,0) else glcolor3ub(255,255,0);
        glloadname(0);
        glpushmatrix;
        gltranslatef(x,y+r,z);
        glusphere(sphere,r,15,15);
        glpopmatrix;

    end;//end all source lights
end; //end procedure

//--------------------

function tr_scene.center:glfloat;
var
despx,despy,despz:glfloat;
sc,scx,scy,scz:glfloat;
k:integer;
x0,z0,
x1,y1,z1:glfloat;

begin
    //averiguar el minimo y maximo.
    min.x:=922337203685477.580;
    min.y:=922337203685477.580;
    min.z:=922337203685477.580;
    max.x:=-922337203685477.580;
    max.y:=-922337203685477.580;
    max.z:=-922337203685477.580;

    x0:=l.rooms[render1-1].room_info.xpos_room/1000;
    z0:=(l.rooms[render1-1].room_info.zpos_room/1000)*-1;

    for k:=1 to l.rooms[render1-1].vertices.num_vertices do
    begin
      //adecuar TR cordinates a OPENGL cordinates
      x1:=l.rooms[render1-1].vertices.vertice[k].x/1000;
      y1:=(l.rooms[render1-1].vertices.vertice[k].y/1000)*-1;
      z1:=(l.rooms[render1-1].vertices.vertice[k].z/1000)*-1;
      x1:=x1+x0;
      z1:=z1+Z0;
//    y1:=y1*-1;

      if min.x>x1 then min.x:=x1;
      if min.y>y1 then min.y:=y1;
      if min.z>z1 then min.z:=z1;
      if max.x<x1 then max.x:=x1;
      if max.y<y1 then max.y:=y1;
      if max.z<z1 then max.z:=z1;

    end; //end k
//-------------------------------------------

    despx:=(min.x+((max.x-min.x)/2))*-1;
    despy:=(min.y+((max.y-min.y)/2))*-1;
    despz:=(min.z+((max.z-min.z)/2))*-1;

    translation.x:=despx;
    translation.y:=despy;
    translation.z:=despz;

   center:=0;

end;
//-----------------------------------------

procedure tr_scene.sort_textures;
var
r,f:integer;
t:word;
begin
       rectan_list[1].clear;
       rectan_list[1].Sorted:=false;
       trian_list[1].clear;
       trian_list[1].Sorted:=false;

       for f:=1 to l.rooms[render1-1].quads.num_quads do
       begin
         t:=l.rooms[render1-1].quads.quad[f].texture;
         rectan_list[1].add(IntToStr(t)+'='+IntToStr(f));
       end;//en rectangles
       rectan_list[1].sort;

       for f:=1 to l.rooms[render1-1].triangles.num_triangles do
       begin
         t:=l.rooms[render1-1].triangles.triangle[f].texture;
         trian_list[1].add(IntToStr(t)+'='+IntToStr(f));
       end;//en rectangles
       trian_list[1].sort;
//-------------------------------------
    if l.num_rooms<2 then exit;

//-------- render2 --------------------
       rectan_list[2].clear;
       rectan_list[2].Sorted:=false;
       trian_list[2].clear;
       trian_list[2].Sorted:=false;

       for f:=1 to l.rooms[render2-1].quads.num_quads do
       begin
         t:=l.rooms[render2-1].quads.quad[f].texture;
         rectan_list[2].add(IntToStr(t)+'='+IntToStr(f));
       end;//en rectangles
       rectan_list[2].sort;

       for f:=1 to l.rooms[render2-1].triangles.num_triangles do
       begin
         t:=l.rooms[render2-1].triangles.triangle[f].texture;
         trian_list[2].add(IntToStr(t)+'='+IntToStr(f));
       end;//en rectangles
       trian_list[2].sort;


end;//


procedure tr_scene.sort_textures(room:integer);
var
r,f:integer;
t:word;
begin
       rectan_list[1].clear;
       rectan_list[1].Sorted:=false;
       trian_list[1].clear;
       trian_list[1].Sorted:=false;

       for f:=1 to l.rooms[room-1].quads.num_quads do
       begin
         t:=l.rooms[room-1].quads.quad[f].texture;
         rectan_list[1].add(IntToStr(t)+'='+IntToStr(f));
       end;//en rectangles
       rectan_list[1].sort;

       for f:=1 to l.rooms[room-1].triangles.num_triangles do
       begin
         t:=l.rooms[room-1].triangles.triangle[f].texture;
         trian_list[1].add(IntToStr(t)+'='+IntToStr(f));
       end;//en rectangles
       trian_list[1].sort;
//-------------------------------------
end;//



procedure tr_scene.change_texture(index,textura,replicate:integer);
var
oldtext:word;
s:string;
i:integer;
t:integer;

begin
   if (index=0) or (index>(l.rooms[render1-1].quads.num_quads+l.rooms[render1-1].triangles.num_triangles)) or
       (textura=0) then exit; //no texture que cambiar

   textura:=textura-1;
   if index<=l.rooms[render1-1].quads.num_quads then
   begin
   for t:=1 to replicate do
   begin
       oldtext:=l.rooms[render1-1].quads.quad[index].texture;
       l.rooms[render1-1].quads.quad[index].texture:=textura;
       if l.tipo=vtr5 then l.rooms[render1-1].quads.quad2[index].texture:=textura;
       s:=IntToStr(oldtext)+'='+IntToStr(index);
       i:=rectan_list[1].IndexOf(S);
       rectan_list[1].strings[i]:=IntToStr(textura)+'='+IntToStr(index);
       rectan_list[1].sort;
       index:=index+1;
       if index>l.rooms[render1-1].quads.num_quads then break;
   end;//end for
   end //si se hizo clik en un quad
   else
   begin
     index:=index-l.rooms[render1-1].quads.num_quads;
   for t:=1 to replicate do
   begin
       oldtext:=l.rooms[render1-1].triangles.triangle[index].texture;
       l.rooms[render1-1].triangles.triangle[index].texture:=textura;
       if l.tipo=vtr5 then l.rooms[render1-1].triangles.triangle2[index].texture:=textura;
       s:=IntToStr(oldtext)+'='+IntToStr(index);
       i:=trian_list[1].IndexOf(S);
       trian_list[1].strings[i]:=IntToStr(textura)+'='+IntToStr(index);
       trian_list[1].sort;
       index:=index+1;
       if index>l.rooms[render1].triangles.num_triangles then break;
   end;//end for
   end;//si se hizo click  en un triangulo.

end;
//............................
function tr_scene.tr_get_texture(index:integer):word;
var
textura:word;
begin
   if (index=0) or (index>(l.rooms[render1-1].quads.num_quads+l.rooms[render1-1].triangles.num_triangles))
                then exit; //no texture que cambiar

   textura:=0;
   if index<=l.rooms[render1-1].quads.num_quads then
   begin
       textura:=l.rooms[render1-1].quads.quad[index].texture and $7fff ;
   end //si se hizo clik en un quad
   else
   begin
       index:=index-l.rooms[render1-1].quads.num_quads;
       textura:=l.rooms[render1-1].triangles.triangle[index].texture and $7fff;
   end;//si se hizo click  en un triangulo.
   tr_get_texture:=textura;
end;
//---------------------------------
function tr_loadTextures(var l:ttrlevel; buffer_size:byte; var vp:tglviewport):word;
//-----------------------
//carga las texturas del nivel al buffer del opengl;
var
a,b,c:tbitmap;
pal:hpalette;
num:integer;
pos:integer;
des:integer;
x1,y1,x2,y2,x3,y3,x4,y4:integer;
minx,miny,maxx,maxy:single;
p:pointer;
position,step:real;

begin
   b:=tbitmap.create;
   c:=tbitmap.create;
   b.pixelformat:=pf24bit;

   a:=tbitmap.create;
   a.pixelformat:=pf15bit;
   a.width:=256;
   a.height:=l.num_texture_pages*256;


//comvertir las texturas a un big bmp;
if l.tipo<vtr2 then
begin
   c.width:=256;
   c.height:=l.num_texture_pages*256;
   c.pixelformat:=pf8bit;
   pal2hpal(trgbpaleta(l.palette),pal);
   c.palette:=pal;
   xsetbitmapbits(c,c.width*c.height, l.texture_data);
   a.canvas.draw(0,0,c);
end
else
   xsetbitmapbits(a,(a.width*a.height)*2, l.texture_data2);

    step:=100/l.num_textures;
    position:=0;

   //---
    for num:=0 to l.num_textures-1 do
    begin
       des:=l.Textures[num].tile*256;

       x1:=l.Textures[num].x1;
       y1:=l.Textures[num].y1;
       x2:=l.Textures[num].x2;
       y2:=l.Textures[num].y2;
       x3:=l.Textures[num].x3;
       y3:=l.Textures[num].y3;
       x4:=l.Textures[num].x4;
       y4:=l.Textures[num].y4;
       if (x4=0) and (y4=0) then begin x4:=x3;y4:=y3;end;

//------------------------------------------
  minx:=fmin(x1,x2);minx:=fmin(minx,x3);minx:=fmin(minx,x4);
  miny:=fmin(y1,y2);miny:=fmin(miny,y3);miny:=fmin(miny,y4);
  maxx:=fmax(x1,x2);maxx:=fmax(maxx,x3);maxx:=fmax(maxx,x4);
  maxy:=fmax(y1,y2);maxy:=fmax(maxy,y3);maxy:=fmax(maxy,y4);
//------------------------------------------

       x1:=trunc(minx);x2:=trunc(maxx);y1:=trunc(miny)+des;y2:=trunc(maxy)+des;

       b.width:=(x2-x1+1); b.height:=(y2-y1+1);
       b.canvas.CopyRect(rect(0,0,b.width,b.height), a.Canvas, rect(x1,y1, x2,y2));
       //b contienen la textura actual en 24bit format

       //if flip the texture horizontal
       if (l.Textures[num].x2<l.Textures[num].x1) and (l.Textures[num].x3<l.Textures[num].x4) then
           bitmap_flip_hor(b);

       //if flip the texture vertical
       if (l.Textures[num].y1>l.Textures[num].y4) and (l.Textures[num].y2>l.Textures[num].y3) then
           bitmap_flip_ver(b);

       //ojo, estoy definiendo las texturas apartir de 1.
       opgl_define_texture(num+1,b,buffer_size,[vp]);
       position:=position+step;
       if l.progressbar<>nil then l.progressbar.Progress:=l.progressbar.Progress+trunc(position);
      end; //end for
   a.free;
   b.free;
   c.free;
   tr_loadTextures:=l.num_textures;
end;

procedure tr_scene.Render_level(from_room,to_room:integer);
var
k:integer;
brender1:integer;
begin
   if to_room>l.num_rooms then to_room:=l.num_rooms;
   if from_room>l.num_rooms then from_room:=l.num_rooms;

   //backup this value
   brender1:=render1;

  prepare_camera;

  for k:=from_room to to_room do
  begin
       case render_tipo of
                rtwireframe:begin wireframe_color:=claqua;render_wireframe(k);end;
                rtsolid : render_solid(k);
                rttextured,rtshaded:begin render1:=k;sort_textures(k);render_textured(k);end;
       end; //endcase
  end;//end all rooms


   glpopmatrix;

   //restore backuped value and sort textures
   render1:=brender1;
   sort_textures(render1);
end;

//---------------------

//---------------------------------
end.

