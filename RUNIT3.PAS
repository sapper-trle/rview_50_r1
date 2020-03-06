unit runit3;

interface

uses
  geometry,Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls,tr_3d,opengl12,fexopgl,fexgraph,trunit2,Spin,
  Buttons;

type
  TForm3 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GroupBox4: TGroupBox;
    TrackBar1: TTrackBar;
    GroupBox5: TGroupBox;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    GroupBox6: TGroupBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    Button2: TButton;
    Shape1: TShape;
    ColorDialog1: TColorDialog;
    Label3: TLabel;
    CheckBox2: TCheckBox;
    SpinEdit3: TSpinEdit;
    Label4: TLabel;
    GroupBox3: TGroupBox;
    Shape2: TShape;
    Button1: TButton;
    SpinEdit4: TSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    GroupBox7: TGroupBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    Label8: TLabel;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    ListBox1: TListBox;
    SpeedButton1: TSpeedButton;
    Shape3: TShape;
    SpinEdit8: TSpinEdit;
    Label12: TLabel;
    SpinEdit9: TSpinEdit;
    SpinEdit10: TSpinEdit;
    Label13: TLabel;
    Label14: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Button7: TButton;
    Button8: TButton;
    procedure Button2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure CheckBox11Click(Sender: TObject);
    procedure CheckBox12Click(Sender: TObject);
    procedure CheckBox13Click(Sender: TObject);
    procedure CheckBox14Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure RadioButton11Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


//-------------

procedure update_lara_light_and_room_flags;

var
  Form3: TForm3;
  control_updated_disabled:boolean;


implementation
uses runit1, runit6;
{$R *.DFM}


//--------
procedure find_sector_from_coordinates(x,z:glfloat; var Column:integer; var row:integer; var sector:integer);
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
   row:=-1;column:=-1;

   room:=form1.scene.render1-1;

//---averiguar el tile sector de este face
try
  vx:=x-l.rooms[room].room_info.xpos_room;
  vz:=z-l.rooms[room].room_info.zpos_room;
  sectorx:=trunc(int(vx/1024));
  sectorz:=trunc(int(vz/1024));
  isector:=((sectorx*l.rooms[room].sectors.largo)+sectorz)+1;
except
   sectorx:=0;
   sectorz:=0;
   isector:=-1;
end;

  row:=sectorz+1;
  column:=sectorx+1;
  sector:=isector;

end; //end procedure
//---------------


procedure update_source_light_selected(i:integer);

type
wcolor = record
    r,g,b,a:byte;
end;

type
tword =
 record
      b2:byte;
      b1:byte;
 end;

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
altura,sector,room,k:integer;
x,y,z:glfloat;
row,col:integer;
r,g,b:word;
color:tcolor;
tr5factor:single;
begin
    if i>l.rooms[form1.Scene.render1-1].Source_lights.num_sources then exit;

    form1.Scene.current_source_light:=i;
    k:=form1.Scene.current_source_light;
    room:=form1.Scene.render1;
    altura:=0; //falta calcular la altura.
    //--------------------
    //if type is phd or tub get white light propertis for tr1 levels
    if l.tipo<vtr2 then
    begin
        form3.spinedit9.Value:=tword(l.rooms[room-1].source_lights.source_light[k].intensity1).b1;
        form3.spinedit10.Value:=tword(l.rooms[room-1].source_lights.source_light[k].fadeA).b1 div 4;
        x:=l.rooms[room-1].source_lights.source_light[k].x;
        y:=l.rooms[room-1].source_lights.source_light[k].y;
        z:=l.rooms[room-1].source_lights.source_light[k].z;
    end;


    //if type is tr2 then get white light properties for trii levels.
    if l.tipo=vtr2 then
    begin
        form3.spinedit9.Value:=31-tword(l.rooms[room-1].source_lights.source_light2[k].intensity1).b1;
        form3.spinedit10.Value:=tword(l.rooms[room-1].source_lights.source_light2[k].fadeA).b1 div 4;

        x:=l.rooms[room-1].source_lights.source_light2[k].x;
        y:=l.rooms[room-1].source_lights.source_light2[k].y;
        z:=l.rooms[room-1].source_lights.source_light2[k].z;
    end;

    //if type is tr3 then get colored light properties for triii levels.
    if l.tipo=vtr3 then
    begin
        form3.spinedit9.Value:=0; //rgbspot(l.rooms[room-1].source_lights.source_light2[k]).fadeA1;
        form3.spinedit10.Value:=rgbspot(l.rooms[room-1].source_lights.source_light2[k]).fadec1;
        //get rgb color.
        r:=rgbspot(l.rooms[room-1].source_lights.source_light2[k]).r;
        g:=rgbspot(l.rooms[room-1].source_lights.source_light2[k]).g;
        b:=rgbspot(l.rooms[room-1].source_lights.source_light2[k]).b;

        wcolor(color).r:=r;
        wcolor(color).g:=g;
        wcolor(color).b:=b;
        form3.shape3.brush.color:=color;
        x:=l.rooms[room-1].source_lights.source_light2[k].x;
        y:=l.rooms[room-1].source_lights.source_light2[k].y;
        z:=l.rooms[room-1].source_lights.source_light2[k].z;
    end;

    //if type is tr4 then get colored light properties for tr4 levels.
    if l.tipo=vtr4 then
    begin
        form3.spinedit9.Value:=0; //l.rooms[room-1].source_lights.source_light3[k].intensity;
        form3.spinedit10.Value:=trunc(l.rooms[room-1].source_lights.source_light3[k].light_out / 1024);
        //get rgb color.
        r:=l.rooms[room-1].source_lights.source_light3[k].r;
        g:=l.rooms[room-1].source_lights.source_light3[k].g;
        b:=l.rooms[room-1].source_lights.source_light3[k].b;

        wcolor(color).r:=r;
        wcolor(color).g:=g;
        wcolor(color).b:=b;
        form3.shape3.brush.color:=color;
        x:=l.rooms[room-1].source_lights.source_light3[k].x;
        y:=l.rooms[room-1].source_lights.source_light3[k].y;
        z:=l.rooms[room-1].source_lights.source_light3[k].z;
    end;


    //if type is tr4 then get colored light properties for tr4 levels.
    if l.tipo=vtr5 then
    begin
        form3.spinedit9.Value:=0; //trunc(l.rooms[room-1].source_lights.source_light4[k].len);
        form3.spinedit10.Value:=trunc(l.rooms[room-1].source_lights.source_light4[k].light_out / 1024);
        //get rgb color.
        tr5factor:=257.57;

        r:=trunc(l.rooms[room-1].source_lights.source_light4[k].r*tr5factor);
        g:=trunc(l.rooms[room-1].source_lights.source_light4[k].g*tr5factor);
        b:=trunc(l.rooms[room-1].source_lights.source_light4[k].b*tr5factor);

        wcolor(color).r:=r;
        wcolor(color).g:=g;
        wcolor(color).b:=b;
        form3.shape3.brush.color:=color;
        x:=l.rooms[room-1].source_lights.source_light4[k].x;
        y:=l.rooms[room-1].source_lights.source_light4[k].y;
        z:=l.rooms[room-1].source_lights.source_light4[k].z;
    end;


    find_sector_from_coordinates(x,z,col,row,sector);
    altura:=trunc(((l.rooms[room-1].sectors.sector[sector].floor_height*256)-y)/256);
    form3.spinedit8.Value:=altura;
    //------------------
