unit rUnit1;

interface

uses
  geometry,Windows, Messages, SysUtils, Classes,  Controls, Forms, Dialogs,Graphics,
  ExtCtrls,opengl12,fexopgl,tr_3d,fexgraph, Menus, StdCtrls,trunit2, Spin, Buttons,
  ComCtrls,regunit;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    F1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    ExportDxf1: TMenuItem;
    ImportDxf1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Save1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog2: TSaveDialog;
    About1: TMenuItem;
    About2: TMenuItem;
    Textures1: TMenuItem;
    ShowTextures1: TMenuItem;
    About3: TMenuItem;
    N3: TMenuItem;
    ShowToolbar1: TMenuItem;
    Save2: TMenuItem;
    SaveasMSH1: TMenuItem;
    OpenMSH1: TMenuItem;
    N4: TMenuItem;
    ChangeallTextures1: TMenuItem;
    ChangeallLights1: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    SaveDialog3: TSaveDialog;
    OpenDialog3: TOpenDialog;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    SpinEdit1: TSpinEdit;
    GroupBox3: TGroupBox;
    ComboBox1: TComboBox;
    Config1: TMenuItem;
    Redo1: TMenuItem;
    N5: TMenuItem;
    None1: TMenuItem;
    None2: TMenuItem;
    None3: TMenuItem;
    None4: TMenuItem;
    Undo1: TMenuItem;
    PanelTexture21: TMenuItem;
    AnimatedTextures1: TMenuItem;
    StatusBar1: TStatusBar;
    None5: TMenuItem;
    N8: TMenuItem;
    CenterCamera1: TMenuItem;
    View1: TMenuItem;
    HideStaticMesh1: TMenuItem;
    HideSourceLights1: TMenuItem;
    N9: TMenuItem;
    EnablePerspectiveCorrect1: TMenuItem;
    N10: TMenuItem;
    RenderLevel1: TMenuItem;
    FindReplace1: TMenuItem;
    FixInvalidTexturesId1: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N640x480layout1: TMenuItem;
    N800x600Layout1: TMenuItem;
    N1024x768Layout1: TMenuItem;
    N13: TMenuItem;
    Language1: TMenuItem;
    N14: TMenuItem;
    FullScreen1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure ExportDxf1Click(Sender: TObject);
    procedure ImportDxf1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure ShowTextures1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShowToolbar1Click(Sender: TObject);
    procedure About3Click(Sender: TObject);
    procedure ChangeallTextures1Click(Sender: TObject);
    procedure ChangeallLights1Click(Sender: TObject);
    procedure UndoLastCutface1Click(Sender: TObject);
    procedure About2Click(Sender: TObject);
    procedure Save2Click(Sender: TObject);
    procedure SaveasMSH1Click(Sender: TObject);
    procedure OpenMSH1Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Config1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure PanelTexture21Click(Sender: TObject);
    procedure Displayhint(sender:tobject);
    procedure AnimatedTextures1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CenterCamera1Click(Sender: TObject);
    procedure HideStaticMesh1Click(Sender: TObject);
    procedure HideSourceLights1Click(Sender: TObject);
    procedure EnablePerspectiveCorrect1Click(Sender: TObject);
    procedure RenderLevel1Click(Sender: TObject);
    procedure FindReplace1Click(Sender: TObject);
    procedure FixInvalidTexturesId1Click(Sender: TObject);
    procedure showmesizes1Click(Sender: TObject);
    procedure N800x600Layout1Click(Sender: TObject);
    procedure N1024x768Layout1Click(Sender: TObject);
    procedure N640x480layout1Click(Sender: TObject);
    procedure FullScreen1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    Scene:Tr_scene;
    camera:tglcamera;
    viewport:tglviewport;
    text1,text2:word;
    procedure open_dinamic(sender:tobject);
  end;

type tundo = record
     count:integer;
     index:integer;
     room : array [0..10] of troom;
     flag :boolean;
end;

var
  Form1:TForm1;
  L    :ttrlevel;
  tx   :ttabla_textures;
  openedfile:string;
  config:tstrings; //para implementar el rconfig.cnf
  apath:string;
  opengl_loaded:boolean;
  glfilename,glufilename:string;
  tm:byte;
  bs:byte;
  undo:tundo;
  //animated textures
  at      : array[1..99] of byte;
  at_data : array[1..99,1..99] of word;
  //recent files
  recent_files : tstrings;
  //manege mehes
  meshes:tmesh_list;

procedure load_states;
procedure update_recent_files(name:string);
procedure find_sector(var Column:integer; var row:integer);
procedure update_undo;

implementation

uses rUnit2,rUnit3,Runit4, rUnit5, runit6, rUnit7, Unit8, Unit9, rUnit8,
  ushowfromto;

{$R *.DFM}
//------------------------------------
//source lights
procedure Put_Spot_Light(var L:ttrlevel; room,fil,col,altura,color,distance:integer);
type
tword =
 record
      b2:byte;
      b1:byte;
 end;

var
x,z:cardinal;
y:integer;
sector:integer;
k:integer;
light:byte;

r:byte;
rr:word;
xr:word;
xxr:word;
k1,k2:integer;
begin

  light :=color;

  if light>31 then light:=31;
  Light:=31-Light;


  x:=l.rooms[room-1].room_info.xpos_room+((col-1)*1024)+512;
  z:=l.rooms[room-1].room_info.zpos_room+((fil-1)*1024)+512;
  //averiguar el sector.
  sector:=get_tile_index(l.rooms[room-1].sectors,col,fil);
  y:=(l.rooms[room-1].sectors.sector[sector].floor_height-altura)*256;

    k:=l.rooms[room-1].source_lights.num_sources+1;
    l.rooms[room-1].source_lights.num_sources:=k;
    //update source lights list here
    form3.ListBox1.Items.Add('Source Light#'+inttostr(k));
    form1.Scene.current_source_light:=k;
    form3.ListBox1.ItemIndex:=k-1;


  //si tr1/tub
  if l.tipo<vtr2 then
    begin
        l.rooms[room-1].source_lights.source_light[k].x:=x;
        l.rooms[room-1].source_lights.source_light[k].y:=y;
        l.rooms[room-1].source_lights.source_light[k].z:=z;


        tword(l.rooms[room-1].source_lights.source_light[k].intensity1).b1:=light;
        tword(l.rooms[room-1].source_lights.source_light[k].intensity1).b2:=0;

        tword(l.rooms[room-1].source_lights.source_light[k].fadeA).b1:=distance*4;
        tword(l.rooms[room-1].source_lights.source_light[k].fadeA).b2:=0;

        l.rooms[room-1].source_lights.source_light[k].fadeb:=0;
    end;

  //si Tomb Raider 2
  if l.tipo=vtr2 then
    begin
        l.rooms[room-1].source_lights.source_light2[k].x:=x;
        l.rooms[room-1].source_lights.source_light2[k].y:=y;
        l.rooms[room-1].source_lights.source_light2[k].z:=z;

        tword(l.rooms[room-1].source_lights.source_light2[k].intensity1).b1:=light;
        tword(l.rooms[room-1].source_lights.source_light2[k].intensity1).b2:=0;

        tword(l.rooms[room-1].source_lights.source_light2[k].fadeA).b1:=distance*4;
        tword(l.rooms[room-1].source_lights.source_light2[k].fadeA).b2:=0;

        l.rooms[room-1].source_lights.source_light2[k].fadeb:=0;
        l.rooms[room-1].source_lights.source_light2[k].fadec:=0;
        l.rooms[room-1].source_lights.source_light2[k].faded:=0;

        l.rooms[room-1].source_lights.source_light2[k].intensity2:=l.rooms[room-1].source_lights.source_light2[k].intensity1


    end;

end;
//-----------------------

procedure Put_RGB_Light(var L:ttrlevel; room,fil,col,altura, ir,ig,ib,intensity,distance:integer);
type
  rgbspot = record
          x,y,z:longint;
          r,g,b,a:byte;
          FadeA2,fadea1:byte;
          Fadeb:word;
          Fadec2,fadec1:byte;
          Faded:word;
  end;

