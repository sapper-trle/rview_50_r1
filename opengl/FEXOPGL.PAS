unit fexopgl;

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
// (away from the screen)  -Z<-------0--------->Z+ (close to the screen)
//
//
{ ****** Uso de esta unidad ******

 1.- Definir una variable Tglviewport. ( viewport : tglviewport;)
 2.- Definir una variable Tglcamera    (camera1   : Tglcamera;)
 3.- Poner un panel en la forma (form1.Panel1);
 4.- crear el viewport especificando la forma que lo contiene. (viewport:=TGlviewport.create(form1);)
 5.- crear la camera. ( camera:=Tglcamera.create;)
 6.- Asignar el panel al property "control" del viewport. (viewport.control:=form1.panel1;)
 7.- Asignar la camera al property "camera" del viewport. ( viewport.camera:=camera;)
 8.- Asignar el procedimiento que dibuja las primitivas al property "Dodraw" del viewport. (viewport.dodraw:=mydraw;);
 9.- Poner el minimo y maximo cordenadas del dibujo en el viewport.
 10.- Ejecutar el procedimiento center del viewport para centrar la escena.
 11.- Ejecutar el procedimiento Redraw el el viewport para dibujar la escena.
 12.- Si dinamicamente se modifica la escena usar el procedimiento invalidateGL para actualizar la escena.
 13. -El color del fondo del viewport se cambia con el property "color"
     -La camera se mueve cambiano el "x", "y", "z" de la camera.
     -La camera se Rota cambiando el "rx", "ry", "rz" de la camera.

 14. - Para definir una textura usar el procedimiento global:
       Opgl_Define_texture(texture_index:TGluint; //numero de textura a definir.
                              width,height:word; //ancho y alto del bitmap,
                              pixelformat:word; //gl_rgb(24bits), gl_bgr(24 bits), gl_rgba(32 bits), gl_rgb16 (16 bits)
                              data:pointer); //pointer al bitmap surface
}



interface

Uses Geometry,Windows, extctrls,Messages, SysUtils, Classes,forms,graphics,controls,opengl12,fexgraph,math;

type
 tglVertex = record
            x,y,z:real;
end;


type
      twcolor = record
      r,g,b,a:byte;
end;


type
  tcullface = (cfback,cffront,cfnone);
  Tpolygonmode = (pmfill,pmline,pmpoint);
  tprojectionType = (ptorthographic,ptperspective);
  tshademodel = (smflat,smsmooth);
  TperspectiveCorrection = (quNone, qufaster, qunicer);
  trender_tipo = (rtwireframe, rthiden, rtshaded, rtsolid, rttextured);
  tautomatic_texture = (atenabled,atdisabled);
  tnormal = (tnfront,tnback,tnleft,tnright,tntop,tnbottom);

//***** CAMERA CLASE **********
type
  TGLCamera=class(Tobject)
  PRIVATE
    px,py,pz:tglfloat; //posicion
    prx,pry,prz:tglfloat; //rotacion
    PviewAngle,PviewFar,PviewNear:tglfloat;
    //--funciones que leen los privados
    function Getx:tglfloat;
    function Gety:tglfloat;
    function Getz:tglfloat;
    function Getrx:tglfloat;
    function Getry:tglfloat;
    function Getrz:tglfloat;
    function GetViewangle:tglfloat;
    function GetViewfar:tglfloat;
    function GetViewnear:tglfloat;
    //procedures que escriben los privados.
    procedure Setx(vx:tglfloat);
    procedure Sety(vy:tglfloat);
    procedure Setz(vz:tglfloat);
    procedure Setrx(vrx:tglfloat);
    procedure Setry(vry:tglfloat);
    procedure Setrz(vrz:tglfloat);
    procedure SetViewangle(vViewAngle:tglfloat);
    procedure SetViewfar(vViewFar:tglfloat);
    procedure SetViewnear(vViewNear:tglfloat);
  PUBLIC
    Property X:tglfloat read GetX write SetX;
    Property Y:tglfloat read GetY write SetY;
    Property Z:tglfloat read GetZ write SetZ;

    Property RX:tglfloat read GetRX write SetRX;
    Property RY:tglfloat read GetRY write SetRY;
    Property RZ:tglfloat read GetRZ write SetRZ;

    Property ViewAngle:tglfloat read GetViewAngle write SetViewangle;
    Property ViewFar:tglfloat read GetViewfar write SetViewfar;
    Property ViewNear:tglfloat read GetViewnear write SetViewnear;

 //-----------------
    Constructor create;
    procedure redraw;
    procedure reset;
  end; {TGLCamera}
//--------------------

type
  tglfigure = class;
  TGLViewport=class(Tobject)
  PRIVATE
    powner:tform;
    Pcontrol:tpanel;
    pDC:HDC;
    pRC: HGLRC;
    Active:boolean;
    pCullface:tcullface;
    pPolygonMode:tpolygonmode;
    pProjectionType:TprojectionType;
    pShadeModel:TShadeModel;
    pPerspectiveCorrection:TperspectiveCorrection;
    ptexturing:boolean;
    plist:integer;
    displaylistID:integer;
    pcolor:tcolor;
    pcamera:TglCamera;
    //----esto es para automaticamente usar el mouse para interactuar el contenido del viewport.
    mx,my  :integer; // mouse x,y
    cx,cy  :integer;// camera moved
    zx,zy  :integer; //zoom in/out
    drag,drag2   :boolean; //si se esta presionando un mouse buton
    lrx,lry,lrz:real; //last x,y,z rotado.
    lcx,lcy,lcz:real; //last x,y,z moved.
    lzx,lzy,lzz:real; //last x,y,z zoomed
    //-----
    rc_already_selected:boolean;

    //paint structure
    ps : TPaintStruct;
    //--------------para remplazar el onpaint
    OldOnPaint:tnotifyevent;
    pOnPaint:tnotifyevent;
    //------------------para remplazar el onresize
    OldOnResize:tnotifyevent;
    pOnResize  :tnotifyevent;
    //------------------para remplazar el onclick
    OldOnClick :tnotifyevent;
    pOnClick   :tnotifyevent;
    //-----------------para el mouse down
    OldOnMouseDown:tMouseEvent;
    pOnMouseDown  :tMouseEvent;
    //-----------------para el mouse up
    OldOnMouseUp:tMouseEvent;
    pOnMouseUP  :tMouseEvent;
    //-----------------para el mouse move
    OldOnMouseMove:tMouseMoveEvent;
    pOnMouseMove  :tMouseMoveEvent;
    //--funciones que leen los privados
    function GethDC:HDC;
    function GethRC: HGLRC;
    function GetControl:tpanel;
    function GetCullface:tcullface;
    function GetPolygonMode:tpolygonmode;
    function GetProjectionType:TprojectionType;
    function GetShadeModel:TShadeModel;
    function GetPerspectiveCorrection:TperspectiveCorrection;
    function Gettexturing:boolean;
    function Getcolor:tcolor;
    function GetCamera:tglcamera;
    //procedures que escriben los privados.
    procedure SetControl(vControl:tpanel);
    procedure SetCullface(vCullface:tcullface);
    procedure SetPolygonMode(vPolygonMode:tpolygonmode);
    procedure SetProjectionType(vProjectionType:TprojectionType);
    procedure SetShadeModel(vShadeModel:TShadeModel);
    procedure SetPerspectiveCorrection(vPerspectiveCorrection:TperspectiveCorrection);
    procedure Settexturing(vtexturing:boolean);
    procedure Setcolor(vcolor:tcolor);
    procedure SetCamera(vcamera:tglcamera);
    procedure FormPaint(Sender: TObject);
    procedure ControlResize(Sender: TObject);
    procedure ControlClick(Sender: TObject);
    //para el mouse
    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    //--otras internas
    Procedure ReleaseRC;
    procedure updateArea;
  PUBLIC
     Translation : tglVertex;
     Rotation    : tglVertex;
     Scale       : tglVertex;
     selection   : cardinal;     //integer;
     min:tglvertex; //minimun x,y,z cordinates en la lista
     max:tglvertex; //maximun x,y,z cordinates en la lista
     mouse_x,mouse_y:integer;
     select_width,select_height:byte; //ancho del box para el select
     buffer_size:integer;
     disable_Mouseclick:boolean;
     //
    DoDraw : procedure;  //asignar a este procedimiento la rutina de dibujado del usuario.
    Property DC:HDC read gethdc;
    Property HRC: HGLRC read gethrc;
    Property Control:tpanel read Getcontrol write SetControl;
    Property Cullface:tcullface read getcullface write setcullface;
    Property PolygonMode:tpolygonmode read getpolygonmode write setpolygonmode;
    Property ProjectionType:TprojectionType read getprojectiontype write setprojectiontype;
    Property ShadeModel:TShadeModel read getshademodel write setshademodel;
    Property PerspectiveCorrection:TperspectiveCorrection read getperspectivecorrection write setperspectivecorrection;
    Property texturing:boolean read gettexturing write settexturing;
    Property color:tcolor read getcolor write setcolor;
    Property Camera:tglcamera read getcamera write setcamera;
    Property Onpaint:tnotifyevent read pOnpaint write pOnpaint;
    Property OnResize:tnotifyevent read pOnResize write pOnResize;
 //-----------------
    Constructor create(owner:tform);     {creates a new scene}
    Destructor  destroy; override;   {don´t call this directly, call free instead}
    procedure setcurrent;
    procedure sharelists(var v:tglviewport);

//---para el mouse
  procedure mouse_down(Shift: TShiftState; X, Y: Integer);
  procedure mouse_move(Shift: TShiftState; X, Y: Integer);
  procedure mouse_up(Shift: TShiftState; X, Y: Integer);
  procedure mouse_click;
  procedure mouse_click2;
//---------------
   //procedures para mantenimiento del mix/max
   procedure ResetDimension;
   procedure GetDimension(figure:tglfigure);
   procedure CompareDimension(figure:tglfigure);
   Procedure center;
   procedure reset;
   procedure invalidategl;
   procedure redraw;
   //for manual drawing
   procedure begin_draw;
   procedure End_draw;
   procedure render_to_backbuffer;
   //manual zoom;
   procedure manual_zoom(x,y,z:glfloat);
   procedure manual_rotate(x,y,z:glfloat);

  end; {TGLviewport}