end;

//-----------

procedure update_lara_light_and_room_flags;
type
trgb = record
       b,g,r,a:byte;
end;

trgb2 = record
       r,g,b:byte;
end;
var
tr4color:trgb2;
k:integer;

begin
    if openedfile='' then exit;

    control_updated_disabled:=true;
    //Lara white light from tr1-tr3
    if l.tipo<vtr4 then form3.spinedit3.value:=l.rooms[form1.scene.render1-1].lara_light else
                        form3.spinedit3.value:=31;

    //colored lara light for tr4/trc.
   if l.tipo=vtr4 then
   begin
       move(l.rooms[form1.scene.render1-1].d0,tr4color,3);
       form3.spinedit1.value:=tr4color.b;
       form3.spinedit2.value:=tr4color.g;
       form3.spinedit4.value:=tr4color.r;
    end;

   if l.tipo=vtr5 then
   begin
     form3.spinedit1.value:=trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).r;
     form3.spinedit2.value:=trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).g;
     form3.spinedit4.value:=trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).b;
   end;

   //room flags.
   if (l.rooms[form1.scene.render1-1].water and 1)=1 then form3.CheckBox11.Checked:=true else form3.CheckBox11.Checked:=false;
   if (l.rooms[form1.scene.render1-1].water and 8)=8 then form3.CheckBox12.Checked:=true else form3.CheckBox12.Checked:=false;
   if (l.rooms[form1.scene.render1-1].water and 32)=32 then form3.CheckBox13.Checked:=true else form3.CheckBox13.Checked:=false;
   if (l.rooms[form1.scene.render1-1].water and 128)=128 then form3.CheckBox14.Checked:=true else form3.CheckBox14.Checked:=false;

   //trc weather.
   case l.tr5_weather of
      0:form3.RadioButton9.Checked:=true;
      1:form3.RadioButton10.Checked:=true;
      2:form3.RadioButton11.Checked:=true;
   end;

   //update the source lights list.
   form3.ListBox1.items.Clear;
   for k:=1 to l.rooms[form1.scene.render1-1].Source_lights.num_sources do
   begin
      form3.ListBox1.Items.Add('Source Light#'+inttostr(k));
   end;
      if form3.ListBox1.count<>0 then form3.ListBox1.ItemIndex:=0;
      update_source_light_selected(1);
      form1.Scene.current_source_light:=1;
   control_updated_disabled:=false;
end;


//-------------