var
x,z:cardinal;
y:integer;
sector:integer;
k,k1,k2:integer;
r,g,b:byte;
rr,gg,bb:word;
xr,xg,xb:word;
xxr,xxg,xxb:word;
roomx,roomz:cardinal;
nomesh:integer;
fadea,fadec:byte;
modo:byte;
tr5factor:single;
begin
  r :=ir;
  g :=ig;
  b :=ib;
  fadea :=31; //intensity;
  fadec :=distance;

  x:=l.rooms[room-1].room_info.xpos_room+((col-1)*1024)+512;
  z:=l.rooms[room-1].room_info.zpos_room+((fil-1)*1024)+512;
  //averiguar el sector.
  sector:=get_tile_index(l.rooms[room-1].sectors,col,fil);
  y:=(l.rooms[room-1].sectors.sector[sector].floor_height-altura)*256;


    k:=l.rooms[room-1].source_lights.num_sources+1;
    l.rooms[room-1].source_lights.num_sources:=k;
    //update source lights list here
    form3.ListBox1.Items.Add('Source Light#'+inttostr(k));
    form1.Scene.current_source_light:=k;
    form3.ListBox1.ItemIndex:=k-1;


  //si Tomb Raider 3
  if l.tipo=vtr3 then
    begin
        l.rooms[room-1].source_lights.source_light2[k].x:=x;
        l.rooms[room-1].source_lights.source_light2[k].y:=y;
        l.rooms[room-1].source_lights.source_light2[k].z:=z;

        rgbspot(l.rooms[room-1].source_lights.source_light2[k]).r:=r;
        rgbspot(l.rooms[room-1].source_lights.source_light2[k]).g:=g;
        rgbspot(l.rooms[room-1].source_lights.source_light2[k]).b:=b;
        rgbspot(l.rooms[room-1].source_lights.source_light2[k]).a:=0;

        rgbspot(l.rooms[room-1].source_lights.source_light2[k]).fadeA1:=fadea;
        rgbspot(l.rooms[room-1].source_lights.source_light2[k]).fadeA2:=0;


        l.rooms[room-1].source_lights.source_light2[k].fadeb:=0;
        rgbspot(l.rooms[room-1].source_lights.source_light2[k]).fadec1:=fadec;
        rgbspot(l.rooms[room-1].source_lights.source_light2[k]).fadec2:=0;

        l.rooms[room-1].source_lights.source_light2[k].faded:=0;
    end; //end if tr3 level

  //si Tomb Raider 4
  if l.tipo=vtr4 then
    begin
        l.rooms[room-1].source_lights.source_light3[k].x:=x;
        l.rooms[room-1].source_lights.source_light3[k].y:=y;
        l.rooms[room-1].source_lights.source_light3[k].z:=z;

        l.rooms[room-1].source_lights.source_light3[k].r:=r;
        l.rooms[room-1].source_lights.source_light3[k].g:=g;
        l.rooms[room-1].source_lights.source_light3[k].b:=b;

        l.rooms[room-1].source_lights.source_light3[k].light_type:=1;

        l.rooms[room-1].source_lights.source_light3[k].intensity:=15; //intensity; 0-31
        l.rooms[room-1].source_lights.source_light3[k].light_in:=(distance*1024)/2; // hot spot, how much sector recive full lighting.
        l.rooms[room-1].source_lights.source_light3[k].light_out:=distance*1024; // coverage.
   end; //end if tr4 level.


  //si Tomb Raider 5
  if l.tipo=vtr5 then
    begin
        l.rooms[room-1].source_lights.source_light4[k].x:=x;
        l.rooms[room-1].source_lights.source_light4[k].y:=y;
        l.rooms[room-1].source_lights.source_light4[k].z:=z;

        //same in different format
        l.rooms[room-1].source_lights.source_light4[k].x2:=x;
        l.rooms[room-1].source_lights.source_light4[k].y2:=y;
        l.rooms[room-1].source_lights.source_light4[k].z2:=z;

        tr5factor:=257.57;
        l.rooms[room-1].source_lights.source_light4[k].r:=r/tr5factor;
        l.rooms[room-1].source_lights.source_light4[k].g:=g/tr5factor;
        l.rooms[room-1].source_lights.source_light4[k].b:=b/tr5factor;

        l.rooms[room-1].source_lights.source_light4[k].light_type:=1;

        l.rooms[room-1].source_lights.source_light4[k].light_in:=(distance*1024)/2; // hot spot, how much sector recive full lighting.
        l.rooms[room-1].source_lights.source_light4[k].light_out:=distance*1024; // coverage.

        l.rooms[room-1].source_lights.source_light4[k].len:=0;

   end; //end if trc level.


end;
//----------------

//-----------
//suport for return2.exe, get the sector for a a clicked face

procedure find_sector(var Column:integer; var row:integer);
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4:glfloat;
vface,vzone,vreply:integer;
room,i:integer;
zindex:integer;
isector,sectorx,sectorz:integer;
vx,vz,vminx,vminz,vmaxx,vmaxz:single;
nx,nz:integer;
begin
   //---------
   vface:=form1.viewport.selection;
   row:=-1;column:=-1;

   if (vface=0) or (vface>(l.rooms[form1.scene.render1-1].quads.num_quads+l.rooms[form1.scene.render1-1].triangles.num_triangles))
         then exit; //asegurarse que no viene una cara invalida.

      room:=form1.scene.render1-1;
      i:=vface;

     if i<=l.rooms[room].quads.num_quads then
     begin //si quads
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
    end
    else
    begin// si triangles
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

    end; //si triangles

//---averiguar el tile sector de este face
// averiguar el normal x y z

nx:=0;
nz:=0;
if (x1=x2) and (x2=x3) and (x3=x4) then nx:=find_normalx(z1,z2,z3,z4);
if (z1=z2) and (z2=z3) and (z3=z4) then nz:=find_normalz(x1,x2,x3,x4);

  vminx:=fmin(x1,x2);vminx:=fmin(vminx,x3);vminx:=fmin(vminx,x4);
  vminz:=fmin(z1,z2);vminz:=fmin(vminz,z3);vminz:=fmin(vminz,z4);
  vmaxx:=fmax(x1,x2);vmaxx:=fmax(vmaxx,x3);vmaxx:=fmax(vmaxx,x4);
  vmaxz:=fmax(z1,z2);vmaxz:=fmax(vmaxz,z3);vmaxz:=fmax(vmaxz,z4);

try
  vx:=(vmaxx-((vmaxx-vminx) / 2))+nx;
  vz:=(vmaxz-((vmaxz-vminz) / 2))+nz;
  sectorx:=trunc(int(vx/1024));
  sectorz:=trunc(int(vz/1024));
  isector:=((sectorx*l.rooms[room].sectors.largo)+sectorz)+1;
  //averiguar el box/zone index.
if (isector>0) and (isector<(l.rooms[room].sectors.ancho*l.rooms[room].sectors.largo)) then
    zindex:= l.rooms[room].sectors.sector[isector].box_index
   else zindex:=-1;

except
     zindex:=-1;
end;

  row:=sectorz+1;
  column:=sectorx+1;


end; //end procedure
//---------------
procedure update_recent_files(name:string);
var
m:integer;
begin
  m:=recent_files.indexof(name);
  if m<0 then
    begin //Nuevo filename en la lista
        recent_files.insert(0,name);
        if recent_files.count>5 then recent_files.delete(5);
    end
  else
     begin
        recent_files.delete(m);
        recent_files.insert(0,name);
      end;
//aqui la lista es ordenada.
    if recent_files.count>=1 then
    begin
        form1.none1.caption:=recent_files[0];
        form1.none1.onclick:=form1.Open_dinamic;
    end;

    if recent_files.count>=2 then
    begin
        form1.none2.caption:=recent_files[1];
        form1.none2.onclick:=form1.Open_dinamic;
    end;

    if recent_files.count>=3 then
    begin
        form1.none3.caption:=recent_files[2];
        form1.none3.onclick:=form1.Open_dinamic;
    end;

    if recent_files.count>=4 then
    begin
        form1.none4.caption:=recent_files[3];
        form1.none4.onclick:=form1.Open_dinamic;
    end;

    if recent_files.count=5 then
    begin
        form1.none5.caption:=recent_files[4];
        form1.none5.onclick:=form1.Open_dinamic;
    end;


end;