//--------------------

//----Tglfigure Clase ----------

   Tglfigure = class(tobject)
   PROTECTED
    procedure DoRender; virtual;
  PUBLIC
     Translation : tglVertex;
     Rotation    : tglVertex;
     Scale       : tglVertex;
     min         : tglvertex; //minimun x,y,z cordinates en la lista
     max         : tglvertex; //maximun x,y,z cordinates en la lista
     perspective_correct_enabled:boolean;

     dinamic_draw:procedure;
     constructor Create; virtual;
     procedure redraw;
     procedure prepare_camera;
     procedure reset; virtual;
end;
//---------------------}

type
tquad = record
         x1,y1,z1,
         x2,y2,z2,
         x3,y3,z3,
         x4,y4,z4:glfloat;
         texture:word;
         color:tcolor;
         color_texture:tcolor;
         light  :byte;
         enabled:boolean;
end;
//-----------
type
ttriad = record
         x1,y1,z1,
         x2,y2,z2,
         x3,y3,z3:glfloat;
         texture:word;
         color:tcolor;
         light  :byte;
         enabled:boolean;
end;
//-----------------
const
max_meshes = 2; //256;
max_rectangles= 4000;


type
xtmesh = record
        x,y,z:glfloat;
        num_rectangles:integer;
        rectan_list : tstringlist;
        rectangles: array[1..max_rectangles] of tquad;
        enabled:boolean;
        solid_bitmap:integer;
        render_tipo:trender_tipo;   //0=wireframe, 1=Shaded, 2=solid one texture, 3=multi Textured
end;

xtmesh_list = record
             num_meshes:integer;
             mesh:array[1..max_meshes] of xtmesh;
end;

 type
  tscene = class(Tglfigure)
  protected
   procedure DoRender; override;
   procedure render_wireframe(nmesh:integer);virtual;
   procedure render_shade(nmesh:integer);virtual;
   procedure render_solid(nmesh:integer);virtual;
   procedure render_textured(nmesh:integer);virtual;
  public
   //--rectangles and triangles list----
   meshes:xtmesh_list;
   current:integer;    //current mesh
   default_color:tcolor; //default color for the current mesh
   force_color:boolean; //si verdadero render the current mesh with default color
   //-------
  constructor Create; override;
  function add_mesh:integer;
  procedure clear_mesh(nmesh:byte);
  function add_face(nmesh:integer; x1,y1,z1,  x2,y2,z2,
                      x3,y3,z3,  x4,y4,z4:glfloat;
                      texture:word; color:tcolor; color_texture:tcolor; light:byte; menabled:boolean=true):integer;

  function center:glfloat;virtual;
  procedure Rectan_Change_texture(nmesh:integer; index:integer; textura:word; k:integer=1);
  procedure clear;
  //some predefined
  procedure make_surface(nmesh:integer; ancho,alto:byte; sx,sy,sz:real; x,y,z:real; normal:boolean=true);
  procedure make_cube(ancho_cube,alto_cube,largo_cube,size:real; x,y,z:real);
  end;
//--------------
//--------------------
// public usefull opengl functions & procedures
procedure emptyproc;
procedure Opgl_Define_Texture(texture_index:TGluint; width,height:word; pixelformat:word; data:pointer; prioridad:byte=1);overload;
procedure Opgl_Define_Texture(texture_index:TGluint; Bitmap:Tbitmap; colorbits:byte; vp:array of tglviewport);overload;
procedure Opgl_Define_Texture(texture_index:TGluint; Bitmap:Tbitmap; colorbits:byte);overload;

procedure opgl_automatic_texture(estado:tautomatic_texture; normal:tnormal=tnfront);
//------ Funcion para encontrar el intersecto de 2 lineas.
Function Opgl_find_intersect(ax1,ay1,ax2,ay2, bx1,by1,bx2,by2 :glfloat; var xi:glfloat; var yi:glfloat):boolean;

Procedure Push_RC;
Procedure Pop_RC;

procedure set_perspective_correct(enabled:boolean);







//predefined------------

VAR
Opengl_ok:boolean;
display_list_count:integer;


implementation
//----funciones y procedimientos independientes-----
uses xopengl;


const
auto_front_s: array[0..3] of glfloat = (1,0,0,0);
auto_back_s: array[0..3] of glfloat = (-1,0,0,0);
auto_left_s: array[0..3] of glfloat = (0,0,1,0);
auto_right_s: array[0..3] of glfloat = (0,0,-1,0);
auto_top_s: array[0..3] of glfloat = (1,0,0,0);
auto_bottom_s: array[0..3] of glfloat = (1,0,0,0);

auto_front_t: array[0..3] of glfloat = (0,-1,0,0);
auto_back_t: array[0..3] of glfloat = (0,-1,0,0);
auto_left_t: array[0..3] of glfloat = (0,-1,0,0);
auto_right_t: array[0..3] of glfloat = (0,-1,0,0);
auto_top_t: array[0..3] of glfloat = (0,0,1,0);
auto_bottom_t: array[0..3] of glfloat = (0,0,-1,0);


type
rc_record = record
     DC:HDC;
     RC: HGLRC;
end;

tstack_rc = record
      count:integer;
      r  : array[1..99] of rc_record;
end;

var

stack_rc:tstack_rc;
auto_custom_s: array[0..3] of glfloat;
auto_custom_t: array[0..3] of glfloat;


procedure emptyproc;
begin
   //hacer absolutamente nada.
end;

Procedure Opgl_SetDCPixelFormat(var dc:hdc; buffer_size:integer);
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd),0);
  with pfd do begin
    nSize     := sizeof(pfd);                               // Size of this structure
    nVersion  := 1;                                         // Version number
    dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_NEED_SYSTEM_PALETTE OR
                 PFD_DOUBLEBUFFER;                          // Flags
    iPixelType:= PFD_TYPE_RGBA;                             // RGBA pixel values
    cColorBits:=buffer_size; //                              // 24-bit color
    cDepthBits:=buffer_size;//
    iLayerType:= PFD_MAIN_PLANE;                            // Layer type
  end;
  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);
  DescribePixelFormat(DC, nPixelFormat, sizeof(TPixelFormatDescriptor), pfd);
end;
//--------
procedure Opgl_Define_Texture(texture_index:TGluint; width,height:word; pixelformat:word; data:pointer; prioridad:byte=1);overload;
var
bpp:byte;
b,c:tbitmap;
p:pointer;
begin
    bpp:=1;
    p:=nil;
    //tener pendiente implementar mas tipos de pixelformat
    case pixelformat of
      gl_rgb,gl_bgr  : bpp:=3;
      gl_rgba        : bpp:=4;
      gl_rgb16       : bpp:=2;
    end; //end case
   //-------
   //si el ancho o alto no es power of 2 strechar la textura a 64x64
   if ((width<>8) and (width<>16) and (width<>32) and (width<>64) and (width<>128) and (width<>256)) or
      ((height<>8) and (height<>16) and (height<>32) and (height<>64) and (height<>128) and (height<>256)) then
   begin
       b:=tbitmap.create;c:=tbitmap.create;
       case bpp of
            //tener pendiente implementar mas tipos de pixelformat
            2:b.pixelformat:=pf15bit;
            3:b.pixelformat:=pf24bit;
            4:b.pixelformat:=pf32bit;
       end;//endcase
       b.width:=width;
       b.height:=height;
       xsetbitmapbits(b,width*height*bpp,data);
       c.pixelformat:=pf24bit;
       c.width:=64;
       c.height:=64;
       c.canvas.StretchDraw( rect(0,0,65,65), b);
       getmem(p,64*64*3);
       xgetbitmapbits(c,64*64*3,p);
       data:=p;
       width:=64;
       height:=64;
       bpp:=3;
       pixelformat:=gl_bgr;
       b.free;
       c.free;
   end; //strech

   //-------

    glbindtexture(gl_texture_2d,texture_index);

    gltexEnvi(gl_texture_env,gl_texture_env_mode,gl_modulate);
    gltexgenf(gl_t, gl_texture_gen_mode, gl_object_linear);
    gltexgenf(gl_s, gl_texture_gen_mode, gl_object_linear);

    gltexparameteri(gl_texture_2d,gl_texture_wrap_s,gl_repeat);
    gltexparameteri(gl_texture_2d,gl_texture_wrap_t,gl_repeat);
    //perspective correct None
    gltexparameteri(gl_texture_2d,gl_texture_mag_filter,gl_nearest);
    gltexparameteri(gl_texture_2d,gl_texture_min_filter,gl_nearest);
    //prioridad
   gltexparameteri(gl_texture_2d,gl_texture_priority,prioridad);


    glpixelstorei(gl_unpack_alignment,2);
    glpixelstorei(gl_unpack_row_length,0);
    glpixelstorei(gl_unpack_skip_rows,0);
    glpixelstorei(gl_unpack_skip_pixels,0);
    glpixelstorei(gl_unpack_lsb_first,0);
    glteximage2d(gl_texture_2d,0,bpp,width,height,0,pixelformat,gl_unsigned_byte,data);
    if assigned(p) then freemem(p);