procedure replace_Spot_Light(var L:ttrlevel; room,k,altura,color,distance:integer);
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
light:byte;
row,col:integer;
r:byte;
rr:word;
xr:word;
xxr:word;
k1,k2:integer;
begin

  light :=color;

  if light>31 then light:=31;
  Light:=31-Light;


  x:=l.rooms[room-1].source_lights.source_light2[k].x;
  z:=l.rooms[room-1].source_lights.source_light2[k].z;
  //averiguar el sector.
  find_sector_from_coordinates(x,z,col,row,sector);
  y:=(l.rooms[room-1].sectors.sector[sector].floor_height-altura)*256;

  //si tr1/tub
  if l.tipo<vtr2 then
    begin
        l.rooms[room-1].source_lights.source_light[k].y:=y;

        tword(l.rooms[room-1].source_lights.source_light[k].intensity1).b1:=light;
        tword(l.rooms[room-1].source_lights.source_light[k].intensity1).b2:=0;

        tword(l.rooms[room-1].source_lights.source_light[k].fadeA).b1:=distance*4;
        tword(l.rooms[room-1].source_lights.source_light[k].fadeA).b2:=0;

        l.rooms[room-1].source_lights.source_light[k].fadeb:=0;
    end;

  //si Tomb Raider 2
  if l.tipo=vtr2 then
    begin
        l.rooms[room-1].source_lights.source_light2[k].y:=y;

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


procedure Replace_RGB_Light(var L:ttrlevel; room,k,altura, ir,ig,ib,intensity,distance:integer);
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
k1,k2:integer;
r,g,b:byte;
rr,gg,bb:word;
xr,xg,xb:word;
xxr,xxg,xxb:word;
roomx,roomz:cardinal;
nomesh:integer;
fadea,fadec:byte;
modo:byte;
row,col:integer;
tr5factor:single;
begin
  r :=ir;
  g :=ig;
  b :=ib;
  fadea :=31; //intensity;
  fadec :=distance;

  x:=l.rooms[room-1].source_lights.source_light2[k].x;
  z:=l.rooms[room-1].source_lights.source_light2[k].z;
  //averiguar el sector.
  find_sector_from_coordinates(x,z,col,row,sector);
  y:=(l.rooms[room-1].sectors.sector[sector].floor_height-altura)*256;

  //si Tomb Raider 3
  if l.tipo=vtr3 then
    begin
        l.rooms[room-1].source_lights.source_light2[k].y:=y;

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
    end;

  //si Tomb Raider 4
  if l.tipo=vtr4 then
    begin
        l.rooms[room-1].source_lights.source_light3[k].y:=y;

        l.rooms[room-1].source_lights.source_light3[k].r:=r;
        l.rooms[room-1].source_lights.source_light3[k].g:=g;
        l.rooms[room-1].source_lights.source_light3[k].b:=b;

        l.rooms[room-1].source_lights.source_light3[k].light_type:=1;

        l.rooms[room-1].source_lights.source_light3[k].intensity:=15; //intensity 0-31
        l.rooms[room-1].source_lights.source_light3[k].light_out:=distance*1024; // coverage.
        l.rooms[room-1].source_lights.source_light3[k].light_in:=(distance*1024)/2; // hot spot, how much sector recive full lighting.
   end; //end if tr4 level.

  //si Tomb Raider 5
  if l.tipo=vtr5 then
    begin
        l.rooms[room-1].source_lights.source_light4[k].y:=y;
        //same in different format
        l.rooms[room-1].source_lights.source_light4[k].y2:=y;

        tr5factor:=257.57;

        l.rooms[room-1].source_lights.source_light4[k].r:=r/tr5factor;
        l.rooms[room-1].source_lights.source_light4[k].g:=g/tr5factor;
        l.rooms[room-1].source_lights.source_light4[k].b:=b/tr5factor;

        l.rooms[room-1].source_lights.source_light4[k].light_type:=1;

        l.rooms[room-1].source_lights.source_light4[k].light_in:=(distance*1024)/2; // hot spot, how much sector recive full lighting.
        l.rooms[room-1].source_lights.source_light4[k].light_out:=distance*1024; // coverage.

        l.rooms[room-1].source_lights.source_light4[k].len:=0;
   end; //end if tr4 level.




end;
//----------------

procedure apply_source_light(var l:ttrlevel; room,i:integer);

type
tword =
 record
      b2:byte;
      b1:byte;
 end;
var
col,fil,altura:integer;
x,z:cardinal;
y:integer;
sector:integer;
k:integer;
light:byte;
distance:byte;
r:byte;
rr:word;
xr:word;
xxr:word;
k1,k2:integer;
roomx,roomz:cardinal;

begin

//Light the vertex too!!

if l.tipo<vtr2 then
begin
   light:=tword(l.rooms[room-1].source_lights.source_light[i].intensity1).b1;
   distance:=tword(l.rooms[room-1].source_lights.source_light[i].fadeA).b1 div 4;
   x:=l.rooms[room-1].source_lights.source_light[i].x;
   y:=l.rooms[room-1].source_lights.source_light[i].y;
   z:=l.rooms[room-1].source_lights.source_light[i].z;