procedure Save_States;
var
version:string;
maximized:boolean;
k:integer;
begin
    version:='Rview 5.x';
    OpenIniFile('Rview');
    maximized:=false;
    //version
    writeini('Version','version',version);

    //Form1
    if form1.windowstate=wsmaximized then
    begin
       maximized:=true;
       form1.WindowState:=wsnormal;
    end;
    writeini('form1','maximized',maximized);
    writeini('form1','left',form1.left);
    writeini('form1','top',form1.top);
    writeini('form1','width',form1.width);
    writeini('form1','height',form1.height);


    //Form3
    writeini('form3','left',form3.left);
    writeini('form3','top',form3.top);
    writeini('form3','width',form3.width);
    writeini('form3','height',form3.height);

    //Form4
    writeini('form4','left',form4.left);
    writeini('form4','top',form4.top);
    writeini('form4','width',form4.width);
    writeini('form4','height',form4.height);

    //Form6
    writeini('form6','left',form6.left);
    writeini('form6','top',form6.top);
    writeini('form6','width',form6.width);
    writeini('form6','height',form6.height);


    //Fpanel2
    writeini('fpanel2','left',fpanel2.left);
    writeini('fpanel2','top',fpanel2.top);
    writeini('fpanel2','width',fpanel2.width);
    writeini('fpanel2','height',fpanel2.height);

    //Fanimated
    writeini('fanimated','left',fanimated.left);
    writeini('fanimated','top',fanimated.top);
    writeini('fanimated','width',fanimated.width);
    writeini('fanimated','height',fanimated.height);

    //recent files
    writeini('Recent files','count',recent_files.count);
    for k:=0 to recent_files.count-1 do
    begin
        writeini('Recent files','File name'+inttostr(k),recent_files[k]);
    end;


    closeinifile;
end;



procedure Load_States;
var
version:string;
maximized:boolean;
left,top,width,height:integer;
m,k:integer;
name:string;
begin
    version:='';
    OpenIniFile('Rview');
    //version
  readini('Version','version',version);
  if version='Rview 5.x' then
  begin

    //Form1
    readini('form1','maximized',maximized);
    readini('form1','left',left);
    readini('form1','top',top);
    readini('form1','width',width);
    readini('form1','height',height);

    form1.left:=left;
    form1.top:=top;
    form1.width:=width;
    form1.height:=height;

    if maximized then form1.WindowState:=wsmaximized;

    //Form3
    readini('form3','left',left);
    readini('form3','top',top);
    readini('form3','width',width);
    readini('form3','height',height);

    form3.left:=left;
    form3.top:=top;
    form3.width:=width;
    form3.height:=height;


    //Form4
    readini('form4','left',left);
    readini('form4','top',top);
    readini('form4','width',width);
    readini('form4','height',height);

    form4.left:=left;
    form4.top:=top;
    form4.width:=width;
    form4.height:=height;


    //Form6
    readini('form6','left',left);
    readini('form6','top',top);
    readini('form6','width',width);
    readini('form6','height',height);

    form6.left:=left;
    form6.top:=top;
    form6.width:=width;
    form6.height:=height;

    //Fpanel2
    readini('fpanel2','left',left);
    readini('fpanel2','top',top);
    readini('fpanel2','width',width);
    readini('fpanel2','height',height);

    fpanel2.left:=left;
    fpanel2.top:=top;
    fpanel2.width:=width;
    fpanel2.height:=height;


    //Fanimated
    readini('fanimated','left',left);
    readini('fanimated','top',top);
    readini('fanimated','width',width);
    readini('fanimated','height',height);

    fanimated.left:=left;
    fanimated.top:=top;
    fanimated.width:=width;
    fanimated.height:=height;

   //recent files
    readini('Recent files','count',m);
    for k:=(m-1) downto 0 do
    begin
        readini('Recent files','File name'+inttostr(k),name);
        update_recent_files(name);
    end;


  end; //si ya estaba creado el ini
    closeinifile;
end;



procedure load_animated_textures;
var
m,x,k,ofset:integer;
aux:word;
begin
ofset:=1;

fanimated.listbox1.Items.clear;

for m:=1 to l.anim_textures[0] do
begin
   fanimated.listbox1.Items.add('Animated Texture #'+inttostr(m));
   x:=l.anim_textures[ofset]+1; //cuantas frames tiene esta textura animada.
   at[m]:=x;

   for k:=1 to x do
   begin
       aux:=l.anim_textures[ofset+k];
       at_data[m,k]:=aux;
   end;
   ofset:=ofset+x+1;
end; //no mas texturas animadas.

fanimated.listbox1.itemindex:=0;
fanimated.ListBox1Click(form1);
end;


procedure update_undo;
var
k:integer;
begin
    undo.index:=undo.index+1;
    if undo.index>10 then
    begin
        undo.index:=10;
        for k:=0 to 9 do undo.room[k]:=undo.room[k+1];
    end;//end si los 11 undo ya estan usados.
    undo.room[undo.index]:=l.rooms[form1.scene.render1-1];

    undo.count:=undo.index;
    undo.flag:=true;
    form1.Undo1.Enabled:=true;
    form1.Redo1.Enabled:=false;
end;

procedure VDraw;
begin
    form1.scene.redraw;
end;


Function loadtrfile(name:string):boolean;
var
  r:byte;
  res:boolean;
begin
 res:=false;
 form1.refresh;

 form10.memo1.lines.clear;
 form10.show;
 form10.gauge1.Progress:=0;
 l.progressbar:=form10.gauge1;
 form10.memo1.lines.add('Opening '+name+'...');
 if  l.Load_level(name)=0 then
begin
  form3.combobox1.Items.Clear;
  form3.combobox2.Items.Clear;

  form10.memo1.lines.add('Building room list..');
  for r:=0 to l.num_rooms-1 do
      begin
          form3.combobox1.Items.Add('Room #'+inttostr(r+1));
          form3.combobox2.Items.Add('Room #'+inttostr(r+1));
      end;

    form3.combobox1.itemindex:=0;
    form3.combobox2.itemindex:=1;

    form10.memo1.lines.add('Building texture table...');

    tr_tabla_textures(l,tx);

    fpanel2.Image1.Picture.bitmap:=tx.textures;

    form10.memo1.lines.add('Loading animated textures...');
    load_animated_textures;

    form4.spinedit1.minvalue:=0;
    form4.spinedit2.minvalue:=0;

    form4.spinedit1.maxvalue:=tx.num_tiles-1;
    form4.spinedit2.maxvalue:=tx.num_tiles-1;

    form10.memo1.Lines.add('Building Object Meshes...');
    build_mesh_list(meshes,l);
    meshes.draw_mode:=0;

    form1.caption:='Turbo Pascal''Room Viewer.- '+name;


   if form1.scene.texture_mode=0 then begin form10.memo1.lines.add('Loading textures into opengl buffers...');l.opengl_LoadTextures( [form1.viewport],form1.scene.buffer_size); end;//cargar textures en opengl

   form1.scene.render1:=1;
   form1.scene.render2:=2;
   form1.scene.sort_textures;

   form1.scene.center;
   form1.viewport.getdimension(form1.scene);
   form1.viewport.center;
   form1.viewport.invalidateGl;
   res:=true;
   form1.Repaint;
 end
 else
   ShowMessage('Invalid Tomb Raider File Format!!');
   form10.close;
   loadtrfile:=res;
   form1.Repaint;
end;
//--------------------------------------
//rutinas mouse click+action
//---------------------------
procedure put_colored_light(index:integer;replicate:integer; rectan:boolean);
type
wcolor = record
    r,g,b,a:byte;
end;

var
p1,p2,p3,p4:word;
r,g,b:byte;
k:integer;
begin

   if l.tipo<vtr3 then exit; //solo hacer esto si se edita tr3.
   for k:=index to index+replicate-1 do
   begin
   if rectan then //poner en rectangulo
   begin
       if k>l.rooms[form1.scene.render1-1].quads.num_quads then break;
       p1:=l.rooms[form1.scene.render1-1].quads.quad[k].p1;
       p2:=l.rooms[form1.scene.render1-1].quads.quad[k].p2;
       p3:=l.rooms[form1.scene.render1-1].quads.quad[k].p3;
       p4:=l.rooms[form1.scene.render1-1].quads.quad[k].p4;
       //poner el nuevo valor, tr3 en vertice2
       r:=wcolor(form3.shape1.brush.color).r div 8; g:=wcolor(form3.shape1.brush.color).g div 8; b:=wcolor(form3.shape1.brush.color).b div 8;
          if form3.checkbox7.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p1+1].light2:=(r shl 10) or (g shl 5) or (b);
          if form3.checkbox8.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p2+1].light2:=(r shl 10) or (g shl 5) or (b);
          if form3.checkbox9.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p3+1].light2:=(r shl 10) or (g shl 5) or (b);
          if form3.checkbox10.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p4+1].light2:=(r shl 10) or (g shl 5) or (b);

          //if TR5 level
          if l.tipo=vtr5 then
          begin
           if form3.checkbox7.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].r:=r*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].g:=g*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].b:=b*8;
                                            end;
           if form3.checkbox8.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].r:=r*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].g:=g*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].b:=b*8;
                                            end;
           if form3.checkbox9.checked then  begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].r:=r*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].g:=g*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].b:=b*8;
                                            end;
           if form3.checkbox10.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p4+1].r:=r*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p4+1].g:=g*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p4+1].b:=b*8;
                                            end;
          end; //end if TRc

   end //poner en rectangulo
   else
   begin //inicio triangulo
       if k>l.rooms[form1.scene.render1-1].triangles.num_triangles then break;
       p1:=l.rooms[form1.scene.render1-1].triangles.triangle[k].p1;
       p2:=l.rooms[form1.scene.render1-1].triangles.triangle[k].p2;
       p3:=l.rooms[form1.scene.render1-1].triangles.triangle[k].p3;
       //poner el nuevo valor, tr3 en vertice2