end;
//----------------------
procedure Opgl_Define_Texture(texture_index:TGluint; Bitmap:Tbitmap; colorbits:byte; vp:array of tglviewport);overload;
var
bpp:byte;
c:tbitmap;
p:pointer;
width,height:integer;
data:pointer;
pixelformat:word;
pf:tpixelformat;
k:integer;
prioridad:word;
begin

  if (colorbits<>16) and (colorbits<>24) and (colorbits<>32) then colorbits:=16;
  case colorbits of
       16:begin pf:=pf24bit; bpp:=3; end;
       24:begin pf:=pf24bit; bpp:=3; end;
       32:begin pf:=pf32bit; bpp:=4; end;
  end; //end case



    if bitmap.pixelformat<>pf then
    begin
       bitmap.pixelformat:=pf;
    end;


  p:=nil;
   //si el ancho o alto no es power of 2 strechar la textura a 64x64
   if ((bitmap.width<>8) and (bitmap.width<>16) and (bitmap.width<>32) and (bitmap.width<>64) and (bitmap.width<>128) and (bitmap.width<>256)) or
      ((bitmap.height<>8) and (bitmap.height<>16) and (bitmap.height<>32) and (bitmap.height<>64) and (bitmap.height<>128) and (bitmap.height<>256)) then
   begin
       c:=tbitmap.create;
       c.pixelformat:=pf;
       c.width:=64;
       c.height:=64;
       c.canvas.StretchDraw( rect(0,0,65,65), bitmap);
       getmem(p,64*64*bpp);
       xgetbitmapbits(c,64*64*bpp,p);
       data:=p;
       width:=64;
       height:=64;
       c.free;
   end //strech
   else
   begin
       getmem(p,bitmap.width*bitmap.height*bpp);
       xgetbitmapbits(bitmap,bitmap.width*bitmap.height*bpp,p);
       data:=p;
       width:=bitmap.width;
       height:=bitmap.height;
   end;
   //-------
    prioridad:=1;

    if bpp=4 then pixelformat:=gl_bgra else pixelformat:=gl_bgr;

  for k:=0 to high(vp) do
  begin

    vp[k].setcurrent;

    glbindtexture(gl_texture_2d,texture_index);
    gltexEnvi(gl_texture_env,gl_texture_env_mode,gl_modulate);
    gltexgenf(gl_t, gl_texture_gen_mode, gl_object_linear);
    gltexgenf(gl_s, gl_texture_gen_mode, gl_object_linear);

    gltexparameteri(gl_texture_2d,gl_texture_wrap_s,gl_repeat);
    gltexparameteri(gl_texture_2d,gl_texture_wrap_t,gl_repeat);
    //perspective correct None
    gltexparameteri(gl_texture_2d,gl_texture_mag_filter,gl_nearest); //use gl_linear for perspective correct.
    gltexparameteri(gl_texture_2d,gl_texture_min_filter,gl_nearest);
    //prioridad
    gltexparameteri(gl_texture_2d,gl_texture_priority,prioridad);

    glpixelstorei(gl_unpack_alignment,1);
    glpixelstorei(gl_unpack_row_length,0);
    glpixelstorei(gl_unpack_skip_rows,0);
    glpixelstorei(gl_unpack_skip_pixels,0);
    glpixelstorei(gl_unpack_lsb_first,0);

    glteximage2d(gl_texture_2d,0,bpp,width,height,0,pixelformat,gl_unsigned_byte,data);

 end;//end all viewport

    if assigned(p) then freemem(p);

end;
//------------------

procedure Opgl_Define_Texture(texture_index:TGluint; Bitmap:Tbitmap; colorbits:byte);overload;
var
bpp:byte;
c:tbitmap;
p:pointer;
width,height:integer;
data:pointer;
pixelformat:word;
pf:tpixelformat;
k:integer;
prioridad:word;
begin

  if (colorbits<>16) and (colorbits<>24) and (colorbits<>32) then colorbits:=16;
  case colorbits of
       16:begin pf:=pf24bit; bpp:=3; end;
       24:begin pf:=pf24bit; bpp:=3; end;
       32:begin pf:=pf32bit; bpp:=4; end;
  end; //end case



    if bitmap.pixelformat<>pf then
    begin
       bitmap.pixelformat:=pf;
    end;


  p:=nil;
   //si el ancho o alto no es power of 2 strechar la textura a 64x64
   if ((bitmap.width<>8) and (bitmap.width<>16) and (bitmap.width<>32) and (bitmap.width<>64) and (bitmap.width<>128) and (bitmap.width<>256)) or
      ((bitmap.height<>8) and (bitmap.height<>16) and (bitmap.height<>32) and (bitmap.height<>64) and (bitmap.height<>128) and (bitmap.height<>256)) then
   begin
       c:=tbitmap.create;
       c.pixelformat:=pf;
       c.width:=64;
       c.height:=64;
       c.canvas.StretchDraw( rect(0,0,65,65), bitmap);
       getmem(p,64*64*bpp);
       xgetbitmapbits(c,64*64*bpp,p);
       data:=p;
       width:=64;
       height:=64;
       c.free;
   end //strech
   else
   begin
       getmem(p,bitmap.width*bitmap.height*bpp);
       xgetbitmapbits(bitmap,bitmap.width*bitmap.height*bpp,p);
       data:=p;
       width:=bitmap.width;
       height:=bitmap.height;
   end;
   //-------
    prioridad:=1;
    if bpp=4 then pixelformat:=gl_bgra else pixelformat:=gl_bgr;


    glbindtexture(gl_texture_2d,texture_index);
    gltexEnvi(gl_texture_env,gl_texture_env_mode,gl_modulate);
    gltexgenf(gl_t, gl_texture_gen_mode, gl_object_linear);
    gltexgenf(gl_s, gl_texture_gen_mode, gl_object_linear);

    gltexparameteri(gl_texture_2d,gl_texture_wrap_s,gl_repeat);
    gltexparameteri(gl_texture_2d,gl_texture_wrap_t,gl_repeat);
    //perspective correct None
    gltexparameteri(gl_texture_2d,gl_texture_mag_filter,gl_nearest); //use gl_linear for perspective correct.
    gltexparameteri(gl_texture_2d,gl_texture_min_filter,gl_nearest);
    //prioridad
    gltexparameteri(gl_texture_2d,gl_texture_priority,prioridad);

    glpixelstorei(gl_unpack_alignment,2);
    glpixelstorei(gl_unpack_row_length,0);
    glpixelstorei(gl_unpack_skip_rows,0);
    glpixelstorei(gl_unpack_skip_pixels,0);
    glpixelstorei(gl_unpack_lsb_first,0);

    glteximage2d(gl_texture_2d,0,bpp,width,height,0,pixelformat,gl_unsigned_byte,data);


    if assigned(p) then freemem(p);

end;
//------------------



procedure opgl_automatic_texture(estado:tautomatic_texture; normal:tnormal=tnfront);
var
ps,pt:pointer;

begin

case normal of
     tnfront:  begin ps:=@auto_front_s; pt:=@auto_front_t;end;
     tnback:   begin ps:=@auto_back_s; pt:=@auto_back_t;end;
     tnleft:   begin ps:=@auto_left_s; pt:=@auto_left_t;end;
     tnright:  begin ps:=@auto_right_s; pt:=@auto_right_t;end;
     tntop:    begin ps:=@auto_top_s; pt:=@auto_top_t;end;
     tnbottom: begin ps:=@auto_bottom_s; pt:=@auto_bottom_t;end;
end; //end case;

if estado=atenabled then
begin
   //---automatic texture generation---
   glenable(gl_texture_gen_s);
   gltexgenfv(gl_s,gl_object_plane,ps);
   glenable(gl_texture_gen_t);
   gltexgenfv(gl_t,gl_object_plane,pt);
   //----------------------------------
end
else
begin
   //---automatic texture generation---
   gldisable(gl_texture_gen_s);
   gldisable(gl_texture_gen_t);
   //----------------------------------
end;


end;


//------------------------------
//tfigure implementation
constructor Tglfigure.create;
begin
  inherited create;
  dinamic_draw:=nil;
  translation.x:=0;
  translation.y:=0;
  translation.z:=0;
  rotation.x:=0;
  rotation.y:=0;
  rotation.z:=0;
  scale.x:=1;
  scale.y:=1;
  scale.z:=1;
  //---min y max
  min.x:=922337203685477.580;
  min.y:=922337203685477.580;
  min.z:=922337203685477.580;
  max.x:=-922337203685477.580;
  max.y:=-922337203685477.580;
  max.z:=-922337203685477.580;
  perspective_correct_enabled:=false;

end;
//------
procedure Tglfigure.reset;
begin
  dinamic_draw:=nil;
  translation.x:=0;
  translation.y:=0;
  translation.z:=0;
  rotation.x:=0;
  rotation.y:=0;
  rotation.z:=0;
  scale.x:=1;
  scale.y:=1;
  scale.z:=1;
  //---min y max
  min.x:=922337203685477.580;
  min.y:=922337203685477.580;
  min.z:=922337203685477.580;
  max.x:=-922337203685477.580;
  max.y:=-922337203685477.580;
  max.z:=-922337203685477.580;
end;
//----------
//esta funcion deve ser redefinida por herencia para dibujar los que
//realmente se desea, si no se redefine entonces la otra alternativa
//es asignar la rutina con el dibujo a el procedimiento tglfigure.dinamic_draw;
procedure Tglfigure.DoRender;
begin
   if assigned(dinamic_draw) then dinamic_draw;
//----
end;

procedure Tglfigure.Redraw;
begin
    GlMatrixMode(Gl_modelview); //se va a modificar las cordenadas
    glpushmatrix;
    GlTranslatef(translation.x, translation.y, translation.z); //mover
    GlScalef(scale.x, scale.y, scale.z); //scalar
    //rotar x
    GlRotatef(rotation.x,1,0,0);
    //rotar y
    GlRotatef(Rotation.y,0,1,0);
    //rotar z
    GlRotatef(rotation.z,0,0,1);
    doRender;
   //---------------
    glpopmatrix;
end;

procedure Tglfigure.prepare_camera;
begin
    GlMatrixMode(Gl_modelview); //se va a modificar las cordenadas
    glpushmatrix;
    GlTranslatef(translation.x, translation.y, translation.z); //mover
    GlScalef(scale.x, scale.y, scale.z); //scalar
    //rotar x
    GlRotatef(rotation.x,1,0,0);
    //rotar y
    GlRotatef(Rotation.y,0,1,0);
    //rotar z
    GlRotatef(rotation.z,0,0,1);
end;




//-------------------------------
//--------------------------------