end
else
begin
   light:=tword(l.rooms[room-1].source_lights.source_light2[i].intensity1).b1;
   distance:=tword(l.rooms[room-1].source_lights.source_light2[i].fadeA).b1 div 4;
   x:=l.rooms[room-1].source_lights.source_light2[i].x;
   y:=l.rooms[room-1].source_lights.source_light2[i].y;
   z:=l.rooms[room-1].source_lights.source_light2[i].z;
end;

if distance<2 then begin showmessage('Fall off has to be at least 2');exit;end;

xr:=31-light;
xxr:=xr;

roomx:=l.rooms[room-1].room_info.xpos_room;
roomz:=l.rooms[room-1].room_info.zpos_room;


for k2:=1 to distance do //altura
begin

for k:=1 to l.rooms[room-1].vertices.num_vertices do
begin
    rr:=xr;

    for k1:=1 to distance-1 do
    begin

        //front?
        if ((l.rooms[room-1].vertices.vertice[k].x+roomx)>=(x-(1024*k1))) and ((l.rooms[room-1].vertices.vertice[k].x+roomx)<=(x+(1024*k1))) and
           ((l.rooms[room-1].vertices.vertice[k].z+roomz)>=(z-(1024*k1))) and ((l.rooms[room-1].vertices.vertice[k].z+roomz)<=z-((k1-1)*1024)) and
           ((l.rooms[room-1].vertices.vertice[k].y)<(y+1024)) and ((l.rooms[room-1].vertices.vertice[k].y)>=y) then
        begin
            l.rooms[room-1].vertices.vertice[k].light0:=0; //reset color
            l.rooms[room-1].vertices.vertice[k].light:=rr;

            l.rooms[room-1].vertices.vertice2[k].light0:=0; //reset color
            l.rooms[room-1].vertices.vertice2[k].light:=rr;

        end; //end vertex found.

        //back?
        if ((l.rooms[room-1].vertices.vertice[k].x+roomx)>=(x-(1024*k1))) and ((l.rooms[room-1].vertices.vertice[k].x+roomx)<=(x+(1024*k1))) and
           ((l.rooms[room-1].vertices.vertice[k].z+roomz)<=(z+(1024*k1))) and ((l.rooms[room-1].vertices.vertice[k].z+roomz)>=z+((k1-1)*1024)) and
           ((l.rooms[room-1].vertices.vertice[k].y)<(y+1024)) and ((l.rooms[room-1].vertices.vertice[k].y)>=y) then
        begin
            l.rooms[room-1].vertices.vertice[k].light0:=0; //reset color
            l.rooms[room-1].vertices.vertice[k].light:=rr;

            l.rooms[room-1].vertices.vertice2[k].light0:=0; //reset color
            l.rooms[room-1].vertices.vertice2[k].light:=rr;

        end; //end vertex found.


        //left?
        if ((l.rooms[room-1].vertices.vertice[k].x+roomx)=( x-(1024*(k1-1))-512)) and
           ((l.rooms[room-1].vertices.vertice[k].z+roomz)>=(z-(1024*k1))) and ((l.rooms[room-1].vertices.vertice[k].z+roomz)<=z+(k1*1024)) and
           ((l.rooms[room-1].vertices.vertice[k].y)<(y+1024)) and ((l.rooms[room-1].vertices.vertice[k].y)>=y) then
        begin
            l.rooms[room-1].vertices.vertice[k].light0:=0; //reset color
            l.rooms[room-1].vertices.vertice[k].light:=rr;

            l.rooms[room-1].vertices.vertice2[k].light0:=0; //reset color
            l.rooms[room-1].vertices.vertice2[k].light:=rr;

        end; //end vertex found.


        //right?
        if ((l.rooms[room-1].vertices.vertice[k].x+roomx)=( x+(1024*(k1-1))+512)) and
           ((l.rooms[room-1].vertices.vertice[k].z+roomz)>=(z-(1024*k1))) and ((l.rooms[room-1].vertices.vertice[k].z+roomz)<=z+(k1*1024)) and
           ((l.rooms[room-1].vertices.vertice[k].y)<(y+1024)) and ((l.rooms[room-1].vertices.vertice[k].y)>=y) then
        begin
            l.rooms[room-1].vertices.vertice[k].light0:=0; //reset color
            l.rooms[room-1].vertices.vertice[k].light:=rr;

            l.rooms[room-1].vertices.vertice2[k].light0:=0; //reset color
            l.rooms[room-1].vertices.vertice2[k].light:=rr;

        end; //end vertex found.


      if rr<>0 then rr:=rr-(xr div distance);

     end; //end fadec
end; //All vertices
y:=y+1024;
if xr<>0 then xr:=xr-(xxr div distance);
end; //end altura;


end;
//----------------------------------

procedure apply_rgb_light(var l:ttrlevel; room,i:integer);
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
x,z:glfloat;
y:glfloat;
k,k1,k2:integer;
r,g,b:byte;
rr,gg,bb:word;
xr,xg,xb:word;
xxr,xxg,xxb:word;
roomx,roomz:cardinal;
fadea,fadec:byte;
tr5factor:single;
begin