//        r:=wcolor(form3.shape1.brush.color).r; g:=wcolor(form3.shape1.brush.color).g; b:=wcolor(form3.shape1.brush.color).b;
          r:=wcolor(form3.shape1.brush.color).r div 8; g:=wcolor(form3.shape1.brush.color).g div 8; b:=wcolor(form3.shape1.brush.color).b div 8;

          if form3.checkbox7.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p1+1].light2:=(r shl 10) or (g shl 5) or (b);
          if form3.checkbox8.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p2+1].light2:=(r shl 10) or (g shl 5) or (b);
          if form3.checkbox9.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p3+1].light2:=(r shl 10) or (g shl 5) or (b);

          //if TR5 level
          if l.tipo=vtr5 then
          begin
           if form3.checkbox7.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].r:=r*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].g:=g*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].b:=b*8;
                                            end;
           if form3.checkbox8.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].r:=r*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].g:=g*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].b:=b*8;
                                            end;
           if form3.checkbox9.checked then  begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].r:=r*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].g:=g*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].b:=b*8;
                                            end;
          end; //end if TRc



   end;//poner en triangulo
 end;//end replicate;
 form1.viewport.invalidateGl;
end;
//--------------
procedure put_white_light(index:integer; replicate:integer; rectan:boolean);
var
p1,p2,p3,p4:word;
color:word;
k:integer;
begin
   for k:=index to index+replicate-1 do
   begin
   if rectan then //poner en rectangulo
   begin
       if k>l.rooms[form1.scene.render1-1].quads.num_quads then break;
       p1:=l.rooms[form1.scene.render1-1].quads.quad[k].p1;
       p2:=l.rooms[form1.scene.render1-1].quads.quad[k].p2;
       p3:=l.rooms[form1.scene.render1-1].quads.quad[k].p3;
       p4:=l.rooms[form1.scene.render1-1].quads.quad[k].p4;
       //poner el nuevo valor, si es tr1 or tr2 en vertice, si tr3 en vertice2
       if l.tipo<vtr3 then //si phd,tub,tr2
       begin
          if form3.checkbox3.checked then l.rooms[form1.scene.render1-1].vertices.vertice[p1+1].light:=form3.trackbar1.position;
          if form3.checkbox4.checked then l.rooms[form1.scene.render1-1].vertices.vertice[p2+1].light:=form3.trackbar1.position;
          if form3.checkbox6.checked then l.rooms[form1.scene.render1-1].vertices.vertice[p3+1].light:=form3.trackbar1.position;
          if form3.checkbox5.checked then l.rooms[form1.scene.render1-1].vertices.vertice[p4+1].light:=form3.trackbar1.position;
          //----------------
          if form3.checkbox3.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p1+1].light2:=form3.trackbar1.position;
          if form3.checkbox4.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p2+1].light2:=form3.trackbar1.position;
          if form3.checkbox6.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p3+1].light2:=form3.trackbar1.position;
          if form3.checkbox5.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p4+1].light2:=form3.trackbar1.position;
          //-----------------
          if form3.checkbox3.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p1+1].light:=form3.trackbar1.position;
          if form3.checkbox4.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p2+1].light:=form3.trackbar1.position;
          if form3.checkbox6.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p3+1].light:=form3.trackbar1.position;
          if form3.checkbox5.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p4+1].light:=form3.trackbar1.position;

       end
       else
       begin //si tr3
          color:=31-form3.trackbar1.position;
          if form3.checkbox3.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p1+1].light2:=(color shl 10) or (color shl 5) or (color);
          if form3.checkbox4.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p2+1].light2:=(color shl 10) or (color shl 5) or (color);
          if form3.checkbox6.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p3+1].light2:=(color shl 10) or (color shl 5) or (color);
          if form3.checkbox5.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p4+1].light2:=(color shl 10) or (color shl 5) or (color);

          //if TR5 level
          if l.tipo=vtr5 then
          begin
           if form3.checkbox3.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].r:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].g:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].b:=color*8;
                                            end;
           if form3.checkbox4.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].r:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].g:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].b:=color*8;
                                            end;
           if form3.checkbox6.checked then  begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].r:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].g:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].b:=color*8;
                                            end;
           if form3.checkbox5.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p4+1].r:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p4+1].g:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p4+1].b:=color*8;
                                            end;
          end; //end if TRc




       end;

   end //poner en rectangulo
   else
   begin //inicio triangulo
       if k>l.rooms[form1.scene.render1-1].triangles.num_triangles then break;
       p1:=l.rooms[form1.scene.render1-1].triangles.triangle[k].p1;
       p2:=l.rooms[form1.scene.render1-1].triangles.triangle[k].p2;
       p3:=l.rooms[form1.scene.render1-1].triangles.triangle[k].p3;
       //poner el nuevo valor, si es tr1 or tr2 en vertice, si tr3 en vertice2
       if l.tipo<vtr3 then //si phd,tub,tr2
       begin
          if form3.checkbox3.checked then l.rooms[form1.scene.render1-1].vertices.vertice[p1+1].light:=form3.trackbar1.position;
          if form3.checkbox4.checked then l.rooms[form1.scene.render1-1].vertices.vertice[p2+1].light:=form3.trackbar1.position;
          if form3.checkbox6.checked then l.rooms[form1.scene.render1-1].vertices.vertice[p3+1].light:=form3.trackbar1.position;
       end
       else
       begin //si tr3
          color:=31-form3.trackbar1.position;
          if form3.checkbox3.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p1+1].light2:=(color shl 10) or (color shl 5) or (color);
          if form3.checkbox4.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p2+1].light2:=(color shl 10) or (color shl 5) or (color);
          if form3.checkbox6.checked then l.rooms[form1.scene.render1-1].vertices.vertice2[p3+1].light2:=(color shl 10) or (color shl 5) or (color);

          //if TR5 level
          if l.tipo=vtr5 then
          begin
           if form3.checkbox3.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].r:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].g:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p1+1].b:=color*8;
                                            end;
           if form3.checkbox4.checked then begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].r:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].g:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p2+1].b:=color*8;
                                            end;
           if form3.checkbox6.checked then  begin
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].r:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].g:=color*8;
                                               l.rooms[form1.scene.render1-1].vertices.vertice3[p3+1].b:=color*8;
                                            end;
          end; //end if TRc


       end;
   end;//poner en triangulo
 end;//end replicate;
   form1.viewport.invalidateGl;
end;
//-----------------------------------
procedure put_zone;
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4:glfloat;
vface,vzone,vreply:integer;
room,i:integer;
zindex:integer;
isector,sectorx,sectorz:integer;
vx,vz,vminx,vminz,vmaxx,vmaxz:single;
nx,nz:integer;
begin
   //---------
   vface:=form1.viewport.selection;
   vzone:=form6.spinedit1.value;
   vreply:=form1.spinedit1.value;
   //---------

for k:=1 to vreply do
begin
      if (vface=0) or (vface>(l.rooms[form1.scene.render1-1].quads.num_quads+l.rooms[form1.scene.render1-1].triangles.num_triangles))
         then continue; //asegurarse que no viene una cara invalida.

      room:=form1.scene.render1-1;
      i:=vface;

     if i<=l.rooms[room].quads.num_quads then
     begin //si quads
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
    end
    else
    begin// si triangles
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

    end; //si triangles

//---averiguar el tile sector de este face
// averiguar el normal x y z