Constructor TGlviewport.create(owner:tform);
begin
  inherited create;
    powner:=owner;
    pControl:=nil;
    pDC:=0;
    pRC:=0;
    Active:=false;
    pCullface:=cffront;
    pPolygonMode:=pmline;
    pProjectionType:=ptperspective;
    pShadeModel:=smflat;
    pPerspectiveCorrection:=qunone;
    ptexturing:=false;
    pcolor:=clblack;
    DoDraw:=emptyproc;
    pcamera:=nil;
    plist:=0;
    inc(display_list_count);
    displaylistID:=display_list_count;
    //------mouse handling----
   translation.x:=0;
   translation.y:=0;
   translation.z:=0;

   rotation.x:=0;
   rotation.y:=0;
   rotation.z:=0;

   scale.x:=1;
   scale.y:=1;
   scale.z:=1;

   mx:=0;my:=0;
   cx:=0;cy:=0;
   zx:=0;zy:=0;
   drag:=false;
   drag2:=false;
   lrx:=0;lry:=0;lrz:=0;
   lcx:=0;lcy:=0;lcz:=0;
   lzx:=0;lzy:=0;lzz:=0;
   mouse_x:=0;mouse_y:=0;
   selection:=0;
   Select_width:=2;
   Select_height:=2;
   buffer_size:=16;

   rc_already_selected:=false;

   Disable_MouseClick:=false;
   //---min y max
    min.x:=922337203685477.580;
    min.y:=922337203685477.580;
    min.z:=922337203685477.580;
    max.x:=-922337203685477.580;
    max.y:=-922337203685477.580;
    max.z:=-922337203685477.580;
    //-------
    pOnpaint:=formpaint;
    OldOnpaint:=powner.onpaint;
    powner.onpaint:=pOnpaint;
end;

Destructor  Tglviewport.destroy;
begin
  If Active then ReleaseRC;
 inherited destroy;
end;
//-------------
function Tglviewport.GethDC:HDC;
begin
    GethDC:=pdc;
end;
//-------------
function Tglviewport.GethRC: HGLRC;
begin
    GethRC:=prc;
end;
//-------------
function Tglviewport.GetControl:tpanel;
begin
    GetControl:=pControl;
end;

//-------------
function Tglviewport.GetCullface:tcullface;
begin
   GetCullface:=pcullface;
end;
//-------------
function Tglviewport.GetPolygonMode:tpolygonmode;
begin
    GetPolygonMode:=ppolygonmode;
end;
//-------------
function Tglviewport.GetProjectionType:TprojectionType;
begin
    GetProjectionType:=pprojectionType;
end;
//-------------
function Tglviewport.GetShadeModel:TShadeModel;
begin
    GetShadeModel:=pShadeModel;
end;
//-------------
function Tglviewport.GetPerspectiveCorrection:TperspectiveCorrection;
begin
    GetPerspectiveCorrection:=pperspectiveCorrection;
end;
//-------------
function Tglviewport.Gettexturing:boolean;
begin
    Gettexturing:=ptexturing;
end;
//-------------
function Tglviewport.Getcolor:tcolor;
begin
    Getcolor:=pcolor;
end;
//---------
function Tglviewport.GetCamera:tglcamera;
begin
    Getcamera:=pcamera;
end;


//-------------
//procedures que escriben los privados.
procedure Tglviewport.SetControl(vControl:tpanel);

begin
   //-----------------
   pcontrol:=vcontrol;

 pDC:= GetDC(pcontrol.Handle);

   //-on resize
   pOnResize:=ControlResize;
   OldOnResize:=pcontrol.onresize;
   pcontrol.onresize:=pOnresize;
   //-on click
   pOnClick:=ControlClick;
   OldOnClick:=pcontrol.OnClick;
   pcontrol.onClick:=pOnClick;
   //-on Mouse down
   pOnMouseDown:=ControlMouseDown;
   OldOnMouseDown:=pcontrol.onMouseDown;
   pcontrol.onMouseDown:=pOnMouseDown;
   //-on Mouse Up
   pOnMouseUp:=ControlMouseUp;
   OldOnMouseUp:=pcontrol.OnMouseUp;
   pcontrol.onMouseUp:=pOnMouseUp;
   //-on Mouse Move
   pOnMouseMove:=ControlMouseMove;
   OldOnMouseMove:=pcontrol.OnMouseMove;
   pcontrol.onMouseMove:=pOnMouseMove;

   //----------------------
   Opgl_SetDCPixelFormat(pdc,buffer_size);
   pRC := wglCreateContext(pDC);

   wglMakeCurrent( pDC{getdc(pcontrol.handle)}, pRC);
   //---enable some states-----
   //for atis
// gldepthfunc(gl_greater); //for default is gl_less
   glenable(gl_depth_test);  //diasble for atis?
   //-----------
   glenable(gl_cull_face);
   glcullface(gl_back);
   glpolygonmode(gl_front_and_back,gl_line);
   //cambiar a clock counter wise direction para definir
   //los faces en sentido a las manecillas del reloj.
   GlFrontFace(gl_cw);
   //do Set Sates; //poner los estados especificados, shade,correction, etc.
   active:=true;
   //viewport
   UpdateArea;
   wglMakeCurrent(0,0);
   //ReleaseDC(pcontrol.Handle,pDC);
end;
//-------------

procedure Tglviewport.Setcurrent;
var
  hDC:Cardinal;
begin
    hDC:= pDC;//getdc(pcontrol.handle);
    wglMakeCurrent( hDC{getdc(pcontrol.handle)}, pRC);
    //ReleaseDC(pcontrol.handle,hDC);
end;

procedure Tglviewport.sharelists(var v:tglviewport);
begin
    wglsharelists(prc,v.hrc)
end;


procedure Tglviewport.SetCullface(vCullface:tcullface);
begin
    pCullface:=vCullface;
end;
//-------------
procedure Tglviewport.SetPolygonMode(vPolygonMode:tpolygonmode);
begin
    pPolygonMode:=vpolygonmode;
end;
//-------------
procedure Tglviewport.SetProjectionType(vProjectionType:TprojectionType);
begin
    pProjectionType:=vprojectionType;
end;
//-------------
procedure Tglviewport.SetShadeModel(vShadeModel:TShadeModel);
begin
    ShadeModel:=vShadeModel;
end;
//-------------
procedure Tglviewport.SetPerspectiveCorrection(vPerspectiveCorrection:TperspectiveCorrection);
begin
    pPerspectiveCorrection:=vperspectiveCorrection;
    case pPerspectiveCorrection of
    quNone:begin
          //perspective correct fastest
            gltexparameteri(gl_texture_2d,gl_texture_mag_filter,gl_nearest);
            gltexparameteri(gl_texture_2d,gl_texture_min_filter,gl_nearest);
          end;

    quFaster:begin
          //perspective correct fastest
            gltexparameteri(gl_texture_2d,gl_texture_mag_filter,gl_linear);
            gltexparameteri(gl_texture_2d,gl_texture_min_filter,gl_nearest);
          end;

    quNicer:begin
          //perspective correct fastest
            gltexparameteri(gl_texture_2d,gl_texture_mag_filter,gl_linear);
            gltexparameteri(gl_texture_2d,gl_texture_min_filter,gl_linear);
          end;
    end; //en case


end;
//-------------
procedure Tglviewport.Settexturing(vtexturing:boolean);
begin
    ptexturing:=vtexturing;
end;
//-------------
procedure Tglviewport.Setcolor(vcolor:tcolor);
begin
    pcolor:=vcolor;
end;
//------------
procedure Tglviewport.Setcamera(vcamera:tglcamera);
begin
    pcamera:=vcamera;
end;

//--------------------------------
Procedure Tglviewport.ReleaseRC;
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(pRC);
  ReleaseDC(Pcontrol.Handle, pDC{getdc(pcontrol.handle)});
  Active:=False;
end;
//-------------
Procedure Tglviewport.UpdateArea;
begin
   //----
    glmatrixmode(gl_projection);
    glloadidentity;
    gluperspective(45,control.width/control.height,0.1,100);
    glviewport(0,0,pcontrol.width,pcontrol.height);
end;

procedure Tglviewport.InvalidateGl;
begin
    plist:=0;
    redraw;
end;

Procedure Tglviewport.redraw;
type
fex = record
      r,g,b:byte;
end;

var
br,bg,bb:byte;
hDC:Cardinal;
begin
 hDC:= pDC;//getdc(pcontrol.handle);
 if not rc_already_selected then wglMakeCurrent( hDC{getdc(pcontrol.handle)}, pRC);
 Set8087CW($133F); //i don't know if this fix the invalid floting point error,

  BeginPaint(pcontrol.Handle, ps);
     br:=twcolor(pcolor).r;bg:=twcolor(pcolor).g;bb:=twcolor(pcolor).b;
     glclearcolor(br,bg,bb,1); //cambiar esto por el property color.
     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); {Clear the rendering area}

     //El ambiente se prepara segun se asignan los valores en el property.
     //do translate,do Rotate,do scale proveido por el viewport.
    GlMatrixMode(Gl_projection);
    glpushmatrix;
    pcamera.redraw;

    GlMatrixMode(Gl_modelview); //se va a modificar las cordenadas
    glpushmatrix;
    GlTranslatef(translation.x, translation.y, translation.z); //mover
    GlScalef(scale.x, scale.y, scale.z); //scalar
    //rotar x
    GlRotatef(rotation.x,1,0,0);
    //rotar y
    GlRotatef(Rotation.y,0,1,0);
    //rotar z
    GlRotatef(rotation.z,0,0,1);
     //----------------ejecutar el procedimiento de dibujo del usuario.
     //usar una lista compilida si las primitivas no tienen cambio.
     if plist=0 then //si "0" crear la lista por primera vez.
     begin
           //reset the polys names.
           glnewlist(DisplayListID,gl_compile_and_execute);
           glInitNames;
           glPushName(0);
           dodraw;
          glendlist;
          plist:=1;
     end
     else glcallList(DisplayListID);

     //---------------
     glpopmatrix;
     GlMatrixMode(Gl_projection);
     glpopmatrix;
     glflush;
     SwapBuffers(hDC{getdc(pcontrol.handle)});

 EndPaint(pcontrol.Handle, ps);
  ///ReleaseDC(pcontrol.Handle,hDC);
 //seems that somevideo cards need to close the Device context in each frame.
 if not rc_already_selected then wglMakeCurrent(0,0);
 //lets try to put next code here to avoid the invalid floating point error.
 asm fclex end;

end;
//---------------------------