//Light the vertex too!!

  //si tr3 level
  if l.tipo=vtr3 then
  begin
    x:=l.rooms[room-1].source_lights.source_light2[i].x;
    y:=l.rooms[room-1].source_lights.source_light2[i].y;
    z:=l.rooms[room-1].source_lights.source_light2[i].z;

    r:=rgbspot(l.rooms[room-1].source_lights.source_light2[i]).r;
    g:=rgbspot(l.rooms[room-1].source_lights.source_light2[i]).g;
    b:=rgbspot(l.rooms[room-1].source_lights.source_light2[i]).b;

    fadea:=rgbspot(l.rooms[room-1].source_lights.source_light2[i]).fadeA1;
    fadec:=rgbspot(l.rooms[room-1].source_lights.source_light2[i]).fadec1;
  end;

  //si tr4 level
  if l.tipo=vtr4 then
  begin
    x:=l.rooms[room-1].source_lights.source_light3[i].x;
    y:=l.rooms[room-1].source_lights.source_light3[i].y;
    z:=l.rooms[room-1].source_lights.source_light3[i].z;

    r:=l.rooms[room-1].source_lights.source_light3[i].r;
    g:=l.rooms[room-1].source_lights.source_light3[i].g;
    b:=l.rooms[room-1].source_lights.source_light3[i].b;

    fadea:=l.rooms[room-1].source_lights.source_light3[i].intensity;
    fadec:=trunc(l.rooms[room-1].source_lights.source_light3[i].light_out/1024);
  end;

  //si trc level
  if l.tipo=vtr5 then
  begin
    x:=l.rooms[room-1].source_lights.source_light4[i].x;
    y:=l.rooms[room-1].source_lights.source_light4[i].y;
    z:=l.rooms[room-1].source_lights.source_light4[i].z;

    tr5factor:=257.57;
    r:=trunc(l.rooms[room-1].source_lights.source_light4[i].r*tr5factor);
    g:=trunc(l.rooms[room-1].source_lights.source_light4[i].g*tr5factor);
    b:=trunc(l.rooms[room-1].source_lights.source_light4[i].b*tr5factor);

    fadec:=trunc(l.rooms[room-1].source_lights.source_light4[i].light_out/1024);
  end;


if fadec<2 then begin showmessage('Fall off has to be at least 2');exit;end;

xr:=trunc(32*(r/256));
xg:=trunc(32*(g/256));
xb:=trunc(32*(b/256));

xxr:=xr;
xxg:=xg;
xxb:=xb;


roomx:=l.rooms[room-1].room_info.xpos_room;
roomz:=l.rooms[room-1].room_info.zpos_room;


for k2:=1 to fadec do //altura
begin

for k:=1 to l.rooms[room-1].vertices.num_vertices do
begin
    rr:=xr;
    gg:=xg;
    bb:=xb;

    for k1:=1 to fadec-1 do
    begin

        //front?
        if ((l.rooms[room-1].vertices.vertice2[k].x+roomx)>=(x-(1024*k1))) and ((l.rooms[room-1].vertices.vertice2[k].x+roomx)<=(x+(1024*k1))) and
           ((l.rooms[room-1].vertices.vertice2[k].z+roomz)>=(z-(1024*k1))) and ((l.rooms[room-1].vertices.vertice2[k].z+roomz)<=z-((k1-1)*1024)) and
           ((l.rooms[room-1].vertices.vertice2[k].y)<(y+1024)) and ((l.rooms[room-1].vertices.vertice2[k].y)>=y) then
        begin
            l.rooms[room-1].vertices.vertice2[k].light2:=0; //reset color
            l.rooms[room-1].vertices.vertice2[k].light2:= (rr shl 10) or (gg shl 5) or (bb);
            //tr5 rgb values
            l.rooms[room-1].vertices.vertice3[k].r:=rr*8;
            l.rooms[room-1].vertices.vertice3[k].g:=gg*8;
            l.rooms[room-1].vertices.vertice3[k].b:=bb*8;
        end; //end vertex found.

        //back?
        if ((l.rooms[room-1].vertices.vertice2[k].x+roomx)>=(x-(1024*k1))) and ((l.rooms[room-1].vertices.vertice2[k].x+roomx)<=(x+(1024*k1))) and
           ((l.rooms[room-1].vertices.vertice2[k].z+roomz)<=(z+(1024*k1))) and ((l.rooms[room-1].vertices.vertice2[k].z+roomz)>=z+((k1-1)*1024)) and
           ((l.rooms[room-1].vertices.vertice2[k].y)<(y+1024)) and ((l.rooms[room-1].vertices.vertice2[k].y)>=y) then
        begin
            l.rooms[room-1].vertices.vertice2[k].light2:=0; //reset color
            l.rooms[room-1].vertices.vertice2[k].light2:= (rr shl 10) or (gg shl 5) or (bb);
            //tr5 rgb values
            l.rooms[room-1].vertices.vertice3[k].r:=rr*8;
            l.rooms[room-1].vertices.vertice3[k].g:=gg*8;
            l.rooms[room-1].vertices.vertice3[k].b:=bb*8;

        end; //end vertex found.


        //left?
        if ((l.rooms[room-1].vertices.vertice2[k].x+roomx)=( x-(1024*(k1-1))-512)) and
           ((l.rooms[room-1].vertices.vertice2[k].z+roomz)>=(z-(1024*k1))) and ((l.rooms[room-1].vertices.vertice2[k].z+roomz)<=z+(k1*1024)) and
           ((l.rooms[room-1].vertices.vertice2[k].y)<(y+1024)) and ((l.rooms[room-1].vertices.vertice2[k].y)>=y) then
        begin
            l.rooms[room-1].vertices.vertice2[k].light2:=0; //reset color
            l.rooms[room-1].vertices.vertice2[k].light2:= (rr shl 10) or (gg shl 5) or (bb);
            //tr5 rgb values
            l.rooms[room-1].vertices.vertice3[k].r:=rr*8;
            l.rooms[room-1].vertices.vertice3[k].g:=gg*8;
            l.rooms[room-1].vertices.vertice3[k].b:=bb*8;

        end; //end vertex found.


        //right?
        if ((l.rooms[room-1].vertices.vertice2[k].x+roomx)=( x+(1024*(k1-1))+512)) and
           ((l.rooms[room-1].vertices.vertice2[k].z+roomz)>=(z-(1024*k1))) and ((l.rooms[room-1].vertices.vertice2[k].z+roomz)<=z+(k1*1024)) and
           ((l.rooms[room-1].vertices.vertice2[k].y)<(y+1024)) and ((l.rooms[room-1].vertices.vertice2[k].y)>=y) then
        begin
            l.rooms[room-1].vertices.vertice2[k].light2:=0; //reset color
            l.rooms[room-1].vertices.vertice2[k].light2:= (rr shl 10) or (gg shl 5) or (bb);
            //tr5 rgb values
            l.rooms[room-1].vertices.vertice3[k].r:=rr*8;
            l.rooms[room-1].vertices.vertice3[k].g:=gg*8;
            l.rooms[room-1].vertices.vertice3[k].b:=bb*8;

        end; //end vertex found.


      if rr<>0 then rr:=rr-(xr div fadec);
      if gg<>0 then gg:=gg-(xg div fadec);
      if bb<>0 then bb:=bb-(xb div fadec);

     end; //end fadec