nx:=0;
nz:=0;
if (x1=x2) and (x2=x3) and (x3=x4) then nx:=find_normalx(z1,z2,z3,z4);
if (z1=z2) and (z2=z3) and (z3=z4) then nz:=find_normalz(x1,x2,x3,x4);

  vminx:=fmin(x1,x2);vminx:=fmin(vminx,x3);vminx:=fmin(vminx,x4);
  vminz:=fmin(z1,z2);vminz:=fmin(vminz,z3);vminz:=fmin(vminz,z4);
  vmaxx:=fmax(x1,x2);vmaxx:=fmax(vmaxx,x3);vmaxx:=fmax(vmaxx,x4);
  vmaxz:=fmax(z1,z2);vmaxz:=fmax(vmaxz,z3);vmaxz:=fmax(vmaxz,z4);

try
  vx:=(vmaxx-((vmaxx-vminx) / 2))+nx;
  vz:=(vmaxz-((vmaxz-vminz) / 2))+nz;
  sectorx:=trunc(int(vx/1024));
  sectorz:=trunc(int(vz/1024));
  isector:=((sectorx*l.rooms[room].sectors.largo)+sectorz)+1;
  //averiguar el box/zone index.
if (isector>0) and (isector<(l.rooms[room].sectors.ancho*l.rooms[room].sectors.largo)) then
    zindex:= l.rooms[room].sectors.sector[isector].box_index
   else zindex:=-1;
  if (l.tipo>=vtr3) and (zindex<>-1) and (zindex>0) then zindex:=zindex shr 4;
  if zindex=-16 then zindex:=-1;

except
     zindex:=-1;
end;

if zindex=-1 then continue;

  case form1.scene.current_zone of
       1:l.nground_zone1[zindex]:=vzone;
       2:l.nground_zone2[zindex]:=vzone;
       3:l.nground_zone3[zindex]:=vzone;
       4:l.nground_zone4[zindex]:=vzone;
       5:l.nfly_zone[zindex]:=vzone;
  end; //end case.
  vface:=vface+1;
end; //end for

end;//fin procedure;
//--------------------------------

procedure do_put(textura:integer);
var
index:integer;
begin
   if (not form1.scene.light_enabled) and (not form3.RadioButton6.checked) then
     begin
         form1.scene.change_texture(form1.viewport.selection,textura+1,form1.spinedit1.value);
     end //fin si poner texturas
   else
     if form3.RadioButton6.checked then
         put_zone
     else
     begin //inicio si poner luz
         index:=form1.viewport.selection;
         if index<=l.rooms[form1.scene.render1-1].quads.num_quads then
         begin
              if form3.RadioButton7.checked then put_white_light(index,form1.spinedit1.value,true) else put_colored_light(index,form1.spinedit1.value,true);
         end //fin si poner en rectangulo
         else
         begin
              index:=index-l.rooms[form1.scene.render1-1].quads.num_quads;
              if form3.RadioButton7.checked then put_white_light(index,form1.spinedit1.value,false) else put_colored_light(index,form1.spinedit1.value,false)
         end;//fin si poner en triangulo

     end;//fin si poner luces.

    form1.viewport.invalidategl;
end;
//-------------
procedure do_put_source_light;

type
wcolor = record
    r,g,b,a:byte;
end;

var
room,fil,col,altura,intensity,distance:integer;
r,g,b:integer;
color:tcolor;
begin
  //-------------------------
  //--find the sector
  find_sector(col,fil);
  form1.statusbar1.Panels[1].text:='Column:'+inttostr(col)+' Row:'+inttostr(fil);

  altura:=form3.spinedit8.value;
  intensity:=form3.spinedit9.value;
  distance:=form3.spinedit10.value;
  room:=form1.Scene.render1;

  if l.tipo<vtr3 then put_spot_light(l,room,fil,col,altura,intensity,distance);
  if l.tipo>=vtr3 then
  begin
     color:=form3.shape3.brush.color;
     r:=wcolor(color).r;
     g:=wcolor(color).g;
     b:=wcolor(color).b;
     put_rgb_light(l,room,fil,col,altura,r,g,b,intensity,distance);
  end;

  //-------------------------
   form1.viewport.invalidategl;
end;

procedure do_move_source_light;
var
room,fil,col:integer;
y,x,z:cardinal;
k:integer;
altura:integer;
sector:integer;
begin
  //--find the sector
  find_sector(col,fil);
  form1.statusbar1.Panels[1].text:='Column:'+inttostr(col)+' Row:'+inttostr(fil);
  room:=form1.Scene.render1;
  k:=form1.Scene.current_source_light;
  altura:=form3.spinedit8.value;

  x:=l.rooms[room-1].room_info.xpos_room+((col-1)*1024)+512;
  z:=l.rooms[room-1].room_info.zpos_room+((fil-1)*1024)+512;
  //averiguar el sector.
  sector:=get_tile_index(l.rooms[room-1].sectors,col,fil);
  y:=(l.rooms[room-1].sectors.sector[sector].floor_height-altura)*256;


  if l.tipo<vtr2 then
  begin
      l.rooms[room-1].source_lights.source_light[k].x:=x;
      l.rooms[room-1].source_lights.source_light[k].y:=y;
      l.rooms[room-1].source_lights.source_light[k].z:=z;
  end;

  if l.tipo=vtr3 then
  begin
      l.rooms[room-1].source_lights.source_light2[k].x:=x;
      l.rooms[room-1].source_lights.source_light2[k].y:=y;
      l.rooms[room-1].source_lights.source_light2[k].z:=z;
  end;

  if l.tipo=vtr4 then
  begin
      l.rooms[room-1].source_lights.source_light3[k].x:=x;
      l.rooms[room-1].source_lights.source_light3[k].y:=y;
      l.rooms[room-1].source_lights.source_light3[k].z:=z;
  end;

  if l.tipo=vtr5 then
  begin
      l.rooms[room-1].source_lights.source_light4[k].x:=x;
      l.rooms[room-1].source_lights.source_light4[k].y:=y;
      l.rooms[room-1].source_lights.source_light4[k].z:=z;
  end;


 //-------------------------
  form1.viewport.invalidategl;
end;

//...............
procedure do_get;
type
wcolor = record
    r,g,b,a:byte;
end;

var
column,row:integer;
p1,index:integer;
light:word;
color:wcolor;
color2:tcolor;
begin
   if not form1.scene.light_enabled then
     begin
       form1.text1:=form1.scene.tr_get_texture(form1.viewport.selection);
       form4.image5.picture.Bitmap:=tr_get_texture(form1.text1,tx,true);
       form4.spinedit1.value:=form1.text1;
       //--find the sector
       find_sector(column,row);
       form1.statusbar1.Panels[1].text:='Column:'+inttostr(column)+' Row:'+inttostr(row);
     end //fin obtener texturas
     else
     begin//get light from the vertex #1.
         //rectangle or triangle.
         index:=form1.viewport.selection;
         if index<=l.rooms[form1.scene.render1-1].quads.num_quads then
            p1:=l.rooms[form1.Scene.render1-1].quads.quad[index].p1 else
            p1:=l.rooms[form1.Scene.render1-1].triangles.triangle[index].p1;
         //now get the light depending the tr version
         if l.tipo<vtr3 then
         begin
             light:=l.rooms[form1.scene.render1-1].vertices.vertice[p1+1].light;
             if light>31 then light:=31;
             form3.TrackBar1.Position:=light;
         end//end if tr-trii level
         else
         begin
             light:=l.rooms[form1.scene.render1-1].vertices.vertice2[p1+1].light2;
             color.r:=((light and $7c00) shr 10)*8;
             color.g:=((light and $3e0) shr 5)*8;
             color.b:=(light and $1f)*8;
             move(color,color2,4);
             form3.shape1.brush.color:=color2;
         end;//end tr3-trc colored vertex.
       //--fin the sector
       find_sector(column,row);
       form1.statusbar1.Panels[1].text:='Column:'+inttostr(column)+' Row:'+inttostr(row);

     end;//end get light