Procedure Tglviewport.Begin_Draw;
var
br,bg,bb:byte;
begin

 wglMakeCurrent( getdc(pcontrol.handle), pRC);
 Set8087CW($133F); //i don't know if this fix the invalid floting point error,

 BeginPaint(pControl.Handle, ps);
     br:=twcolor(pcolor).r;bg:=twcolor(pcolor).g;bb:=twcolor(pcolor).b;
     glclearcolor(br,bg,bb,1); //cambiar esto por el property color.
     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); {Clear the rendering area}
     //El ambiente se prepara segun se asignan los valores en el property.
     //do translate,do Rotate,do scale proveido por el viewport.
    GlMatrixMode(Gl_projection);
    glpushmatrix;
    pcamera.redraw;

    GlMatrixMode(Gl_modelview); //se va a modificar las cordenadas
    glpushmatrix;
    GlTranslatef(translation.x, translation.y, translation.z); //mover
    GlScalef(scale.x, scale.y, scale.z); //scalar
    //rotar x
    GlRotatef(rotation.x,1,0,0);
    //rotar y
    GlRotatef(Rotation.y,0,1,0);
    //rotar z
    GlRotatef(rotation.z,0,0,1);
     //----------------ejecutar el procedimiento de dibujo del usuario.
     //usar una lista compilida si las primitivas no tienen cambio.
          glnewlist(DisplayListID,gl_compile_and_execute);
end;

Procedure Tglviewport.End_Draw;
var
br,bg,bb:byte;
begin
    glendlist;
    //---------------
    glpopmatrix;
    GlMatrixMode(Gl_projection);
    glpopmatrix;
    glflush;
    SwapBuffers(getdc(pcontrol.handle));
 EndPaint(pcontrol.Handle, ps);
 //seems that somevideo cards need to close the Device context in each frame.
 wglMakeCurrent(0,0);

 //lets try to put next code here to avoid the invalid floating point error.
 asm fclex end;

end;
//---------------------------

Procedure Tglviewport.render_to_backbuffer;
var
br,bg,bb:byte;
begin


 if not rc_already_selected then wglMakeCurrent( getdc(pcontrol.handle), pRC);
 Set8087CW($133F); //i don't know if this fix the invalid floting point error,

//     br:=twcolor(pcolor).r;bg:=twcolor(pcolor).g;bb:=twcolor(pcolor).b;
//     glclearcolor(0,0,0,1); //for selecting always in black.
//     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); {Clear the rendering area}
     //El ambiente se prepara segun se asignan los valores en el property.
     //do translate,do Rotate,do scale proveido por el viewport.
    GlMatrixMode(Gl_projection);
    glpushmatrix;
    pcamera.redraw;

    GlMatrixMode(Gl_modelview); //se va a modificar las cordenadas
    glpushmatrix;
    GlTranslatef(translation.x, translation.y, translation.z); //mover
    GlScalef(scale.x, scale.y, scale.z); //scalar
    //rotar x
    GlRotatef(rotation.x,1,0,0);
    //rotar y
    GlRotatef(Rotation.y,0,1,0);
    //rotar z
    GlRotatef(rotation.z,0,0,1);
     //----------------ejecutar el procedimiento de dibujo del usuario.
     //draw the scene.
     glInitNames;
     glPushName(0);

     dodraw;

     //---------------
     glpopmatrix;
     GlMatrixMode(Gl_projection);
     glpopmatrix;
     glflush;

     //i guees the scene is in backbuffer now.

 //seems that somevideo cards need to close the Device context in each frame.
 if not rc_already_selected then wglMakeCurrent(0,0);
 //lets try to put next code here to avoid the invalid floating point error.
 asm fclex end;

end;
//---------------------------


procedure Tglviewport.FormPaint(Sender: TObject);
begin
    if assigned(OldOnpaint) then OldOnpaint(sender);
    redraw;
end;

procedure Tglviewport.ControlResize(Sender: TObject);
var
  hDC:Cardinal;
begin
    if assigned(OldOnresize) then OldOnresize(sender);
    hDC:= pDC;//getdc(pcontrol.handle);
    wglMakeCurrent( hDC{getdc(pcontrol.handle)}, pRC);
    ///ReleaseDC(Pcontrol.Handle,hDC);
    UpdateArea;
    redraw;
end;

procedure Tglviewport.ControlClick(Sender: TObject);
begin
   if not disable_mouseclick then mouse_click;
   if assigned(OldOnclick) then OldOnclick(sender);
end;


procedure Tglviewport.ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    mouse_down(shift,x,y);
    if assigned(OldOnmousedown) then OldOnmouseDown(sender,button,shift,x,y);
end;

procedure Tglviewport.ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    mouse_Up(shift,x,y);
    if assigned(OldOnmouseUp) then OldOnmouseUp(sender,button,shift,x,y);
end;

procedure Tglviewport.ControlMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
begin
   mouse_Move(shift,x,y);
   if assigned(OldOnmouseMove) then OldOnmousemove(sender,shift,x,y);

end;

procedure tglviewport.Reset;
begin
    plist:=0;
    //------mouse handling----
   translation.x:=0;
   translation.y:=0;
   translation.z:=0;

   rotation.x:=0;
   rotation.y:=0;
   rotation.z:=0;

   scale.x:=1;
   scale.y:=1;
   scale.z:=1;

   mx:=0;my:=0;
   cx:=0;cy:=0;
   zx:=0;zy:=0;
   drag:=false;
   drag2:=false;
   lrx:=0;lry:=0;lrz:=0;
   lcx:=0;lcy:=0;lcz:=0;
   lzx:=0;lzy:=0;lzz:=0;
   mouse_x:=0;mouse_y:=0;
   selection:=0;
   //---min y max
    min.x:=922337203685477.580;
    min.y:=922337203685477.580;
    min.z:=922337203685477.580;
    max.x:=-922337203685477.580;
    max.y:=-922337203685477.580;
    max.z:=-922337203685477.580;
    //--------
end;

procedure tglviewport.ResetDimension;
begin
    min.x:=922337203685477.580;
    min.y:=922337203685477.580;
    min.z:=922337203685477.580;
    max.x:=-922337203685477.580;
    max.y:=-922337203685477.580;
    max.z:=-922337203685477.580;
end;


procedure tglviewport.GetDimension(figure:tglfigure);
begin
    min.x:=figure.min.x+figure.translation.x;
    min.y:=figure.min.y+figure.translation.y;
    min.z:=figure.min.z+figure.translation.z;

    max.x:=figure.max.x+figure.translation.x;
    max.y:=figure.max.y+figure.translation.y;
    max.z:=figure.max.z+figure.translation.z;
end;

procedure tglviewport.CompareDimension(figure:tglfigure);
begin

end;

procedure tglviewport.center;
var
despx,despy,despz:glfloat;
sc,scx,scy:glfloat;
begin
    despx:=(min.x+((max.x-min.x)/2));
    despy:=(min.y+((max.y-min.y)/2));
    despz:=max.z+4;
   //scalar.
    sc:=1;scx:=1;scy:=1;

    if abs(max.x-min.x)>6 then scx:=6/abs(max.x-min.x);
    if abs(max.y-min.y)>4 then scy:=4/abs(max.y-min.y);
    if scx<scy then sc:=scx else sc:=scy;

    if assigned(camera) then
    begin
      camera.x:=despx*sc;
      camera.y:=despy*sc;
      camera.z:=despz;
   end;

    scale.x:=sc;
    scale.y:=sc;
    scale.z:=sc;
//actualizar las variables para el
//mouse handling----
   translation.x:=0;
   translation.y:=0;
   translation.z:=0;

   rotation.x:=0;
   rotation.y:=0;
   rotation.z:=0;

   mx:=0;my:=0;
   cx:=0;cy:=0;
   zx:=0;zy:=0;
   drag:=false;
   drag2:=false;
   lrx:=0;lry:=0;lrz:=0;
   lcx:=camera.x;lcy:=camera.y;
   lzx:=scale.x;lzy:=scale.y;lzz:=scale.z;
   mouse_x:=0;mouse_y:=0;
//   redraw;
end;

procedure tglviewport.mouse_down(Shift: TShiftState; X, Y: Integer);
begin
     if (ssright in shift) and (not (ssShift in shift)) and (not (ssctrl in shift)) then
    begin
       mx:=x; my:=y;
       drag:=true;
    end;

    if (ssright in shift) and (ssShift in shift) then
    begin
       cx:=x; cy:=y;
    end;
end;
//-------------------------
procedure tglviewport.mouse_move(Shift: TShiftState; X, Y: Integer);
begin
    //salvar las cordenadas del mouse
    mouse_x:=x;mouse_y:=y;

    if (drag) and not (ssShift in shift) then //rotar el mesh
    begin
        Rotation.y:=(x-mx+lry);
        Rotation.x:=(y-my+lrx);
    end;//end if drag

    //move
    if (ssright in shift) and (ssShift in shift) then //mover la camera
    begin
        if assigned(camera) then
        begin
          camera.x:=(((x-cx)/50)*-1)+lcx;
          camera.y:=((y-cy)/50)+lcy;
        end;
    end;

    //zoom
    if (ssright in shift) and (ssctrl in shift) then //zoom in/out
    begin
        if not drag2 then
        begin
          drag2:=true;
          lzx:=scale.x;
          lzy:=scale.y;
          lzz:=scale.z;
          zx:=x; zy:=y;
       end;
        Scale.x:=((y-zy)/100)+lzx; if scale.x<0 then scale.x:=0;
        Scale.y:=((y-zy)/100)+lzy; if scale.y<0 then scale.y:=0;
        Scale.z:=((y-zy)/100)+lzz; if scale.z<0 then scale.z:=0;
    end;
    //si no se esta presionando el ctrl.
    if not (ssctrl in shift) then drag2:=false;
    redraw;
end;
//--------------------------
procedure tglviewport.mouse_up(Shift: TShiftState; X, Y: Integer);
begin

     drag:=false;
     drag2:=false;
     //last rotated
     lrx:=Rotation.x;
     lry:=Rotation.y;
     if assigned(camera) then
     begin
       lcx:=camera.x;
       lcy:=camera.y;
     end;