end; //All vertices
y:=y+1024;
if xr<>0 then xr:=xr-(xxr div fadec);
if xg<>0 then xg:=xg-(xxg div fadec);
if xb<>0 then xb:=xb-(xxb div fadec);

end; //end altura;

end;

//------------

procedure TForm3.Button2Click(Sender: TObject);
begin
    colordialog1.execute;
    shape1.brush.color:=colordialog1.color;
end;

procedure TForm3.RadioButton3Click(Sender: TObject);
begin
  if radiobutton3.Checked then
  begin
      form1.scene.render_tipo:=rtWireframe;
      form1.viewport.invalidategl;
   end;

end;

procedure TForm3.RadioButton4Click(Sender: TObject);
begin
  if radiobutton4.Checked then
  begin
      form1.scene.render_tipo:=rtsolid;
      form1.viewport.invalidategl;
   end;

end;

procedure TForm3.RadioButton5Click(Sender: TObject);
begin
  if radiobutton5.Checked then
  begin
      form1.scene.render_tipo:=rttextured;
      form1.viewport.invalidategl;
   end;

end;

procedure TForm3.RadioButton6Click(Sender: TObject);
begin
  if radiobutton6.Checked then
  begin
      form6.show;
      form1.scene.render_tipo:=rtshaded;
      form1.viewport.invalidategl;
   end
   else form6.close;

end;

procedure TForm3.ComboBox1Change(Sender: TObject);
begin
 if radiobutton1.checked then
 begin
     form1.scene.render1:=combobox1.itemindex+1;
     form1.scene.render2:=combobox2.itemindex+1;
     undo.count:=-1;
     undo.index:=-1;
     undo.flag:=false;
     form1.Undo1.Enabled:=false;
     form1.redo1.enabled:=false;
     //lara's ligh updated
     update_lara_light_and_room_flags;

 end
 else
 begin
     form1.scene.render1:=combobox2.itemindex+1;
     form1.scene.render2:=combobox1.itemindex+1;
 end;
 form1.scene.sort_textures;

 if (form1.scene.current_only) and (radiobutton1.checked) then
 begin
    form1.scene.center;
    form1.viewport.getdimension(form1.scene);
    form1.viewport.center;
 end;
 form1.viewport.invalidategl;

end;

procedure TForm3.CheckBox1Click(Sender: TObject);
begin
     if checkbox1.checked then form1.scene.light_enabled:=true else form1.scene.light_enabled:=false;
     form1.viewport.invalidategl;
end;

procedure TForm3.CheckBox2Click(Sender: TObject);
begin
  if checkbox2.checked then form1.scene.current_only:=true else form1.scene.current_only:=false;
  form1.viewport.invalidategl;
end;