end;
//...............
procedure do_rotar;
var
p0,p1,p2,p3:word;
index:integer;
begin
   if form1.viewport.selection<>0 then
    begin
       index:=form1.viewport.selection;
       if index<=l.rooms[form1.scene.render1-1].quads.num_quads then
       begin
            p1:=l.rooms[form1.scene.render1-1].quads.quad[index].p1;
            p2:=l.rooms[form1.scene.render1-1].quads.quad[index].p2;
            p3:=l.rooms[form1.scene.render1-1].quads.quad[index].p3;
            p0:=l.rooms[form1.scene.render1-1].quads.quad[index].p4;

            l.rooms[form1.scene.render1-1].quads.quad[index].p1:=p0;
            l.rooms[form1.scene.render1-1].quads.quad[index].p2:=p1;
            l.rooms[form1.scene.render1-1].quads.quad[index].p3:=p2;
            l.rooms[form1.scene.render1-1].quads.quad[index].p4:=p3;

            if l.tipo=vtr5 then
            begin
                l.rooms[form1.scene.render1-1].quads.quad2[index].p1:=p0;
                l.rooms[form1.scene.render1-1].quads.quad2[index].p2:=p1;
                l.rooms[form1.scene.render1-1].quads.quad2[index].p3:=p2;
                l.rooms[form1.scene.render1-1].quads.quad2[index].p4:=p3;
            end;

       end //si rectangle.
       else
       begin
            index:=index-l.rooms[form1.scene.render1-1].quads.num_quads;
            p1:=l.rooms[form1.scene.render1-1].triangles.triangle[index].p1;
            p2:=l.rooms[form1.scene.render1-1].triangles.triangle[index].p2;
            p0:=l.rooms[form1.scene.render1-1].triangles.triangle[index].p3;

            l.rooms[form1.scene.render1-1].triangles.triangle[index].p1:=p0;
            l.rooms[form1.scene.render1-1].triangles.triangle[index].p2:=p1;
            l.rooms[form1.scene.render1-1].triangles.triangle[index].p3:=p2;

            if l.tipo=vtr5 then
            begin
               l.rooms[form1.scene.render1-1].triangles.triangle2[index].p1:=p0;
               l.rooms[form1.scene.render1-1].triangles.triangle2[index].p2:=p1;
               l.rooms[form1.scene.render1-1].triangles.triangle2[index].p3:=p2;
            end;


       end;//si triangulo
   end;//fin si hay selection.

   form1.viewport.invalidateGl;

end;
//...............
procedure do_cut;
var
index:integer;
begin
   if form1.viewport.selection<>0 then
    begin
       index:=form1.viewport.selection;
       if index<=l.rooms[form1.scene.render1-1].quads.num_quads then
       begin
            l.rooms[form1.scene.render1-1].quads.quad[index].p1:=0;
            l.rooms[form1.scene.render1-1].quads.quad[index].p2:=0;
            l.rooms[form1.scene.render1-1].quads.quad[index].p3:=0;
            l.rooms[form1.scene.render1-1].quads.quad[index].p4:=0;

            if l.tipo=vtr5 then
            begin
                l.rooms[form1.scene.render1-1].quads.quad2[index].p1:=0;
                l.rooms[form1.scene.render1-1].quads.quad2[index].p2:=0;
                l.rooms[form1.scene.render1-1].quads.quad2[index].p3:=0;
                l.rooms[form1.scene.render1-1].quads.quad2[index].p4:=0;
            end;

       end //si rectangle.
       else
       begin
            index:=index-l.rooms[form1.scene.render1-1].quads.num_quads;
            l.rooms[form1.scene.render1-1].triangles.triangle[index].p1:=0;
            l.rooms[form1.scene.render1-1].triangles.triangle[index].p2:=0;
            l.rooms[form1.scene.render1-1].triangles.triangle[index].p3:=0;


            if l.tipo=vtr5 then
            begin
             l.rooms[form1.scene.render1-1].triangles.triangle2[index].p1:=0;
             l.rooms[form1.scene.render1-1].triangles.triangle2[index].p2:=0;
             l.rooms[form1.scene.render1-1].triangles.triangle2[index].p3:=0;
            end;

       end;//si traingulo
   end;//fin si hay selection.

   form1.viewport.invalidateGl;
end;
//...............




//---------------------------------------

procedure tform1.Displayhint(sender:tobject);
begin
    statusbar1.Panels[0].text:=GetLongHint(application.hint);
end;


procedure TForm1.FormCreate(Sender: TObject);
var
k:integer;
NewItem: array[0..5] of TMenuItem;
solid_bitmap:tbitmap;
f:textfile;
begin
    l:=ttrlevel.create;
   //numeric international setting changed to american way.
   FormatSettings.decimalseparator:='.';
   FormatSettings.ThousandSeparator:=',';
    application.onhint:=form1.displayhint;
    //----------------
   //abrir el config.opt-------
    apath:=application.exename;
    apath:=ExtractFilePath(apath);
    if not fileExists(apath+'config.opt') then
    begin
         showmessage('Config.opt file not found!');
         halt;
    end;
    assignFile(f,apath+'config.opt');
    reset(f);
    //leer la configuracion.
    readln(f,glfilename);
    readln(f,glufilename);
    readln(f,tm);
    readln(f,bs);
    closefile(f);
    //----
   if glfilename='' then glfilename:='opengl32.dll';
   if glufilename='' then glufilename:='glu32.dll';

   if initopenglfromlibrary(glfilename,glufilename) then
   begin
    viewport:=tglviewport.create(form1);
    scene:=tr_scene.create;
    camera:=tglcamera.create;
    scene.buffer_size:=bs;
    viewport.buffer_size:=scene.buffer_size;
    viewport.control:=panel1;
    viewport.dodraw:=vdraw;
    viewport.camera:=camera;
    viewport.disable_mouseclick:=true;

    solid_bitmap:=tbitmap.create;
    solid_bitmap.LoadFromFile(ExtractFilePath(application.exename)+'solid.bmp');
    scene.solid_bitmap:=3999;
    Opgl_define_Texture(scene.solid_bitmap,solid_bitmap,scene.buffer_size,[form1.viewport]);
    scene.L:=L;
    scene.tabla_texture:=@tx;
    scene.meshes:=@meshes;

    opengl_loaded:=true;
    if tm=0 then scene.texture_mode:=0 else scene.texture_mode:=1;
   end
   else showmessage('OPENGL drivers not found!, check config.opt');
//------------------------
    openedfile:='';
   combobox1.itemindex:=0;
   undo.count:=-1;
   undo.index:=-1;
   undo.flag:=false;
   form1.Undo1.Enabled:=false;
   form1.redo1.enabled:=false;
   recent_files:=tstringlist.create;

   //initialize the global sphere
   sphere:=glunewquadric;

end;


procedure TForm1.Exit1Click(Sender: TObject);
begin
    form1.close;
end;

procedure TForm1.Open1Click(Sender: TObject);
begin
   if opendialog1.execute then
   begin
      screen.cursor:=crhourglass;
      form1.refresh;
      if not Loadtrfile(opendialog1.FileName) then begin screen.cursor:=crdefault;exit;end;
      openedfile:=opendialog1.FileName;
      //lara's ligh updated
      update_lara_light_and_room_flags;

      form4.loadtextures(l);

      text1:=runit4.a.index[1];text2:=runit4.a.index[2];

      form4.spinedit1.value:=text1;
      form4.spinedit2.value:=text2;

      form4.image5.picture.Bitmap:=tr_get_texture(text1,tx,true);
      form4.image6.picture.Bitmap:=tr_get_texture(text2,tx,true);
      update_recent_files(opendialog1.FileName);
      screen.cursor:=crdefault;
   end else form1.refresh;
end;

procedure TForm1.ExportDxf1Click(Sender: TObject);
var
r:integer;
begin
   if (savedialog1.Execute) then
   begin
      screen.cursor:=crhourglass;
      form1.refresh;
       r:=scene.render1-1;
       tr_exportdxf(savedialog1.FileName,r,l);

      screen.cursor:=crdefault;

   end;
end;