end;
//-------------------------
procedure tglviewport.mouse_click;

type tt = record
          x,z:smallint;
end;

type
   thit = record
          num:cardinal;
          min:tt;
          max:tt;
          name:cardinal;
end;

var
SelectBuf : array [1..32] of thit;
hits:tglint;
vp : tvector4i;
k,index:word;
minz:integer;

begin

   wglMakeCurrent( {getdc(pcontrol.handle)}pdc, pRC);
   rc_already_selected:=true;

    fillchar(selectbuf,sizeof(selectbuf),chr(0));
    glGetIntegerv (GL_VIEWPORT, @vp);

    glSelectBuffer (16*32, @selectBuf);

    glMatrixMode(gl_projection);
    glpushmatrix;
    glRenderMode(GL_SELECT); //select

    glloadidentity();
    gluPickMatrix( mouse_x,vp[3]-mouse_y, 0.09,0.09, vp);
    gluperspective(45,control.width/control.height,0.1,100);

//---------------

    redraw;  //call the compiled scene

//---------------
    glMatrixMode(gl_projection);
    glpopmatrix;
    hits:=0;
    hits:= glRenderMode(GL_RENDER);

    //retornar el name para el registro con el menor min.z.

    minz:=200000;
    index:=0;
    for k:=1 to hits do
    begin
        if selectbuf[k].min.z<minz then
        begin
            index:=k;minz:=selectbuf[k].min.z;
        end;
    end;

     if index<>0 then selection:=selectbuf[index].name else selection:=0;
     updatearea;

    wglMakeCurrent(0,0);
    rc_already_selected:=false;
end;
//-------------------------
procedure tglviewport.mouse_click2;

type tt = record
          x,z:smallint;
end;

type
   thit = record
          num:cardinal;
          min:tt;
          max:tt;
          name:cardinal;
end;

var
SelectBuf : array [1..32] of thit;
hits:tglint;
vp : tvector4i;
k,index:word;
minz:integer;

begin

   wglMakeCurrent( getdc(pcontrol.handle), pRC);
   rc_already_selected:=true;

    fillchar(selectbuf,sizeof(selectbuf),chr(0));
    glGetIntegerv (GL_VIEWPORT, @vp);

    glSelectBuffer (16*32, @selectBuf);


    glMatrixMode(gl_projection);
    glpushmatrix;
    glRenderMode(GL_SELECT); //select


    glloadidentity();
    gluPickMatrix( mouse_x,vp[3]-mouse_y, 0.09,0.09, vp);
    gluperspective(45,control.width/control.height,0.1,100);

//---------------
  gldisable(gl_depth_test);
   xselect_mode(1); //turn ON for-select-mode rendering.
   render_to_backbuffer; //render the scene in back buffer.
   xselect_mode(0); //turn OFF for-select-mode rendering.
 glenable(gl_depth_test);
   //---------------
    glMatrixMode(gl_projection);
    glpopmatrix;
    hits:=0;
    hits:= glRenderMode(GL_RENDER);

    //retornar el name para el registro con el menor min.z.

    minz:=200000;
    index:=0;
    for k:=1 to hits do
    begin
        if selectbuf[k].min.z<minz then
        begin
            index:=k;minz:=selectbuf[k].min.z;
        end;
    end;

     if index<>0 then selection:=selectbuf[index].name else selection:=0;

    wglMakeCurrent(0,0);
    rc_already_selected:=false;
end;

//----Camera implementation ------------
Constructor TGlCamera.create;
begin
  inherited create;
    px:=0;py:=0;pz:=5;
    prx:=0;pry:=0;prz:=0;
    pviewangle:=0;pviewfar:=100;pviewnear:=0.1;
end;
//-------
procedure TGlCamera.reset;
begin
    px:=0;py:=0;pz:=5;
    prx:=0;pry:=0;prz:=0;
    pviewangle:=0;pviewfar:=100;pviewnear:=0.1;

end;
//-------

Function TGlCamera.GetX:tglfloat;
begin
   getx:=px;
end;
//-------
Function TGlCamera.GetY:tglfloat;
begin
   gety:=py;
end;
//-------
Function TGlCamera.GetZ:tglfloat;
begin
   getz:=pz;
end;
//-------
Function TGlCamera.Getrx:tglfloat;
begin
   getrx:=prx;
end;
//-------
Function TGlCamera.GetrY:tglfloat;
begin
   getry:=pry;
end;
//-------
Function TGlCamera.GetrZ:tglfloat;
begin
   getrz:=prz;
end;
//------------
Function TGlCamera.GetViewAngle:tglfloat;
begin
   getviewangle:=pviewangle;
end;
//-----------
Function TGlCamera.GetViewFar:tglfloat;
begin
   getviewfar:=pviewfar;
end;
//-----------
Function TGlCamera.GetViewNear:tglfloat;
begin
   getviewnear:=pviewnear;
end;

//------

Procedure TGlCamera.SetX(vx:tglfloat);
begin
   px:=vx;
//   redraw;
end;
//------------
Procedure TGlCamera.SetY(vy:glfloat);
begin
   py:=vy;
//   redraw;
end;
//------------
Procedure TGlCamera.SetZ(vz:tglfloat);
begin
   pz:=vZ;
//   redraw;
end;
//------------
Procedure TGlCamera.SetrX(vrx:tglfloat);
begin
   prx:=vrx;
//   redraw;
end;
//------------
Procedure TGlCamera.SetrY(vry:glfloat);
begin
   pry:=vry;
//   redraw;
end;
//------------
Procedure TGlCamera.SetrZ(vrz:tglfloat);
begin
   prz:=vrZ;
//   redraw;
end;
//-----------
Procedure TGlCamera.SetViewAngle(vviewangle:tglfloat);
begin
   pviewangle:=vviewangle;
//  redraw;
end;
//-----------
Procedure TGlCamera.SetViewFar(vviewfar:tglfloat);
begin
   pviewfar:=vviewfar;
end;
//-----------
Procedure TGlCamera.SetViewNear(vviewnear:tglfloat);
begin
   pviewnear:=vviewnear;
end;
//******************************
Procedure TGlCamera.Redraw;
begin
    GlMatrixMode(Gl_projection); //se va a modificar las cordenadas del espectador.
    GlTranslatef(px*-1,py*-1,pz*-1); //mover la camera
    //rotar x
    GlRotatef(prx,1,0,0);
    //rotar y
    GlRotatef(pry,0,1,0);
    //rotar z
    GlRotatef(prz,0,0,1);
end;
//=============================
//usar esto solo una vez en el programa
constructor tscene.Create;
begin
   inherited create;
   //agregar default values.
   meshes.num_meshes:=0;
   default_color:=clwhite;
   force_color:=false;
   current:=1;
   //---min y max
    min.x:=922337203685477.580;
    min.y:=922337203685477.580;
    min.z:=922337203685477.580;
    max.x:=-922337203685477.580;
    max.y:=-922337203685477.580;
    max.z:=-922337203685477.580;
end;
//------------------------------------------------
//usar esto primero antes de agregar faces.
function Tscene.add_mesh:integer;
begin
     if meshes.num_meshes<max_meshes then
     begin
       meshes.num_meshes:=meshes.num_meshes+1;
       meshes.mesh[meshes.num_meshes].x:=0;
       meshes.mesh[meshes.num_meshes].y:=0;
       meshes.mesh[meshes.num_meshes].z:=0;
       meshes.mesh[meshes.num_meshes].num_rectangles:=0;
       meshes.mesh[meshes.num_meshes].enabled:=true;
       meshes.mesh[meshes.num_meshes].rectan_list:=tstringlist.create;
       meshes.mesh[meshes.num_meshes].rectan_list.Sorted:=false;
       meshes.mesh[meshes.num_meshes].solid_bitmap:=0;
       meshes.mesh[meshes.num_meshes].render_tipo:=rtWireframe;

       add_mesh:=meshes.num_meshes;
    end
      else add_mesh:=-1;
end;
//-------------------------------------------------
//usar esto para borar un mesh ya creado y usar add_face desde cero.
//note de que mantiene el solid bitmap ya asignado.
procedure tscene.clear_mesh(nmesh:byte);
begin
     meshes.mesh[nmesh].x:=0;
     meshes.mesh[nmesh].y:=0;
     meshes.mesh[nmesh].z:=0;
     meshes.mesh[nmesh].num_rectangles:=0;
     meshes.mesh[nmesh].enabled:=true;
     meshes.mesh[nmesh].rectan_list.clear;
end;
//-----------------------------------------------

//usar esto para reinicializar toda la scena, y volver a usar add_mesh desde cero.
procedure tscene.clear;
var k:integer;
begin
   //agregar default values.
   force_color:=false;
   default_color:=clwhite;
   current:=1;
   //---min y max
    min.x:=922337203685477.580;
    min.y:=922337203685477.580;
    min.z:=922337203685477.580;
    max.x:=-922337203685477.580;
    max.y:=-922337203685477.580;
    max.z:=-922337203685477.580;
   //-------------
   for k:=1 to meshes.num_meshes do
   begin
       meshes.mesh[k].rectan_list.free;
       meshes.mesh[k].solid_bitmap:=0;
   end;
   meshes.num_meshes:=0;
end;

//--------------------------------------------------------------------------------------------
//usar add_face para agregar faces to meshes.
// add_face espera las cordenadas a lo Tomb Raider, internamente las convierte a Opengl cordenadas.
function tscene.add_face(nmesh:integer; x1,y1,z1,  x2,y2,z2,
                      x3,y3,z3,  x4,y4,z4:glfloat;
                      texture:word; color:tcolor; color_texture:tcolor; light:byte; menabled:boolean=true):integer;
var
i:integer;