procedure TForm3.Image1Click(Sender: TObject);
begin
{   image2.picture.bitmap:=image1.picture.bitmap;
   form1.text2:=form1.text1;
   form3.spinedit2.value:=form1.text2;
}   
end;

procedure TForm3.Image2Click(Sender: TObject);
begin
{   image1.picture.bitmap:=image2.picture.bitmap;
   form1.text1:=form1.text2;
   form3.spinedit1.value:=form1.text1;
   }
end;

procedure TForm3.RadioButton1Click(Sender: TObject);
begin
    if openedfile='' then exit;
    form1.scene.render1:=combobox1.ItemIndex+1;
    form1.scene.render2:=combobox2.ItemIndex+1;
    radiobutton1.caption:='Current';
    radiobutton2.caption:='';
     undo.count:=-1;
     undo.index:=-1;
     undo.flag:=false;
     form1.Undo1.Enabled:=false;
     form1.redo1.enabled:=false;

    //lara's ligh updated
    update_lara_light_and_room_flags;
//  form1.scene.center;
    form1.scene.sort_textures;
    form1.viewport.invalidategl;
end;

procedure TForm3.RadioButton2Click(Sender: TObject);
begin
    if openedfile='' then exit;
    form1.scene.render2:=combobox1.ItemIndex+1;
    form1.scene.render1:=combobox2.ItemIndex+1;
    radiobutton2.caption:='Current';
    radiobutton1.caption:='';
    undo.count:=-1;
    undo.index:=-1;
    undo.flag:=false;
     form1.Undo1.Enabled:=false;
     form1.redo1.enabled:=false;

   //lara's ligh updated
   update_lara_light_and_room_flags;


//  form1.scene.center;
    form1.scene.sort_textures;
    form1.viewport.invalidategl;
end;

procedure TForm3.ComboBox2Change(Sender: TObject);
begin
 if radiobutton2.checked then
 begin
     undo.count:=-1;
     undo.index:=-1;
     undo.flag:=false;
     form1.Undo1.Enabled:=false;
     form1.redo1.enabled:=false;

     form1.scene.render1:=combobox2.itemindex+1;
     form1.scene.render2:=combobox1.itemindex+1;

     //lara's ligh updated
     update_lara_light_and_room_flags;

 end
 else
 begin
     form1.scene.render1:=combobox1.itemindex+1;
     form1.scene.render2:=combobox2.itemindex+1;
 end;
 form1.scene.sort_textures;
 if (form1.scene.current_only) and (radiobutton2.checked) then
 begin
    form1.scene.center;
    form1.viewport.getdimension(form1.scene);
    form1.viewport.center;
 end;
 form1.viewport.invalidategl;
end;

procedure TForm3.Button1Click(Sender: TObject);
type
wcolor = record
    r,g,b,a:byte;
end;
var
color:longint;
begin
    colordialog1.execute;
    shape2.brush.color:=colordialog1.color;
    color:=shape2.brush.color;
    spinedit1.Value:=wcolor(color).r;
    spinedit2.Value:=wcolor(color).g;
    spinedit4.Value:=wcolor(color).b;
end;

procedure TForm3.TrackBar1Change(Sender: TObject);
begin
     label3.caption:=IntToStr(trackbar1.position);
end;

procedure TForm3.SpinEdit1Change(Sender: TObject);
type
trgb = record
       b,g,r,a:byte;
end;

trgb2 = record
       r,g,b:byte;
end;

wcolor = record
    r,g,b,a:byte;
end;


var
r,g,b:word;
tr4color:trgb2;
color:longint;
begin

   r:=spinedit1.value;
   g:=spinedit2.value;
   b:=spinedit4.value;
   wcolor(color).r:=r;
   wcolor(color).g:=g;
   wcolor(color).b:=b;
   shape2.brush.color:=color;

   if openedfile='' then exit;
   if control_updated_disabled then exit;

   if l.tipo=vtr4 then
   begin
       tr4color.b:=r;tr4color.g:=g;tr4color.r:=b;
       move(tr4color,l.rooms[form1.scene.render1-1].d0,3);
    end;

   if l.tipo=vtr5 then
   begin
     trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).r:=r;
     trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).g:=g;
     trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).b:=b;
     trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).a:=0;
   end;
end;

procedure TForm3.SpinEdit3Change(Sender: TObject);

type
trgb = record
       b,g,r,a:byte;
end;

trgb2 = record
       r,g,b:byte;
end;

var
color:word;
tr4color:trgb2;
begin
   if openedfile='' then exit;
   if control_updated_disabled then exit;
   l.rooms[form1.scene.render1-1].lara_light:=spinedit3.value;
   //fix lara light in tr4 levels
   if l.tipo=vtr4 then
   begin
       color:=(31-spinedit3.value)*8;
       tr4color.b:=color;tr4color.g:=color;tr4color.r:=color;
       if ((l.rooms[form1.scene.render1-1].water and 1)=1) then tr4color.b:=0; //if water room put Lara with cyan color.
       move(tr4color,l.rooms[form1.scene.render1-1].d0,3);
    end;

   if l.tipo=vtr5 then
   begin
     trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).r:=(31-l.rooms[form1.scene.render1-1].lara_light)*8;
     trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).g:=(31-l.rooms[form1.scene.render1-1].lara_light)*8;
     trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).b:=(31-l.rooms[form1.scene.render1-1].lara_light)*8;
     trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).a:=0;
     if (l.rooms[form1.scene.render1-1].water and 1)=1 then trgb(l.rooms[form1.scene.render1-1].tr5_unknowns.room_color).r:=0;
   end;