procedure TForm1.ImportDxf1Click(Sender: TObject);
var
r:byte;
v:tvertice_list;
k:integer;
n:integer;
begin
   r:=scene.render1-1;
   if opendialog2.execute then
   begin
     screen.cursor:=crhourglass;
     form1.refresh;
     //salvar las lights
     v:=l.rooms[r].vertices;
     update_undo; //para el undo.
     tr_importdxf(opendialog2.filename,r,L);
     //restaurar the lights
     n:=v.num_vertices;
     if n>l.rooms[r].vertices.num_vertices then n:=l.rooms[r].vertices.num_vertices;
     for k:=1 to n do
     begin
         //vertices1 primero
         l.rooms[r].vertices.vertice[k].light0:=v.vertice[k].light0;
         l.rooms[r].vertices.vertice[k].light:=v.vertice[k].light;
         //vertices2 segundo
         l.rooms[r].vertices.vertice2[k].light0:=v.vertice2[k].light0;
         l.rooms[r].vertices.vertice2[k].light:=v.vertice2[k].light;
         l.rooms[r].vertices.vertice2[k].attrib:=v.vertice2[k].attrib;
         l.rooms[r].vertices.vertice2[k].light2:=v.vertice2[k].light2;
         //vertices3 tercero
         l.rooms[r].vertices.vertice3[k].b:=v.vertice3[k].b;
         l.rooms[r].vertices.vertice3[k].g:=v.vertice3[k].g;
         l.rooms[r].vertices.vertice3[k].r:=v.vertice3[k].r;
         l.rooms[r].vertices.vertice3[k].a:=v.vertice3[k].a;
     end;
     form1.scene.sort_textures;
     form1.scene.center;

     viewport.getdimension(scene);
     viewport.center;
     viewport.invalidategl;
     screen.cursor:=crdefault;
    end;

end;

procedure TForm1.Save1Click(Sender: TObject);
var
m:integer;
k:integer;
NewItem:TMenuItem;
begin
   if openedfile='' then exit;
   if (savedialog2.Execute) then
   begin
       screen.cursor:=crhourglass;
       form1.refresh;
       form10.memo1.Lines.clear;
       form10.Show;
       form10.memo1.lines.add('Saving level file '+savedialog2.FileName+'...');
       L.Save_Level(savedialog2.FileName);
       openedfile:=savedialog2.FileName;
       screen.cursor:=crdefault;
       update_recent_files(savedialog2.FileName);
       form10.close;
//----------------------------------
//--------------------------------------------
   end;//end si se acepto gravar el archivo
end;

procedure tform1.open_dinamic(sender:tobject);
var
filename:string;
begin

    filename:=tmenuitem(sender).caption;

    if not fileExists(filename) then
    begin
       showmessage('File not found!!!');
       exit;
    end;

      screen.cursor:=crhourglass;
      form1.refresh;
      if not Loadtrfile(FileName) then begin screen.cursor:=crdefault;exit;end;
      openedfile:=FileName;
      //lara's ligh updated
      update_lara_light_and_room_flags;

      form4.loadtextures(l);

      text1:=runit4.a.index[1];text2:=runit4.a.index[2];
      form4.spinedit1.value:=form1.text1;
      form4.spinedit2.value:=form1.text2;

      form4.image5.picture.Bitmap:=tr_get_texture(text1,tx,true);
      form4.image6.picture.Bitmap:=tr_get_texture(text2,tx,true);

      update_recent_files(filename);
      screen.cursor:=crdefault;

end;

procedure TForm1.ShowTextures1Click(Sender: TObject);
begin
    form4.show;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
form3.show;
form4.Show;

end;

procedure TForm1.ShowToolbar1Click(Sender: TObject);
begin
    form3.show;
//  form6.show;
end;

procedure TForm1.About3Click(Sender: TObject);
begin
    form2.showmodal;
    form1.Refresh;
end;

procedure TForm1.ChangeallTextures1Click(Sender: TObject);
var
k:integer;
begin
    if openedfile='' then exit;
    for k:=1 to l.rooms[form1.scene.render1-1].quads.num_quads do begin l.rooms[form1.scene.render1-1].quads.quad[k].texture:=form1.text1;if l.tipo=vtr5 then l.rooms[form1.scene.render1-1].quads.quad2[k].texture:=form1.text1; end;
    for k:=1 to l.rooms[form1.scene.render1-1].triangles.num_triangles do begin l.rooms[form1.scene.render1-1].triangles.triangle[k].texture:=form1.text1;if l.tipo=vtr5 then l.rooms[form1.scene.render1-1].triangles.triangle2[k].texture:=form1.text1;end;
    scene.sort_textures;
    viewport.InvalidateGL;
end;

procedure TForm1.ChangeallLights1Click(Sender: TObject);
var
k:integer;
begin
  if openedfile='' then exit;
  k:=l.rooms[form1.scene.render1-1].quads.num_quads;
  if form3.RadioButton7.checked then put_white_light(1,k,true) else put_colored_light(1,k,true);

  k:=l.rooms[form1.scene.render1-1].triangles.num_triangles;
  if form3.RadioButton7.checked then put_white_light(1,k,false) else put_colored_light(1,k,false);
  viewport.InvalidateGL;

end;

procedure TForm1.UndoLastCutface1Click(Sender: TObject);
begin
    viewport.invalidategl;
end;

procedure TForm1.About2Click(Sender: TObject);
begin
    form5.showmodal;
    form1.Refresh;
end;

procedure TForm1.Save2Click(Sender: TObject);
var
m:integer;
NewItem:TMenuItem;
begin
       if openedfile<>'' then
       begin
          screen.cursor:=crhourglass;
          form1.refresh;
          form10.memo1.Lines.clear;
          form10.Show;
          form10.memo1.lines.add('Saving level file '+openedfile+'...');
//        l.tr1TOtr2;
          l.Save_Level(openedfile);
          screen.cursor:=crdefault;
          update_recent_files(openedfile);
          form10.close;
       end
       else Form1.Save1Click(Sender);
end;


procedure TForm1.SaveasMSH1Click(Sender: TObject);
begin
   if (savedialog3.Execute) then
   begin
      screen.cursor:=crhourglass;
      form1.refresh;
      tr_savemsh(l,savedialog3.FileName);
      screen.cursor:=crdefault;
   end;

end;

procedure TForm1.OpenMSH1Click(Sender: TObject);
var
r:byte;
k:integer;
n:integer;
begin
   r:=scene.render1-1;
   if opendialog3.execute then
   begin
     screen.cursor:=crhourglass;
     form1.refresh;

     tr_loadmsh(l,opendialog3.filename);
     undo.count:=-1;
     undo.index:=-1;
     undo.flag:=false;
     form1.Undo1.Enabled:=false;
     form1.redo1.enabled:=false;

     runit3.update_lara_light_and_room_flags;

     form1.scene.sort_textures;
     form1.scene.center;
     screen.cursor:=crdefault;
     viewport.getdimension(scene);
     viewport.center;
     viewport.invalidategl;
     screen.cursor:=crdefault;
    end;
end;

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
xaction:byte;
begin
    //averiguar si se hizo click con el boton izquierdo.
    if (ssleft in shift) then
    begin
        viewport.mouse_click; //hacer esto para que en scene.selection diga en que face se hizo click.
        if viewport.selection=0 then exit; //se hizo click en el vecino o en ningun lado.
        xaction:=0; //solo click = poner textura primaria or light.
        if (ssctrl in shift) then xaction:=1; //click+ctrl = get texture or light
        if (ssalt in shift) then  xaction:=2; //click+alt = rotar face.
        if (ssshift in shift) then xaction:=3;//click+shift = poner textura secundaria or light or zone
        if (ssshift in shift) and (ssctrl in shift) then xaction:=4; //click+shift+ctrl = Borrar face.

        if xaction<>1 then update_undo; //para el undo;

        case xaction of
             0:if not form3.speedbutton1.down then do_put(form1.text1) else do_put_source_light; //poner textura primaria or light  o tambien poner source lights.
             1:do_get; //obtener texture or light
             2:do_rotar; //rotar face;
             3:if not form3.speedbutton1.down then do_put(form1.text2) else do_move_source_light; //poner textura secundaria or light
             4:do_cut; //borrar un face.
        end;//fin click + accion
    end;//fin se presiono left mouse boton.

end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
    viewport.perspectiveCorrection:=qunone;
    viewport.invalidategl;
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
    viewport.perspectiveCorrection:=qufaster;
    viewport.invalidategl;

end;

procedure TForm1.RadioButton3Click(Sender: TObject);
begin
    viewport.perspectiveCorrection:=qunicer;
    viewport.invalidategl;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
    case combobox1.ItemIndex of
       0:viewport.color:=clblack;
       1:viewport.color:=clblue;
       2:viewport.color:=clgreen;
       3:viewport.color:=claqua;
       4:viewport.color:=clyellow;
       5:viewport.color:=clwhite;
    end;//
end;

procedure TForm1.Config1Click(Sender: TObject);
begin
    form7.showmodal;
    form1.Refresh;
end;

procedure TForm1.Undo1Click(Sender: TObject);
begin
    if undo.flag then update_undo;
    undo.flag:=false;
    undo.index:=undo.index-1;
    l.rooms[form1.scene.render1-1]:=undo.room[undo.index];
    scene.sort_textures(scene.render1);
    if undo.index=0 then undo1.Enabled:=false;
    redo1.enabled:=true;
    viewport.invalidategl;