begin
   //adecuar TR cordinates a OPENGL cordinates
   y1:=y1*-1;y2:=y2*-1;y3:=y3*-1;y4:=y4*-1;
   z1:=z1*-1;z2:=z2*-1;z3:=z3*-1;z4:=z4*-1;
          if meshes.mesh[nmesh].num_rectangles<max_rectangles then
          begin
             meshes.mesh[nmesh].num_rectangles:=meshes.mesh[nmesh].num_rectangles+1;
             i:=meshes.mesh[nmesh].num_rectangles;
             meshes.mesh[nmesh].rectangles[i].x1:=x1; meshes.mesh[nmesh].rectangles[i].y1:=y1;meshes.mesh[nmesh].rectangles[i].z1:=z1;
             meshes.mesh[nmesh].rectangles[i].x2:=x2; meshes.mesh[nmesh].rectangles[i].y2:=y2;meshes.mesh[nmesh].rectangles[i].z2:=z2;
             meshes.mesh[nmesh].rectangles[i].x3:=x3; meshes.mesh[nmesh].rectangles[i].y3:=y3;meshes.mesh[nmesh].rectangles[i].z3:=z3;
             meshes.mesh[nmesh].rectangles[i].x4:=x4; meshes.mesh[nmesh].rectangles[i].y4:=y4;meshes.mesh[nmesh].rectangles[i].z4:=z4;
             meshes.mesh[nmesh].rectangles[i].texture:=texture;
             meshes.mesh[nmesh].rectangles[i].color:=color;
             meshes.mesh[nmesh].rectangles[i].color_texture:=color_texture;
             meshes.mesh[nmesh].rectangles[i].light:=light;
             meshes.mesh[nmesh].rectangles[i].enabled:=menabled;
             //actualizar la lista para ordenarlo por textura.
             meshes.mesh[nmesh].rectan_list.add(IntToStr(texture)+'='+IntToStr(i));
             //calcular minimo y maximo
             if min.x>x1 then min.x:=x1;
             if min.y>y1 then min.y:=y1;
             if min.z>z1 then min.z:=z1;
             if min.x>x2 then min.x:=x2;
             if min.y>y2 then min.y:=y2;
             if min.z>z2 then min.z:=z2;
             if min.x>x3 then min.x:=x3;
             if min.y>y3 then min.y:=y3;
             if min.z>z3 then min.z:=z3;
             if min.x>x4 then min.x:=x4;
             if min.y>y4 then min.y:=y4;
             if min.z>z4 then min.z:=z4;
           //-----
             if max.x<x1 then max.x:=x1;
             if max.y<y1 then max.y:=y1;
             if max.z<z1 then max.z:=z1;
             if max.x<x2 then max.x:=x2;
             if max.y<y2 then max.y:=y2;
             if max.z<z2 then max.z:=z2;
             if max.x<x3 then max.x:=x3;
             if max.y<y3 then max.y:=y3;
             if max.z<z3 then max.z:=z3;
             if max.x<x4 then max.x:=x4;
             if max.y<y4 then max.y:=y4;
             if max.z<z4 then max.z:=z4;
             //ordenar las listas
             meshes.mesh[nmesh].rectan_list.sort;
             add_face:=meshes.mesh[nmesh].num_rectangles;
       end //si no mas de 4000 rectangles.
       else add_face:=-1;

end;
//------------

function tscene.center:glfloat;
var
despx,despy,despz:glfloat;
begin
    despx:=(min.x+(max.x-min.x)/2)*-1;
    despy:=(min.y+(max.y-min.y)/2)*-1;
    despz:=(min.z+(max.z-min.z)/2)*-1;

    translation.x:=despx;
    translation.y:=despy;
    translation.z:=despz;
    center:=0;
end;
//-----------------

procedure tscene.DoRender;
var
k:integer;
begin
  for k:=1 to meshes.num_meshes do //inicio bucle de todos los meshes
  begin
      if meshes.mesh[k].enabled then //render si este mesh es enabled
      begin
           case meshes.mesh[k].render_tipo of
                rtwireframe:begin render_wireframe(k);end; //wireframe
                rtshaded:begin render_shade(k);end; //shade.
                rtsolid:begin render_solid(k);end; //solid one texture
                rttextured:begin render_textured(k);end; //multi-textured;
           end; //endcase
      end; //fin si mesh enabled
  end;//fin del los meshes
end;
//--------------------
procedure tscene.Render_wireframe(nmesh:integer);
var
k:integer;
x,y,z:glfloat;
color:tcolor;
begin
  //adecuar a Opengl las cordenadas del origen.
  x:=meshes.mesh[nmesh].x;
  y:=meshes.mesh[nmesh].y*-1;
  z:=meshes.mesh[nmesh].z*-1;

  //---AQUI ADECUAR LOS ESTADOS DE ESTE MESH
   GlPolygonMode(GL_FRONT_AND_BACK,GL_line);
   GLdisable(gl_texture_2d);
   glshademodel(gl_flat);

  //-----------
  //draw rectangles
  for k:=1 to meshes.mesh[nmesh].num_rectangles do
  begin
     //draw the rectangle
   if meshes.mesh[nmesh].rectangles[k].enabled then   //si esta cara esta enabled
   begin
    //seleccionar el color de este face.
        color:=meshes.mesh[nmesh].rectangles[k].color;
        if force_color and (nmesh=current) then color:=default_color;
        glcolor3f(twcolor(color).r, twcolor(color).g, twcolor(color).b);

     Glloadname(k);
     if (meshes.mesh[nmesh].rectangles[k].x4=meshes.mesh[nmesh].rectangles[k].x3) and
        (meshes.mesh[nmesh].rectangles[k].y4=meshes.mesh[nmesh].rectangles[k].y3) and
        (meshes.mesh[nmesh].rectangles[k].z4=meshes.mesh[nmesh].rectangles[k].z3) then
     begin
       glBegin(GL_triangles);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x1+x, meshes.mesh[nmesh].rectangles[k].y1+y, meshes.mesh[nmesh].rectangles[k].z1+z);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x2+x, meshes.mesh[nmesh].rectangles[k].y2+y, meshes.mesh[nmesh].rectangles[k].z2+z);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x3+x, meshes.mesh[nmesh].rectangles[k].y3+y, meshes.mesh[nmesh].rectangles[k].z3+z);
        glEnd;
      end
     else
     begin
       glBegin(GL_quads);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x1+x, meshes.mesh[nmesh].rectangles[k].y1+y, meshes.mesh[nmesh].rectangles[k].z1+z);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x2+x, meshes.mesh[nmesh].rectangles[k].y2+y, meshes.mesh[nmesh].rectangles[k].z2+z);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x3+x, meshes.mesh[nmesh].rectangles[k].y3+y, meshes.mesh[nmesh].rectangles[k].z3+z);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x4+x, meshes.mesh[nmesh].rectangles[k].y4+y, meshes.mesh[nmesh].rectangles[k].z4+z);
        glEnd;
     end;
   end;//end si face enabled
   end;//end for

end;
//------------------------
procedure tscene.Render_shade(nmesh:integer);
var
k:integer;
x,y,z:glfloat;
color:tcolor;
x1,y1,z1:glfloat;
begin
  //adecuar a Opengl las cordenadas del origen.
  x:=meshes.mesh[nmesh].x;
  y:=meshes.mesh[nmesh].y*-1;
  z:=meshes.mesh[nmesh].z;

   GlPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
   GLdisable(gl_texture_2d);
   glshademodel(gl_smooth);
   glenable(gl_light0);
   glenable(gl_lighting);
   gllightf(0,gl_diffuse,clwhite);
   glenable(gl_normalize);

  //-------
 //draw the rectangle
  for k:=1 to meshes.mesh[nmesh].num_rectangles do
  begin
   if meshes.mesh[nmesh].rectangles[k].enabled then   //si esta cara esta enabled
   begin
    //seleccionar el color de este face.
        color:=meshes.mesh[nmesh].rectangles[k].color;
        if force_color and (nmesh=current) then color:=default_color;
     glcolor3f(twcolor(color).r, twcolor(color).g, twcolor(color).b);

    if (meshes.mesh[nmesh].rectangles[k].x1+x)<(meshes.mesh[nmesh].rectangles[k].x2+x)
        then x1:=1 else x1:=-1;

    if (meshes.mesh[nmesh].rectangles[k].y1+y)<(meshes.mesh[nmesh].rectangles[k].y2+y)
        then y1:=1 else y1:=0;

     if (meshes.mesh[nmesh].rectangles[k].z1+z)<(meshes.mesh[nmesh].rectangles[k].z2+z)
         then z1:=1 else z1:=0;

     GlLoadname(k);
     glBegin(GL_quads);
            glnormal3f(x1,y1,z1);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x1+x, meshes.mesh[nmesh].rectangles[k].y1+y, meshes.mesh[nmesh].rectangles[k].z1+z);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x2+x, meshes.mesh[nmesh].rectangles[k].y2+y, meshes.mesh[nmesh].rectangles[k].z2+z);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x3+x, meshes.mesh[nmesh].rectangles[k].y3+y, meshes.mesh[nmesh].rectangles[k].z3+z);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x4+x, meshes.mesh[nmesh].rectangles[k].y4+y, meshes.mesh[nmesh].rectangles[k].z4+z);

     glEnd;

   end;//end si face enabled
   end;//end for

end;

//------------------
procedure tscene.Render_solid(nmesh:integer);
var
k:integer;
x,y,z:glfloat;
begin
  //adecuar a Opengl las cordenadas del origen.
  x:=meshes.mesh[nmesh].x;
  y:=meshes.mesh[nmesh].y*-1;
  z:=meshes.mesh[nmesh].z;
  //-------------
   GlPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
   GLenable(gl_texture_2d);
   glshademodel(gl_flat);
  //------------
 glbindtexture(gl_texture_2d, meshes.mesh[nmesh].solid_bitmap);
 //draw the rectangle
  for k:=1 to meshes.mesh[nmesh].num_rectangles do
  begin
   if meshes.mesh[nmesh].rectangles[k].enabled then   //si esta cara esta enabled
   begin
     GlLoadname(k);
     glBegin(GL_quads);
            gltexcoord2f(0,0);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x1+x, meshes.mesh[nmesh].rectangles[k].y1+y, meshes.mesh[nmesh].rectangles[k].z1+z);

            gltexcoord2f(1,0);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x2+x, meshes.mesh[nmesh].rectangles[k].y2+y, meshes.mesh[nmesh].rectangles[k].z2+z);

            gltexcoord2f(1,1);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x3+x, meshes.mesh[nmesh].rectangles[k].y3+y, meshes.mesh[nmesh].rectangles[k].z3+z);

            gltexcoord2f(0,1);
            glVertex3f(meshes.mesh[nmesh].rectangles[k].x4+x, meshes.mesh[nmesh].rectangles[k].y4+y, meshes.mesh[nmesh].rectangles[k].z4+z);
     glEnd;

   end;//end si face enabled
   end;//end for