end;

procedure TForm3.Button7Click(Sender: TObject);
begin
    if openedfile='' then exit;
    form1.scene.center;
    form1.viewport.getdimension(form1.scene);
    form1.viewport.center;
    form1.viewport.invalidategl;
end;

procedure TForm3.CheckBox11Click(Sender: TObject);
begin
    //enable/disable water
    if checkbox11.Checked then l.rooms[form1.Scene.render1-1].water:=l.rooms[form1.Scene.render1-1].water or 1 else
                               l.rooms[form1.Scene.render1-1].water:=l.rooms[form1.Scene.render1-1].water and 254;
end;

procedure TForm3.CheckBox12Click(Sender: TObject);
begin
    //enable/disable sky
    if checkbox12.Checked then l.rooms[form1.Scene.render1-1].water:=l.rooms[form1.Scene.render1-1].water or 8 else
                               l.rooms[form1.Scene.render1-1].water:=l.rooms[form1.Scene.render1-1].water and 247;

end;

procedure TForm3.CheckBox13Click(Sender: TObject);
begin
    //enable/disable outdoor
    if checkbox13.Checked then l.rooms[form1.Scene.render1-1].water:=l.rooms[form1.Scene.render1-1].water or 32 else
                               l.rooms[form1.Scene.render1-1].water:=l.rooms[form1.Scene.render1-1].water and 223;
end;

procedure TForm3.CheckBox14Click(Sender: TObject);
begin
    //enable/disable quicksand
    if checkbox14.Checked then l.rooms[form1.Scene.render1-1].water:=l.rooms[form1.Scene.render1-1].water or 128 else
                               l.rooms[form1.Scene.render1-1].water:=l.rooms[form1.Scene.render1-1].water and 127;
end;

procedure TForm3.RadioButton9Click(Sender: TObject);
begin
   if radiobutton9.Checked then l.tr5_weather:=0;
end;

procedure TForm3.RadioButton10Click(Sender: TObject);
begin
   if radiobutton10.Checked then l.tr5_weather:=1;
end;

procedure TForm3.RadioButton11Click(Sender: TObject);
begin
   if radiobutton11.Checked then l.tr5_weather:=2;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
   control_updated_disabled:=false;
end;

procedure TForm3.Button8Click(Sender: TObject);
begin
    colordialog1.execute;
    shape3.brush.color:=colordialog1.color;
end;

procedure TForm3.SpeedButton1Click(Sender: TObject);
begin
    if speedbutton1.Down then form1.scene.source_light_enabled:=true else form1.scene.source_light_enabled:=false;
    form1.viewport.invalidategl;
end;

procedure TForm3.ListBox1Click(Sender: TObject);
var
k:integer;
begin
    if listbox1.Count=0 then exit;
    k:=listbox1.itemindex+1;
    update_source_light_selected(k);
    form1.viewport.invalidategl;
end;

procedure TForm3.Button3Click(Sender: TObject);
type
wcolor = record
    r,g,b,a:byte;
end;

var
room,altura,intensity,distance:integer;
r,g,b:integer;
color:tcolor;
k:integer;

begin
    if listbox1.Count=0 then exit;

    altura:=form3.spinedit8.value;
    intensity:=form3.spinedit9.value;
    distance:=form3.spinedit10.value;
    room:=form1.Scene.render1;
    color:=form3.shape3.brush.color;
    r:=wcolor(color).r;
    g:=wcolor(color).g;
    b:=wcolor(color).b;
    k:=listbox1.ItemIndex+1;

    if l.tipo<vtr3 then replace_spot_light(l,room,k,altura,intensity,distance);
    if l.tipo>=vtr3 then replace_rgb_light(l,room,k,altura,r,g,b,intensity,distance);

    form1.viewport.invalidategl;
end;

procedure TForm3.Button4Click(Sender: TObject);
begin
   if listbox1.count=0 then exit;
   //delete last source light
   dec(l.rooms[form1.scene.render1-1].Source_lights.num_sources);
   listbox1.Items.Delete(listbox1.Count-1);
   form1.Scene.current_source_light:=listbox1.ItemIndex+1;

   form1.viewport.invalidategl;

end;

procedure TForm3.Button5Click(Sender: TObject);
var
room,i:integer;
begin
     if listbox1.Count=0 then exit;
     //for the undo.
     update_undo;
     room:=form1.scene.render1;
     i:=form1.Scene.current_source_light;

     if l.tipo<vtr3 then apply_source_light(l,room,i);
     if l.tipo>=vtr3 then apply_rgb_light(l,room,i);

     form1.viewport.invalidategl;

end;

end.