end;

procedure TForm1.Redo1Click(Sender: TObject);
begin
     undo.index:=undo.index+1;
     l.rooms[form1.scene.render1-1]:=undo.room[undo.index];
     scene.sort_textures(scene.render1);
     if undo.index=undo.count then redo1.Enabled:=false;
     undo1.enabled:=true;
     viewport.invalidategl;
end;

procedure TForm1.PanelTexture21Click(Sender: TObject);
begin
     fpanel2.show;
     form1.Scene.redraw;
end;

procedure TForm1.AnimatedTextures1Click(Sender: TObject);
begin
    if fanimated.listbox1.items.count=0 then fanimated.image1.picture.Bitmap:=nil;
    fanimated.show;
    form1.Scene.redraw;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    save_states;
end;


procedure TForm1.CenterCamera1Click(Sender: TObject);
begin
    if openedfile='' then exit;
    form1.scene.center;
    form1.viewport.getdimension(form1.scene);
    form1.viewport.center;
    form1.viewport.invalidategl;

end;

procedure TForm1.HideStaticMesh1Click(Sender: TObject);
begin
    hidestaticmesh1.Checked:=not hidestaticmesh1.Checked;
    scene.hide_static_mesh:=hidestaticmesh1.Checked;
    viewport.invalidategl;
end;

procedure TForm1.HideSourceLights1Click(Sender: TObject);
begin
    hidesourcelights1.Checked:=not hidesourcelights1.Checked;
    scene.hide_source_light:=hidesourcelights1.Checked;
    viewport.invalidategl;
end;

procedure TForm1.EnablePerspectiveCorrect1Click(Sender: TObject);
begin
    scene.perspective_correct_enabled:=not scene.perspective_correct_enabled;
    form1.EnablePerspectiveCorrect1.Checked:=scene.perspective_correct_enabled;
    viewport.invalidategl;
end;

procedure TForm1.RenderLevel1Click(Sender: TObject);
begin
    if openedfile='' then exit;
    if showfromto.showmodal=mrok then
    begin
       //render severals rooms.
       viewport.Begin_draw;
       scene.Render_level(showfromto.spinedit1.value,showfromto.spinedit2.value);
       viewport.End_draw;
    end;

end;


procedure TForm1.FindReplace1Click(Sender: TObject);
var
m,k:integer;
textid1,textid2:integer;
begin
  if openedfile='' then exit;

  if MessageDlg('Find Primary Texture ID in all rooms and Replace it by Secoundary texture Id?',
  mtConfirmation, [mbYes, mbNo], 0) = mrYes then

  textid1:=form1.text1;
  textid2:=form1.text2;

  for k:=0 to l.num_rooms-1 do
  begin
      for m:=1 to l.rooms[k].quads.num_quads do
      begin
         if (l.rooms[k].quads.quad[m].texture and $0fff)=textid1
         then begin l.rooms[k].quads.quad[m].texture:=textid2;l.rooms[k].quads.quad2[m].texture:=textid2;end;
      end;//todos los quads

      for m:=1 to l.rooms[k].triangles.num_triangles do
      begin
         if (l.rooms[k].triangles.triangle[m].texture and $0fff)=textid1
         then begin l.rooms[k].triangles.triangle[m].texture:=textid2;l.rooms[k].triangles.triangle2[m].texture:=textid2;end;
      end;//todos los triangles
   end;//todos los cuartos

   //sort textures.
   form1.scene.sort_textures;
   form1.viewport.invalidategl;

end;

procedure TForm1.FixInvalidTexturesId1Click(Sender: TObject);
var
m,k:integer;
textid1,textid2:integer;
c:integer;
begin
  if openedfile='' then exit;

  textid1:=l.num_Textures-1;
  textid2:=form1.text1;
  c:=0;

  for k:=0 to l.num_rooms-1 do
  begin
      for m:=1 to l.rooms[k].quads.num_quads do
      begin
         if (l.rooms[k].quads.quad[m].texture and $7fff)>textid1
         then begin l.rooms[k].quads.quad[m].texture:=textid2;l.rooms[k].quads.quad2[m].texture:=textid2;inc(c);end;
      end;//todos los quads

      for m:=1 to l.rooms[k].triangles.num_triangles do
      begin
         if (l.rooms[k].triangles.triangle[m].texture and $7fff)>textid1
         then begin l.rooms[k].triangles.triangle[m].texture:=textid2;l.rooms[k].triangles.triangle2[m].texture:=textid2;inc(c);end;
      end;//todos los triangles
   end;//todos los cuartos

   showmessage(inttostr(c)+' invalid textures id fixed');

end;

procedure TForm1.showmesizes1Click(Sender: TObject);
begin
    form5.Memo1.Lines.clear;
    form5.Memo1.Lines.add('form1.left'+inttostr(form1.Left));
    form5.Memo1.Lines.add('form1.width'+inttostr(form1.width));
    form5.Memo1.Lines.add('form1.top'+inttostr(form1.top));
    form5.Memo1.Lines.add('form1.height'+inttostr(form1.height));
    //----------
    form5.Memo1.Lines.add('  ');
    form5.Memo1.Lines.add('form3.left'+inttostr(form3.Left));
    form5.Memo1.Lines.add('form3.width'+inttostr(form3.width));
    form5.Memo1.Lines.add('form3.top'+inttostr(form3.top));
    form5.Memo1.Lines.add('form3.height'+inttostr(form3.height));

    form5.Memo1.Lines.add('  ');
    form5.Memo1.Lines.add('form4.left'+inttostr(form4.Left));
    form5.Memo1.Lines.add('form4.width'+inttostr(form4.width));
    form5.Memo1.Lines.add('form4.top'+inttostr(form4.top));
    form5.Memo1.Lines.add('form4.height'+inttostr(form4.height));

    form5.Memo1.Lines.add('  ');
    form5.Memo1.Lines.add('form6.left'+inttostr(form6.Left));
    form5.Memo1.Lines.add('form6.width'+inttostr(form6.width));
    form5.Memo1.Lines.add('form6.top'+inttostr(form6.top));
    form5.Memo1.Lines.add('form6.height'+inttostr(form6.height));



end;

procedure TForm1.N800x600Layout1Click(Sender: TObject);
begin
    //800x600 layout
    form1.Left:=0;
    form1.width:=499;
    form1.top:=0;
    form1.height:=421;
    //-------------
    form3.Left:=0;
    form3.width:=499;
    form3.top:=421;
    form3.height:=151;
    //-------------
    form4.Left:=499;
    form4.width:=301;
    form4.top:=0;
    form4.height:=572;
    //-------------
    form6.Left:=671;
    form6.width:=127;
    form6.top:=0;
    form6.height:=202;
    //-------------
end;

procedure TForm1.N1024x768Layout1Click(Sender: TObject);
begin
    //1024x768 layout
    form1.Left:=0;
    form1.width:=705;
    form1.top:=0;
    form1.height:=589;
    //-------------
    form3.Left:=0;
    form3.width:=1018;
    form3.top:=589;
    form3.height:=153;
    //-------------
    form4.Left:=705;
    form4.width:=314;
    form4.top:=0;
    form4.height:=588;
    //-------------
    form6.Left:=880;
    form6.width:=127;
    form6.top:=5;
    form6.height:=203;
    //-------------
end;

procedure TForm1.N640x480layout1Click(Sender: TObject);
begin
    //640x480 layout
    form1.Left:=0;
    form1.width:=333;
    form1.top:=0;
    form1.height:=300;
    //-------------
    form3.Left:=0;
    form3.width:=499;
    form3.top:=297;
    form3.height:=159;
    //-------------
    form4.Left:=332;
    form4.width:=314;
    form4.top:=0;
    form4.height:=454;
    //-------------
    form6.Left:=502;
    form6.width:=127;
    form6.top:=0;
    form6.height:=203;
    //-------------

end;

procedure TForm1.FullScreen1Click(Sender: TObject);
begin
    if not form1.FullScreen1.Checked then
    begin
        form3.Close;
        form4.close;
        form1.windowstate:=wsmaximized;
        form1.FullScreen1.Checked:=true;
    end
    else
    begin
        form3.show;
        form4.show;
        form1.windowstate:=wsnormal;
        form1.FullScreen1.Checked:=false;
    end;


end;

end.