end;

//---------------------------
procedure tscene.Render_textured(nmesh:integer);
var
k:integer;
i,ntexture,cur_texture:integer;
xpos:integer;
nt:integer;
x,y,z:glfloat;
color:tcolor;
begin
  x:=meshes.mesh[nmesh].x;
  y:=meshes.mesh[nmesh].y*-1;
  z:=meshes.mesh[nmesh].z;

   GlPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
   GLenable(gl_texture_2d);
   glshademodel(gl_smooth);

   //si automatic texture
  // glenable(gl_texture_gen_s);
  // glenable(gl_texture_gen_t);


  //draw rectangles
  cur_texture:=-1;
  i:=0;
  for k:=1 to meshes.mesh[nmesh].num_rectangles do
  begin
     //averiguar que rectangulo sigue en la lista ordenada de rectangulos.
      xpos:=pos('=',meshes.mesh[nmesh].rectan_list.strings[k-1]);
      ntexture:=strToint(copy(meshes.mesh[nmesh].rectan_list.strings[k-1],1,xpos-1));
      i:=strToint(copy(meshes.mesh[nmesh].rectan_list.strings[k-1],xpos+1,100));
     ntexture:=meshes.mesh[nmesh].rectangles[i].texture;
     if cur_texture<>ntexture then
     begin
         glbindtexture(gl_texture_2d,ntexture);
         cur_texture:=ntexture;
     end; //si necesario cambiar textura


     //draw the rectangle
   if meshes.mesh[nmesh].rectangles[i].enabled then   //si esta cara esta enabled
   begin
    //seleccionar el color de este face.
      color:=meshes.mesh[nmesh].rectangles[k].color_texture;
      if force_color and (nmesh=current) then color:=default_color;
      glcolor3f(twcolor(color).r, twcolor(color).g, twcolor(color).b);

     GlLoadname(i);
     glBegin(GL_quads);
            gltexcoord2f(0,0);
            glVertex3f(meshes.mesh[nmesh].rectangles[i].x1+x, meshes.mesh[nmesh].rectangles[i].y1+y, meshes.mesh[nmesh].rectangles[i].z1+z);

            gltexcoord2f(1,0);
            glVertex3f(meshes.mesh[nmesh].rectangles[i].x2+x, meshes.mesh[nmesh].rectangles[i].y2+y, meshes.mesh[nmesh].rectangles[i].z2+z);

            gltexcoord2f(1,1);
            glVertex3f(meshes.mesh[nmesh].rectangles[i].x3+x, meshes.mesh[nmesh].rectangles[i].y3+y, meshes.mesh[nmesh].rectangles[i].z3+z);

            gltexcoord2f(0,1);
            glVertex3f(meshes.mesh[nmesh].rectangles[i].x4+x, meshes.mesh[nmesh].rectangles[i].y4+y, meshes.mesh[nmesh].rectangles[i].z4+z);
     glEnd;

   end;//end si face enabled
   end;// end for

end;

//*********************************-------------



procedure tscene.rectan_Change_texture(nmesh:integer; index:integer; textura:word;k:integer=1);
var
oldtext:word;
s:string;
i:integer;
t:integer;
begin
   if (index>0) and (index<=meshes.mesh[nmesh].num_rectangles) then
   begin
   for t:=1 to k do
   begin
       oldtext:=meshes.mesh[nmesh].rectangles[index].texture;
       meshes.mesh[nmesh].rectangles[index].texture:=textura;
       s:=IntToStr(oldtext)+'='+IntToStr(index);
       i:=meshes.mesh[nmesh].rectan_list.IndexOf(S);
       meshes.mesh[nmesh].rectan_list.strings[i]:=IntToStr(textura)+'='+IntToStr(index);
       meshes.mesh[nmesh].rectan_list.sort;
       index:=index+1;
       if index>meshes.mesh[nmesh].num_rectangles then break;
   end;
   end;

end;
//------------------------------
//.............................
//make surface hace planos horinzontales y verticales
//use con sx<>0, sy<>0, sz=0  para hacer planos verticales (walls)
//use con sx<>0, sy=0, sz<>0  para hacer planos horizontales (floors)
//use con sx=0, sy<>0, sz<>0  para hacer planos verticales (walls hacia el horizonte)
//use normal=false para cambiar la orientacion del plano.

procedure tscene.make_surface(nmesh:integer; ancho,alto:byte; sx,sy,sz:real; x,y,z:real; normal:boolean=true);
var
m,n:integer;
x1,y1,z1:real;

begin

    x1:=x;
    z1:=z;

    for n:=1 to ancho do
    begin
        y1:=y;
        if sx<>0 then z1:=z;
        for m:=1 to alto do
        begin
          if normal then
          begin
              if sx<>0 then add_face(nmesh,x1,y1-sy,z1+sz,   x1+sx,y1-sy,z1+sz, x1+sx,y1,z1,  x1,y1,z1, 1,1,1,1)
              else          add_face(nmesh,x1,y1-sy,z1,   x1,y1-sy,z1+sz, x1,y1,z1+sz, x1,y1,z1, 1,1,1,1);
          end
          else //si no normal
          begin
              if sx<>0 then add_face(nmesh, x1+sx,y1-sy,z1+sz,  x1,y1-sy,z1+sz,   x1,y1,z1,  x1+sx,y1,z1,   1,1,1,1)

              else          add_face(nmesh,x1,y1-sy,z1+sz,  x1,y1-sy,z1,      x1,y1,z1,  x1,y1,z1+sz,  1,1,1,1);
          end;


           y1:=y1-sy;
           if sx<>0 then z1:=z1+sz;
        end;
        x1:=x1+sx;
        if sx=0 then z1:=z1+sz;
    end; {end wall)}
end;
//......................

procedure tscene.make_cube(ancho_cube,alto_cube,largo_cube,size:real; x,y,z:real);
begin

end;

//los valores deben ser en enteros.
Function Opgl_find_intersect(ax1,ay1,ax2,ay2, bx1,by1,bx2,by2 :glfloat; var xi:glfloat; var yi:glfloat):boolean;
var
m,n:integer;
astepx,astepy:glfloat;
bstepx,bstepy:glfloat;
astep,bstep:integer;
x,y:glfloat;

begin
   result:=false;
   //--linea a--
   astepx:=ax2-ax1+1;
   astepy:=ay2-ay1+1;
   astep:=trunc(max(astepx,astepy));
   astepx:=astepx/astep;
   astepy:=astepy/astep;

   //--linea b--
   bstepx:=bx2-bx1;
   bstepy:=by2-by1;
   bstep:=trunc(max(bstepx,bstepy));
   bstepx:=bstepx/bstep;
   bstepy:=bstepy/bstep;

   x:=bx1;y:=by1;

   for m:=1 to astep do
   begin
       bx1:=x;by1:=y;
       for n:=1 to bstep do
       begin
          if (int(ax1)=int(bx1)) and (int(ay1)=int(by1)) then begin result:=true;break;end;
          bx1:=bx1+bstepx;by1:=by1+bstepy;
       end;//fin leer todos los puntos linea B
       if result then break;
       ax1:=ax1+astepx;ay1:=ay1+astepy;
   end;//fin leer todos los puntos de la linea A.

if result then begin xi:=bx1;yi:=by1;end;

end;


//---------------------------------

Procedure Push_RC;
begin
    exit;
    inc(stack_rc.count);
    if stack_rc.count>99 then stack_rc.count:=1;
    stack_rc.r[stack_rc.count].dc:=wglGetCurrentDc;
    stack_rc.r[stack_rc.count].rc:=wglGetCurrentContext;
end;

Procedure Pop_RC;
var
dc:hdc;
rc:hglrc;
begin
    exit;
    if stack_rc.count=0 then exit;
    dc:=stack_rc.r[stack_rc.count].dc;
    rc:=stack_rc.r[stack_rc.count].rc;
    wglmakecurrent(dc,rc);
    dec(stack_rc.count);
end;


procedure set_perspective_correct(enabled:boolean);
begin
    //perspective correct None
    if enabled then
    begin
      gltexparameteri(gl_texture_2d,gl_texture_mag_filter,gl_linear); //use gl_linear for perspective correct.
      gltexparameteri(gl_texture_2d,gl_texture_min_filter,gl_linear);
    end
    else
    begin
       gltexparameteri(gl_texture_2d,gl_texture_mag_filter,gl_nearest); //use gl_linear for perspective correct.
       gltexparameteri(gl_texture_2d,gl_texture_min_filter,gl_nearest);
    end;

end;

procedure tglviewport.manual_zoom(x,y,z:glfloat);
begin

     scale.x:=scale.x+x;
     scale.y:=scale.y+y;
     scale.z:=scale.z+z;

     if scale.x<0 then scale.x:=0;
     if scale.y<0 then scale.y:=0;
     if scale.z<0 then scale.z:=0;

     lzx:=scale.x;
     lzy:=scale.y;
     lzz:=scale.z;
end;


procedure tglviewport.manual_rotate(x,y,z:glfloat);
begin
     rotation.x:=rotation.x+x;
     rotation.y:=rotation.y+y;
     rotation.z:=rotation.z+z;

     if rotation.x<0 then rotation.x:=360;
     if rotation.y<0 then rotation.y:=360;
     if rotation.z<0 then rotation.z:=360;

     if rotation.x>360 then rotation.x:=0;
     if rotation.y>360 then rotation.y:=0;
     if rotation.z>360 then rotation.z:=0;


     //last rotated
     lrx:=Rotation.x;
     lry:=Rotation.y;

end;



initialization
opengl_ok:=false;
stack_rc.count:=0;
display_list_count:=0;
//opengl_ok:=initopengl;
finalization
CloseOpengl;

end.

