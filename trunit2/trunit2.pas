// MAIN TOMB RAIDER UNIT INTERFACE, VERSION 31-10-2002.


{$A-}
unit trunit2;
interface
uses geometry,windows,graphics,sysutils,classes,fexgraph,zfiles,zlib,stdctrls,comctrls,gauges,dialogs,memlist,opengl12,fexopgl,math,xopengl;
const
xstep = 1024;
ystep = 1024;
zstep = 1024;

f_front  =  1;
f_back   =  2;
f_left   =  4;
f_right  =  8;
f_top    = 16;
f_bottom = 32;

//---Version de los niveles.

vTR1 = 1; //phd
vTub = 2; //tub
vTr2 = 3; //normal tr2
vTrg = 4; //tr2 gold (not implemented)
VTr3 = 5; //Tr3
Vtr4 = 6; //Tr4
VTr5 = 7; //TRc.

max_mesh_vertices = 5000;
max_mesh_polys = 5000;

type tword = record
      byte1,byte2:byte;
end;

type TLongWord = record
     word1:word;
     word2:word;
end;

{*****************************************}
{        ESTRUCTURAS EN EL PHD             }
{*****************************************}
{room info}
type troom_info = record
     xpos_room,
     zpos_room:longint;
     ymin,ymax   : longint;
     num_words: longint;
end;


 {Vertice}
type
  tvertice = record
      x,y,z:smallint;
      light0,light:byte;
  end;

type
  tvertice2 = record
      x,y,z:smallint;
      light0,light:byte;
      attrib:word;
      light2:word;
  end;

  tvertice3 = record
      x,y,z:single;
      nx,ny,nz:single;
      b,g,r,a:byte;
  end;


  {poly4}
  tquad = record
        p1,p2,p3,p4,texture:word;
  end;

  //tr5 rectangles
  tquad2 = record
        p1,p2,p3,p4,texture,unk:word;
  end;


  {triangles}
  ttriangle = record
              p1,p2,p3,texture:word;
  end;

  //tr5 triangles
  ttriangle2 = record
              p1,p2,p3,texture,unk:word;
  end;

//tr5 layers5
  tlayers = record
            num_vertices:longint;
            unknownl1:word;
            num_rectangles:word;
            num_triangles:word;
            //-----
             unknownl2:word;
             filler2:integer;
             x1,y1,z1,x2,y2,z2:single;
             filler3:longint;
             unknownl3,unknownl4,unknownl5:integer;
            //----
   end;


  {sprites?}
  tsprite = record
       x,y:word;
  end;

  {doors}
  tdoor = record
          room,x_type,y_type,z_type,
          x1,y1,z1,
          x2,y2,z2,
          x3,y3,z3,
          x4,y4,z4:smallint;
  end;

  {Each tile floor}

  tsector = record
          floor_index    :word;
          box_index      :smallint;
          room_below     :byte;
          floor_height   :shortint;
          room_above     :byte;
          ceiling_height :shortint;
  end;

  {Sources lights}
  tsource_light = record
          x,y,z:longint;
          intensity1:word;
          fadea:word;
          fadeb:word;
   end;

  tsource_light2 = record
          x,y,z:longint;
          Intensity1:word;
          Intensity2:word;
          FadeA:word;
          Fadeb:word;
          Fadec:word;
          Faded:word;
  end;

  tsource_light3 = record
          x,y,z:integer;
          r,g,b:byte;
          light_type:byte;
          dumy:byte;
          intensity:byte;
          light_in:single;
          light_out:single;
          len:single;
          cutoff:single;
          dx,dy,dz:single;
  end;


  tsource_light4 = record
          x,y,z:single;
          r,g,b:single;
          dumy:longint;
          light_in:single;
          light_out:single;
          light_rin:single;
          light_rout:single;
          len:single; //48
          dx,dy,dz:single; //60
          x2,y2,z2:integer; //72
          dx2,dy2,dz2:integer;//84
          light_type:byte;//85
          dumy2: array [0..2] of byte; // 88 bytes record length.
  end;


  {Static Objects}
  tStatic = record
          x,y,z:longint;
          angle,
          Light1,
          obj:word;
  end;


  tStatic2 = record
          x,y,z:longint;
          angle,
          Light1,light2,
          obj:word;
  end;


   {floor data}
   tfloor_data = record
                 data1:byte;
                 data2:byte;
   end;

   {meshwords}
   tmeshwords = array [0..17999] of word;

   {meshpointers}
   tmeshpointers = array [0..8999] of longint;


   {anims 32bytes}
   tanims = record
           frameoffset:integer;
           framerate:byte;
           framesize:byte;
           stateid:word;
           u2,u3,u4,u5:word;
           framestart,frameend,NextAnimation,nextframe,
           numstatechanges,statechange,numanimcom,animcom:word;
   end;

   tanims2 = record
           u: array[1..40] of byte;
   end;


   {Structures}
   tStruct = record
           stateid:word;
           numanimdispatch:word;
           animdispatch:word;
   end;

   {ranges}
   tRange  = record
           u: array[1..8] of byte;
   end;

   {Bones1}
   Tbone1  = record
           u: WORD;
   end;

   {Bones2}
   Tbone2  = record
           u1: WORD;
           u2: WORD;
   end;

   {Frames}
   Tframe = record
           u: WORD;
   end;

   {Movable}
   TMovable = record
           objectId:cardinal;
           nummeshes:word;
           startmesh:word;
           meshtree:cardinal;
           frameoffset:cardinal;
           animation:word;
   end;

   TMovable2 = record //for tr5 levels
           objectId:cardinal;
           nummeshes:word;
           startmesh:word;
           meshtree:cardinal;
           frameoffset:cardinal;
           animation:word;
           unknown:word;
   end;



   {tipo desconocido1}
   tstatic_table = record
          Idobj :longint;
          mesh        : word;          
          vx1,vx2,vy1 : smallint;
          vy2,vz1,vz2 : smallint;

          cx1,cx2,cy1 : smallint;
          cy2,cz1,cz2 : smallint;
          flag        : word;
   end;

   {Object textures}
   tobjtexture = record
               attrib,
               tile:word;
               mx1,x1,my1,y1,
               mx2,x2,my2,y2,
               mx3,x3,my3,y3,
               mx4,x4,my4,y4:byte;
    end;


   tobjtexture2 = record
               attrib,
               tile:word;
               flags:word; //only tr4 & tr5
               mx1,x1,my1,y1,
               mx2,x2,my2,y2,
               mx3,x3,my3,y3,
               mx4,x4,my4,y4:byte;
               uk1,uk2,uk3,uk4:longint;
               uk5:word;
    end;

   {sprite textures}
   tsprite_texture = record
             u: array[1..16] of byte;
   end;

   {tipo desconocido2}
   tunknow2 = record
           u: array[1..8] of byte;
   end;

   {cameras}
   Tcamera = record
          x,y,z:integer;
          room:word;
          unknown:word;
   end;

   ttr4_unknow1 = record
              u: array[1..40] of byte
   end;

   {sound fx}
   Tsoundfx = record
            x,y,z:integer;
            soundid:word;
            flag:word;
   end;

  {boxes}
   Tbox = record
         zmin,zmax,
         xmin,xmax:longint;
         floory:smallint;
         overlap_index:word;
   end;

   Tbox2 = record
         zmin,zmax,
         xmin,xmax:byte;
         floory:smallint;
         overlap_index:word;
   end;


  {overlaps}
   tOverlap = record
        u: array[1..2] of byte;
   end;

  {zonas}
   Tzone = record
          nground_zone1,
          nground_zone2,
          nfly_zone,
          aground_zone1,
          aground_zone2,
          afly_zone:smallint;
   end;

   Tzone2 = record
          nground_zone1,
          nground_zone2,
          nground_zone3,
          nground_zone4,
          nfly_zone,
          aground_zone1,
          aground_zone2,
          aground_zone3,
          aground_zone4,
          afly_zone:smallint;
   end;


   {tipo animate texture}
   Tanimtexture = record
           u: array[1..2] of byte;
   end;

   {Items}
   tItem = record
           obj,
           room:word;
           x,y,z:longint;
           d    :byte;
           angle:byte;
           light1:byte;
           light2:byte;
           un1:word;
   end;

   tItem2 = record
           obj,
           room:word;
           x,y,z:longint;
           d    :byte;
           angle:byte;
           light1:word;
           light2:word;
           un1:word;
   end;


   {Colormaps}
   tcolormap = record
             u: array [1..8192] of byte;
   end;


    {paleta entry}
    tpalette_entry = record
                   r,g,b:byte;
     end;
    {palette}
     Ttrpalette = array [0..255] of tpalette_entry;


   {tipo desconocido3}
   tunknow3= record
           u: array[1..16] of byte;
   end;

  tAI_Table = record
           obj,
           room:word;
           x,y,z:longint;
           OCB  :smallint;
           flag :word;
           angle:integer;
   end;


   {tipo desconocido4}
   tunknow4 = array[1..16000] of byte;

   {desconocido 5}
   tunknow5 = array[1..512] of byte;


   {samples info}
   tSample_info = record
               Sample,
               Volume,
               d1,
               d2:Word;
    end;

    {samples}
    tsamples = record
               samples_size:longint;
               buffer      :pointer;
    end;

    {Samples offsets}
    Tsamples_offsets = record
                      num_offsets :longint;
                      offset : array[1..255] of longint;
    end;


tvertice_list = record
                num_vertices:word;
                vertice : array [1..10000] of tvertice;
                vertice2: array [1..10000] of tvertice2;
                vertice3: array [1..10000] of tvertice3;
end;


Tquad_list = record
              num_quads  : word;
              quad       : array[1..10000] of tquad;
              quad2      : array[1..10000] of tquad2;
end;

ttriangle_list = record
               num_triangles  :Word;
               Triangle       :array[1..10000] of Ttriangle;
               Triangle2      :array[1..10000] of Ttriangle2;
end;

//****************************

tvertice_list2 = record
                num_vertices:word;
                vertice3: array [1..10000] of tvertice3;
end;


Tquad_list2 = record
              num_quads  : word;
              quad2      : array[1..10000] of tquad2;
end;

ttriangle_list2 = record
               num_triangles  :Word;
               Triangle2      :array[1..10000] of Ttriangle2;
end;

{****************************}

tsector_list = record
             largo,ancho:word;
             sector       : array[1..1024] of Tsector;
end;

tsprite_list = record
               num_sprites:word;
               sprite     : array[1..50] of tsprite;
end;

tdoor_list = record
             num_doors:word;
             door       : array[1..20] of tdoor;
end;

tsource_light_list = record
                     num_sources:word;
                     source_light : array [1..50] of tsource_light;
                     source_light2 : array [1..50] of tsource_light2;
                     source_light3 : array [1..50] of tsource_light3;
                     source_light4 : array [1..50] of tsource_light4;

end;

Tstatic_list = record
               num_static:word;
               static    : array[1..300] of tstatic;
               static2    : array[1..300] of tstatic2;

end;

{****************************}
unk8 = record
       case integer of
        0: (data : array [1..36] of byte);
        1: (x,y,z : single;
           Int,_in,_out : single;//still unsure about these
           r,g,b : single;);
end;

unk5 = record
       case integer of
        0: (data : array[1..16] of Byte);
        1: (u1,u2 : Word;
            roomx,roomy,roomz:Single;);
        //2: (u1u2:UInt32; b,c,d : Single;);
end;

tTr5unk8 = record
          num_unk8 : longint;
          data : array [0..20] of unk8;
end;

   ttr5_layers = record
           Num_layers:integer;
           vertices: array of tvertice_list2;
           quads:    array of tquad_list2;
           triangles: array of ttriangle_list2;
    end;

ttr5_unknowns = record
              chunk_size:longint; //next xela
              ublock1,ublock2,ublock3,ublock4:longint;
              unknown1:longint;
              room_color:longint;
              unknown2,unknown3,unknown4:longint;
              unknown5:unk5;//array[1..16] of byte;
              unknown6:longint;
              total_triangles,total_rectangles:longword;
              unknown7:longint;
              lightsize,numberlights:longint;
              unknown9,unknown10,unknown11,unknown12,
              unknown13,unknown14,unknown15:longint;
end;


troom      = record
             room_info    :     troom_info;
             num_layers   :     longint;
             layers       :     array of tlayers;
             tr5_layers   :     ttr5_layers;
             vertices     :     tvertice_list;
             quads        :     tquad_list;
             triangles    :     Ttriangle_list;
             sprites      :     tsprite_list;
             tr5unk8      :     ttr5unk8;
             tr5_unknowns :     ttr5_unknowns;
             tr5_numpads  :     longint; //padded bytes before next room
             doors        :     Tdoor_list;
             sectors      :     Tsector_list;
             d0,Lara_light:     byte;
             sand_effect  :     word; //in tr4 d0=b, lara_ligh=g, hi(ligh_mode):=b.
             light_mode   :     word;
             Source_lights:     tsource_light_list;
             Statics      :     tstatic_list;
             alternate    :     word;
             water        :     byte;
             d2           :     byte;
             room_color   :     longword;
             water_scheme :     word; //tr3 and tr4 underwater scheme
             room_group   :     byte; //group used by alternates rooms.

             tr5_flag     :     word;

end;

trooms_list = record
         num_rooms   :    word;
         room        :    array[1..200] of troom; //para tomb2 y tomb3 se ocupan mas cuartos.
end;


tfloor_data_list = record
               num_floor_data:longint;
               floor_data : array[0..20000] of tfloor_data;
end;


tmeshwords_list = record
               num_meshwords:longint;
               meshword  :array[1..112000] of word;
end;

tmeshpointers_list = record
               num_meshpointers:longint;
              meshpointer :array[1..1500] of longint;
end;

tanims_list = record
               num_anims :longint;
               anim :array[1..1100] of tanims;
end;

tstructs_list = record
               num_struct :longint;
               struct :array[1..1100] of tstruct;
end;


tranges_list = record
               num_ranges :longint;
               range :array[1..1000] of trange;
end;

tBones1_list = record
               Num_bones1 :longint;
               Bone1 :array[1..4000] of word;
end;

tBones2_list = record
               Num_bones2 :longint;
               Bone2 :array[1..4000] of longint;
end;

tframes_list = record
               Num_frames :longint;
               frame :array[1..233000] of word;
end;


tmovables_list = record
               Num_movables :longint;
               movable :array[1..300] of tmovable;
end;

tstatic_table_list = record
               Num_static :longint;
               static :array[1..250] of tstatic_table;
end;

tobj_textures_list = record
               Num_textures :longint;
               texture :array[1..3100] of tobjtexture;
end;

tspr_textures_list = record
               Num_spr_textures :longint;
               spr_texture :array[1..2000] of tsprite_texture;
end;


tdes2_list = record
               Num_des2 :longint;
               des2 :array[1..250] of tunknow2;
end;


tcameras_list = record
               Num_cameras :longint;
               camera :array[1..100] of tcamera;
end;

tsound_fxs_list = record
               Num_sound_fxs :longint;
               sound_fx :array[1..200] of tsoundfx;
end;


tboxes_list = record
               Num_boxes :longint;
               box :array[1..5000] of tbox;
               box2:array[1..5000] of tbox2;

end;

toverlaps_list = record
               Num_overlaps :longint;
               overlap :array[1..15000] of word;
end;


tzones_list = record
               Num_zones :longint;
               nground_zone1:array[1..5000] of word;
               nground_zone2:array[1..5000] of word;
               nground_zone3:array[1..5000] of word;
               nground_zone4:array[1..5000] of word;
               nfly_zone    :array[1..5000] of word;
               //--------------------
               aground_zone1:array[1..5000] of word;
               aground_zone2:array[1..5000] of word;
               aground_zone3:array[1..5000] of word;
               aground_zone4:array[1..5000] of word;
               afly_zone    :array[1..5000] of word;
end;

tanim_textures_list = record
               Num_anim_textures :longint;
               anim_texture :array[1..200] of word; //tanimtexture;
end;


titems_list = record
              Num_items :longint;
              item :array[1..300] of titem;
              item2 :array[1..300] of titem2;
end;


tdes3_list = record
               Num_des3 :word;
               des3 :array[1..90] of tunknow3;
end;

tdes4_list = record
               Num_des4 :word;
               des4 :array[1..16000] of byte;
end;


tsamples_info_list = record
               Num_samples_info :longint;
               sample_info :array[1..200] of tsample_info;
end;


{ Estructura principal donde se cargara todo el pdh}

TPhd = record
          valido               :string[7];
          Version              :cardinal; {version}
          tipo                 :integer;
          Size_Textures        :longint; {tama¤o texturas}
          Num_Texture_pages    :longint; {numero de paginas texturas}
          texture_data         :pointer;
          texture_data2        :pointer;
          dumys                : array[1..6] of byte;
          rooms                :trooms_list;
          floor_data           :tfloor_data_list; {floor data}
          meshwords            :tmeshwords_list; {meshwords }
          Meshpointers         :tmeshpointers_list; {meshpointers}
          Anims                :tanims_list; {anim}
          Structs              :tstructs_list; {struct}
          Ranges               :tranges_list; {range}
          Bones1               :tbones1_list; {bones1}
          Bones2               :tbones2_list; {bones2}
          Frames               :tframes_list; {Frames}
          Movables             :tmovables_list; {Movables}
          Static_table         :tstatic_table_list; {statics objects table}
          Textures             :tobj_textures_list; {Object Textures}
          Spr_Textures         :tspr_textures_list; {Sprite Textures}
          Desconocido2         :tdes2_list; {desconocido2}
          Cameras              :tcameras_list; {Camara}
          Sound_fxs            :tsound_fxs_list; {soundfx}
          boxes                :tboxes_list; {Boxes}
          Overlaps             :toverlaps_list; {Overlaps}
          zones                :tzones_list; {zonas}
          Anim_textures        :tanim_textures_list; {texturas animadas}
          Items                :titems_list; {Itemss!}
          Colormap             :tcolormap; {colormaps}
          Palette              :ttrpalette; {paleta}
          palette16            : array [0..1023] of byte;
          Desconocido3         :tdes3_list; {desconocido3}
          Desconocido4         :tdes4_list; {desconocido4}
          sound_map            :array[1..900] of byte; {512 bytes para tr1, 740 para tr2-tr4, 900 para tr5.}
          samples_info         :tsamples_info_list; {samples info}
          samples              :tsamples; {samples data}
          samples_offsets      :tsamples_offsets; {tabla samples}
end;

//nuevo objecto para manejar trlevels

Ttrlevel = class(tobject)
  private
          fnum_rooms:word;
          fnum_floor_data:longint;
          fnum_meshwords:longint;
          fnum_Meshpointers:longint;
          fnum_Anims:longint;
          fnum_Structs:longint;
          fnum_Ranges:longint;
          fnum_Bones1:longint;
          fnum_Bones2:longint;
          fnum_Frames:longint;
          fnum_Movables:longint;
          fnum_Static_table:longint;
          fnum_Textures:longint;
          fnum_Spr_Textures:longint;
          fnum_spr_sequences:longint;
          fnum_Cameras:longint;
          fnum_tr4_unknow1:longint;
          fnum_Sound_fxs:longint;
          fnum_boxes:longint;
          fnum_overlaps:longint;
          fnum_zones:longint;
          fnum_Anim_textures:longint;
          fnum_Items:longint;
          fnum_cinematic_frames:longint;
          fnum_demo_data:longint;
          fnum_samples_info:longint;
          fnum_samples_offsets:longint;
       //--procedures para ponerle valores
          procedure pnum_rooms(k:word);
          procedure pnum_floor_data(k:longint);
          procedure pnum_meshwords(k:longint);
          procedure pnum_Meshpointers(k:longint);
          procedure pnum_Anims(k:longint);
          procedure pnum_Structs(k:longint);
          procedure pnum_Ranges(k:longint);
          procedure pnum_Bones1(k:longint);
          procedure pnum_Bones2(k:longint);
          procedure pnum_Frames(k:longint);
          procedure pnum_Movables(k:longint);
          procedure pnum_Static_table(k:longint);
          procedure pnum_Textures(k:longint);
          procedure pnum_Spr_Textures(k:longint);
          procedure pnum_spr_sequences(k:longint);
          procedure pnum_Cameras(k:longint);
          procedure pnum_tr4_unknow1(k:longint);
          procedure pnum_Sound_fxs(k:longint);
          procedure pnum_boxes(k:longint);
          procedure pnum_overlaps(k:longint);
          procedure pnum_zones(k:longint);
          procedure pnum_Anim_textures(k:longint);
          procedure pnum_Items(k:longint);
          procedure pnum_cinematic_frames(k:longint);
          procedure pnum_demo_data(k:longint);
          procedure pnum_samples_info(k:longint);
          procedure pnum_samples_offsets(k:longint);
  public
         //las variables primero
          valido               :string[7];
          Version              :cardinal; {version}
          tipo                 :integer;
          Num_nonbump_tiles,
          Num_object_tiles,
          Num_bump_tiles              :word; //desconocidos 3 words
          uncompressed32bitT,
          compressed32bitT     :integer;

          uncompressed16bitT,
          compressed16bitT     :integer;

          uncompressedxbitT,
          compressedxbitT      :integer;

          Size_Textures        :longint; {tama¤o texturas}
          Num_Texture_pages    :longint; {numero de paginas texturas}
          texture_data         :pointer; //8 bit textures
          texture_data2        :pointer; //16 bit textures
          texture_data3        :POinter; //32 bit textures
          texture_data4        :Pointer; //x bit texture data?
          dumys                :array[1..6] of byte;
          tr5_lara_type        : word;
          tr5_weather          : word;
          tr5_unknownx         : array[1..28] of byte;
          tr5size_data1        :longint;
          tr5size_data2        :longint;
          tr5layertype         :word;
          rooms                :array of troom;
          floor_data           :array of tfloor_data; {floor data}
          meshwords            :array of word; {meshwords }
          Meshpointers         :array of longint; {meshpointers}
          Anims                :array of tanims; {anim}
          Anims2               :array of tanims2;// Anims for tr4 and tr5
          Structs              :array of tstruct; {struct}
          Ranges               :array of trange; {range}
          Bones1               :array of word; {bones1}
          Bones2               :array of longint; {bones2}
          Frames               :array of smallint; {Frames}
          Movables             :array of tmovable;{Movables}
          Movables2            :array of tmovable2;//movables for tr5 levels
          Static_table         :array of tstatic_table; {statics objects table}
          text                 :array [0..4] of char; //'0tex\0' text string.
          Textures             :array of tobjtexture2; {Object Textures 2 version}
          spr                  :array [0..3] of char; //'Spr' abd spr/0 text label for tr4 and tr5.
          Spr_Textures         :array of tsprite_texture; {Sprite Textures}
          Spr_sequences        :array of tunknow2; {desconocido2}
          Cameras              :array of tcamera; {Camara}
          tr4_unknow1          :array of ttr4_unknow1; //desconocido.
          Sound_fxs            :array of tsoundfx; {soundfx}
          boxes                :array of tbox; {Boxes}
          boxes2               :array of tbox2; {Boxes tr2-tr4}
          Overlaps             :array of word; {Overlaps}
             //--zones
               nground_zone1:array of word;
               nground_zone2:array of word;
               nground_zone3:array of word;
               nground_zone4:array of word;
               nfly_zone    :array of word;
               //--------------------
               aground_zone1:array of word;
               aground_zone2:array of word;
               aground_zone3:array of word;
               aground_zone4:array of word;
               afly_zone    :array of word;
          Anim_textures        :array of word;
          Items                :array of titem; {Itemss!}
          Items2               :array of titem2; {Itemss! tr2-trc}
          Colormap             :tcolormap; {colormaps}
          Palette              :ttrpalette; {paleta}
          palette16            :array [0..255] of rgbdpal;
          cinematic_frames     :array of tunknow3; {desconocido3}
          AI_table             :array of tai_table; // AI items table in tr4 y tr5
          demo_data            :array of byte; {desconocido4}
          sound_map            :array[1..900] of byte; {512 bytes para tr1, 740 para tr2-tr4, 900 para tr5.}
          samples_info         :array of tsample_info; {samples info}
          samples_size         :longint;
          samples_buffer       :pointer; {samples data}
          samples_offsets      :array of longint;
          display:tmemo;
          //progressbar class
          progressbar:tgauge;
    //-----Procedimientos y funciones.
    constructor create;
    function Load_level(name:string; only_textures:boolean=false):byte;
    function Save_Level(name:string):byte;
    function Save_Level2(name:string):byte;

    function roomToStr(var r:troom):TStringList;

    procedure tr1TOtr2;
    procedure tr1TOtrc;
    procedure Build_boxes;
    procedure Build_box(r:integer);
    procedure Build_box2(r:integer);

    procedure Free_Level;
    procedure Addpage;
    procedure Opengl_loadTextures(vp:array of tglviewport; colorbits:byte);


   //properties
     Property num_rooms:word read fnum_rooms write pnum_rooms;
     Property num_floor_data:longint read fnum_floor_data write pnum_floor_data;
     Property num_meshwords:longint read fnum_meshwords write pnum_meshwords;
     Property num_Meshpointers:longint read fnum_Meshpointers write pnum_Meshpointers;
     Property num_Anims:longint read fnum_Anims write pnum_Anims;
     Property num_Structs:longint read fnum_Structs write pnum_Structs;
     Property num_Ranges:longint read fnum_Ranges write pnum_Ranges;
     Property num_Bones1:longint read fnum_Bones1 write pnum_Bones1;
     Property num_Bones2:longint read fnum_Bones2 write pnum_Bones2;
     Property num_Frames:longint read fnum_Frames write pnum_Frames;
     Property num_Movables:longint read fnum_Movables write pnum_Movables;
     Property num_Static_table:longint read fnum_Static_table write pnum_Static_table;
     Property num_Textures:longint read fnum_Textures write pnum_Textures;
     Property num_Spr_Textures:longint read fnum_Spr_Textures write pnum_Spr_Textures;
     Property num_spr_sequences:longint read fnum_spr_sequences write pnum_spr_sequences;
     Property num_Cameras:longint read fnum_Cameras write pnum_Cameras;
     Property num_tr4_unknow1:longint read fnum_tr4_unknow1 write pnum_tr4_unknow1;
     Property num_Sound_fxs:longint read fnum_Sound_fxs write pnum_Sound_fxs;
     Property num_boxes:longint read fnum_boxes write pnum_boxes;
     Property num_overlaps:longint read fnum_overlaps write pnum_overlaps;
     Property num_zones:longint read fnum_zones write pnum_zones;
     Property num_Anim_textures:longint read fnum_Anim_textures write pnum_Anim_textures;
     Property num_Items:longint read fnum_Items write pnum_Items;
     Property num_cinematic_frames:longint read fnum_cinematic_frames write pnum_cinematic_frames;
     Property num_demo_data:longint read fnum_demo_data write pnum_demo_data;
     Property num_samples_info:longint read fnum_samples_info write pnum_samples_info;
     Property num_samples_offsets:longint read fnum_samples_offsets write pnum_samples_offsets;

end; //end ttrlevel class

{*****************************************}
{      STRUCTURAS AUXILIARES              }
{*****************************************}
tpunto   = record
           x,y,z :smallint;
           light :word;
end;
{----------------------------------------}
tpoly4 = record
         x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4 :smallint;
         texture                 :word;
         light                   :byte;
end;
{----------------------------------------}
tpoly3 = record
         x1,y1,z1,x2,y2,z2,x3,y3,z3:smallint;
         texture                 :word;
         light                   :byte;
end;
{----------------------------------------}
Tpoly4_list = record
          num_poly4 : word;
          poly4 : array[1..5000] of tpoly4;
end;

{----------------------------------------}
Tpoly3_list = record
          num_poly3 : word;
          poly3 : array[1..3000] of tpoly3;
end;


tpanel_texture = record
               valido:string;
               width,height:byte;
               columns,rows:byte;
               textures:tbitmap;
               num_textures:integer;
               index   : array [1..999] of integer;
end;

Ttabla_textures = record
                    valido:string;
                    textures:tbitmap;
                    cur_tile:tbitmap;
                    cur_texture:integer;
                    num_tiles:integer;
                    l:ttrlevel;
                  end;


tshapex = record
         altura:byte;
         front1,front2,
         back1,back2,
         left1,left2,
         right1,right2:integer;
         floor_index:word;
         camera      :word;
end;

Tshape_list = record
            num_shape:byte;
            shape: array [0..30] of tshapex;
end;


tinfo = record
        ftipo:byte;
        ctipo:byte;
        findex:byte;
        cindex:byte;
        ffront_texture,
        fback_texture,
        ftop_texture,
        fleft_texture,
        fright_texture:integer;
        flight_front,flight_back,
        flight_left,flight_right,flight_top:byte;

        cfront_texture,
        cback_texture,
        ctop_texture,
        cleft_texture,
        cright_texture:integer;
        clight_front,clight_back,
        clight_left,clight_right,clight_top:byte;
        //-------------------
        join_room:integer;
        tipo_portal:integer;
        //hasta aqui graba la version 1.00
        reservado: array[1..40] of byte;

end;

ttile_info = array[1..1024] of tinfo;

//lo siguiente es para la construccion de meshes

mvertice = record
             x,y,z:smallint;
           end;

Tmesh = record
        mesh_pointer:longint;
        sphere_x,
        sphere_y,
        sphere_z:smallint;
        sphere_radius:integer;
        num_vertices:word;
        vertices : array [0..max_mesh_vertices] of mvertice;
        num_normals:smallint;
        normals : array [0..max_mesh_vertices] of mvertice;
        lights : array [0..max_mesh_vertices] of smallint;
        Num_textured_rectangles:word;
        textured_rectangles: array[0..max_mesh_polys] of tquad2;
        Num_textured_triangles:word;
        textured_triangles: array[0..max_mesh_polys] of ttriangle2;
        num_colored_rectangles:word;
        colored_rectangles: array[0..max_mesh_polys] of tquad2;
        num_colored_triangles:word;
        colored_triangles: array[0..max_mesh_polys] of ttriangle2;
        //auxiliar fields
        minx,miny,minz,maxx,maxy,maxz:real;
        despx,despy,despz:real;

end;

Tmesh_list = record
                num_meshes:integer;
                meshes:array of tmesh;
                mesh_pointers: array of integer;
                draw_mode:byte;
                solid_texture:word;
                light_enabled:boolean;
                r,g,b:byte;
             end;

{*****************************************}
{      FUNCIONES Y PROCEDIMIENTOS         }
{*****************************************}


{----------Phd file format especifiq--------------------}



{----------Meshes procedures------------------------------}

function seek_vertex(var v:tvertice_list; x,y,z:smallint):word;
procedure add_vertex(var v:tvertice_list; x,y,z:smallint; light:byte);

procedure add_poly4( var poly4:tpoly4_list; x1,y1,z1, x2,y2,z2, x3,y3,z3, x4,y4,z4:smallint; texture:word; light:byte );
procedure Poly4_2_Quad(var P:tpoly4_list; var Q:tquad_list; var V:tvertice_list);
procedure Build_room_mesh(var P:tpoly4_list; var Q:tquad_list; var T:ttriangle_list; var V:tvertice_list);
procedure add_poly3( var poly3:tpoly3_list; x1,y1,z1, x2,y2,z2, x3,y3,z3:smallint; texture:word; light:byte );
procedure Poly3_2_Trian(var P:tpoly3_list; var Q:ttriangle_list; var V:tvertice_list);
Procedure Generate_Mesh(var poly:tpoly4_list; var tile:tsector_list;texture:word);overload; //old rutine.
Procedure Generate_Mesh(var poly:tpoly4_list; var tile:tsector_list; var tile_info:ttile_info; var shapes:tshape_list; flags:byte=0;light:integer=16);overload; //new rutine.

//tile sectors stufs
function Short2Byte(altura:shortint):byte;
function Byte2Short(altura:byte):shortint;

function get_tile_index(var Tile:tsector_list; columna,fila:byte):word;

procedure put_sector( sec:tsector; var Tile:tsector_list; columna,fila:byte);
procedure get_sector( var sec:tsector; var Tile:tsector_list; columna,fila:byte);

procedure linea_sector( sec:tsector; var Tile:tsector_list; f1,c1,f2,c2:byte);
procedure bloque_sector( sec:tsector; var Tile:tsector_list; f1,c1,f2,c2:byte);


function Get_floor(var tile:tsector_list; columna,fila:byte):shortint;
function Get_ceiling(var Tile:tsector_list; columna,fila:byte):shortint;
function Get_floor_index(var Tile:tsector_list; columna,fila:byte):word;
function Get_room_below(var Tile:tsector_list; columna,fila:byte):byte;

{---------DXF file format procedures------------------------}
procedure dxf_create(var f:textfile; name:string);
procedure dxf_face(var f:textfile; color:word;
                   x1,y1,z1,
                   x2,y2,z2,
                   x3,y3,z3,
                   x4,y4,z4:real);
procedure dxf_close(var f:textfile);

procedure tr_ExportDxf(name:string; room:byte; var L:ttrlevel);
procedure tr_ImportDxf(name:string; room:byte; var L:ttrlevel);
{---------Textures procedures-------------------------------------------}
procedure Tr_panel_textures(tancho,talto,tcolumns:byte; var L:Ttrlevel; var panel:tpanel_texture);
Function Tr_panel_getindex(x,y:integer; var panel:tpanel_texture):integer;

procedure Tr_tabla_textures(var L:ttrlevel; var tabla:ttabla_textures);
function tr_Get_texture(num:integer; var tabla:ttabla_textures; tri:boolean=true):tbitmap;

{------ITM save/restore---------}
function tr_loaditm(var L:tphd; name:string):byte;
procedure tr_saveitm(var L:tphd; name:string);
//------MSH save/restote------------
procedure TR_savemsh(var L:ttrlevel; name:string);
function TR_loadmsh(var L:ttrlevel; name:string):byte;

//---------------------------------------------------

procedure build_mesh_list(var mesh_list:tmesh_list; var L:ttrlevel);
procedure update_mesh_data(var mesh_list:tmesh_list; var L:ttrlevel);

procedure Draw_mesh(var m:tmesh_list; var l:ttrlevel; nmesh:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false);//Render with not pickable faces.
procedure Draw_mesh2(var m:tmesh_list; var l:ttrlevel; nmesh:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false); //render with pickable faces.
procedure Draw_mesh3(var m:tmesh_list; var l:ttrlevel; nmesh:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false; pickable:boolean=true); //render with lights.

procedure Draw_movable(var m:tmesh_list; var l:ttrlevel; movable:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false; rx_adjust:real=0;ry_adjust:real=0;rz_adjust:real=0);//para el editor
procedure Draw_movable2(var m:tmesh_list; var l:ttrlevel; movable:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false);//para el pixstr

//para averiguar si una textura es tringular
function IsTriangular(var l:ttrlevel; num:integer):boolean;

procedure get_text_coord(var l:ttrlevel; num:integer; var rx1:integer; var ry1:integer; var rx2:integer; var ry2:integer);

Procedure Calc_TRNormals(x1,y1,z1,
                       x2,y2,z2,
                       x3,y3,z3:glfloat;
                       var nx:glfloat;
                       var ny:glfloat;
                       var nz:glfloat);

procedure update_min_max(var m:tmesh_list; nmesh:integer);


implementation

procedure merge_layers(var tr5_layers:ttr5_layers; var vertices:tvertice_list; var quads:tquad_list; var triangles:ttriangle_list);
var
k:integer;
m:integer;
x,y,z:smallint;
i:word;
n:integer;
p1,p2,p3,p4:integer;
r,g,b:word;
begin
    //crear la tabla de vertices fucionada.
    vertices.num_vertices:=0;
    for k:=0 to tr5_layers.Num_layers-1 do
    begin
         for m:=1 to tr5_layers.vertices[k].num_vertices do
         begin
             x:=trunc(tr5_layers.vertices[k].vertice3[m].x);
             y:=trunc(tr5_layers.vertices[k].vertice3[m].y);
             z:=trunc(tr5_layers.vertices[k].vertice3[m].z);
             add_vertex(vertices,x,y,z,0);
             i:=seek_vertex(vertices,x,y,z);
             vertices.vertice3[i]:=tr5_layers.vertices[k].vertice3[m];

           r:=vertices.vertice3[i].r div 8;
           g:=vertices.vertice3[i].g div 8;
           b:=vertices.vertice3[i].b div 8;

           vertices.vertice2[i].light2:=0; //reset color
           vertices.vertice2[i].light2:= (r shl 10) or (g shl 5) or (b);

         end; //end todos los vertices.
    end; //end todos los layers

   //ahora traducir la tabla de quads y triangles a la tabla
   //fucionada.

    //the rectangles first.
    quads.num_quads:=0;
    triangles.num_triangles:=0;

    for k:=0 to tr5_layers.Num_layers-1 do
    begin
        for m:=1 to tr5_layers.quads[k].num_quads do
        begin
            quads.num_quads:=quads.num_quads+1;
            p1:=tr5_layers.quads[k].quad2[m].p1;
            p2:=tr5_layers.quads[k].quad2[m].p2;
            p3:=tr5_layers.quads[k].quad2[m].p3;
            p4:=tr5_layers.quads[k].quad2[m].p4;

            x:=trunc(tr5_layers.vertices[k].vertice3[p1+1].x);
            y:=trunc(tr5_layers.vertices[k].vertice3[p1+1].y);
            z:=trunc(tr5_layers.vertices[k].vertice3[p1+1].z);
            quads.quad[quads.num_quads].p1:=seek_vertex(vertices,x,y,z)-1;

            x:=trunc(tr5_layers.vertices[k].vertice3[p2+1].x);
            y:=trunc(tr5_layers.vertices[k].vertice3[p2+1].y);
            z:=trunc(tr5_layers.vertices[k].vertice3[p2+1].z);
            quads.quad[quads.num_quads].p2:=seek_vertex(vertices,x,y,z)-1;

            x:=trunc(tr5_layers.vertices[k].vertice3[p3+1].x);
            y:=trunc(tr5_layers.vertices[k].vertice3[p3+1].y);
            z:=trunc(tr5_layers.vertices[k].vertice3[p3+1].z);
            quads.quad[quads.num_quads].p3:=seek_vertex(vertices,x,y,z)-1;

            x:=trunc(tr5_layers.vertices[k].vertice3[p4+1].x);
            y:=trunc(tr5_layers.vertices[k].vertice3[p4+1].y);
            z:=trunc(tr5_layers.vertices[k].vertice3[p4+1].z);
            quads.quad[quads.num_quads].p4:=seek_vertex(vertices,x,y,z)-1;
            //textura y actualizar quad2.
            quads.quad[quads.num_quads].texture:=tr5_layers.quads[k].quad2[m].texture;
            quads.quad2[quads.num_quads].p1:=quads.quad[quads.num_quads].p1;
            quads.quad2[quads.num_quads].p2:=quads.quad[quads.num_quads].p2;
            quads.quad2[quads.num_quads].p3:=quads.quad[quads.num_quads].p3;
            quads.quad2[quads.num_quads].p4:=quads.quad[quads.num_quads].p4;
            quads.quad2[quads.num_quads].texture:=quads.quad[quads.num_quads].texture;
            quads.quad2[quads.num_quads].unk:=tr5_layers.quads[k].quad2[m].unk;

        end; //end rectangles

        //Now the triangles.
        for m:=1 to tr5_layers.triangles[k].num_triangles do
        begin
            Triangles.num_Triangles:=triangles.num_triangles+1;
            p1:=tr5_layers.triangles[k].triangle2[m].p1;
            p2:=tr5_layers.triangles[k].triangle2[m].p2;
            p3:=tr5_layers.triangles[k].triangle2[m].p3;

            x:=trunc(tr5_layers.vertices[k].vertice3[p1+1].x);
            y:=trunc(tr5_layers.vertices[k].vertice3[p1+1].y);
            z:=trunc(tr5_layers.vertices[k].vertice3[p1+1].z);
            triangles.triangle[triangles.num_triangles].p1:=seek_vertex(vertices,x,y,z)-1;

            x:=trunc(tr5_layers.vertices[k].vertice3[p2+1].x);
            y:=trunc(tr5_layers.vertices[k].vertice3[p2+1].y);
            z:=trunc(tr5_layers.vertices[k].vertice3[p2+1].z);
            triangles.triangle[triangles.num_triangles].p2:=seek_vertex(vertices,x,y,z)-1;

            x:=trunc(tr5_layers.vertices[k].vertice3[p3+1].x);
            y:=trunc(tr5_layers.vertices[k].vertice3[p3+1].y);
            z:=trunc(tr5_layers.vertices[k].vertice3[p3+1].z);
            triangles.triangle[triangles.num_triangles].p3:=seek_vertex(vertices,x,y,z)-1;
            //textura y actualizar triangle2.
            triangles.triangle[triangles.num_triangles].texture:=tr5_layers.triangles[k].triangle2[m].texture;
            triangles.triangle2[triangles.num_triangles].p1:=triangles.triangle[triangles.num_triangles].p1;
            triangles.triangle2[triangles.num_triangles].p2:=triangles.triangle[triangles.num_triangles].p2;
            triangles.triangle2[triangles.num_triangles].p3:=triangles.triangle[triangles.num_triangles].p3;
            triangles.triangle2[triangles.num_triangles].texture:=triangles.triangle[triangles.num_triangles].texture;
            triangles.triangle2[triangles.num_triangles].unk:=tr5_layers.triangles[k].triangle2[m].unk;

         end; //end todos los triangles

     end;//end todos los layers.


end; //end procedure


//----definicion de los procedimientos que escriben los datos con elos properties
procedure ttrlevel.pnum_rooms(k:word);
begin
     setlength(rooms,k);
     fnum_rooms:=k;
end;

procedure ttrlevel.pnum_floor_data(k:longint);
begin
     setlength(floor_data,k);
     fnum_floor_data:=k;
end;

procedure ttrlevel.pnum_meshwords(k:longint);
begin
     setlength(meshwords,k);
     fnum_meshwords:=k;
end;

procedure ttrlevel.pnum_Meshpointers(k:longint);
begin
     setlength(meshpointers,k);
     fnum_meshpointers:=k;
end;

procedure ttrlevel.pnum_Anims(k:longint);
begin
     if tipo<vtr4 then setlength(anims,k) else setlength(anims2,k);
     fnum_anims:=k;
end;

procedure ttrlevel.pnum_Structs(k:longint);
begin
     setlength(structs,k);
     fnum_structs:=k;
end;

procedure ttrlevel.pnum_Ranges(k:longint);
begin
     setlength(ranges,k);
     fnum_ranges:=k;
end;

procedure ttrlevel.pnum_Bones1(k:longint);
begin
     setlength(bones1,k);
     fnum_bones1:=k;
end;

procedure ttrlevel.pnum_Bones2(k:longint);
begin
     setlength(bones2,k);
     fnum_bones2:=k;
end;

procedure ttrlevel.pnum_Frames(k:longint);
begin
     setlength(frames,k);
     fnum_frames:=k;
end;

procedure ttrlevel.pnum_Movables(k:longint);
begin
     setlength(movables,k);
     setlength(movables2,k);
     fnum_movables:=k;
end;

procedure ttrlevel.pnum_Static_table(k:longint);
begin
     setlength(static_table,k);
     fnum_static_table:=k;
end;

procedure ttrlevel.pnum_Textures(k:longint);
begin
     setlength(textures,k);
     fnum_textures:=k;
end;

procedure ttrlevel.pnum_Spr_Textures(k:longint);
begin
     setlength(spr_textures,k);
     fnum_spr_textures:=k;
end;

procedure ttrlevel.pnum_spr_sequences(k:longint);
begin
     setlength(spr_sequences,k);
     fnum_spr_sequences:=k;
end;

procedure ttrlevel.pnum_Cameras(k:longint);
begin
     setlength(cameras,k);
     fnum_cameras:=k;
end;

procedure ttrlevel.pnum_tr4_unknow1(k:longint);
begin
     setlength(tr4_unknow1,k);
     fnum_tr4_unknow1:=k;
end;

procedure ttrlevel.pnum_Sound_fxs(k:longint);
begin
     setlength(sound_fxs,k);
     fnum_sound_fxs:=k;
end;


procedure ttrlevel.pnum_boxes(k:longint);
begin
     setlength(boxes,k);
     setlength(boxes2,k);
     fnum_boxes:=k;
end;

procedure ttrlevel.pnum_overlaps(k:longint);
begin
     setlength(overlaps,k);
     fnum_overlaps:=k;
end;

procedure ttrlevel.pnum_zones(k:longint);
begin

    setlength(nground_zone1,k);
    setlength(nground_zone2,k);
    setlength(nground_zone3,k);
    setlength(nground_zone4,k);
    setlength(nfly_zone,k);
    //--------------------
    setlength(aground_zone1,k);
    setlength(aground_zone2,k);
    setlength(aground_zone3,k);
    setlength(aground_zone4,k);
    setlength(afly_zone,k);

    fnum_zones:=k;
end;


function Ttrlevel.roomToStr(var r: troom): TStringList;
var
  sl:TStringList;
  s:string;
  u:ttr5_unknowns;
  L:tlayers;
begin
  sl:=TStringList.Create;
  if tipo <> VTr5  then Exit;
  sl.Append(Format('Num layers %d',[r.num_layers]));
  sl.Append(Format('d0 %d lara light %d',[r.d0, r.Lara_light]));
  sl.Append(Format('sand effect %d light mode %d',[r.sand_effect,r.light_mode]));
  sl.Append(Format('water %d alternate %d d2 %d',[r.water,r.alternate,r.d2]));
  sl.Append(Format('tr5_flag %d',[r.tr5_flag]));
  u:=r.tr5_unknowns;
  sl.Append(Format('tr5 unk5 %d %d %.2f %.2f %.2f',[u.unknown5.u1,u.unknown5.u2,u.unknown5.roomx,u.unknown5.roomy,u.unknown5.roomz]));
  sl.Append(Format('tr5 room colour %d',[u.room_color]));
  if r.num_layers<>0 then
  begin
    L:=r.layers[0];
    sl.Append(Format(#9'unknownl1 %d unknownl2 %d',[L.unknownl1,L.unknownl2]));
    sl.Append(Format(#9'unknownl3 %d unknownl4 %d unknownl5 %d',[L.unknownl3,L.unknownl4,L.unknownl5]));
    sl.Append(Format(#9'filler2 %d filler3 %d',[L.filler2,L.filler3]));
    sl.Append(Format(#9'num verts %d',[L.num_vertices]));
  end;

                           
  Result:=sl;
end;

procedure ttrlevel.pnum_Anim_textures(k:longint);
begin
     setlength(anim_textures,k);
     fnum_anim_textures:=k;
end;

procedure ttrlevel.pnum_Items(k:longint);
begin
     setlength(items,k);
     setlength(items2,k);
     fnum_items:=k;
end;

procedure ttrlevel.pnum_cinematic_frames(k:longint);
begin
     if tipo<vtr4 then setlength(cinematic_frames,k) else
                       setlength(ai_table,k);

     fnum_cinematic_frames:=k;
end;

procedure ttrlevel.pnum_demo_data(k:longint);
begin
     setlength(demo_data,k);
     fnum_demo_data:=k;
end;

procedure ttrlevel.pnum_samples_info(k:longint);
begin
     setlength(samples_info,k);
     fnum_samples_info:=k;
end;


procedure ttrlevel.pnum_samples_offsets(k:longint);
begin
     setlength(samples_offsets,k);
     fnum_samples_offsets:=k;
end;
//------*---*---------*--------*--------*-
// resto de las procedures y funciones de la clase.
constructor ttrlevel.create;
begin
    fnum_rooms:=0;
    fnum_floor_data:=0;
    fnum_meshwords:=0;
    fnum_Meshpointers:=0;
    fnum_Anims:=0;
    fnum_Structs:=0;
    fnum_Ranges:=0;
    fnum_Bones1:=0;
    fnum_Bones2:=0;
    fnum_Frames:=0;
    fnum_Movables:=0;
    fnum_Static_table:=0;
    fnum_Textures:=0;
    fnum_Spr_Textures:=0;
    fnum_spr_sequences:=0;
    fnum_Cameras:=0;
    fnum_tr4_unknow1:=0;
    fnum_Sound_fxs:=0;
    fnum_boxes:=0;
    fnum_overlaps:=0;
    fnum_zones:=0;
    fnum_Anim_textures:=0;
    fnum_Items:=0;
    fnum_cinematic_frames:=0;
    fnum_demo_data:=0;
    fnum_samples_info:=0;
    fnum_samples_offsets:=0;
    valido:='';
    Version:=0;
    tipo:=0;
    Size_Textures:=0;
    Num_Texture_pages:=0;
    texture_data:=nil;
    texture_data2:=nil;
    display:=nil;
    progressbar:=nil;
end;

function ttrlevel.Load_level(name:string; only_textures:boolean=false):byte;
var
f:tzfile;
resultado:byte;
x:word;
k:word;
aux_word:word;
aux,aux2:longint;
ofset:longint;
comprimido,descomprimido:integer;
temp,temp2:pointer;
fx:file;
buf: array [0..1024] of byte;
chunk_start,chunk_size:longint;
aux_byte:byte;
ofset_wavs:longint;
F2:FILE;
PA:POINTER;
porcent,porcent2:real;
  ii: Integer;
{$IFDEF  debug}
  room_start,room_end:LongInt;
{$ENDIF}
begin
 //si L contiene ya contiene un nivel cargado
 //liberar las texturas y los sonidos en tr1.

 if progressbar<>nil then progressbar.progress:=0;


 if valido='Tpascal' then
 begin
     if tipo<=vtr3 then FreeMem(texture_data);
     if tipo>=vtr2 then FreeMem(texture_data2);
     if tipo>=vtr4 then begin FreeMem(texture_data3);FreeMem(texture_data4);end;
     if (tipo<vtr2) or (tipo>=vtr4) then FreeMem(samples_buffer);
     if progressbar<>nil then progressbar.progress:=10;

 end;
 resultado:=0;

 if fileExists(name) then
 begin
    filemode:=0;
    zassignfile(f,name);
    zreset(f,1);
    filemode:=2;
    zblockread(f,version,4);


    if (version<>$20) and (version<>$2d) and (version<>$ff180038) and (version<>$ff080038)
        and (version<>$fffffff0) and (version<>$00345254) then begin zclosefile(f,false);version:=0;resultado:=2;end;
 end
 else resultado:=1;
 {*****************}

 if resultado=0 then
 begin
     tipo:=0;
     valido:='Tpascal'; //para poder liberar las textures y los samples despues.

     //tipo=no version, 1=phd, 2=tub, 3=TR2, 3.5=TRg, 4=TR3, 5=tr4, 6=tr5
     case version of
          $20: if (pos('.TUB',name)<>0) or (pos('.tub',name)<>0) then tipo:=vTub else tipo:=VTr1;
          $2d: if (pos('.TRG',name)<>0) or (pos('.trg',name)<>0) then tipo:=vTrg else tipo:=vTR2;
          $ff080038,$ff180038:tipo:=vTR3;
          $fffffff0,$00345254:if (pos('.TRC',name)<>0) or (pos('.trc',name)<>0) then tipo:=vtr5 else tipo:=vtr4;
     end;//end case

     //si TR4 o tr5 leer 3 words, y las texturas
     if (tipo=vtr4) or (tipo=vtr5) then
     begin

          zblockread(f,Num_nonbump_tiles,2);
          zblockread(f,Num_object_tiles,2);
          zblockread(f,num_bump_tiles,2);
          //descomprimir 32bit textures.
          zblockread(f,uncompressed32bitT,4);
          zblockread(f,compressed32bitT,4);
          getmem(temp,compressed32bitT);
          zblockread(f,temp^,compressed32bitT);
          zlib_decompress(temp,compressed32bitT,0,texture_data3,uncompressed32bitT);
          freemem(temp);
          if progressbar<>nil then progressbar.progress:=20;

          //descomprimir 16bit textures.
          zblockread(f,uncompressed16bitT,4);
          zblockread(f,compressed16bitT,4);
          getmem(temp,compressed16bitT);
          zblockread(f,temp^,compressed16bitT);
          zlib_decompress(temp,compressed16bitT,0,texture_data2,uncompressed16bitT);
          freemem(temp);
          if progressbar<>nil then progressbar.progress:=30;
          //descomprimir xbit textures.
          zblockread(f,uncompressedxbitT,4);
          zblockread(f,compressedxbitT,4);
          getmem(temp,compressedxbitT);
          zblockread(f,temp^,compressedxbitT);
          zlib_decompress(temp,compressedxbitT,0,texture_data4,uncompressedxbitT);
          freemem(temp);
          if progressbar<>nil then progressbar.progress:=40;
         //actualizar algunos campos de trabajo.
          num_texture_pages:=uncompressed16bitT div 131072;
          size_textures:=num_texture_pages*65536;
        //si Tr4 descomprimir el resto del nivel
     if tipo=vtr4 then
        begin
          zblockread(f,descomprimido,4);
          zblockread(f,comprimido,4);
          getmem(temp,comprimido);
          zblockread(f,temp^,comprimido);
          zlib_decompress(temp,comprimido,0,temp2,descomprimido);
          freemem(temp); //temp2 tiene el resto del nivel descomprimido.
          //acontinuacion leer los wave files que estan en el resto del archivo
          samples_size:=zfilesize(f)-zfilepos(f);
          getmem(samples_buffer,samples_size);
          zblockread(f,samples_buffer^,samples_size);
          // copiar el nivel en el buffer normal del archivo abierto.
          zseek(f,0);
          zblockwrite(f,temp2^,descomprimido);
          freemem(temp2);
          zseek(f,0);
          if progressbar<>nil then progressbar.progress:=50;
      end; //end si solo tr4

     end; //end si tr4 y tr5.

     //si tr2 o tr3 cargar las paletas aqui.
     if (tipo=vtr2) or (tipo=vtrg) or (tipo=vtr3) then
     begin
          zblockread(f,Palette,768); //palette 256 colors
          zblockread(f,Palette16,1024); //palette 16bit colors
     end;


    if (tipo<>vtr4) and (tipo<>vtr5) then
    begin
     zBlockread(f, Size_Textures,4); {get size textures 8 bit bitmaps}
     Num_texture_pages:=Size_Textures; //salvar aqui cuantas paginas de texturas hay.
     Size_Textures:=Size_Textures*65536; //calcular aqui el tamano de las texturas.

     if progressbar<>nil then progressbar.progress:=30;

     //cargar las texturas 8 bit bitmaps
     getmem(texture_data, Size_Textures);
     zblockread(f, texture_data^, Size_Textures);

     //si tr2 o tr3 cargar las 16bit texturas bitmaps.
     if (tipo=vtr2) or (tipo=vtrg) or (tipo=vtr3) then
     begin
          getmem(texture_data2, Num_texture_pages*131072);
          Zblockread(f, texture_data2^, num_texture_pages*131072);
     end;//
     if progressbar<>nil then progressbar.progress:=50;

   end; //leer texturas en phd,tub,tr2 y tr3 levels.

   if (tipo>vtub) and (only_textures) then begin result:=0;if progressbar<>nil then progressbar.progress:=0;exit;end;

//*****************************************************
//si tr5 entonces leer room data en forma especial
//*****************************************************
if tipo=vtr5 then
begin
Zblockread(f, tr5_lara_type, 32); //unknow32 bytes
Zblockread(f, tr5size_data1, 4); //sizedata1
Zblockread(f, tr5size_data2, 4); //sizedata2

ofset_wavs:=zfilepos(f)+tr5size_data1;

Zblockread(f, aux, 4); //unknown always 0
Zblockread(f, aux, 4); //num rooms
num_rooms:=aux;

porcent:=30/num_rooms;
porcent2:=0;
{$IFDEF  debug}
room_start:=zFilePos(f);
{$ENDIF}

for x:=0 to num_rooms-1 do
begin
   Zblockread(f, buf, 4); //xela
   //after reading the whole room, calc how much paded bytes
   //are before the next room using chunk_start and chunk_size.
   Zblockread(f, rooms[x].tr5_unknowns.chunk_size, 4); //size next xela block
   chunk_start:=zfilepos(f);
   chunk_size:=rooms[x].tr5_unknowns.chunk_size;

   Zblockread(f, aux, 4); //cdcdcdcd
   Zblockread(f, rooms[x].tr5_unknowns.ublock1,4);
   Zblockread(f, rooms[x].tr5_unknowns.ublock2,4);

   Zblockread(f, rooms[x].tr5_unknowns.ublock3,4);//cdcdcdcd???
   Zblockread(f, rooms[x].tr5_unknowns.ublock4,4);

   Zblockread(f, rooms[x].room_info.xpos_room,4); //X room position
   Zblockread(f, rooms[x].tr5_unknowns.unknown1,4);
   Zblockread(f, rooms[x].room_info.zpos_room,4); //Z room position
   Zblockread(f, rooms[x].room_info.ymin,4); //Y botton podition
   Zblockread(f, rooms[x].room_info.ymax,4); //X room position
   Zblockread(f, rooms[x].sectors.largo,2); // Z amount sectors
   Zblockread(f, rooms[x].sectors.ancho,2); // X amount sectors
   Zblockread(f, rooms[x].tr5_unknowns.room_color,4);

   Zblockread(f, rooms[x].source_lights.num_sources,2); // amount spot lights.
   Zblockread(f, rooms[x].statics.num_static,2); // amount statics ornaments
   Zblockread(f, rooms[x].tr5_unknowns.unknown2,4); //reverbinfo,alternategroup,waterscheme
   Zblockread(f, rooms[x].tr5_unknowns.unknown3,4); //filler 0x00007FFF
   Zblockread(f, rooms[x].tr5_unknowns.unknown4,4); //filler 0x00007FFF


   Zblockread(f, aux, 4); //cdcdcdcd
   Zblockread(f, aux, 4); //cdcdcdcd
   //Zblockread(f, buf, 6); //6 bytes ffffffffff
   zblockread(f, aux,4); //0xffffffff
   zblockread(f, rooms[x].alternate,2);
   Zblockread(f, rooms[x].water,1); // room flag
   Zblockread(f, rooms[x].d2,1); // room flag2
   Zblockread(f, rooms[x].tr5_flag,2); // Alternate room?
   Zblockread(f, buf, 10); //10 bytes bytes 0
   Zblockread(f, aux, 4); //cdcdcdcd
   Zblockread(f, rooms[x].tr5_unknowns.unknown5.data[1],16); //unknown5
   Zblockread(f, aux, 4); //cdcdcdcd
   Zblockread(f, aux, 4); //cdcdcdcd
   Zblockread(f, aux, 4); //cdcdcdcd
   Zblockread(f, aux, 4); //cdcdcdcd
   Zblockread(f, rooms[x].tr5_unknowns.unknown6,4); //unknown6 //->null room 0xcdcdcdcd
   Zblockread(f, aux, 4); //cdcdcdcd
   Zblockread(f, rooms[x].tr5_unknowns.total_triangles,4); //amount triangles
   Zblockread(f, rooms[x].tr5_unknowns.total_rectangles,4);
   Zblockread(f, rooms[x].tr5_unknowns.unknown7,4); //separator=0
   Zblockread(f, rooms[x].tr5_unknowns.lightsize,4);
   Zblockread(f, rooms[x].tr5_unknowns.numberlights,4);
   Zblockread(f, rooms[x].tr5unk8.num_unk8, 4); //unknown8.
   Zblockread(f, rooms[x].tr5_unknowns.unknown9,4);//roomytop
   Zblockread(f, rooms[x].tr5_unknowns.unknown10,4); //roomybottom
   Zblockread(f, rooms[x].num_layers, 4); //amount pieces in room.
   rooms[x].tr5_layers.num_layers:=rooms[x].num_layers;

   Zblockread(f, rooms[x].tr5_unknowns.unknown11,4);
   Zblockread(f, rooms[x].tr5_unknowns.unknown12,4);
   Zblockread(f, rooms[x].tr5_unknowns.unknown13,4);
   Zblockread(f, rooms[x].tr5_unknowns.unknown14,4);
   Zblockread(f, rooms[x].tr5_unknowns.unknown15,4); //verticesSize

   Zblockread(f, aux, 4); //cdcdcdcd.
   Zblockread(f, aux, 4); //cdcdcdcd.
   Zblockread(f, aux, 4); //cdcdcdcd.
   Zblockread(f, aux, 4); //cdcdcdcd.

   //read source lights.
   Zblockread(f, rooms[x].source_lights.source_light4,rooms[x].source_lights.num_sources*sizeof(tsource_light4));

   //leer structura desconocida, 36 bytes por registros.
   Zblockread(f,rooms[x].tr5unk8.data, rooms[x].tr5unk8.num_unk8*36);

   Zblockread(f, rooms[x].sectors.sector, (rooms[x].sectors.largo*rooms[x].sectors.ancho)*sizeof(tsector));

   Zblockread(f, aux_word, 2); //num doors.

   rooms[x].doors.num_doors:=aux_word;
   Zblockread(f, rooms[x].doors.door, aux_word*32); //door data

   Zblockread(f, aux, 2); //cdcd.
   Zblockread(f, rooms[x].statics.static2, rooms[x].statics.num_static*20); //static mesh

   //next come the layer data blocks.!!!
   //reset rectangles,triangles,vertices and sprites to 0.
   rooms[x].vertices.num_vertices:=0;
   rooms[x].quads.num_quads:=0;
   rooms[x].triangles.num_triangles:=0;
   rooms[x].sprites.num_sprites:=0;
   SetLength(rooms[x].layers,rooms[x].num_layers);

   setlength(rooms[x].tr5_layers.vertices,rooms[x].tr5_layers.num_layers);
   setlength(rooms[x].tr5_layers.quads,rooms[x].tr5_layers.num_layers);
   setlength(rooms[x].tr5_layers.triangles,rooms[x].tr5_layers.num_layers);
   tr5layertype:=$c2a;
//aveces hay cuartos sin layers!!!
if rooms[x].num_layers<>0 then
begin
   for k:=0 to rooms[x].num_layers-1 do
   begin
      Zblockread(f, aux, 4); //amount vertices in this layer
      rooms[x].layers[k].num_vertices:=aux;
      rooms[x].tr5_layers.vertices[k].num_vertices:=aux;

      Zblockread(f, aux_word, 2); //unknowl1
      rooms[x].layers[k].unknownl1:=aux_word;

      Zblockread(f, aux_word, 2); //amount rectangles in this layer
      rooms[x].layers[k].num_rectangles:=aux_word;
      rooms[x].tr5_layers.quads[k].num_quads:=aux_word;

      Zblockread(f, aux_word, 2); //amount triangles in this layer
      rooms[x].layers[k].num_triangles:=aux_word;
      rooms[x].triangles.num_triangles:=rooms[x].triangles.num_triangles+aux_word;
      rooms[x].tr5_layers.triangles[k].num_triangles:=aux_word;
      Zblockread(f, rooms[x].layers[k].unknownl2, 46); //46 bytes.
   end;
   //read rectangles and triangles

   for k:=0 to rooms[x].num_layers-1 do
   begin
       zblockread(f,rooms[x].tr5_layers.quads[k].quad2,sizeof(tquad2)*rooms[x].layers[k].num_rectangles);
       zblockread(f,rooms[x].tr5_layers.triangles[k].triangle2,sizeof(ttriangle2)*rooms[x].layers[k].num_triangles);
   end;
   //si amount triangules no es par entonces hay un pad word.
   if (rooms[x].triangles.num_triangles mod 2)<>0 then zblockread(f,aux_word,2); //leer si hay un paded cdcd antes
   //leer ahora los vertices
   for k:=0 to rooms[x].num_layers-1 do
   begin
       zblockread(f,rooms[x].tr5_layers.vertices[k].vertice3,sizeof(tvertice3)*rooms[x].tr5_layers.vertices[k].num_vertices);
   end;

   //merge all layers info.
   merge_layers(rooms[x].tr5_layers, rooms[x].vertices, rooms[x].quads, rooms[x].triangles);

//---now let's put whole room dimension to the first layer, i am going to
//save the whole room using just one leyer later.
    //Layer box
    rooms[x].layers[0].unknownl1:=0;
    rooms[x].layers[0].unknownl2:=0;
    rooms[x].layers[0].filler2:=0;
    rooms[x].layers[0].filler3:=0;

    rooms[x].layers[0].unknownl3:=3552812; //?
    rooms[x].layers[0].unknownl4:=36576740;//?
    rooms[x].layers[0].unknownl5:=23403952;//?

    rooms[x].layers[0].x1:=0;
    rooms[x].layers[0].x2:=rooms[x].sectors.ancho*1024;
    rooms[x].layers[0].y1:=rooms[x].room_info.ymax;
    rooms[x].layers[0].y2:=rooms[x].room_info.ymin;
    rooms[x].layers[0].z1:=0;
    rooms[x].layers[0].z2:=rooms[x].sectors.largo*1024;
    
   end; //si amount layers<>0

rooms[x].tr5_numpads:=(chunk_start+chunk_size)-zfilepos(f);
//go to next room.
zseek(f,chunk_start+chunk_size); //es mas seguro de esta forma

//update % status
porcent2:=porcent2+porcent;
if progressbar<>nil then progressbar.progress:=50+trunc(porcent2);


end; //end leer todos los rooms.
{$ifdef debug}
room_end:=zFilePos(f);
{$endif}
end;//fin version tr5 leer rooms en forma especial.
//******************************************************
//si version<tr5 entonces leer room data en forma normal
if tipo<>vtr5 then
begin
     zblockread(f, dumys,4); //4 bytes segun roseta, yo tenia 6.

     zblockread(f,aux_word,2);   {get total rooms}
     num_rooms:=aux_word;

      porcent:=30/num_rooms;
      porcent2:=0;

     {Cargar todos los Rooms.}
     for x:=0 to num_rooms-1 do
     begin
          //Room info
          zblockread(f,rooms[x].room_info, sizeof(troom_info) );

          zblockread(f,rooms[x].vertices.num_vertices,2);


          //cargar los vertices deacuerdo a la version.
          if tipo>=vtr2 then
              begin
                  zblockread(f,rooms[x].vertices.vertice2, sizeof(tvertice2) * rooms[x].vertices.num_vertices );
                  //poner los vertices en tr1/tub formato tambien
                  for k:=1 to rooms[x].vertices.num_vertices do
                  begin
                       rooms[x].vertices.vertice[k].x:=rooms[x].vertices.vertice2[k].x;
                       rooms[x].vertices.vertice[k].y:=rooms[x].vertices.vertice2[k].y;
                       rooms[x].vertices.vertice[k].z:=rooms[x].vertices.vertice2[k].z;
                       rooms[x].vertices.vertice[k].light:=rooms[x].vertices.vertice2[k].light;
                       rooms[x].vertices.vertice[k].light0:=rooms[x].vertices.vertice2[k].light0;
                  end;

              end
           else
               begin
                   zblockread(f,rooms[x].vertices.vertice, sizeof(tvertice) * rooms[x].vertices.num_vertices );
                  for k:=1 to rooms[x].vertices.num_vertices do
                  begin
                       rooms[x].vertices.vertice2[k].x:=rooms[x].vertices.vertice[k].x;
                       rooms[x].vertices.vertice2[k].y:=rooms[x].vertices.vertice[k].y;
                       rooms[x].vertices.vertice2[k].z:=rooms[x].vertices.vertice[k].z;
                       rooms[x].vertices.vertice2[k].light:=rooms[x].vertices.vertice[k].light;
                       rooms[x].vertices.vertice2[k].light0:=rooms[x].vertices.vertice[k].light0;
                       rooms[x].vertices.vertice2[k].light2:=15855;
                       rooms[x].vertices.vertice2[k].attrib:=16;

                  end;

               end;


          zblockread(f,rooms[x].quads.num_quads,2);
          zblockread(f,rooms[x].quads.quad,  sizeof(tquad) * rooms[x].quads.num_quads );


          zblockread(f,rooms[x].triangles.num_triangles,2);
          zblockread(f,rooms[x].triangles.triangle,  sizeof(ttriangle) * rooms[x].triangles.num_triangles );


          zblockread(f,rooms[x].sprites.num_sprites,2);
          zblockread(f,rooms[x].sprites.sprite, sizeof(tsprite) * rooms[x].sprites.num_sprites);

          zblockread(f,rooms[x].doors.num_doors,2);
          zblockread(f,rooms[x].doors.door, sizeof(tdoor) * rooms[x].doors.num_doors );

          zblockread(f,rooms[x].sectors.largo,2);
          zblockread(f,rooms[x].sectors.ancho,2);
          zblockread(f,rooms[x].sectors.sector,  sizeof(tsector) * rooms[x].sectors.largo * rooms[x].sectors.ancho);
          zblockread(f,rooms[x].d0,1);
          zblockread(f,rooms[x].lara_light,1);



          //if tr2 o tr3 cargar sand efect en el room
          if tipo>=vtr2 then zblockread(f,rooms[x].sand_effect,2);
          if (tipo=vtr2) or (tipo=vtrg) then zblockread(f,rooms[x].light_mode,2);

          zblockread(f,rooms[x].Source_lights.num_sources,2);

          //si phd o tub
          if tipo<=vtub then zblockread(f,rooms[x].Source_lights.source_light, sizeof(tsource_light) * rooms[x].Source_lights.num_sources );
          //if tr2 o tr3
          if (tipo>=vtr2) and (tipo<=vtr3) then zblockread(f,rooms[x].Source_lights.source_light2, sizeof(tsource_light2) * rooms[x].Source_lights.num_sources );
          //si tr4 o tr5
          if tipo>=vtr4 then zblockread(f,rooms[x].Source_lights.source_light3, sizeof(tsource_light3) * rooms[x].Source_lights.num_sources );

          zblockread(f, rooms[x].Statics.num_static,2);
        //if tr2 o tr3 cargar los statics objects
          if (tipo>=vtr2) then zblockread(f,rooms[x].statics.static2, sizeof(tstatic2) * rooms[x].statics.num_static ) else
                               zblockread(f,rooms[x].statics.static, sizeof(tstatic) * rooms[x].statics.num_static );

          zblockread(f,rooms[x].alternate,2);
          zblockread(f,rooms[x].water,1);
          zblockread(f,rooms[x].d2,1);
          //solo tr3 tiene lo siguiente.
          rooms[x].room_color:=0;
          if tipo>=vtr3 then zblockread(f,rooms[x].room_color,3);

         //update % status
         porcent2:=porcent2+porcent;
         if progressbar<>nil then progressbar.progress:=50+trunc(porcent2);

     end; {fin cargar todos los rooms}

end;//end si version <>tr5

  if progressbar<>nil then progressbar.progress:=80;

     //floor_data
   zblockread(f,aux,4);
   num_floor_data:=aux;
   zblockread(f,Floor_data[0], num_floor_data*2);

     //mesh words
     zblockread(f,aux,4);
     num_meshwords:=aux;
     zblockread(f, meshwords[0], num_meshwords*2);

     //mesh pointers
     zblockread(f,aux,4);
     num_meshpointers:=aux;
     zblockread(f, meshpointers[0], num_meshpointers *4);


     //anims
     zblockread(f,aux,4);
     num_anims:=aux;
     if tipo<vtr4 then zblockread(f, anims[0],num_anims*32) else
                       zblockread(f, anims2[0],num_anims*40);



     //structs
     zblockread(f,aux,4);
     num_structs:=aux;
     zblockread(f, Structs[0],num_structs*6);


     //ranges
     zblockread(f,aux,4);
     num_ranges:=aux;
     zblockread(f, Ranges[0], num_ranges*8);


     //bones1
     zblockread(f,aux,4);
     Num_bones1:=aux;
     zblockread(f, Bones1[0], Num_bones1*2);


     //bones2
     zblockread(f,aux,4);
     Num_bones2:=aux;
     zblockread(f, Bones2[0], Num_bones2*4);


     //frames
     zblockread(f,aux,4);
     Num_frames:=aux;
     zblockread(f, Frames[0], Num_frames*2);


     //movables
     zblockread(f,aux,4);
     Num_movables:=aux;
     //if tr1-tr4 leer 18 bytes for registro, si no leer 20 bytes.
     if tipo<vtr5 then zblockread(f, movables[0], Num_movables*18) else
                        begin
                           zblockread(f, movables2[0], Num_movables*20);
                           //since treditor will render movables, then is beter to map
                           //movables 1.
                            for x:=0 to num_movables-1 do move(movables2[x],movables[x],18);
                         end;
     //esto son los static mesh disponibles.
     zblockread(f,aux,4);
     Num_static_table:=aux;
     zblockread(f, static_table[0], Num_static_table*32);


     //obj textures
     //solo tr1/tub and tr2 tiene los obj texturas aqui.
     if tipo<vtr3 then
     begin
          zblockread(f,aux,4);
          Num_textures:=aux;
      //leer las texturas una por una.
      for x:=0 to num_textures-1 do
      begin
          zblockread(f,textures[x].attrib,2);
          zblockread(f,textures[x].tile,2);
          zblockread(f,textures[x].mx1,1);
          zblockread(f,textures[x].x1,1);
          zblockread(f,textures[x].my1,1);
          zblockread(f,textures[x].y1,1);
          zblockread(f,textures[x].mx2,1);
          zblockread(f,textures[x].x2,1);
          zblockread(f,textures[x].my2,1);
          zblockread(f,textures[x].y2,1);
          zblockread(f,textures[x].mx3,1);
          zblockread(f,textures[x].x3,1);
          zblockread(f,textures[x].my3,1);
          zblockread(f,textures[x].y3,1);
          zblockread(f,textures[x].mx4,1);
          zblockread(f,textures[x].x4,1);
          zblockread(f,textures[x].my4,1);
          zblockread(f,textures[x].y4,1);
      end; //endfor
     end;


     if tipo=vtr4 then zblockread(f,spr,3); //spr text label for tr4.
     if tipo=vtr5 then zblockread(f,spr,4); //spr/0 text label for tr5.

     //sprites textures
     zblockread(f,aux,4);
     Num_spr_textures:=aux;
     zblockread(f, Spr_Textures[0], Num_spr_textures*16);


     //sprites sequencias
     zblockread(f,aux,4);
     num_spr_sequences:=aux;
     zblockread(f,spr_sequences[0], num_spr_sequences*8);


     //if tub file load the palette here
     if tipo=vtub then zblockread(f, Palette,768); //palette

     //cameras
     zblockread(f,aux,4);
     Num_cameras:=aux;
     zblockread(f, Cameras[0], Num_cameras*16);


     //tr4 unknow1 //flyby cameras
     if tipo>=vtr4 then
     begin
          zblockread(f,aux,4);
          Num_tr4_unknow1:=aux;
          zblockread(f, tr4_unknow1[0], Num_tr4_unknow1*40);
     end;


     //sound fxs
     zblockread(f,aux,4);
     Num_sound_fxs:=aux;
     zblockread(f, Sound_fxs[0], Num_sound_fxs*16);

     //boxes
     zblockread(f,aux,4);
     Num_boxes:=aux;

     if (tipo>=vtr2) then zblockread(f,boxes2[0], Num_boxes*8) else
                          zblockread(f,boxes[0] , Num_boxes*20);

     //overlaps
     zblockread(f,aux,4);
     Num_overlaps:=aux;
     zblockread(f, Overlaps[0], Num_overlaps*2);


     //zonas
     Num_zones:=Num_boxes;

     if tipo>=vtr2 then
     begin
         zblockread(f, nground_zone1[0], Num_zones*2);
         zblockread(f, nground_zone2[0], Num_zones*2);
         zblockread(f, nground_zone3[0], Num_zones*2);
         zblockread(f, nground_zone4[0], Num_zones*2);
         zblockread(f, nfly_zone[0]    , Num_zones*2);
         //----------
         zblockread(f, aground_zone1[0], Num_zones*2);
         zblockread(f, aground_zone2[0], Num_zones*2);
         zblockread(f, aground_zone3[0], Num_zones*2);
         zblockread(f, aground_zone4[0], Num_zones*2);
         zblockread(f, afly_zone[0]    , Num_zones*2);
     end //fin cargar zonas para tr2/tr3
     else
     begin
         zblockread(f, nground_zone1[0], Num_zones*2);
         zblockread(f, nground_zone2[0], Num_zones*2);
         zblockread(f, nfly_zone[0]    , Num_zones*2);
         //----------
         zblockread(f, aground_zone1[0], Num_zones*2);
         zblockread(f, aground_zone2[0], Num_zones*2);
         zblockread(f, afly_zone[0]    , Num_zones*2);
     end;//fin phd/tub


     //animated textures
     zblockread(f,aux,4);
     Num_anim_textures:=aux;
     zblockread(f, Anim_textures[0], Num_anim_textures*2);

    if progressbar<>nil then progressbar.progress:=85;
     //obj textures
     if tipo=vtr4 then zblockread(f,text,4); // 'tex\0' text label in tr4
     if tipo=vtr5 then zblockread(f,text,5); // '0tex\0' text label in tr5
     //solo tr3, tr4 y tr5 tiene los obj texturas aqui.
     if tipo>=vtr3 then
     begin
          zblockread(f,aux,4);
          Num_textures:=aux;

      //leer las texturas una por una. solo tr3 y tr4 y tr5 tienen las texturas aqui.
      for x:=0 to num_textures-1 do
      begin
          zblockread(f,textures[x].attrib,2);
          zblockread(f,textures[x].tile,2);

          if tipo>=vtr4 then zblockread(f,textures[x].flags,2);

          zblockread(f,textures[x].mx1,1);
          zblockread(f,textures[x].x1,1);
          zblockread(f,textures[x].my1,1);
          zblockread(f,textures[x].y1,1);
          zblockread(f,textures[x].mx2,1);
          zblockread(f,textures[x].x2,1);
          zblockread(f,textures[x].my2,1);
          zblockread(f,textures[x].y2,1);
          zblockread(f,textures[x].mx3,1);
          zblockread(f,textures[x].x3,1);
          zblockread(f,textures[x].my3,1);
          zblockread(f,textures[x].y3,1);
          zblockread(f,textures[x].mx4,1);
          zblockread(f,textures[x].x4,1);
          zblockread(f,textures[x].my4,1);
          zblockread(f,textures[x].y4,1);

          if tipo>=vtr4 then
          begin
             zblockread(f,textures[x].uk1,4);
             zblockread(f,textures[x].uk2,4);
             zblockread(f,textures[x].uk3,4);
             zblockread(f,textures[x].uk4,4);
          end;
          //tr5 unknow 2 bytes
          if tipo=vtr5 then zblockread(f,textures[x].uk5,2);

      end; //endfor
     end;

     if progressbar<>nil then progressbar.progress:=90;

     //Items
     zblockread(f,aux,4);
     Num_items:=aux;

     if (tipo>=vtr2) then
                              begin
                                 zblockread(f,items2[0], Num_items*sizeof(titem2));
                                 for k:=0 to num_items-1 do
                                 begin
                                     items[k].obj:=items2[k].obj;
                                     items[k].room:=items2[k].room;
                                     items[k].x:=items2[k].x;
                                     items[k].y:=items2[k].y;
                                     items[k].z:=items2[k].z;
                                     items[k].d:=items2[k].d;
                                     items[k].angle:=items2[k].angle;
                                     items[k].light1:=items2[k].light1;
                                     items[k].light2:=items2[k].light2;
                                     items[k].un1:=items2[k].un1;
                                   end; //endfor;
                               end //endtipo
     else
                              begin
                                 zblockread(f, items[0], Num_items*sizeof(titem));
                                 for k:=0 to num_items-1 do
                                 begin
                                     items2[k].obj:=items[k].obj;
                                     items2[k].room:=items[k].room;
                                     items2[k].x:=items[k].x;
                                     items2[k].y:=items[k].y;
                                     items2[k].z:=items[k].z;
                                     items2[k].d:=items[k].d;
                                     items2[k].angle:=items[k].angle;
                                     items2[k].light1:=items[k].light1;
                                     items2[k].light2:=items[k].light2;
                                     items2[k].un1:=items[k].un1;
                                   end; //endfor;

                              end;


     //colormap
   if tipo<vtr4 then
   begin
     zblockread(f,Colormap,32*256);

   end;

     //if phd file load the palette here
     if tipo=vtr1 then zblockread(f,Palette,768); //palette

     //cinematic frames
     if tipo<vtr4 then
        begin
           zblockread(f,aux_word,2);
           Num_cinematic_frames:=aux_word;
           zblockread(f, cinematic_frames[0], num_cinematic_frames*16);
        end
    else
        begin  //note that in tr4 and tr5 num_cinematic is 4 bytes.
            zblockread(f,aux,4);
            Num_cinematic_frames:=aux;
            zblockread(f, ai_table[0], num_cinematic_frames*24);
        end;

     //demo data
     zblockread(f,aux_word,2);
     Num_demo_data:=aux_word;

     zblockread(f, demo_data[0], num_demo_data);


     //sound_map

     if (tipo=vtr1) or (tipo=vtub) then zblockread(f, sound_map, 512);
     if (tipo>=vtr2) and (tipo<=vtr4) then zblockread(f, sound_map, 740);
     if tipo=vtr5 then zblockread(f, sound_map, 900);


     //samples info
     zblockread(f,aux,4);
     Num_samples_info:=aux;
     zblockread(f, samples_info[0], Num_samples_info*sizeof(tsample_info));

     //samples, only phd and tub have waves here
     if (tipo=vtr1) or (tipo=vtub) then
     begin
         zblockread(f,aux,4);
         samples_size:=aux;
         getmem( samples_buffer, samples_size);
         zblockread(f, samples_buffer^, samples_size);
     end;//end si phd or tub

     //samples offsets
     zblockread(f,aux,4);
     Num_samples_offsets:=aux;
     zblockread(f, samples_offsets[0], Num_samples_offsets*4);
     //si tr5, wav are here. but use ofset_wavs for avoid padded cdcdcd.
     if tipo=vtr5 then
     begin
         zseek(f,ofset_wavs);
         samples_size:=zfilesize(f)-zfilepos(f);
         getmem(samples_buffer,samples_size);
         zblockread(f,samples_buffer^,samples_size);
     end;

//***************************

     if progressbar<>nil then progressbar.progress:=100;
     zclosefile(f,false);
 end;{load level}
 result:=resultado;
     if progressbar<>nil then progressbar.progress:=0;
end;

//----
function ttrlevel.Save_Level(name:string):byte;
var
f:tzfile;
resultado:byte;
x:word;
k:word;
aux_word:word;
aux:longint;
ofset:longint;
comprimido,descomprimido:integer;
temp,temp2,temp3:pointer;
fx:file;
buf: array [0..1024] of byte;
xela:longint;
cd:longint;
//----
ofset1,ofset2,ofset3,
ofset4,ofset5,ofset6,
ofset7,ofset8,ofset9,ofset10,ofset11:longint;
data_start:longint;
zupdate:longint;
porcent,porcent2:real;
singledata:single;
begin

 if progressbar<>nil then progressbar.progress:=0;


 if valido<>'Tpascal' then begin result:=1;exit;end;

 //for the moment, use save_level2 for save back tr5 levels.
// if tipo=vtr5 then begin save_level2(name);exit;end;
 resultado:=0;

  zassignfile(f,name);
  zrewrite(f,1);

     //tipo=no version, 1=phd, 2=tub, 3=TR2, 3.5=TRg, 4=TR3, 5=tr4, 6=tr5
     case version of
          $20: if (pos('.TUB',name)<>0) or (pos('.tub',name)<>0) then tipo:=vTub else tipo:=VTr1;
          $2d: if (pos('.TRG',name)<>0) or (pos('.trg',name)<>0) then tipo:=vTrg else tipo:=vTR2;
          $ff080038,$ff180038:tipo:=vTR3;
     end;//end case

     //si tr4 o tr5 gravar el nivel primero, despues comprimir las texturas.
     if tipo<=vtr3 then zblockwrite(f,version,4);

     //si tr2 o tr3 cargar las paletas aqui.
     if (tipo=vtr2) or (tipo=vtrg) or (tipo=vtr3) then
     begin
          zblockwrite(f,Palette,768); //palette 256 colors
          zblockwrite(f,Palette16,1024); //palette 16bit colors
     end;


    if (tipo<>vtr4) and (tipo<>vtr5) then
    begin
     zBlockwrite(f, num_texture_pages,4); {get size textures 8 bit bitmaps}

     if progressbar<>nil then progressbar.progress:=30;

     zblockwrite(f, texture_data^, Size_Textures);

     //si tr2 o tr3 cargar las 16bit texturas bitmaps.
     if (tipo=vtr2) or (tipo=vtrg) or (tipo=vtr3) then
     begin
          Zblockwrite(f, texture_data2^, num_texture_pages*131072);
     end;//
     if progressbar<>nil then progressbar.progress:=50;

   end; //leer texturas en phd,tub,tr2 y tr3 levels.

//*****************************************************
//si tr5 entonces escribir el room data en forma especial
//*****************************************************
if tipo=vtr5 then
begin
fillchar(buf[0],1024,chr(0));
Zblockwrite(f, Tr5_Lara_type, 32); //unknow32 bytes

ofset1:=zfilepos(f);
Zblockwrite(f, tr5size_data1, 4); //sizedata1
Zblockwrite(f, tr5size_data2, 4); //sizedata2

aux:=0;
Zblockwrite(f, aux, 4); //unknown always 0
aux:=num_rooms; //-unused_rooms; //no save back the rooms with not layers.

Zblockwrite(f, aux, 4); //num rooms


porcent:=30/num_rooms;
porcent2:=0;

xela:=$414C4558;
cd:=$cdcdcdcd;
for x:=0 to num_rooms-1 do
begin
   Zblockwrite(f, xela, 4); //xela
   //after reading the whole room, calc how much paded bytes
   //are before the next room using chunk_start and chunk_size.
   if (tr5layertype and 2)=2 then begin
   ofset2:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.chunk_size, 4); //size next xela block

   Zblockwrite(f, cd, 4); //cdcdcdcd

   ofset3:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.ublock1,4);

   ofset4:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.ublock2,4);


   ofset5:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.ublock3,4);

   ofset6:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.ublock4,4);

   Zblockwrite(f, rooms[x].room_info.xpos_room,4); //X room position
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown1,4);
   Zblockwrite(f, rooms[x].room_info.zpos_room,4); //Z room position
   Zblockwrite(f, rooms[x].room_info.ymin,4); //Y botton podition
   Zblockwrite(f, rooms[x].room_info.ymax,4); //X room position
   Zblockwrite(f, rooms[x].sectors.largo,2); // Z amount sectors
   Zblockwrite(f, rooms[x].sectors.ancho,2); // X amount sectors
   Zblockwrite(f, rooms[x].tr5_unknowns.room_color,4);  //check

   Zblockwrite(f, rooms[x].source_lights.num_sources,2); // amount spot lights.
   Zblockwrite(f, rooms[x].statics.num_static,2); // amount statics ornaments
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown2,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown3,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown4,4);


   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, cd, 4); //cdcdcdcd
   //fillchar(buf,6,chr(255));
   fillchar(buf,4,chr(255));
   Zblockwrite(f, buf, 4); //6 bytes ffffffffff
   zblockwrite(f, rooms[x].alternate,2);//sapper
   Zblockwrite(f, rooms[x].water,1); // room flag
   Zblockwrite(f, rooms[x].d2,1); // room flag2
   Zblockwrite(f, rooms[x].tr5_flag,2); // Alternate room?

   fillchar(buf,10,chr(0));
   Zblockwrite(f, buf, 10); //10 bytes bytes 0
   Zblockwrite(f, cd, 4); //cdcdcdcd
 //----------------------------------------
//    rooms[x].tr5_unknowns.unknown5[9]:=0;   //if not 0 dynamic lights don't work->binoculars,lasersight,guns
//    rooms[x].tr5_unknowns.unknown5[10]:=0;
//    rooms[x].tr5_unknowns.unknown5[11]:=0;
//    rooms[x].tr5_unknowns.unknown5[12]:=0;
//    Zblockwrite(f, rooms[x].tr5_unknowns.unknown5[1],16); //unknown5 original
  Zblockwrite(f, rooms[x].tr5_unknowns.unknown5.data[1], 4); //desconocido 4 bytes.
  singledata:=rooms[x].room_info.xpos_room;
  Zblockwrite(f, singledata,4); //X room position
  aux:=0;
  Zblockwrite(f, aux, 4); //must be 0
singledata:=rooms[x].room_info.zpos_room;
 Zblockwrite(f, singledata,4); //Z room position
//--------------------------

   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown6,4); //unknown6
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, rooms[x].tr5_unknowns.total_triangles,4); //amount triangles
   Zblockwrite(f, rooms[x].tr5_unknowns.total_rectangles,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown7,4); //separador 4 bytes 0

   rooms[x].tr5_unknowns.lightsize:=rooms[x].source_lights.num_sources*88;

   Zblockwrite(f, rooms[x].tr5_unknowns.lightsize,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.numberlights,4);
   Zblockwrite(f, rooms[x].tr5unk8.num_unk8, 4); //unknown8.
// Zblockwrite(f, rooms[x].tr5_unknowns.unknown9,4);// ytop?
   Zblockwrite(f, rooms[x].room_info.ymax,4); //
// Zblockwrite(f, rooms[x].tr5_unknowns.unknown10,4);
   Zblockwrite(f, rooms[x].room_info.ymin,4); //

   aux:=1;
   Zblockwrite(f, aux, 4); //amount pieces in room.

   ofset7:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown11,4);

   ofset8:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown12,4);

   ofset9:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown13,4);

   ofset10:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown14,4);

   ofset11:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown15,4);

   Zblockwrite(f, cd, 4); //cdcdcdcd.
   Zblockwrite(f, cd, 4); //cdcdcdcd.
   Zblockwrite(f, cd, 4); //cdcdcdcd.
   Zblockwrite(f, cd, 4); //cdcdcdcd.

   data_start:=zfilepos(f);

   //write source lights
   Zblockwrite(f, rooms[x].source_lights.source_light4,rooms[x].source_lights.num_sources*sizeof(tsource_light4));

   //escribir structura desconocida, 36 bytes por registros.
   Zblockwrite(f,rooms[x].tr5unk8.data, rooms[x].tr5unk8.num_unk8*36);

   //actualizar ofset4 (sector data start)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset4);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------------------------


   //sector data
   Zblockwrite(f, rooms[x].sectors.sector, (rooms[x].sectors.largo*rooms[x].sectors.ancho)*sizeof(tsector));

   //actualizar ofset3 (sector data end)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset3);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   end; //zfex
   //---------------------------------

   aux_word:=rooms[x].doors.num_doors;
   Zblockwrite(f, aux_word, 2); //num doors.
   Zblockwrite(f, rooms[x].doors.door, aux_word*32); //door data

   Zblockwrite(f, cd, 2); //cdcd.

   //actualizar ofset6 (start staticmesh data)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset6);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------------------------
   Zblockwrite(f, rooms[x].statics.static2, rooms[x].statics.num_static*20); //static mesh

   //next come the layer data blocks.!!!
   //when the level is saved i put all polys using just one layer.

   //actualizar ofset7 (start layer data info)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset7);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------------------------
      aux:=rooms[x].vertices.num_vertices;
      Zblockwrite(f, aux, 4); //amount vertices in this layer

      if rooms[x].num_layers<>0 then aux_word:=rooms[x].layers[0].unknownl1 else aux_word:=0;
      Zblockwrite(f, aux_word, 2); //unknow16

      Zblockwrite(f, rooms[x].quads.num_quads, 2); //amount rectangles in this layer
      Zblockwrite(f,rooms[x].triangles.num_triangles, 2); //amount triangles in this layer

      if rooms[x].num_layers<>0 then Zblockwrite(f, rooms[x].layers[0].unknownl2, 46) else
                                     Zblockwrite(f, buf[0], 46);


     //actualizar ofset9 y ofset10(start rectangles/triangles data info)
     if (tr5layertype and 8)=8 then begin
     aux:=zfilepos(f);
     zupdate:=aux-data_start;
     zseek(f,ofset9);
     zblockwrite(f,zupdate,4);
     zblockwrite(f,zupdate,4);

     zseek(f,aux);
    //---------------------------------

     //start rectangles and triangles info.
      zblockwrite(f,rooms[x].quads.quad2,sizeof(tquad2)*rooms[x].quads.num_quads);
      zblockwrite(f, rooms[x].triangles.triangle2,sizeof(ttriangle2)*rooms[x].triangles.num_triangles);

     //si amount triangles no es par entonces hay un pad word.
      if (rooms[x].triangles.num_triangles mod 2)<>0 then zblockwrite(f,cd,2);


   //actualizar ofset8 (start vertices data info)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset8);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //we are gona use ofset8 for save above calc.
   ofset8:=aux;
   //---------------------------------

   //write vertices table
   zblockwrite(f,rooms[x].vertices.vertice3,sizeof(tvertice3)*rooms[x].vertices.num_vertices);

  //put a paded word;
  zblockwrite(f,cd,2);

   //actualizar size to next xela
   aux:=zfilepos(f);
   zupdate:=aux-(ofset2+4);
   zseek(f,ofset2);
   zblockwrite(f,zupdate,4);
   end;//zfex
  //actualizar ofset11 (start vertices data)
    zupdate:=aux-ofset8; //we used ofset8 for save start vertice data,
    zseek(f,ofset11);
    zblockwrite(f,zupdate,4);

    //back to next room
    zseek(f,aux);

//update % status
porcent2:=porcent2+porcent;
if progressbar<>nil then progressbar.progress:=50+trunc(porcent2);

end; //end leer todos los rooms.

end;//fin version tr5 write rooms en forma especial.
//******************************************************

//si version<tr5 entonces leer room data en forma normal
if tipo<>vtr5 then
begin
     zblockwrite(f, dumys,4);

     aux_word:=num_rooms;
     zblockwrite(f,aux_word,2);   {get total rooms}

     porcent:=30/num_rooms;
     porcent2:=0;


     {Cargar todos los Rooms.}
     for x:=0 to num_rooms-1 do
     begin
        //calcular amount words to store room geometry.

        if tipo>=vtr2 then
        rooms[x].room_info.num_words:=(((rooms[x].vertices.num_vertices*12)+
                                             (rooms[x].quads.num_quads*10)+
                                             (rooms[x].triangles.num_triangles*8)+
                                             (rooms[x].sprites.num_sprites*4))+8) div 2 else

        rooms[x].room_info.num_words:=(((rooms[x].vertices.num_vertices*8)+
                                             (rooms[x].quads.num_quads*10)+
                                             (rooms[x].triangles.num_triangles*8)+
                                             (rooms[x].sprites.num_sprites*4))+8) div 2;

          //Room info
          zblockwrite(f,rooms[x].room_info, sizeof(troom_info) );
          zblockwrite(f,rooms[x].vertices.num_vertices,2);


          //cargar los vertices deacuerdo a la version.
          if tipo>=vtr2 then
                  zblockwrite(f,rooms[x].vertices.vertice2, sizeof(tvertice2) * rooms[x].vertices.num_vertices )
                  else
                  zblockwrite(f,rooms[x].vertices.vertice, sizeof(tvertice) * rooms[x].vertices.num_vertices );


          zblockwrite(f,rooms[x].quads.num_quads,2);
          zblockwrite(f,rooms[x].quads.quad,  sizeof(tquad) * rooms[x].quads.num_quads );


          zblockwrite(f,rooms[x].triangles.num_triangles,2);
          zblockwrite(f,rooms[x].triangles.triangle,  sizeof(ttriangle) * rooms[x].triangles.num_triangles );


          zblockwrite(f,rooms[x].sprites.num_sprites,2);
          zblockwrite(f,rooms[x].sprites.sprite, sizeof(tsprite) * rooms[x].sprites.num_sprites);

          zblockwrite(f,rooms[x].doors.num_doors,2);
          zblockwrite(f,rooms[x].doors.door, sizeof(tdoor) * rooms[x].doors.num_doors );

          zblockwrite(f,rooms[x].sectors.largo,2);
          zblockwrite(f,rooms[x].sectors.ancho,2);
          zblockwrite(f,rooms[x].sectors.sector,  sizeof(tsector) * rooms[x].sectors.largo * rooms[x].sectors.ancho);
          zblockwrite(f,rooms[x].d0,1);
          zblockwrite(f,rooms[x].lara_light,1);

          //if tr2 o tr3 cargar sand efect en el room
          if tipo>=vtr2 then zblockwrite(f,rooms[x].sand_effect,2);
          if (tipo=vtr2) or (tipo=vtrg) then zblockwrite(f,rooms[x].light_mode,2);

          zblockwrite(f,rooms[x].Source_lights.num_sources,2);

          //si phd o tub
          if tipo<=vtub then zblockwrite(f,rooms[x].Source_lights.source_light, sizeof(tsource_light) * rooms[x].Source_lights.num_sources );
          //if tr2 o tr3
          if (tipo>=vtr2) and (tipo<=vtr3) then zblockwrite(f,rooms[x].Source_lights.source_light2, sizeof(tsource_light2) * rooms[x].Source_lights.num_sources );
          //si tr4 o tr5
          if tipo=vtr4 then zblockwrite(f,rooms[x].Source_lights.source_light3, sizeof(tsource_light3) * rooms[x].Source_lights.num_sources );

          zblockwrite(f, rooms[x].Statics.num_static,2);
        //if tr2 o tr3 cargar los statics objects
          if (tipo>=vtr2) then zblockwrite(f,rooms[x].statics.static2, sizeof(tstatic2) * rooms[x].statics.num_static ) else
                               zblockwrite(f,rooms[x].statics.static, sizeof(tstatic) * rooms[x].statics.num_static );

          zblockwrite(f,rooms[x].alternate,2);
          zblockwrite(f,rooms[x].water,1);
          zblockwrite(f,rooms[x].d2,1);
          //solo tr3 tiene lo siguiente.
          if tipo>=vtr3 then zblockwrite(f,rooms[x].room_color,3);

         //update % status
         porcent2:=porcent2+porcent;
         if progressbar<>nil then progressbar.progress:=50+trunc(porcent2);

     end; {fin cargar todos los rooms}

end;//escribir los rooms en forma normal.

   if progressbar<>nil then progressbar.progress:=80;

    //floor_data
   aux:=num_floor_data;
   zblockwrite(f,aux,4);
   zblockwrite(f,Floor_data[0], num_floor_data*2);

     //mesh words
     aux:=num_meshwords;
     zblockwrite(f,aux,4);
     zblockwrite(f, meshwords[0], num_meshwords*2);

     //mesh pointers
     aux:=num_meshpointers;
     zblockwrite(f,aux,4);
     zblockwrite(f, meshpointers[0], num_meshpointers *4);


     //anims
     aux:=num_anims;
     zblockwrite(f,aux,4);
     if tipo<vtr4 then zblockwrite(f, anims[0],num_anims*32) else
                       zblockwrite(f, anims2[0],num_anims*40);


     //structs
     aux:=num_structs;
     zblockwrite(f,aux,4);
     zblockwrite(f, Structs[0],num_structs*6);

     //ranges
     aux:=num_ranges;
     zblockwrite(f,aux,4);
     zblockwrite(f, Ranges[0], num_ranges*8);

     //bones1
     aux:=num_bones1;
     zblockwrite(f,aux,4);
     zblockwrite(f, Bones1[0], Num_bones1*2);


     //bones2
     aux:=num_bones2;
     zblockwrite(f,aux,4);
     zblockwrite(f, Bones2[0], Num_bones2*4);


     //frames
     aux:=num_frames;
     zblockwrite(f,aux,4);
     zblockwrite(f, Frames[0], Num_frames*2);


     //movables
     aux:=num_movables;
     zblockwrite(f,aux,4);

     if tipo<vtr5 then zblockwrite(f, movables[0], Num_movables*18)
                  else zblockwrite(f, movables2[0], Num_movables*20);


     //esto son los static mesh disponibles.
     aux:=num_static_table;
     zblockwrite(f,aux,4);
     zblockwrite(f, static_table[0], Num_static_table*32);


     //obj textures
     //solo tr1/tub and tr2 tiene los obj texturas aqui.
     if tipo<vtr3 then
     begin
          aux:=num_textures;
          zblockwrite(f,aux,4);
      //leer las texturas una por una.
      for x:=0 to num_textures-1 do
      begin
          zblockwrite(f,textures[x].attrib,2);
          zblockwrite(f,textures[x].tile,2);
          zblockwrite(f,textures[x].mx1,1);
          zblockwrite(f,textures[x].x1,1);
          zblockwrite(f,textures[x].my1,1);
          zblockwrite(f,textures[x].y1,1);
          zblockwrite(f,textures[x].mx2,1);
          zblockwrite(f,textures[x].x2,1);
          zblockwrite(f,textures[x].my2,1);
          zblockwrite(f,textures[x].y2,1);
          zblockwrite(f,textures[x].mx3,1);
          zblockwrite(f,textures[x].x3,1);
          zblockwrite(f,textures[x].my3,1);
          zblockwrite(f,textures[x].y3,1);
          zblockwrite(f,textures[x].mx4,1);
          zblockwrite(f,textures[x].x4,1);
          zblockwrite(f,textures[x].my4,1);
          zblockwrite(f,textures[x].y4,1);
      end; //endfor
     end;

     if tipo=vtr4 then zblockwrite(f,spr,3); //spr text label for tr4.
     if tipo=vtr5 then zblockwrite(f,spr,4); //spr/0 text label for tr5.

     //sprites textures
     aux:=num_spr_textures;
     zblockwrite(f,aux,4);
     zblockwrite(f, Spr_Textures[0], Num_spr_textures*16);


     //sprites sequencias
     aux:=num_spr_sequences;
     zblockwrite(f,aux,4);
     zblockwrite(f,spr_sequences[0], num_spr_sequences*8);


     //if tub file load the palette here
     if tipo=vtub then zblockwrite(f, Palette,768); //palette

     //cameras
     aux:=num_cameras;
     zblockwrite(f,aux,4);
     zblockwrite(f, Cameras[0], Num_cameras*16);
     //tr4 unknow1
     if tipo>=vtr4 then
     begin
          aux:=num_tr4_unknow1;
          zblockwrite(f,aux,4);
          if aux<>0 then zblockwrite(f, tr4_unknow1[0], Num_tr4_unknow1*40);
     end;


     //sound fxs
     aux:=num_sound_fxs;
     zblockwrite(f,aux,4);
     if aux<>0 then zblockwrite(f, Sound_fxs[0], Num_sound_fxs*16);

     //boxes

     aux:=num_boxes;
     zblockwrite(f,aux,4);

     if (tipo>=vtr2) then zblockwrite(f,boxes2[0], Num_boxes*8) else
                          zblockwrite(f,boxes[0] , Num_boxes*20);

     //overlaps
     aux:=num_overlaps;
     zblockwrite(f,aux,4);
     zblockwrite(f, Overlaps[0], Num_overlaps*2);


     //zonas

     if tipo>=vtr2 then
     begin
         zblockwrite(f, nground_zone1[0], Num_zones*2);
         zblockwrite(f, nground_zone2[0], Num_zones*2);
         zblockwrite(f, nground_zone3[0], Num_zones*2);
         zblockwrite(f, nground_zone4[0], Num_zones*2);
         zblockwrite(f, nfly_zone[0]    , Num_zones*2);
         //----------
         zblockwrite(f, aground_zone1[0], Num_zones*2);
         zblockwrite(f, aground_zone2[0], Num_zones*2);
         zblockwrite(f, aground_zone3[0], Num_zones*2);
         zblockwrite(f, aground_zone4[0], Num_zones*2);
         zblockwrite(f, afly_zone[0]    , Num_zones*2);
     end //fin cargar zonas para tr2/tr3
     else
     begin
         zblockwrite(f, nground_zone1[0], Num_zones*2);
         zblockwrite(f, nground_zone2[0], Num_zones*2);
         zblockwrite(f, nfly_zone[0]    , Num_zones*2);
         //----------
         zblockwrite(f, aground_zone1[0], Num_zones*2);
         zblockwrite(f, aground_zone2[0], Num_zones*2);
         zblockwrite(f, afly_zone[0]    , Num_zones*2);
     end;//fin phd/tub


     //animated textures

     aux:=num_anim_textures;
     zblockwrite(f,aux,4);
     if aux<>0 then zblockwrite(f, Anim_textures[0], Num_anim_textures*2);

    if progressbar<>nil then progressbar.progress:=85;
     //obj textures

     if tipo=vtr4 then zblockwrite(f,text,4); // 'tex\0' text label in tr4
     if tipo=vtr5 then zblockwrite(f,text,5); // '0tex\0' text label in tr5


     //solo tr3, tr4 y tr5 tiene los obj texturas aqui.
     if tipo>=vtr3 then
     begin
          aux:=num_textures;
          zblockwrite(f,aux,4);

      //leer las texturas una por una.
      for x:=0 to num_textures-1 do
      begin
          zblockwrite(f,textures[x].attrib,2);
          zblockwrite(f,textures[x].tile,2);
          if tipo>=vtr4 then zblockwrite(f,textures[x].flags,2);

          zblockwrite(f,textures[x].mx1,1);
          zblockwrite(f,textures[x].x1,1);
          zblockwrite(f,textures[x].my1,1);
          zblockwrite(f,textures[x].y1,1);
          zblockwrite(f,textures[x].mx2,1);
          zblockwrite(f,textures[x].x2,1);
          zblockwrite(f,textures[x].my2,1);
          zblockwrite(f,textures[x].y2,1);
          zblockwrite(f,textures[x].mx3,1);
          zblockwrite(f,textures[x].x3,1);
          zblockwrite(f,textures[x].my3,1);
          zblockwrite(f,textures[x].y3,1);
          zblockwrite(f,textures[x].mx4,1);
          zblockwrite(f,textures[x].x4,1);
          zblockwrite(f,textures[x].my4,1);
          zblockwrite(f,textures[x].y4,1);

          if tipo>=vtr4 then
          begin
             zblockwrite(f,textures[x].uk1,4);
             zblockwrite(f,textures[x].uk2,4);
             zblockwrite(f,textures[x].uk3,4);
             zblockwrite(f,textures[x].uk4,4);
          end;
          //tr5 unknow 2 bytes
          if tipo=vtr5 then zblockwrite(f,textures[x].uk5,2);

      end; //endfor
     end;


   if progressbar<>nil then progressbar.progress:=90;


     //Items
     aux:=num_items;
     zblockwrite(f,aux,4);


     if (tipo>=vtr2) then
                              begin
                                 zblockwrite(f,items2[0], Num_items*sizeof(titem2));
                               end //endtipo
     else
                              begin
                                 zblockwrite(f, items[0], Num_items*sizeof(titem));
                              end;


     //colormap
   if tipo<vtr4 then
   begin
     zblockwrite(f,Colormap,32*256);
   end;

     //if phd file load the palette here
     if tipo=vtr1 then zblockwrite(f,Palette,768); //palette

     //cinematic frames
     if tipo<vtr4 then
        begin
           aux_word:=Num_cinematic_frames;
           zblockwrite(f,aux_word,2);
           if aux_word<>0 then zblockwrite(f, cinematic_frames[0], num_cinematic_frames*16);
        end
    else
        begin  //note that in tr4 and tr5 num_cinematic is 4 bytes.
            aux:=num_cinematic_frames;
            zblockwrite(f,aux,4);
            if aux<>0 then zblockwrite(f, ai_table[0], num_cinematic_frames*24);
        end;

     //demo data
     aux_word:=num_demo_data;
     zblockwrite(f,aux_word,2);

     if aux_word<>0 then zblockwrite(f, demo_data[0], num_demo_data);


     //sound_map

     if (tipo=vtr1) or (tipo=vtub) then zblockwrite(f, sound_map, 512);
     if (tipo>=vtr2) and (tipo<=vtr4) then zblockwrite(f, sound_map, 740);
     if tipo=vtr5 then zblockwrite(f, sound_map, 900);

     //samples info
     aux:=num_samples_info;
     zblockwrite(f,aux,4);
     zblockwrite(f, samples_info[0], Num_samples_info*sizeof(tsample_info));

     //samples, only phd and tub have waves here
     if (tipo=vtr1) or (tipo=vtub) then
     begin
         aux:=samples_size;
         zblockwrite(f,aux,4);
         zblockwrite(f, samples_buffer^, samples_size);
     end;//end si phd or tub

     //samples offsets
     aux:=num_samples_offsets;
     zblockwrite(f,aux,4);
     zblockwrite(f, samples_offsets[0], Num_samples_offsets*4);



//si tr5 then update ofset1 (size to wave-riffs)

if tipo=vtr5 then
begin
   zblockwrite(f,cd,4); //add 4 paded cdcdcdcd
   aux:=zfilepos(f);
   zupdate:=aux-(ofset1+8);
   zseek(f,ofset1);
   zblockwrite(f,zupdate,4);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------
end;


//si es tr4 y tr5 armar y comprimir las texturas aqui
If tipo>=vtr4 then
   begin
       aux:=zfilesize(f);
       getmem(temp2,aux);
       zseek(f,0);
       zblockread(f,temp2^,aux);
       //temp2 tiene el chunk del nivel, aux el tamaño

       zseek(f,0);
       //grabar la version
       zblockwrite(f,version,4);
       // Crear y comprimir el chunk de las texturas
       zblockwrite(f,Num_nonbump_tiles,2);
       zblockwrite(f,Num_object_tiles,2);
       zblockwrite(f,num_bump_tiles,2);
       //comprimir 32bit textures.
       uncompressed32bitT:=size_textures*4;
       zlib_compress(texture_data3, uncompressed32bitT,temp,compressed32bitT);

       zblockwrite(f,uncompressed32bitT,4);
       zblockwrite(f,compressed32bitT,4);
       zblockwrite(f,temp^,compressed32bitT);
       freemem(temp);

       //comprimir 16bit textures.
       uncompressed16bitT:=size_textures*2;
       zlib_compress(texture_data2, uncompressed16bitT,temp,compressed16bitT);

       zblockwrite(f,uncompressed16bitT,4);
       zblockwrite(f,compressed16bitT,4);
       zblockwrite(f,temp^,compressed16bitT);
       freemem(temp);

       //comprimir xbit textures.
       //xbit textures not actualized for now.
       //uncompressed16bitT:=size_textures*2;
       zlib_compress(texture_data4, uncompressedxbitT,temp,compressedxbitT);

       zblockwrite(f,uncompressedxbitT,4);
       zblockwrite(f,compressedxbitT,4);
       zblockwrite(f,temp^,compressedxbitT);
       freemem(temp);

       //comprimir el resto del nivel

       if tipo=vtr4 then
       begin
        descomprimido:=aux;
        zlib_compress(temp2, descomprimido,temp,comprimido);

        zblockwrite(f,descomprimido,4);
        zblockwrite(f,comprimido,4);

        zblockwrite(f,temp^,comprimido);
         freemem(temp);
       end
       else zblockwrite(f,temp2^,aux);

       freemem(temp2);

        //gravar los wave samples.
        zblockwrite(f,samples_buffer^,samples_size);
   end;//----fin si tr4 y tr5 levels
     if progressbar<>nil then progressbar.progress:=100;
     zclosefile(f);
     result:=resultado;
     if progressbar<>nil then progressbar.progress:=0;
end;

//this is for save tr5 levels with originals layers.

function ttrlevel.Save_Level2(name:string):byte;
var
f:tzfile;
resultado:byte;
x:word;
k:word;
aux_word:word;
aux:longint;
ofset:longint;
comprimido,descomprimido:integer;
temp,temp2,temp3:pointer;
fx:file;
buf: array [0..1024] of byte;
xela:longint;
cd:longint;
//----
ofset1,ofset2,ofset3,
ofset4,ofset5,ofset6,
ofset7,ofset8,ofset9,ofset10,ofset11:longint;
data_start:longint;
zupdate:longint;
kk:integer;
begin

 if progressbar<>nil then progressbar.progress:=0;


 if valido<>'Tpascal' then begin result:=1;exit;end;

 resultado:=0;

  zassignfile(f,name);
  zrewrite(f,1);

     //tipo=no version, 1=phd, 2=tub, 3=TR2, 3.5=TRg, 4=TR3, 5=tr4, 6=tr5
     case version of
          $20: if (pos('.TUB',name)<>0) or (pos('.tub',name)<>0) then tipo:=vTub else tipo:=VTr1;
          $2d: if (pos('.TRG',name)<>0) or (pos('.trg',name)<>0) then tipo:=vTrg else tipo:=vTR2;
          $ff080038,$ff180038:tipo:=vTR3;
          $fffffff0,$00345254:if (pos('.TRC',name)<>0) or (pos('.trc',name)<>0) then tipo:=vtr5 else tipo:=vtr4;
     end;//end case

     //si tr4 o tr5 gravar el nivel primero, despues comprimir las texturas.
     if tipo<=vtr3 then zblockwrite(f,version,4);

     //si tr2 o tr3 cargar las paletas aqui.
     if (tipo=vtr2) or (tipo=vtrg) or (tipo=vtr3) then
     begin
          zblockwrite(f,Palette,768); //palette 256 colors
          zblockwrite(f,Palette16,1024); //palette 16bit colors
     end;


    if (tipo<>vtr4) and (tipo<>vtr5) then
    begin
     zBlockwrite(f, num_texture_pages,4); {get size textures 8 bit bitmaps}

     if progressbar<>nil then progressbar.progress:=30;

     zblockwrite(f, texture_data^, Size_Textures);

     //si tr2 o tr3 cargar las 16bit texturas bitmaps.
     if (tipo=vtr2) or (tipo=vtrg) or (tipo=vtr3) then
     begin
          Zblockwrite(f, texture_data2^, num_texture_pages*131072);
     end;//
     if progressbar<>nil then progressbar.progress:=50;

   end; //leer texturas en phd,tub,tr2 y tr3 levels.


//*****************************************************
//si tr5 entonces escribir el room data en forma especial
//*****************************************************
if tipo=vtr5 then
begin
fillchar(buf[0],1024,chr(0));
Zblockwrite(f, tr5_lara_type, 32); //unknow32 bytes

ofset1:=zfilepos(f);
Zblockwrite(f, tr5size_data1, 4); //sizedata1
Zblockwrite(f, tr5size_data2, 4); //sizedata2

aux:=0;
Zblockwrite(f, aux, 4); //unknown always 0
aux:=num_rooms; //-unused_rooms; //no save back the rooms with not layers.
Zblockwrite(f, aux, 4); //num rooms

xela:=$414C4558;
cd:=$cdcdcdcd;
for x:=0 to num_rooms-1 do
begin
   Zblockwrite(f, xela, 4); //xela
   //after reading the whole room, calc how much paded bytes
   //are before the next room using chunk_start and chunk_size.
   if (tr5layertype and 2)=2 then begin
   ofset2:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.chunk_size, 4); //size next xela block

   Zblockwrite(f, cd, 4); //cdcdcdcd

   ofset3:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.ublock1,4);

   ofset4:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.ublock2,4);


   ofset5:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.ublock3,4);

   ofset6:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.ublock4,4);

   Zblockwrite(f, rooms[x].room_info.xpos_room,4); //X room position
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown1,4);
   Zblockwrite(f, rooms[x].room_info.zpos_room,4); //Z room position
   Zblockwrite(f, rooms[x].room_info.ymin,4); //Y botton podition
   Zblockwrite(f, rooms[x].room_info.ymax,4); //X room position
   Zblockwrite(f, rooms[x].sectors.largo,2); // Z amount sectors
   Zblockwrite(f, rooms[x].sectors.ancho,2); // X amount sectors
   Zblockwrite(f, rooms[x].tr5_unknowns.room_color,4);

   Zblockwrite(f, rooms[x].source_lights.num_sources,2); // amount spot lights.
   Zblockwrite(f, rooms[x].statics.num_static,2); // amount statics ornaments
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown2,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown3,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown4,4);


   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, cd, 4); //cdcdcdcd
   fillchar(buf,6,chr(255));
   Zblockwrite(f, buf, 6); //6 bytes ffffffffff
   Zblockwrite(f, rooms[x].water,1); // room flag
   Zblockwrite(f, rooms[x].d2,1); // room flag2
   Zblockwrite(f, rooms[x].tr5_flag,2); // Alternate room?

   fillchar(buf,10,chr(0));
   Zblockwrite(f, buf, 10); //10 bytes bytes 0
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown5.data[1],16); //unknown5
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown6,4); //unknown6
   Zblockwrite(f, cd, 4); //cdcdcdcd
   Zblockwrite(f, rooms[x].tr5_unknowns.total_triangles,4); //amount triangles
   Zblockwrite(f, rooms[x].tr5_unknowns.total_rectangles,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown7,4);

   rooms[x].tr5_unknowns.lightsize:=rooms[x].source_lights.num_sources*88;

   Zblockwrite(f, rooms[x].tr5_unknowns.lightsize,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.numberlights,4);
   Zblockwrite(f, rooms[x].tr5unk8.num_unk8, 4); //unknown8.
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown9,4);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown10,4);

   aux:=rooms[x].num_layers;
   Zblockwrite(f, aux, 4); //amount pieces in room.

   ofset7:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown11,4);

   ofset8:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown12,4);

   ofset9:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown13,4);

   ofset10:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown14,4);

   ofset11:=zfilepos(f);
   Zblockwrite(f, rooms[x].tr5_unknowns.unknown15,4);

   Zblockwrite(f, cd, 4); //cdcdcdcd.
   Zblockwrite(f, cd, 4); //cdcdcdcd.
   Zblockwrite(f, cd, 4); //cdcdcdcd.
   Zblockwrite(f, cd, 4); //cdcdcdcd.

   data_start:=zfilepos(f);


   for k:=1 to rooms[x].source_lights.num_sources do
   begin
      Zblockwrite(f, rooms[x].source_lights.source_light4, 85);
      Zblockwrite(f, cd, 3); //cdcdcd.
   end;//fin read all source lights

   //escribir structura desconocida, 36 bytes por registros.
   Zblockwrite(f,rooms[x].tr5unk8.data, rooms[x].tr5unk8.num_unk8*36);

   //actualizar ofset4 (sector data start)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset4);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------------------------


   //sector data
   Zblockwrite(f, rooms[x].sectors.sector, (rooms[x].sectors.largo*rooms[x].sectors.ancho)*sizeof(tsector));

   //actualizar ofset3 (sector data end)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset3);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   end; //zfex
   //---------------------------------

   aux_word:=rooms[x].doors.num_doors;
   Zblockwrite(f, aux_word, 2); //num doors.
   Zblockwrite(f, rooms[x].doors.door, aux_word*32); //door data

   //actualizar ofset6 (start statics meshes? data)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset6);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------------------------
   Zblockwrite(f, cd, 2); //cdcd.
   //actualizar ofset6 (start statics meshes? data)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset6);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------------------------
   Zblockwrite(f, rooms[x].statics.static2, rooms[x].statics.num_static*20); //static mesh

   //next come the layer data blocks.!!!
   //actualizar ofset7 (start layer data info)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset7);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------------------------
   //write layers

if rooms[x].num_layers<>0 then
begin
   for k:=0 to rooms[x].num_layers-1 do
   begin
      Zblockwrite(f,rooms[x].layers[k].num_vertices, 4); //amount vertices in this layer
      Zblockwrite(f,rooms[x].layers[k].unknownl1, 2); //unknow16
      Zblockwrite(f,rooms[x].layers[k].num_rectangles, 2); //amount rectangles in this layer
      Zblockwrite(f,rooms[x].layers[k].num_triangles, 2); //amount triangles in this layer

      Zblockwrite(f, rooms[x].layers[k].unknownl2, 46); //46 bytes.
   end;
   //write rectangles and triangles

    //actualizar ofset9 y ofset10(start rectangles/triangles data info)
     if (tr5layertype and 8)=8 then begin
     aux:=zfilepos(f);
     zupdate:=aux-data_start;
     zseek(f,ofset9);
     zblockwrite(f,zupdate,4);
     zblockwrite(f,zupdate,4);
     zseek(f,aux);
    //---------------------------------
    //start rectangles and triangles info.
    for k:=0 to rooms[x].num_layers-1 do
    begin
        zblockwrite(f,rooms[x].tr5_layers.quads[k].quad2,sizeof(tquad2)*rooms[x].layers[k].num_rectangles);
        zblockwrite(f,rooms[x].tr5_layers.triangles[k].triangle2,sizeof(ttriangle2)*rooms[x].layers[k].num_triangles);
    end;

   //si amount triangles no es par entonces hay un pad word.
   if (rooms[x].triangles.num_triangles mod 2)<>0 then zblockwrite(f,cd,2);

   //actualizar ofset8 (start vertices data info)
   aux:=zfilepos(f);
   zupdate:=aux-data_start;
   zseek(f,ofset8);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //we are gona use ofset8 for save above calc.
   ofset8:=aux;
   //---------------------------------
   for k:=0 to rooms[x].num_layers-1 do
   begin
       zblockwrite(f,rooms[x].tr5_layers.vertices[k].vertice3,sizeof(tvertice3)*rooms[x].tr5_layers.vertices[k].num_vertices);
   end;

end; //end if layer is not null

//put padded bytes.
fillchar(buf[0],rooms[x].tr5_numpads,chr($cd));
Zblockwrite(f, buf,rooms[x].tr5_numpads);

   //actualizar size to next xela
   aux:=zfilepos(f);
   zupdate:=aux-(ofset2+4);
   zseek(f,ofset2);
   zblockwrite(f,zupdate,4);
   end;//zfex
  //actualizar ofset11 (start vertices data)
    zupdate:=aux-ofset8; //we used ofset8 for save start vertice data,
    zseek(f,ofset11);
   zblockwrite(f,zupdate,4);

    //back to next room
    zseek(f,aux);

end; //end leer todos los rooms.

end;//fin version tr5 write rooms en forma especial.
//******************************************************

//si version<tr5 entonces leer room data en forma normal
if tipo<>vtr5 then
begin
     zblockwrite(f, dumys,4);

     aux_word:=num_rooms;
     zblockwrite(f,aux_word,2);   {get total rooms}

     {Cargar todos los Rooms.}
     for x:=0 to num_rooms-1 do
     begin
        //calcular amount words to store room geometry.

        if tipo>=vtr2 then
        rooms[x].room_info.num_words:=(((rooms[x].vertices.num_vertices*12)+
                                             (rooms[x].quads.num_quads*10)+
                                             (rooms[x].triangles.num_triangles*8)+
                                             (rooms[x].sprites.num_sprites*4))+8) div 2 else

        rooms[x].room_info.num_words:=(((rooms[x].vertices.num_vertices*8)+
                                             (rooms[x].quads.num_quads*10)+
                                             (rooms[x].triangles.num_triangles*8)+
                                             (rooms[x].sprites.num_sprites*4))+8) div 2;

          //Room info
          zblockwrite(f,rooms[x].room_info, sizeof(troom_info) );
          zblockwrite(f,rooms[x].vertices.num_vertices,2);


          //cargar los vertices deacuerdo a la version.
          if tipo>=vtr2 then
                  zblockwrite(f,rooms[x].vertices.vertice2, sizeof(tvertice2) * rooms[x].vertices.num_vertices )
                  else
                  zblockwrite(f,rooms[x].vertices.vertice, sizeof(tvertice) * rooms[x].vertices.num_vertices );


          zblockwrite(f,rooms[x].quads.num_quads,2);
          zblockwrite(f,rooms[x].quads.quad,  sizeof(tquad) * rooms[x].quads.num_quads );


          zblockwrite(f,rooms[x].triangles.num_triangles,2);
          zblockwrite(f,rooms[x].triangles.triangle,  sizeof(ttriangle) * rooms[x].triangles.num_triangles );


          zblockwrite(f,rooms[x].sprites.num_sprites,2);
          zblockwrite(f,rooms[x].sprites.sprite, sizeof(tsprite) * rooms[x].sprites.num_sprites);

          zblockwrite(f,rooms[x].doors.num_doors,2);
          zblockwrite(f,rooms[x].doors.door, sizeof(tdoor) * rooms[x].doors.num_doors );

          zblockwrite(f,rooms[x].sectors.largo,2);
          zblockwrite(f,rooms[x].sectors.ancho,2);
          zblockwrite(f,rooms[x].sectors.sector,  sizeof(tsector) * rooms[x].sectors.largo * rooms[x].sectors.ancho);
          zblockwrite(f,rooms[x].d0,1);
          zblockwrite(f,rooms[x].lara_light,1);

          //if tr2 o tr3 cargar sand efect en el room
          if tipo>=vtr2 then zblockwrite(f,rooms[x].sand_effect,2);
          if (tipo=vtr2) or (tipo=vtrg) then zblockwrite(f,rooms[x].light_mode,2);

          zblockwrite(f,rooms[x].Source_lights.num_sources,2);

          //si phd o tub
          if tipo<=vtub then zblockwrite(f,rooms[x].Source_lights.source_light, sizeof(tsource_light) * rooms[x].Source_lights.num_sources );
          //if tr2 o tr3
          if (tipo>=vtr2) and (tipo<=vtr3) then zblockwrite(f,rooms[x].Source_lights.source_light2, sizeof(tsource_light2) * rooms[x].Source_lights.num_sources );
          //si tr4 o tr5
          if tipo>=vtr4 then zblockwrite(f,rooms[x].Source_lights.source_light3, sizeof(tsource_light3) * rooms[x].Source_lights.num_sources );

          zblockwrite(f, rooms[x].Statics.num_static,2);
        //if tr2 o tr3 cargar los statics objects
          if (tipo>=vtr2) then zblockwrite(f,rooms[x].statics.static2, sizeof(tstatic2) * rooms[x].statics.num_static ) else
                               zblockwrite(f,rooms[x].statics.static, sizeof(tstatic) * rooms[x].statics.num_static );

          zblockwrite(f,rooms[x].alternate,2);
          zblockwrite(f,rooms[x].water,1);
          zblockwrite(f,rooms[x].d2,1);
          //solo tr3 tiene lo siguiente.
          if tipo>=vtr3 then zblockwrite(f,rooms[x].room_color,3);


     end; {fin cargar todos los rooms}

end;//escribir los rooms en forma normal.


   if progressbar<>nil then progressbar.progress:=80;

    //floor_data
   aux:=num_floor_data;
   zblockwrite(f,aux,4);
   zblockwrite(f,Floor_data[0], num_floor_data*2);

     //mesh words
     aux:=num_meshwords;
     zblockwrite(f,aux,4);
     zblockwrite(f, meshwords[0], num_meshwords*2);

     //mesh pointers
     aux:=num_meshpointers;
     zblockwrite(f,aux,4);
     zblockwrite(f, meshpointers[0], num_meshpointers *4);


     //anims
     aux:=num_anims;
     zblockwrite(f,aux,4);
     if tipo<vtr4 then zblockwrite(f, anims[0],num_anims*32) else
                       zblockwrite(f, anims2[0],num_anims*40);


     //structs
     aux:=num_structs;
     zblockwrite(f,aux,4);
     zblockwrite(f, Structs[0],num_structs*6);

     //ranges
     aux:=num_ranges;
     zblockwrite(f,aux,4);
     zblockwrite(f, Ranges[0], num_ranges*8);

     //bones1
     aux:=num_bones1;
     zblockwrite(f,aux,4);
     zblockwrite(f, Bones1[0], Num_bones1*2);


     //bones2
     aux:=num_bones2;
     zblockwrite(f,aux,4);
     zblockwrite(f, Bones2[0], Num_bones2*4);


     //frames
     aux:=num_frames;
     zblockwrite(f,aux,4);
     zblockwrite(f, Frames[0], Num_frames*2);


     //movables
     aux:=num_movables;
     zblockwrite(f,aux,4);

     if tipo<vtr5 then zblockwrite(f, movables[0], Num_movables*18)
                  else zblockwrite(f, movables2[0], Num_movables*20);



     //esto son los static mesh disponibles.
     aux:=num_static_table;
     zblockwrite(f,aux,4);
     zblockwrite(f, static_table[0], Num_static_table*32);


     //obj textures
     //solo tr1/tub and tr2 tiene los obj texturas aqui.
     if tipo<vtr3 then
     begin
          aux:=num_textures;
          zblockwrite(f,aux,4);
      //leer las texturas una por una.
      for x:=0 to num_textures-1 do
      begin
          zblockwrite(f,textures[x].attrib,2);
          zblockwrite(f,textures[x].tile,2);
          zblockwrite(f,textures[x].mx1,1);
          zblockwrite(f,textures[x].x1,1);
          zblockwrite(f,textures[x].my1,1);
          zblockwrite(f,textures[x].y1,1);
          zblockwrite(f,textures[x].mx2,1);
          zblockwrite(f,textures[x].x2,1);
          zblockwrite(f,textures[x].my2,1);
          zblockwrite(f,textures[x].y2,1);
          zblockwrite(f,textures[x].mx3,1);
          zblockwrite(f,textures[x].x3,1);
          zblockwrite(f,textures[x].my3,1);
          zblockwrite(f,textures[x].y3,1);
          zblockwrite(f,textures[x].mx4,1);
          zblockwrite(f,textures[x].x4,1);
          zblockwrite(f,textures[x].my4,1);
          zblockwrite(f,textures[x].y4,1);
      end; //endfor
     end;

     if tipo=vtr4 then zblockwrite(f,spr,3); //spr text label for tr4.
     if tipo=vtr5 then zblockwrite(f,spr,4); //spr/0 text label for tr5.

     //sprites textures
     aux:=num_spr_textures;
     zblockwrite(f,aux,4);
     zblockwrite(f, Spr_Textures[0], Num_spr_textures*16);


     //sprites sequencias
     aux:=num_spr_sequences;
     zblockwrite(f,aux,4);
     zblockwrite(f,spr_sequences[0], num_spr_sequences*8);


     //if tub file load the palette here
     if tipo=vtub then zblockwrite(f, Palette,768); //palette

     //cameras
     aux:=num_cameras;
     zblockwrite(f,aux,4);
     zblockwrite(f, Cameras[0], Num_cameras*16);


     //tr4 unknow1
     if tipo>=vtr4 then
     begin
          aux:=num_tr4_unknow1;
          zblockwrite(f,aux,4);
          zblockwrite(f, tr4_unknow1[0], Num_tr4_unknow1*40);
     end;


     //sound fxs
     aux:=num_sound_fxs;
     zblockwrite(f,aux,4);
     zblockwrite(f, Sound_fxs[0], Num_sound_fxs*16);

     //boxes

     aux:=num_boxes;
     zblockwrite(f,aux,4);

     if (tipo>=vtr2) then zblockwrite(f,boxes2[0], Num_boxes*8) else
                          zblockwrite(f,boxes[0] , Num_boxes*20);

     //overlaps
     aux:=num_overlaps;
     zblockwrite(f,aux,4);
     zblockwrite(f, Overlaps[0], Num_overlaps*2);


     //zonas

     if tipo>=vtr2 then
     begin
         zblockwrite(f, nground_zone1[0], Num_zones*2);
         zblockwrite(f, nground_zone2[0], Num_zones*2);
         zblockwrite(f, nground_zone3[0], Num_zones*2);
         zblockwrite(f, nground_zone4[0], Num_zones*2);
         zblockwrite(f, nfly_zone[0]    , Num_zones*2);
         //----------
         zblockwrite(f, aground_zone1[0], Num_zones*2);
         zblockwrite(f, aground_zone2[0], Num_zones*2);
         zblockwrite(f, aground_zone3[0], Num_zones*2);
         zblockwrite(f, aground_zone4[0], Num_zones*2);
         zblockwrite(f, afly_zone[0]    , Num_zones*2);
     end //fin cargar zonas para tr2/tr3
     else
     begin
         zblockwrite(f, nground_zone1[0], Num_zones*2);
         zblockwrite(f, nground_zone2[0], Num_zones*2);
         zblockwrite(f, nfly_zone[0]    , Num_zones*2);
         //----------
         zblockwrite(f, aground_zone1[0], Num_zones*2);
         zblockwrite(f, aground_zone2[0], Num_zones*2);
         zblockwrite(f, afly_zone[0]    , Num_zones*2);
     end;//fin phd/tub


     //animated textures

     aux:=num_anim_textures;
     zblockwrite(f,aux,4);
     zblockwrite(f, Anim_textures[0], Num_anim_textures*2);

    if progressbar<>nil then progressbar.progress:=85;
     //obj textures
     if tipo=vtr4 then zblockwrite(f,text,4); // 'tex\0' text label in tr4
     if tipo=vtr5 then zblockwrite(f,text,5); // '0tex\0' text label in tr5

     //solo tr3, tr4 y tr5 tiene los obj texturas aqui.
     if tipo>=vtr3 then
     begin
          aux:=num_textures;
          zblockwrite(f,aux,4);

      //leer las texturas una por una.
      for x:=0 to num_textures-1 do
      begin
          zblockwrite(f,textures[x].attrib,2);
          zblockwrite(f,textures[x].tile,2);
          if tipo>=vtr4 then zblockwrite(f,textures[x].flags,2);

          zblockwrite(f,textures[x].mx1,1);
          zblockwrite(f,textures[x].x1,1);
          zblockwrite(f,textures[x].my1,1);
          zblockwrite(f,textures[x].y1,1);
          zblockwrite(f,textures[x].mx2,1);
          zblockwrite(f,textures[x].x2,1);
          zblockwrite(f,textures[x].my2,1);
          zblockwrite(f,textures[x].y2,1);
          zblockwrite(f,textures[x].mx3,1);
          zblockwrite(f,textures[x].x3,1);
          zblockwrite(f,textures[x].my3,1);
          zblockwrite(f,textures[x].y3,1);
          zblockwrite(f,textures[x].mx4,1);
          zblockwrite(f,textures[x].x4,1);
          zblockwrite(f,textures[x].my4,1);
          zblockwrite(f,textures[x].y4,1);

          if tipo>=vtr4 then
          begin
             zblockwrite(f,textures[x].uk1,4);
             zblockwrite(f,textures[x].uk2,4);
             zblockwrite(f,textures[x].uk3,4);
             zblockwrite(f,textures[x].uk4,4);
          end;
          //tr5 unknow 2 bytes
          if tipo=vtr5 then zblockwrite(f,textures[x].uk5,2);

      end; //endfor
     end;


   if progressbar<>nil then progressbar.progress:=90;


     //Items
     aux:=num_items;
     zblockwrite(f,aux,4);


     if (tipo>=vtr2) then
                              begin
                                 zblockwrite(f,items2[0], Num_items*sizeof(titem2));
                               end //endtipo
     else
                              begin
                                 zblockwrite(f, items[0], Num_items*sizeof(titem));
                              end;


     //colormap
   if tipo<vtr4 then
   begin
     zblockwrite(f,Colormap,32*256);
   end;

     //if phd file load the palette here
     if tipo=vtr1 then zblockwrite(f,Palette,768); //palette

     //cinematic frames
     if tipo<vtr4 then
        begin
           aux_word:=Num_cinematic_frames;
           zblockwrite(f,aux_word,2);
           zblockwrite(f, cinematic_frames[0], num_cinematic_frames*16);
        end
    else
        begin  //note that in tr4 and tr5 num_cinematic is 4 bytes.
            aux:=num_cinematic_frames;
            zblockwrite(f,aux,4);
            zblockwrite(f, ai_table[0], num_cinematic_frames*24);
        end;

     //demo data
     aux_word:=num_demo_data;
     zblockwrite(f,aux_word,2);

     zblockwrite(f, demo_data[0], num_demo_data);


     //sound_map

     if (tipo=vtr1) or (tipo=vtub) then zblockwrite(f, sound_map, 512);
     if (tipo>=vtr2) and (tipo<=vtr4) then zblockwrite(f, sound_map, 740);
     if tipo=vtr5 then zblockwrite(f, sound_map, 900);

     //samples info
     aux:=num_samples_info;
     zblockwrite(f,aux,4);
     zblockwrite(f, samples_info[0], Num_samples_info*sizeof(tsample_info));

     //samples, only phd and tub have waves here
     if (tipo=vtr1) or (tipo=vtub) then
     begin
         aux:=samples_size;
         zblockwrite(f,aux,4);
         zblockwrite(f, samples_buffer^, samples_size);
     end;//end si phd or tub

     //samples offsets
     aux:=num_samples_offsets;
     zblockwrite(f,aux,4);
     zblockwrite(f, samples_offsets[0], Num_samples_offsets*4);


//si tr5 then update ofset1 (size to wave-riffs)

if tipo=vtr5 then
begin
   zblockwrite(f,cd,4); //add 4 paded cdcdcdcd
   aux:=zfilepos(f);
   zupdate:=aux-(ofset1+8);
   zseek(f,ofset1);
   zblockwrite(f,zupdate,4);
   zblockwrite(f,zupdate,4);
   zseek(f,aux);
   //---------------
end;


//si es tr4 y tr5 armar y comprimir las texturas aqui
If tipo>=vtr4 then
   begin
       aux:=zfilesize(f);
       getmem(temp2,aux);
       zseek(f,0);
       zblockread(f,temp2^,aux);
       //temp2 tiene el chunk del nivel, aux el tamaño

       zseek(f,0);
       //grabar la version
       zblockwrite(f,version,4);
       // Crear y comprimir el chunk de las texturas
       zblockwrite(f,Num_nonBump_tiles,2);
       zblockwrite(f,Num_object_tiles,2);
       zblockwrite(f,Num_bump_tiles,2);
       //comprimir 32bit textures.
       uncompressed32bitT:=size_textures*4;
       zlib_compress(texture_data3, uncompressed32bitT,temp,compressed32bitT);

       zblockwrite(f,uncompressed32bitT,4);
       zblockwrite(f,compressed32bitT,4);
       zblockwrite(f,temp^,compressed32bitT);
       freemem(temp);

       //comprimir 16bit textures.
       uncompressed16bitT:=size_textures*2;
       zlib_compress(texture_data2, uncompressed16bitT,temp,compressed16bitT);

       zblockwrite(f,uncompressed16bitT,4);
       zblockwrite(f,compressed16bitT,4);
       zblockwrite(f,temp^,compressed16bitT);
       freemem(temp);

       //comprimir xbit textures.
       //xbit textures not actualized for now.
       //uncompressed16bitT:=size_textures*2;
       zlib_compress(texture_data4, uncompressedxbitT,temp,compressedxbitT);

       zblockwrite(f,uncompressedxbitT,4);
       zblockwrite(f,compressedxbitT,4);
       zblockwrite(f,temp^,compressedxbitT);
       freemem(temp);

       //comprimir el resto del nivel

       if tipo=vtr4 then
       begin
        descomprimido:=aux;
        zlib_compress(temp2, descomprimido,temp,comprimido);

        zblockwrite(f,descomprimido,4);
        zblockwrite(f,comprimido,4);

        zblockwrite(f,temp^,comprimido);
         freemem(temp);
       end
       else zblockwrite(f,temp2^,aux);

       freemem(temp2);

        //gravar los wave samples.
        zblockwrite(f,samples_buffer^,samples_size);
   end;//----fin si tr4 y tr5 levels
     if progressbar<>nil then progressbar.progress:=100;
     zclosefile(f);
     result:=resultado;
     if progressbar<>nil then progressbar.progress:=0;

end;

//**********************




procedure ttrlevel.tr1TOtr2;
type
trgb = record
       r,g,b:byte;
end;

var
k:integer;
x:integer;
color:word;
tr4color:trgb;

begin
    for x:=0 to num_rooms-1 do
    begin
    for k:=1 to rooms[x].vertices.num_vertices do
    begin
        rooms[x].vertices.vertice2[k].x:=rooms[x].vertices.vertice[k].x;
        rooms[x].vertices.vertice2[k].y:=rooms[x].vertices.vertice[k].y;
        rooms[x].vertices.vertice2[k].z:=rooms[x].vertices.vertice[k].z;
        rooms[x].vertices.vertice2[k].light:=rooms[x].vertices.vertice[k].light;
        rooms[x].vertices.vertice2[k].light0:=rooms[x].vertices.vertice[k].light0;
        if tipo>=vtr3 then
        begin
           color:=31-rooms[x].vertices.vertice[k].light;
           rooms[x].vertices.vertice2[k].light2:=0; //reset color
           rooms[x].vertices.vertice2[k].light2:= (color shl 10) or (color shl 5) or (color);
           if (tipo>vtr3) and ((rooms[x].water and 1)=1) then rooms[x].vertices.vertice2[k].light2:= (0 shl 10) or (color shl 5) or (color);


           // 15855 es la mitad de la intensidad color rgb de cada vertice
           if (rooms[x].water and 1)=1 then rooms[x].vertices.vertice2[k].attrib:=(16) or ($4000)
                                              else rooms[x].vertices.vertice2[k].attrib:=16;
                                             //16 efecto normal, 8192=water efecto
          //si quicksand
          if (rooms[x].water and 128)=128 then rooms[x].vertices.vertice2[k].attrib:=$2000;

        end
        else
        begin
           rooms[x].vertices.vertice2[k].light2:=$ffff;
           rooms[x].vertices.vertice2[k].attrib:=0;
        end


    end; //end k
    if tipo>=vtr3 then rooms[x].sand_effect:=0 else rooms[x].sand_effect:=$ffff;
    rooms[x].light_mode:=3; //0=brillante, 1=intermitente,2=fade light,3=normal. solo tr2??

    //fix lara light in tr4 levels
     if tipo=vtr4 then
     begin
        color:=(31-rooms[x].lara_light)*8;
        tr4color.b:=color;tr4color.g:=color;tr4color.r:=color;
        if (tipo>vtr3) and ((rooms[x].water and 1)=1) then tr4color.b:=0; //if water room put Lara with cyan color.
        move(tr4color,rooms[x].d0,3);
      end;

    end;//end x

    for k:=0 to num_items-1 do
    begin
        items2[k].obj:=items[k].obj;
        items2[k].room:=items[k].room;
        items2[k].x:=items[k].x;
        items2[k].y:=items[k].y;
        items2[k].z:=items[k].z;
        items2[k].d:=items[k].d;
        items2[k].angle:=items[k].angle;

        tword(items2[k].light1).byte1:=items[k].light1;
        tword(items2[k].light1).byte2:=items[k].light1;

        tword(items2[k].light2).byte1:=items[k].light2;
        tword(items2[k].light2).byte2:=items[k].light2;

        if tipo>vtr3 then
        begin
           items2[k].light1:=65535;
           items2[k].light2:=0;
        end;

        items2[k].un1:=items[k].un1;
    end; //endfor;

//arreglar los boxes y zones;
for k:=0 to num_boxes-1 do
begin
    boxes2[k].zmin:=boxes[k].zmin div 1024;
    boxes2[k].zmax:=boxes[k].zmax div 1024;
    boxes2[k].xmin:=boxes[k].xmin div 1024;
    boxes2[k].xmax:=boxes[k].xmax div 1024;
    boxes2[k].floory:=boxes[k].floory;
    boxes2[k].overlap_index:=boxes[k].overlap_index;
end;


for k:=0 to num_zones-1 do
begin
     nground_zone1[k]:=0;
     nground_zone2[k]:=0;
     nground_zone3[k]:=0;
     nground_zone4[k]:=0;
     nfly_zone[k]:=0;
     aground_zone1[k]:=0;
     aground_zone2[k]:=0;
     aground_zone3[k]:=0;
     aground_zone4[k]:=0;
     afly_zone[k]:=0;
end;



end;
//----------------------
procedure ttrlevel.tr1TOtrC;
type
trgb = record
       b,g,r,a:byte;
end;

var
k:integer;
x:integer;
color:word;
tr4color:trgb;
//------
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
nx,ny,nz:glfloat;
begin

    for x:=0 to num_rooms-1 do
    begin
    //fix vertices
    for k:=1 to rooms[x].vertices.num_vertices do
    begin
        rooms[x].vertices.vertice3[k].x:=rooms[x].vertices.vertice2[k].x;
        rooms[x].vertices.vertice3[k].y:=rooms[x].vertices.vertice2[k].y;
        rooms[x].vertices.vertice3[k].z:=rooms[x].vertices.vertice2[k].z;

        rooms[x].vertices.vertice3[k].r:=(31-rooms[x].vertices.vertice[k].light)*8;
        rooms[x].vertices.vertice3[k].g:=(31-rooms[x].vertices.vertice[k].light)*8;
        rooms[x].vertices.vertice3[k].b:=(31-rooms[x].vertices.vertice[k].light)*8;
        rooms[x].vertices.vertice3[k].a:=255;

        //if underwater room then put the mesh cyan colored
        if (rooms[x].water and 1)=1 then rooms[x].vertices.vertice3[k].r:=0;
       //---
        rooms[x].vertices.vertice3[k].nx:=1;
        rooms[x].vertices.vertice3[k].ny:=0;
        rooms[x].vertices.vertice3[k].nz:=0;
    end; //end k

    //fix quads;
    for k:=1 to rooms[x].quads.num_quads do
    begin
         rooms[x].quads.quad2[k].p1:=rooms[x].quads.quad[k].p1;
         rooms[x].quads.quad2[k].p2:=rooms[x].quads.quad[k].p2;
         rooms[x].quads.quad2[k].p3:=rooms[x].quads.quad[k].p3;
         rooms[x].quads.quad2[k].p4:=rooms[x].quads.quad[k].p4;
         rooms[x].quads.quad2[k].texture:=rooms[x].quads.quad[k].texture;
         rooms[x].quads.quad2[k].unk:=0;

         //calc the normals
//         for some reason the room meshes are not geting affected fgor the light no
//         mateher what values i put in the "normal" fields, so this will have to
//         wait for more study.

         x1:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].x;
         y1:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].y;
         z1:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].z;

         x2:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].x;
         y2:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].y;
         z2:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].z;

         x3:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].x;
         y3:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].y;
         z3:=rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].z;

         calc_trnormals(x1,y1,z1,
                      x2,y2,z2,
                      x3,y3,z3,
                      nx,ny,nz);

{
         //poner los normal en la tabla.

         //update all x
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].nx=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].nx:=nx else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].nx:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].nx+nx)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].nx=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].nx:=nx else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].nx:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].nx+nx)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].nx=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].nx:=nx else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].nx:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].nx+nx)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].nx=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].nx:=nx else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].nx:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].nx+nx)/2;

         //update all y
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].ny=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].ny:=ny else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].ny:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].ny+ny)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].ny=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].ny:=ny else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].ny:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].ny+ny)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].ny=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].ny:=nx else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].ny:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].ny+ny)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].ny=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].ny:=ny else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].ny:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].ny+ny)/2;


         //update all z
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].nz=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].nz:=nz else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].nz:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p1+1].nz+nz)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].nz=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].nz:=nz else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].nz:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p2+1].nz+nz)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].nz=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].nz:=nz else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].nz:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p3+1].nz+nz)/2;
         if rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].nz=0 then
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].nz:=nz else
            rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].nz:=(rooms[x].vertices.vertice3[rooms[x].quads.quad2[k].p4+1].nz+nz)/2;
 }
    end; //end rectangles

    for k:=1 to rooms[x].triangles.num_triangles do
    begin
         rooms[x].triangles.triangle2[k].p1:=rooms[x].triangles.triangle[k].p1;
         rooms[x].triangles.triangle2[k].p2:=rooms[x].triangles.triangle[k].p2;
         rooms[x].triangles.triangle2[k].p3:=rooms[x].triangles.triangle[k].p3;
         rooms[x].triangles.triangle2[k].texture:=rooms[x].triangles.triangle[k].texture;
         rooms[x].triangles.triangle2[k].unk:=0;
     end; //end triangles

    rooms[x].tr5_unknowns.total_triangles:=rooms[x].triangles.num_triangles;
    rooms[x].tr5_unknowns.total_rectangles:=rooms[x].quads.num_quads;
    rooms[x].tr5unk8.num_unk8:=0;

    fillchar(rooms[x].tr5_unknowns.unknown5.data[1],16,0);
    //lara light
    trgb(rooms[x].tr5_unknowns.room_color).r:=(31-rooms[x].lara_light)*8;
    trgb(rooms[x].tr5_unknowns.room_color).g:=(31-rooms[x].lara_light)*8;
    trgb(rooms[x].tr5_unknowns.room_color).b:=(31-rooms[x].lara_light)*8;
    trgb(rooms[x].tr5_unknowns.room_color).a:=0;

    if (rooms[x].water and 1)=1 then trgb(rooms[x].tr5_unknowns.room_color).r:=0;

    //more unknowns
    rooms[x].tr5_unknowns.unknown1:=0;
    rooms[x].tr5_unknowns.unknown2:=1;
    rooms[x].tr5_unknowns.unknown3:=$7fff;
    rooms[x].tr5_unknowns.unknown4:=$7fff;
    rooms[x].tr5_unknowns.unknown6:=0;
    rooms[x].tr5_unknowns.unknown7:=0;

    //Layer box
    rooms[x].layers[0].unknownl1:=0;
    rooms[x].layers[0].unknownl2:=0;
    rooms[x].layers[0].filler2:=0;
    rooms[x].layers[0].filler3:=0;

    rooms[x].layers[0].unknownl3:=3552812; //?
    rooms[x].layers[0].unknownl4:=36576740;//?
    rooms[x].layers[0].unknownl5:=23403952;//?

    rooms[x].layers[0].x1:=0;
    rooms[x].layers[0].x2:=rooms[x].sectors.ancho*1024;
    rooms[x].layers[0].y1:=rooms[x].room_info.ymax;
    rooms[x].layers[0].y2:=rooms[x].room_info.ymin;
    rooms[x].layers[0].z1:=0;
    rooms[x].layers[0].z2:=rooms[x].sectors.largo*1024;

 end;//end x end rooms


end;





//----------------------
procedure ttrlevel.Build_boxes;
const
altura = 128;

type
   tabox = record
           box_no:integer;
           zmin,zmax,
           xmin,xmax:longint;
           floory:smallint;
           overlap_index:smallint;
   end;

var
aux_box: array[1..32,1..32] of tabox;
r:integer;
curbox:integer;
k:word;
fil,col:integer;
tindex:word;
begin

{inicializar los boxes,overlaps y zones}
num_boxes:=0;
num_overlaps:=0;
num_zones:=0;
curbox:=0;

for r:=0 to num_rooms-1 do
begin

    for col:=1 to rooms[r].sectors.ancho do
    begin
        for fil:=1 to rooms[r].sectors.largo do
        begin
           tindex:=get_tile_index(rooms[r].sectors,col,fil);

           if (rooms[r].sectors.sector[tindex].floor_height<>rooms[r].sectors.sector[tindex].ceiling_height)
           THEN
           begin
              aux_box[col,fil].box_no:=curbox; curbox:=curbox+1;
              aux_box[col,fil].zmin:=rooms[r].room_info.zpos_room+((fil-1)*1024);
              aux_box[col,fil].zmax:=aux_box[col,fil].zmin+1024;
              aux_box[col,fil].xmin:=rooms[r].room_info.xpos_room+((col-1)*1024);
              aux_box[col,fil].xmax:=aux_box[col,fil].xmin+1024;
              aux_box[col,fil].floory:=short2byte(rooms[r].sectors.sector[tindex].floor_height)*altura;


              if rooms[r].sectors.sector[tindex].room_below<>255 then
              aux_box[col,fil].floory:=0;

           end //si no es pared.
           else aux_box[col,fil].box_no:=-1;
        end;//fin filas
     end;//fin columnas

     //--------------------------------------------------
     //crear los box/overlaps/zones para este room.
    for col:=1 to rooms[r].sectors.ancho do
    begin
        for fil:=1 to rooms[r].sectors.largo do
        begin
              tindex:=get_tile_index(rooms[r].sectors,col,fil);
              if aux_box[col,fil].box_no>=0 then
              begin
                  word(rooms[r].sectors.sector[tindex].box_index):=aux_box[col,fil].box_no;
                  if tipo>=vtr3 then rooms[r].sectors.sector[tindex].box_index:=(rooms[r].sectors.sector[tindex].box_index shl 4) or 5;
                  //crear un nuevo box
                  num_boxes:=num_boxes+1;
                  boxes[num_boxes-1].xmin:=aux_box[col,fil].xmin;
                  boxes[num_boxes-1].xmax:=aux_box[col,fil].xmax;
                  boxes[num_boxes-1].zmin:=aux_box[col,fil].zmin;
                  boxes[num_boxes-1].zmax:=aux_box[col,fil].zmax;
                  boxes[num_boxes-1].floory:=aux_box[col,fil].floory;
                  boxes[num_boxes-1].overlap_index:=num_overlaps;

                  //averiguar y agregar los overlaps

                  //agregar en la lista el nuevo box actual.
                  num_overlaps:=num_overlaps+1;
                  overlaps[num_overlaps-1]:=aux_box[col,fil].box_no;//sin la marca de fin de la lista.

                  //----hay vecino atras?--------
                  if fil<rooms[r].sectors.largo then
                  begin
                      k:=get_tile_index(rooms[r].sectors,col,fil+1);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col,fil+1].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          num_overlaps:=num_overlaps+1;
                          overlaps[num_overlaps-1]:=aux_box[col,fil+1].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino enfrente?--------
                  if fil>1 then
                  begin
                      k:=get_tile_index(rooms[r].sectors,col,fil-1);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col,fil-1].floory-aux_box[col,fil].floory)<=altura) then
                     begin
                          num_overlaps:=num_overlaps+1;
                          overlaps[num_overlaps-1]:=aux_box[col,fil-1].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino a la derecha?--------
                  if col<rooms[r].sectors.ancho then
                  begin
                      k:=get_tile_index(rooms[r].sectors,col+1,fil);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col+1,fil].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          num_overlaps:=num_overlaps+1;
                          overlaps[num_overlaps-1]:=aux_box[col+1,fil].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino a la izquierda?--------
                  if col>1 then
                  begin
                      k:=get_tile_index(rooms[r].sectors,col-1,fil);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col-1,fil].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          num_overlaps:=num_overlaps+1;
                          overlaps[num_overlaps-1]:=aux_box[col-1,fil].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.
                  //----------------------------------------

                 //poner la marca de fin de lista
                 overlaps[num_overlaps-1]:=overlaps[num_overlaps-1] or $8000;
                 //ahora agregar una zona.
                 num_zones:=num_zones+1;
                 nground_zone1[num_zones-1]:=0;
                 nground_zone2[num_zones-1]:=0;
                 nfly_zone[num_zones-1]:=0;
                 aground_zone1[num_zones-1]:=0;
                 aground_zone2[num_zones-1]:=0;
                 afly_zone[num_zones-1]:=0;

               end
               else
                  begin
                      //solo poner el box_index:=-1;
                      rooms[r].sectors.sector[tindex].box_index:=-1;
                      if tipo>=vtr3 then rooms[r].sectors.sector[tindex].box_index:=(rooms[r].sectors.sector[tindex].box_index shl 4) or 5;
                  end;

        end;//fin filas
     end;//fin columnas
//-------------------------------------------------------------------------


end;//fin todos los rooms.


end;
//----------------------

procedure ttrlevel.Build_box(r:integer);
const
altura = 128;

type
   tabox = record
           box_no:integer;
           zmin,zmax,
           xmin,xmax:longint;
           floory:smallint;
           overlap_index:smallint;
   end;

var
aux_box: array[1..32,1..32] of tabox;
curbox:integer;
k:word;
fil,col:integer;
tindex:word;
begin

    curbox:=num_boxes;

    for col:=1 to rooms[r].sectors.ancho do
    begin
        for fil:=1 to rooms[r].sectors.largo do
        begin
           tindex:=get_tile_index(rooms[r].sectors,col,fil);

           if (rooms[r].sectors.sector[tindex].floor_height<>rooms[r].sectors.sector[tindex].ceiling_height)
           THEN
           begin
              aux_box[col,fil].box_no:=curbox; curbox:=curbox+1;
              aux_box[col,fil].zmin:=rooms[r].room_info.zpos_room+((fil-1)*1024);
              aux_box[col,fil].zmax:=aux_box[col,fil].zmin+1024;
              aux_box[col,fil].xmin:=rooms[r].room_info.xpos_room+((col-1)*1024);
              aux_box[col,fil].xmax:=aux_box[col,fil].xmin+1024;
              aux_box[col,fil].floory:=short2byte(rooms[r].sectors.sector[tindex].floor_height)*altura;

              if rooms[r].sectors.sector[tindex].room_below<>255 then
              aux_box[col,fil].floory:=0;

           end //si no es pared.
           else aux_box[col,fil].box_no:=-1;
        end;//fin filas
     end;//fin columnas

     //--------------------------------------------------
     //crear los box/overlaps/zones para este room.
    for col:=1 to rooms[r].sectors.ancho do
    begin
        for fil:=1 to rooms[r].sectors.largo do
        begin
              tindex:=get_tile_index(rooms[r].sectors,col,fil);
              if aux_box[col,fil].box_no>=0 then
              begin
                  word(rooms[r].sectors.sector[tindex].box_index):=aux_box[col,fil].box_no;
                  if tipo>=vtr3 then rooms[r].sectors.sector[tindex].box_index:=(rooms[r].sectors.sector[tindex].box_index shl 4) or 5;
                  //crear un nuevo box
                  num_boxes:=num_boxes+1;
                  boxes[num_boxes-1].xmin:=aux_box[col,fil].xmin;
                  boxes[num_boxes-1].xmax:=aux_box[col,fil].xmax;
                  boxes[num_boxes-1].zmin:=aux_box[col,fil].zmin;
                  boxes[num_boxes-1].zmax:=aux_box[col,fil].zmax;
                  boxes[num_boxes-1].floory:=aux_box[col,fil].floory;
                  boxes[num_boxes-1].overlap_index:=num_overlaps;

                  //averiguar y agregar los overlaps

                  //agregar en la lista el nuevo box actual.
                  num_overlaps:=num_overlaps+1;
                  overlaps[num_overlaps-1]:=aux_box[col,fil].box_no;//sin la marca de fin de la lista.

                  //----hay vecino atras?--------
                  if fil<rooms[r].sectors.largo then
                  begin
                      k:=get_tile_index(rooms[r].sectors,col,fil+1);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col,fil+1].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          num_overlaps:=num_overlaps+1;
                          overlaps[num_overlaps-1]:=aux_box[col,fil+1].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino enfrente?--------
                  if fil>1 then
                  begin
                      k:=get_tile_index(rooms[r].sectors,col,fil-1);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col,fil-1].floory-aux_box[col,fil].floory)<=altura) then
                     begin
                          num_overlaps:=num_overlaps+1;
                          overlaps[num_overlaps-1]:=aux_box[col,fil-1].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino a la derecha?--------
                  if col<rooms[r].sectors.ancho then
                  begin
                      k:=get_tile_index(rooms[r].sectors,col+1,fil);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col+1,fil].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          num_overlaps:=num_overlaps+1;
                          overlaps[num_overlaps-1]:=aux_box[col+1,fil].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino a la izquierda?--------
                  if col>1 then
                  begin
                      k:=get_tile_index(rooms[r].sectors,col-1,fil);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col-1,fil].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          num_overlaps:=num_overlaps+1;
                          overlaps[num_overlaps-1]:=aux_box[col-1,fil].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.
                  //----------------------------------------

                 //poner la marca de fin de lista
                 overlaps[num_overlaps-1]:=overlaps[num_overlaps-1] or $8000;
                 //ahora agregar una zona.
                 num_zones:=num_zones+1;
                 nground_zone1[num_zones-1]:=0;
                 nground_zone2[num_zones-1]:=0;
                 nfly_zone[num_zones-1]:=0;
                 aground_zone1[num_zones-1]:=0;
                 aground_zone2[num_zones-1]:=0;
                 afly_zone[num_zones-1]:=0;

               end
               else
                  begin
                      //solo poner el box_index:=-1;
                      rooms[r].sectors.sector[tindex].box_index:=-1;
                      if tipo>=vtr3 then rooms[r].sectors.sector[tindex].box_index:=(rooms[r].sectors.sector[tindex].box_index shl 4) or 5;
                  end;

        end;//fin filas
     end;//fin columnas
//-------------------------------------------------------------------------
end; //end procedure
//----------

procedure ttrlevel.Build_box2(r:integer);
const
altura = 128;
var
fil,col:integer;
tindex:word;
zmin,zmax,
xmin,xmax:longint;
floory:smallint;
begin
    //cacl and add a new box for the whole room
    zmin:=rooms[r].room_info.zpos_room+1024;
    zmax:=rooms[r].room_info.zpos_room+((rooms[r].sectors.largo-1)*1024);
    xmin:=rooms[r].room_info.xpos_room+1024;
    xmax:=rooms[r].room_info.xpos_room+((rooms[r].sectors.ancho-1)*1024);
    floory:=short2byte(rooms[r].room_info.ymin)*altura;
    //add it
     num_boxes:=num_boxes+1;
     boxes[num_boxes-1].xmin:=xmin;
     boxes[num_boxes-1].xmax:=xmax;
     boxes[num_boxes-1].zmin:=zmin;
     boxes[num_boxes-1].zmax:=zmax;
     boxes[num_boxes-1].floory:=floory;
     boxes[num_boxes-1].overlap_index:=num_overlaps;

     //agregar un overlap
     num_overlaps:=num_overlaps+1;
     overlaps[num_overlaps-1]:=(num_boxes-1) or $8000;
     //ahora agregar una zona.
     num_zones:=num_zones+1;
     nground_zone1[num_zones-1]:=0;
     nground_zone2[num_zones-1]:=0;
     nfly_zone[num_zones-1]:=0;
     aground_zone1[num_zones-1]:=0;
     aground_zone2[num_zones-1]:=0;
     afly_zone[num_zones-1]:=0;

     //porner este box to sector where is not wall.
    //----------------------------------
    for col:=1 to rooms[r].sectors.ancho do
    begin
        for fil:=1 to rooms[r].sectors.largo do
        begin
           tindex:=get_tile_index(rooms[r].sectors,col,fil);
           if (rooms[r].sectors.sector[tindex].floor_height<>rooms[r].sectors.sector[tindex].ceiling_height)
           THEN
           begin //if not wall
                  rooms[r].sectors.sector[tindex].box_index:=num_boxes-1;
                  if tipo>=vtr3 then rooms[r].sectors.sector[tindex].box_index:=(rooms[r].sectors.sector[tindex].box_index shl 4) or 5;
           end //end if not wall.
           else//if wall
               begin
                  rooms[r].sectors.sector[tindex].box_index:=-1;
                  if tipo>=vtr3 then rooms[r].sectors.sector[tindex].box_index:=(rooms[r].sectors.sector[tindex].box_index shl 4) or 5;
               end;
        end;//fin filas
     end;//fin columnas
end;
//-------------------------------------

procedure ttrlevel.Free_Level;
begin
     if tipo<=vtr3 then FreeMem(texture_data);
     if tipo>=vtr2 then FreeMem(texture_data2);
     if tipo>=vtr4 then begin FreeMem(texture_data3);FreeMem(texture_data4);end;
     if (tipo<vtr2) or (tipo>=vtr4) then FreeMem(samples_buffer);
end;

procedure ttrlevel.Addpage;
var
p:pointer;
begin

//agregar espacio en las tablas de texturas.
  //8bit version
  if tipo<vtr4 then
  begin
    getmem(p,(256*256)*(Num_Texture_pages+1));
    fillchar(p^,(256*256)*(Num_Texture_pages+1),chr(0));
    move(texture_data^,p^,(256*256)*Num_Texture_pages);
    freemem(texture_data);
    texture_data:=p;
  end; //fin 8bits version
    
    //16bit version
  if tipo>=vtr2 then
  begin
     getmem(p,(256*256*2)*(Num_Texture_pages+1));
     fillchar(p^,(256*256*2)*(Num_Texture_pages+1),chr(0));
     move(texture_data2^,p^,(256*256*2)*Num_Texture_pages);
     freemem(texture_data2);
     texture_data2:=p;
  end;//fin si hay 16 bit textures

  //32bit version
  if tipo>=vtr4 then
  begin
     getmem(p,(256*256*4)*(Num_Texture_pages+1));
     fillchar(p^,(256*256*4)*(Num_Texture_pages+1),chr(0));
     move(texture_data3^,p^,(256*256*4)*Num_Texture_pages);
     freemem(texture_data3);
     texture_data3:=p;
     //-----------------
  end;//fin si hay 32 bit textures

  //actualizar algunos campos.
  Num_Texture_pages:=Num_Texture_pages+1;
  size_textures:=(256*256)*Num_Texture_pages;
  num_nonbump_tiles:=num_nonbump_tiles+1;
end;

//************************************
function Short2Byte(altura:shortint):byte;
begin
   Short2Byte:=altura*-1+127;
end;

function Byte2Short(altura:byte):shortint;
begin
   Byte2short:=altura*-1+127;
end;


function Get_floor(var Tile:tsector_list; columna,fila:byte):shortint;
begin
    if columna>0 then columna:=columna-1;
   Get_floor:=tile.sector[ columna*tile.largo+fila].floor_height ;

end;


procedure put_sector( sec:tsector; var Tile:tsector_list; columna,fila:byte);
begin
    if columna>0 then columna:=columna-1;
    tile.sector[ columna*tile.largo+fila].floor_index:=sec.floor_index;
    tile.sector[ columna*tile.largo+fila].box_index:=sec.box_index;
    tile.sector[ columna*tile.largo+fila].room_below:=sec.room_below;
    tile.sector[ columna*tile.largo+fila].floor_height:=sec.floor_height;
    tile.sector[ columna*tile.largo+fila].room_above:=sec.room_above;
    tile.sector[ columna*tile.largo+fila].ceiling_height:=sec.ceiling_height;

end;


procedure get_sector( var sec:tsector; var Tile:tsector_list; columna,fila:byte);
begin
    if columna>0 then columna:=columna-1;
    sec.floor_index:=tile.sector[ columna*tile.largo+fila].floor_index;
    sec.box_index:=tile.sector[ columna*tile.largo+fila].box_index;
    sec.room_below:=tile.sector[ columna*tile.largo+fila].room_below;
    sec.floor_height:=tile.sector[ columna*tile.largo+fila].floor_height;
    sec.room_above:=tile.sector[ columna*tile.largo+fila].room_above;
    sec.ceiling_height:=tile.sector[ columna*tile.largo+fila].ceiling_height;
end;


function get_tile_index(var Tile:tsector_list; columna,fila:byte):word;
begin
     if columna>0 then columna:=columna-1;
    get_tile_index:= columna*tile.largo+fila;
end;


function Get_ceiling(var Tile:tsector_list; columna,fila:byte):shortint;
begin
    if columna>0 then columna:=columna-1;
    Get_ceiling:=tile.sector[ columna*tile.largo+fila].ceiling_height ;
end;


function Get_floor_index(var Tile:tsector_list; columna,fila:byte):word;
begin
   if columna>0 then columna:=columna-1;
    Get_floor_index:=tile.sector[ columna*tile.largo+fila].floor_index ;
end;

function Get_room_below(var Tile:tsector_list; columna,fila:byte):byte;
begin
    if columna>0 then columna:=columna-1;
    Get_room_below:=tile.sector[ columna*tile.largo+fila].room_below ;
end;



{***********************************}

function tr_LoadPhd(var L:tphd; name:string):byte;
var
f:file;
resultado:byte;
x:word;
k:word;
tipo:byte; //0=no version, 1=phd, 2=tub, 3=TR2, 4=TR3
begin
 //si L contiene ya contiene un nivel cargado
 //liberar las texturas y los sonidos en tr1.
 if l.valido='Tpascal' then
 begin
     FreeMem(l.texture_data);
     if l.tipo>2 then FreeMem(l.texture_data2);
     if l.tipo<3 then FreeMem(l.samples.buffer);
 end;
 fillchar(L,sizeof(L),chr(0));
 resultado:=0;
 tipo:=0;

 if fileExists(name) then
 begin
    filemode:=0;
    assignfile(f,name);
    reset(f,1);
    filemode:=2;
    blockread(f,L.version,4);



    if (l.version<>$20) and (l.version<>$2d) and (l.version<>$ff180038) and (l.version<>$ff080038) then begin close(f);L.version:=0;resultado:=2;end;
 end
 else resultado:=1;
 {*****************}

 if resultado=0 then
 begin

     l.valido:='Tpascal'; //para poder liberar las textures y los samples despues.
     case l.version of

          $20: if (pos('.TUB',name)<>0) or (pos('.tub',name)<>0) then tipo:=2 else tipo:=1;
          $2d:tipo:=3;
          $ff080038,$ff180038:tipo:=4;
     end;//end case

     l.tipo:=tipo;

     //si tr2 o tr3 cargar las paletas aqui.
     if (tipo=3) or (tipo=4) then
     begin
          blockread(f,l.Palette,768); //palette 256 colors
          blockread(f,l.Palette16,1024); //palette 16bit colors
     end;


     Blockread(f, l.Size_Textures,4); {get size textures bitmaps}
     L.Num_texture_pages:=l.Size_Textures; //salvar aqui cuantas paginas de texturas hay.
     l.Size_Textures:=l.Size_Textures*65536; //calcular aqui el tamano de las texturas.

     //cargar las texturas bitmaps
     getmem(l.texture_data, l.Size_Textures);
     blockread(f, l.texture_data^, l.Size_Textures);

     //si tr2 o tr3 cargar las 16bit texturas bitmaps.
     if (tipo=3) or (tipo=4) then
     begin
          getmem(l.texture_data2, L.Num_texture_pages*131072);
          blockread(f, l.texture_data2^, L.Num_texture_pages*131072);
     end;//

     blockread(f, l.dumys,4); //4 bytes segun roseta, yo tenia 6..
     blockread(f,l.rooms.num_rooms,2);   {get total rooms}

     {Cargar todos los Rooms.}
     for x:=1 to l.rooms.num_rooms do
     begin
          //Room info
          blockread(f,l.rooms.room[x].room_info, sizeof(troom_info) );

          blockread(f,l.rooms.room[x].vertices.num_vertices,2);


          //cargar los vertices deacuerdo a la version.
          if (tipo=3) or (tipo=4) then
              begin
                  blockread(f,l.rooms.room[x].vertices.vertice2, sizeof(tvertice2) * l.rooms.room[x].vertices.num_vertices );
                  //poner los vertices en tr1/tub formato tambien
                  for k:=1 to l.rooms.room[x].vertices.num_vertices do
                  begin
                       l.rooms.room[x].vertices.vertice[k].x:=l.rooms.room[x].vertices.vertice2[k].x;
                       l.rooms.room[x].vertices.vertice[k].y:=l.rooms.room[x].vertices.vertice2[k].y;
                       l.rooms.room[x].vertices.vertice[k].z:=l.rooms.room[x].vertices.vertice2[k].z;
                       l.rooms.room[x].vertices.vertice[k].light:=l.rooms.room[x].vertices.vertice2[k].light;
                       l.rooms.room[x].vertices.vertice[k].light0:=l.rooms.room[x].vertices.vertice2[k].light0;
                  end;

              end
           else
               begin
                   blockread(f,l.rooms.room[x].vertices.vertice, sizeof(tvertice) * l.rooms.room[x].vertices.num_vertices );
                  for k:=1 to l.rooms.room[x].vertices.num_vertices do
                  begin
                       l.rooms.room[x].vertices.vertice2[k].x:=l.rooms.room[x].vertices.vertice[k].x;
                       l.rooms.room[x].vertices.vertice2[k].y:=l.rooms.room[x].vertices.vertice[k].y;
                       l.rooms.room[x].vertices.vertice2[k].z:=l.rooms.room[x].vertices.vertice[k].z;
                       l.rooms.room[x].vertices.vertice2[k].light:=l.rooms.room[x].vertices.vertice[k].light;
                       l.rooms.room[x].vertices.vertice2[k].light0:=l.rooms.room[x].vertices.vertice[k].light0;
                       l.rooms.room[x].vertices.vertice2[k].light2:=15855;
                       l.rooms.room[x].vertices.vertice2[k].attrib:=16;

                  end;

               end;

          blockread(f,l.rooms.room[x].quads.num_quads,2);
          blockread(f,l.rooms.room[x].quads.quad,  sizeof(tquad) * l.rooms.room[x].quads.num_quads );



          blockread(f,l.rooms.room[x].triangles.num_triangles,2);
          blockread(f,l.rooms.room[x].triangles.triangle,  sizeof(ttriangle) * l.rooms.room[x].triangles.num_triangles );


          blockread(f,l.rooms.room[x].sprites.num_sprites,2);
          blockread(f,l.rooms.room[x].sprites.sprite, sizeof(tsprite) * l.rooms.room[x].sprites.num_sprites);


          blockread(f,l.rooms.room[x].doors.num_doors,2);
          blockread(f,l.rooms.room[x].doors.door, sizeof(tdoor) * l.rooms.room[x].doors.num_doors );


          blockread(f,l.rooms.room[x].sectors.largo,2);
          blockread(f,l.rooms.room[x].sectors.ancho,2);
          blockread(f,l.rooms.room[x].sectors.sector,  sizeof(tsector) * l.rooms.room[x].sectors.largo * l.rooms.room[x].sectors.ancho);
          blockread(f,l.rooms.room[x].d0,1);
          blockread(f,l.rooms.room[x].lara_light,1);


          //if tr2 o tr3 cargar sand efect en el room
          if (tipo=3) or (tipo=4) then blockread(f,l.rooms.room[x].sand_effect,2);
          if (tipo=3) then blockread(f,l.rooms.room[x].light_mode,2);

          blockread(f,l.rooms.room[x].Source_lights.num_sources,2);

          //if tr2 o tr3 cargar la fuente de luz
          if (tipo=3) or (tipo=4) then
                     blockread(f,l.rooms.room[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms.room[x].Source_lights.num_sources ) else
                     blockread(f,l.rooms.room[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms.room[x].Source_lights.num_sources );



          blockread(f,l.rooms.room[x].Statics.num_static,2);
        //if tr2 o tr3 cargar los statics objects
          if (tipo=3) or (tipo=4) then
                                      blockread(f,l.rooms.room[x].statics.static2, sizeof(tstatic2) * l.rooms.room[x].statics.num_static ) else
                                      blockread(f,l.rooms.room[x].statics.static, sizeof(tstatic) * l.rooms.room[x].statics.num_static );




          blockread(f,l.rooms.room[x].alternate,2);
          blockread(f,l.rooms.room[x].water,1);
          blockread(f,l.rooms.room[x].d2,1);

          //solo tr3 tiene lo siguiente.
          if tipo=4 then blockread(f,l.rooms.room[x].room_color,3);

     end; {fin cargar todos los rooms}



     //floor_data
     blockread(f,l.floor_data.num_floor_data,4);
     blockread(f,l.floor_data.floor_data, l.floor_data.num_floor_data*2);


     //mesh words
     blockread(f,l.meshwords.num_meshwords,4);
     blockread(f,l.meshwords.meshword, l.meshwords.num_meshwords*2);


     //mesh pointers
     blockread(f,l.Meshpointers.num_meshpointers,4);
     blockread(f,l.meshpointers.meshpointer, l.Meshpointers.num_meshpointers *4);

     //anims
     blockread(f,l.Anims.num_anims,4);
     blockread(f,l.Anims.anim,l.Anims.num_anims*32);


     //structs
     blockread(f,l.Structs.num_struct,4);
     blockread(f,l.Structs.struct, l.Structs.num_struct*6);


     //ranges
     blockread(f,l.Ranges.num_ranges,4);
     blockread(f,l.Ranges.range, l.Ranges.num_ranges*8);


     //bones1
     blockread(f,l.Bones1.Num_bones1,4);
     blockread(f,l.Bones1.Bone1, l.Bones1.Num_bones1*2);

     //bones2
     blockread(f,l.Bones2.Num_bones2,4);
     blockread(f,l.Bones2.Bone2, l.Bones2.Num_bones2*4);

     //frames
     blockread(f,l.Frames.Num_frames,4);
     blockread(f,l.Frames.frame, l.Frames.Num_frames*2);

     //movables
     blockread(f,l.Movables.Num_movables,4);
     blockread(f,l.movables.movable, l.Movables.Num_movables*18);

     //esto son los static mesh disponibles.
     blockread(f,l.static_table.Num_static,4);
     blockread(f,l.static_table.static, l.static_table.Num_static*32);

     //obj textures
     //solo tr1/tub and tr2 tiene los obj texturas aqui.
     if tipo<>4 then
     begin
          blockread(f,l.Textures.Num_textures,4);
          blockread(f,l.Textures.texture, l.Textures.Num_textures*20);
     end;


     //sprites textures
     blockread(f,l.Spr_Textures.Num_spr_textures,4);
     blockread(f,l.Spr_Textures.spr_texture, l.Spr_Textures.Num_spr_textures*16);

     //desconocido2 sprites sequencias
     blockread(f,l.Desconocido2.Num_des2,4);
     blockread(f,l.desconocido2.des2, l.Desconocido2.Num_des2*8);

     //if tub file load the palette here
     if tipo=2 then blockread(f,l.Palette,768); //palette

     //cameras
     blockread(f,l.Cameras.Num_cameras,4);
     blockread(f,l.Cameras.camera, l.Cameras.Num_cameras*16);

     //sound fxs
     blockread(f,l.Sound_fxs.Num_sound_fxs,4);
     blockread(f,l.Sound_fxs.sound_fx, l.Sound_fxs.Num_sound_fxs*16);

     //boxes
     blockread(f,l.boxes.Num_boxes,4);

     if (tipo=3) or (tipo=4) then
                             blockread(f,l.boxes.box2, l.boxes.Num_boxes*8) else
                             blockread(f,l.boxes.box, l.boxes.Num_boxes*20);

     //overlaps
     blockread(f,l.Overlaps.Num_overlaps,4);
     blockread(f,l.Overlaps.overlap, l.Overlaps.Num_overlaps*2);

     //zonas
     l.zones.Num_zones:=l.boxes.Num_boxes;

     if (tipo=3) or (tipo=4) then
     begin
         blockread(f, l.zones.nground_zone1, l.zones.Num_zones*2);
         blockread(f, l.zones.nground_zone2, l.zones.Num_zones*2);
         blockread(f, l.zones.nground_zone3, l.zones.Num_zones*2);
         blockread(f, l.zones.nground_zone4, l.zones.Num_zones*2);
         blockread(f, l.zones.nfly_zone    , l.zones.Num_zones*2);
         //----------
         blockread(f, l.zones.aground_zone1, l.zones.Num_zones*2);
         blockread(f, l.zones.aground_zone2, l.zones.Num_zones*2);
         blockread(f, l.zones.aground_zone3, l.zones.Num_zones*2);
         blockread(f, l.zones.aground_zone4, l.zones.Num_zones*2);
         blockread(f, l.zones.afly_zone    , l.zones.Num_zones*2);
     end //fin cargar zonas para tr2/tr3
     else
     begin
         blockread(f, l.zones.nground_zone1, l.zones.Num_zones*2);
         blockread(f, l.zones.nground_zone2, l.zones.Num_zones*2);
         blockread(f, l.zones.nfly_zone    , l.zones.Num_zones*2);
         //----------
         blockread(f, l.zones.aground_zone1, l.zones.Num_zones*2);
         blockread(f, l.zones.aground_zone2, l.zones.Num_zones*2);
         blockread(f, l.zones.afly_zone    , l.zones.Num_zones*2);
     end;//fin phd/tub


     //animated textures
     blockread(f,l.Anim_textures.Num_anim_textures,4);
     blockread(f,l.Anim_textures.anim_texture, l.Anim_textures.Num_anim_textures*2);


     //obj textures
     //solo tr3 tiene los obj texturas aqui.
     if tipo=4 then
     begin
          blockread(f,l.Textures.Num_textures,4);
          blockread(f,l.Textures.texture, l.Textures.Num_textures*20);
     end;


     //Items
     blockread(f,l.items.Num_items,4);

     if (tipo=3) or (tipo=4) then
                              begin
                                 blockread(f,l.items.item2, l.items.Num_items*sizeof(titem2));
                                 for k:=1 to l.items.num_items do
                                 begin
                                     l.items.item[k].obj:=l.items.item2[k].obj;
                                     l.items.item[k].room:=l.items.item2[k].room;
                                     l.items.item[k].x:=l.items.item2[k].x;
                                     l.items.item[k].y:=l.items.item2[k].y;
                                     l.items.item[k].z:=l.items.item2[k].z;
                                     l.items.item[k].d:=l.items.item2[k].d;
                                     l.items.item[k].angle:=l.items.item2[k].angle;
                                     l.items.item[k].light1:=l.items.item2[k].light1;
                                     l.items.item[k].light2:=l.items.item2[k].light2;
                                     l.items.item[k].un1:=l.items.item2[k].un1;
                                   end; //endfor;
                               end //endtipo
     else
                              begin
                                 blockread(f,l.items.item, l.items.Num_items*sizeof(titem));
                                 for k:=1 to l.items.num_items do
                                 begin
                                     l.items.item2[k].obj:=l.items.item[k].obj;
                                     l.items.item2[k].room:=l.items.item[k].room;
                                     l.items.item2[k].x:=l.items.item[k].x;
                                     l.items.item2[k].y:=l.items.item[k].y;
                                     l.items.item2[k].z:=l.items.item[k].z;
                                     l.items.item2[k].d:=l.items.item[k].d;
                                     l.items.item2[k].angle:=l.items.item[k].angle;
                                     l.items.item2[k].light1:=l.items.item[k].light1;
                                     l.items.item2[k].light2:=l.items.item[k].light2;
                                     l.items.item2[k].un1:=l.items.item[k].un1;
                                   end; //endfor;

                              end;
     //colormap
     blockread(f,l.Colormap,32*256);


     //if phd file load the palette here
     if tipo=1 then blockread(f,l.Palette,768); //palette

     //desconocido3 cinematic frames
     blockread(f,l.Desconocido3.Num_des3,2);
     blockread(f,l.Desconocido3.des3, l.Desconocido3.Num_des3*16);

     //desconocido4 demo data
     blockread(f,l.Desconocido4.Num_des4,2);
     blockread(f,l.Desconocido4.des4, l.Desconocido4.Num_des4);


     //sound_map
     if (tipo=3) or (tipo=4) then
                  blockread(f,l.sound_map, 740) else
                  blockread(f,l.sound_map, 512);


     //samples info
     blockread(f,l.samples_info.Num_samples_info,4);
     blockread(f,l.samples_info.sample_info, l.samples_info.Num_samples_info*sizeof(tsample_info));

     //samples
     if (tipo=1) or (tipo=2) then
     begin
         blockread(f,l.samples.samples_size,4);
         getmem(l.samples.buffer, l.samples.samples_size);
         blockread(f,l.samples.buffer^, l.samples.samples_size);
     end;//end si phd or tub

     //samples offsets
     blockread(f,l.samples_offsets.Num_offsets,4);
     blockread(f,l.samples_offsets.offset, l.samples_offsets.Num_offsets*4);

     close(f);
 end;{load phd}

 tr_LoadPhd:=resultado;

end;

//--------------------------------
//copiar los valores del tr1 hacia tr2/3
procedure tr1TOtr2(var l:tphd);
var
k:integer;
x:integer;
color:word;
begin
    for x:=1 to l.rooms.num_rooms do
    begin
    for k:=1 to l.rooms.room[x].vertices.num_vertices do
    begin
        l.rooms.room[x].vertices.vertice2[k].x:=l.rooms.room[x].vertices.vertice[k].x;
        l.rooms.room[x].vertices.vertice2[k].y:=l.rooms.room[x].vertices.vertice[k].y;
        l.rooms.room[x].vertices.vertice2[k].z:=l.rooms.room[x].vertices.vertice[k].z;
        l.rooms.room[x].vertices.vertice2[k].light:=l.rooms.room[x].vertices.vertice[k].light;
        l.rooms.room[x].vertices.vertice2[k].light0:=l.rooms.room[x].vertices.vertice[k].light0;
        if l.tipo=4 then
        begin
           color:=31-l.rooms.room[x].vertices.vertice[k].light;
           l.rooms.room[x].vertices.vertice2[k].light2:= (color shl 10) or (color shl 5) or (color);
           // 15855 es la mitad de la intensidad color rgb de cada vertice
           if (l.rooms.room[x].water and 1)=1 then l.rooms.room[x].vertices.vertice2[k].attrib:=16 or $2000 // or $4000)
                                              else l.rooms.room[x].vertices.vertice2[k].attrib:=16;
                                             //16 efecto normal, 8192=water efecto
          //si quicksand
          if (l.rooms.room[x].water and 128)=128 then l.rooms.room[x].vertices.vertice2[k].attrib:=$2000;

        end
        else
        begin
           l.rooms.room[x].vertices.vertice2[k].light2:=$ffff;
           l.rooms.room[x].vertices.vertice2[k].attrib:=0;
        end


    end; //end k
    if l.tipo=4 then l.rooms.room[x].sand_effect:=0 else l.rooms.room[x].sand_effect:=$ffff;

    l.rooms.room[x].light_mode:=3; //0=brillante, 1=intermitente,2=fade light,3=normal.
    end;//end x


    for k:=1 to l.items.num_items do
    begin
        l.items.item2[k].obj:=l.items.item[k].obj;
        l.items.item2[k].room:=l.items.item[k].room;
        l.items.item2[k].x:=l.items.item[k].x;
        l.items.item2[k].y:=l.items.item[k].y;
        l.items.item2[k].z:=l.items.item[k].z;
        l.items.item2[k].d:=l.items.item[k].d;
        l.items.item2[k].angle:=l.items.item[k].angle;
        l.items.item2[k].light1:=l.items.item[k].light1;
        l.items.item2[k].light2:=l.items.item[k].light2;
        l.items.item2[k].un1:=l.items.item[k].un1;
    end; //endfor;

//arreglar los boxes y zones;
for k:=1 to l.boxes.num_boxes do
begin
    l.boxes.box2[k].zmin:=l.boxes.box[k].zmin div 1024;
    l.boxes.box2[k].zmax:=l.boxes.box[k].zmax div 1024;
    l.boxes.box2[k].xmin:=l.boxes.box[k].xmin div 1024;
    l.boxes.box2[k].xmax:=l.boxes.box[k].xmax div 1024;
    l.boxes.box2[k].floory:=l.boxes.box[k].floory;
    l.boxes.box2[k].overlap_index:=l.boxes.box[k].overlap_index;
end;


for k:=1 to l.zones.num_zones do
begin
     l.zones.nground_zone1[k]:=0;
     l.zones.nground_zone2[k]:=0;
     l.zones.nground_zone3[k]:=0;
     l.zones.nground_zone4[k]:=0;
     l.zones.nfly_zone[k]:=0;
     l.zones.aground_zone1[k]:=0;
     l.zones.aground_zone2[k]:=0;
     l.zones.aground_zone3[k]:=0;
     l.zones.aground_zone4[k]:=0;
     l.zones.afly_zone[k]:=0;
end;


end;
{***********************************}

{
function ttrlevel.Loaditm(name:string):byte;
var
f:file;
x,x2:word;
xroom,xsector,xfloor_index:word;
numdata:word;
newdata:word;
signature:string[7];

begin
   if not fileExists(name) then begin loaditm:=1;exit; end;
   assign(f,name);
   reset(f,1);

   //signature primero
   blockread(f,signature,sizeof(signature));
   if signature<>'TPASCAL' then begin tr_loaditm:=2;exit;end;
  //restaurar tabla de items
  blockread(f,l.items.num_items,4);

  if (l.tipo<vtr2) then blockread(f,l.items.item, l.items.Num_items*sizeof(titem)); //tr1/tub

  if (l.tipo=3) or (l.tipo=4) then
                                 blockread(f,l.items.item2, l.items.Num_items*sizeof(titem2)) else
                                 blockread(f,l.items.item, l.items.Num_items*sizeof(titem));
    //floor_data
   numdata:=l.floor_data.num_floor_data;
   blockread(f,newdata,2);
   l.floor_data.num_floor_data:=l.floor_data.num_floor_data+newdata;
   blockread(f,l.floor_data.floor_data[numdata], newdata*2);

//las cameras
     blockread(f,l.cameras.Num_cameras,4);
     blockread(f,l.cameras.camera, l.cameras.Num_cameras*sizeof(tcamera));

   //restaurar cuantos rooms habia al salvar esto.
   blockread(f,x2,2);

//restaurar los source lights y static meshes, sprites and room flags
  for x:=1 to x2 do
  begin
         //sprites primero.
          blockread(f,l.rooms.room[x].Sprites.num_sprites,2);
          blockread(f,l.rooms.room[x].Sprites.sprite, sizeof(tsprite) * l.rooms.room[x].Sprites.num_sprites );

          //spoot lights
          blockread(f,l.rooms.room[x].Source_lights.num_sources,2);
          if (l.tipo=3) or (l.tipo=4) then
                     blockread(f,l.rooms.room[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms.room[x].Source_lights.num_sources ) else
                     blockread(f,l.rooms.room[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms.room[x].Source_lights.num_sources );

          //static meshs
          blockread(f,l.rooms.room[x].Statics.num_static,2);
          if (l.tipo=3) or (l.tipo=4) then
                                      blockread(f,l.rooms.room[x].statics.static2, sizeof(tstatic2) * l.rooms.room[x].statics.num_static ) else
                                      blockread(f,l.rooms.room[x].statics.static, sizeof(tstatic) * l.rooms.room[x].statics.num_static );

         //room flags
          blockread(f,l.rooms.room[x].d1,2); //alternate room
          blockread(f,l.rooms.room[x].d1,1); //water
          blockread(f,l.rooms.room[x].d1,1); //


 end; //restaurar todos los static y source lights.



   //restaurar los trigers
   while not eof(f) do
   begin
         blockread(f,xroom,2);
         blockread(f,xsector,2);
         blockread(f,xfloor_index,2);
         l.rooms.room[xroom].sectors.sector[xsector].floor_index:=numdata+xfloor_index;
   end;//fin leer todos los trigers

close(f);
   tr_loaditm:=0;

end;

//------------------------------------------------

procedure tr_saveitm(var L:tphd; name:string);
var
f:file;
x,y:integer;
xfloor_index:word;
numdata:word;
newdata:word;
signature:string[7];
begin
  assign(f,name);
  rewrite(f,1);
  //signature primero
  signature:='TPASCAL';
  blockwrite(f,signature,sizeof(signature));

  //salvar la tabla de items
  blockwrite(f,l.items.num_items,4);
  if (l.tipo=3) or (l.tipo=4) then
                                 blockwrite(f,l.items.item2, l.items.Num_items*sizeof(titem2)) else
                                 blockwrite(f,l.items.item, l.items.Num_items*sizeof(titem));

   //floor_data
   //averiguar cuantos floor datas agrego tritem.
   move(l.floor_data.floor_data[0],numdata,2);
   newdata:=l.floor_data.num_floor_data-numdata;

   blockwrite(f,newdata,2);
   blockwrite(f,l.floor_data.floor_data[numdata],newdata*2);


//las cameras
     blockwrite(f,l.cameras.Num_cameras,4);
     blockwrite(f,l.cameras.camera, l.cameras.Num_cameras*sizeof(tcamera));



   //salvar cuantos rooms habia al salvar esto.
   blockwrite(f,l.rooms.num_rooms,2);

//Salvar Statics mesh and source lights. y sprites, y room flags.
   for x:=1 to l.rooms.num_rooms do
   begin
      //sprites
      blockwrite(f,l.rooms.room[x].Sprites.num_sprites,2);
      blockwrite(f,l.rooms.room[x].Sprites.sprite, sizeof(tsprite) * l.rooms.room[x].Sprites.num_sprites );

      //source lights
          blockwrite(f,l.rooms.room[x].Source_lights.num_sources,2);
          if (l.tipo=3) or (l.tipo=4) then
                     blockwrite(f,l.rooms.room[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms.room[x].Source_lights.num_sources ) else
                     blockwrite(f,l.rooms.room[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms.room[x].Source_lights.num_sources );


       //numero de static meshes
       blockwrite(f,l.rooms.room[x].statics.num_static,2);
         if (l.tipo=3) or (l.tipo=4) then
                                 blockwrite(f,l.rooms.room[x].statics.static2, sizeof(tstatic2) * l.rooms.room[x].statics.num_static ) else
                                 blockwrite(f,l.rooms.room[x].statics.static, sizeof(tstatic) * l.rooms.room[x].statics.num_static );


       //Salvar room flags
       blockwrite(f,l.rooms.room[x].d1,2); //alternate room
       blockwrite(f,l.rooms.room[x].d1,1); //water
       blockwrite(f,l.rooms.room[x].d1,1); //


   end;//salvar todos los static and sources lights


   //salvar los trigers
   for x:=1 to l.rooms.num_rooms do
   begin
       for y:=1 to l.rooms.room[x].sectors.largo*l.rooms.room[x].sectors.ancho do
       begin
            if  l.rooms.room[x].sectors.sector[y].floor_index>=numdata then
            begin
                blockwrite(f,x,2); //salvar el room number
                blockwrite(f,y,2); //salvar el sector number;
                xfloor_index:=l.rooms.room[x].sectors.sector[y].floor_index-numdata;
                blockwrite(f,xfloor_index,2);
            end;//salver este floor_data
       end;//fin leer todos los sectores;
   end;//fin de scanear all rooms.

close(f);
end;
//---------------------------------------

}



//para efectos de depurado.
function tr_testPhd(var L:tphd; name:string):byte;
var
f:file;
resultado:byte;
x:word;
k:word;
tipo:byte; //0=no version, 1=phd, 2=tub, 3=TR2, 4=TR3
begin
 fillchar(L,sizeof(L),chr(0));
 resultado:=0;
 tipo:=0;

 if fileExists(name) then
 begin
    filemode:=0;
    assignfile(f,name);
    reset(f,1);
    filemode:=2;
    blockread(f,L.version,4);



    if (l.version<>$20) and (l.version<>$2d) and (l.version<>$ff180038) and (l.version<>$ff080038) then begin close(f);L.version:=0;resultado:=2;end;
 end
 else resultado:=1;
 {*****************}

 if resultado=0 then
 begin


     case l.version of

          $20: if (pos('.TUB',name)<>0) or (pos('.tub',name)<>0) then tipo:=2 else tipo:=1;
          $2d:tipo:=3;
          $ff080038,$ff180038:tipo:=4;
     end;//end case

     WRITELN('File Pos:',filepos(f)-4,' Tipo:',tipo);

     //si tr2 o tr3 cargar las paletas aqui.
     if (tipo=3) or (tipo=4) then
     begin
          blockread(f,l.Palette,768); //palette 256 colors
          blockread(f,l.Palette16,1024); //palette 16bit colors
     end;


     Blockread(f, l.Size_Textures,4); {get size textures bitmaps}
     L.Num_texture_pages:=l.Size_Textures; //salvar aqui cuantas paginas de texturas hay.
     l.Size_Textures:=l.Size_Textures*65536; //calcular aqui el tamano de las texturas.

     //cargar las texturas bitmaps
     getmem(l.texture_data, l.Size_Textures);
     blockread(f, l.texture_data^, l.Size_Textures);

     //si tr2 o tr3 cargar las 16bit texturas bitmaps.
     if (tipo=3) or (tipo=4) then
     begin
          getmem(l.texture_data2, L.Num_texture_pages*131072);
          blockread(f, l.texture_data2^, L.Num_texture_pages*131072);
     end;//

     blockread(f, l.dumys,4); //4 bytes segun roseta, yo tenia 6..
     blockread(f,l.rooms.num_rooms,2);   {get total rooms}

     WRITELN('File Pos:',filepos(f)-4,' Num rooms:',l.rooms.num_rooms);

     {Cargar todos los Rooms.}
     for x:=1 to l.rooms.num_rooms do
     begin
          //Room info
          blockread(f,l.rooms.room[x].room_info, sizeof(troom_info) );

          blockread(f,l.rooms.room[x].vertices.num_vertices,2);
          if x=1 then WRITELN('File Pos:',filepos(f)-2,' Num vertices:',l.rooms.room[x].vertices.num_vertices);


          //cargar los vertices deacuerdo a la version.
          if (tipo=3) or (tipo=4) then
              begin
                  blockread(f,l.rooms.room[x].vertices.vertice2, sizeof(tvertice2) * l.rooms.room[x].vertices.num_vertices );
                  //poner los vertices en tr1/tub formato tambien
                  for k:=1 to l.rooms.room[x].vertices.num_vertices do
                  begin
                       l.rooms.room[x].vertices.vertice[k].x:=l.rooms.room[x].vertices.vertice2[k].x;
                       l.rooms.room[x].vertices.vertice[k].y:=l.rooms.room[x].vertices.vertice2[k].y;
                       l.rooms.room[x].vertices.vertice[k].z:=l.rooms.room[x].vertices.vertice2[k].z;
                       l.rooms.room[x].vertices.vertice[k].light:=l.rooms.room[x].vertices.vertice2[k].light;
                  end;

              end
           else
               begin
                   blockread(f,l.rooms.room[x].vertices.vertice, sizeof(tvertice) * l.rooms.room[x].vertices.num_vertices );
                  for k:=1 to l.rooms.room[x].vertices.num_vertices do
                  begin
                       l.rooms.room[x].vertices.vertice2[k].x:=l.rooms.room[x].vertices.vertice[k].x;
                       l.rooms.room[x].vertices.vertice2[k].y:=l.rooms.room[x].vertices.vertice[k].y;
                       l.rooms.room[x].vertices.vertice2[k].z:=l.rooms.room[x].vertices.vertice[k].z;
                       l.rooms.room[x].vertices.vertice2[k].light:=l.rooms.room[x].vertices.vertice[k].light;
                  end;

               end;

          blockread(f,l.rooms.room[x].quads.num_quads,2);
          blockread(f,l.rooms.room[x].quads.quad,  sizeof(tquad) * l.rooms.room[x].quads.num_quads );



          blockread(f,l.rooms.room[x].triangles.num_triangles,2);
          blockread(f,l.rooms.room[x].triangles.triangle,  sizeof(ttriangle) * l.rooms.room[x].triangles.num_triangles );


          blockread(f,l.rooms.room[x].sprites.num_sprites,2);
          blockread(f,l.rooms.room[x].sprites.sprite, sizeof(tsprite) * l.rooms.room[x].sprites.num_sprites);


          blockread(f,l.rooms.room[x].doors.num_doors,2);
          blockread(f,l.rooms.room[x].doors.door, sizeof(tdoor) * l.rooms.room[x].doors.num_doors );


          blockread(f,l.rooms.room[x].sectors.largo,2);
          blockread(f,l.rooms.room[x].sectors.ancho,2);
          blockread(f,l.rooms.room[x].sectors.sector,  sizeof(tsector) * l.rooms.room[x].sectors.largo * l.rooms.room[x].sectors.ancho);
          blockread(f,l.rooms.room[x].d0,1);
          blockread(f,l.rooms.room[x].lara_light,1);


          //if tr2 o tr3 cargar segunda luz de ambiente en el room
          if (tipo=3) or (tipo=4) then blockread(f,l.rooms.room[x].sand_effect,2);
          if (tipo=3) then blockread(f,l.rooms.room[x].light_mode,2);

          blockread(f,l.rooms.room[x].Source_lights.num_sources,2);

          //if tr2 o tr3 cargar la fuente de luz
          if (tipo=3) or (tipo=4) then
                     blockread(f,l.rooms.room[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms.room[x].Source_lights.num_sources ) else
                     blockread(f,l.rooms.room[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms.room[x].Source_lights.num_sources );



          blockread(f,l.rooms.room[x].Statics.num_static,2);
        //if tr2 o tr3 cargar los statics objects
          if (tipo=3) or (tipo=4) then
                                      blockread(f,l.rooms.room[x].statics.static2, sizeof(tstatic2) * l.rooms.room[x].statics.num_static ) else
                                      blockread(f,l.rooms.room[x].statics.static, sizeof(tstatic) * l.rooms.room[x].statics.num_static );




          blockread(f,l.rooms.room[x].alternate,2);
          blockread(f,l.rooms.room[x].water,1);
          blockread(f,l.rooms.room[x].d2,1);

          //solo tr3 tiene lo siguiente.
          if tipo=4 then blockread(f,l.rooms.room[x].room_color,3);

     end; {fin cargar todos los rooms}



     //floor_data
     blockread(f,l.floor_data.num_floor_data,4);

     WRITELN('File Pos:',filepos(f)-4,' Num floor data:',l.floor_data.num_floor_data);


     blockread(f,l.floor_data.floor_data, l.floor_data.num_floor_data*2);


     //mesh words
     blockread(f,l.meshwords.num_meshwords,4);

     WRITELN('File Pos:',filepos(f)-4,' Num meshwords:',l.meshwords.num_meshwords);

     blockread(f,l.meshwords.meshword, l.meshwords.num_meshwords*2);


     //mesh pointers
     blockread(f,l.Meshpointers.num_meshpointers,4);
     WRITELN('File Pos:',filepos(f)-4,' meshpointers:',l.meshpointers.num_meshpointers);

     blockread(f,l.meshpointers.meshpointer, l.Meshpointers.num_meshpointers *4);

     //anims
     blockread(f,l.Anims.num_anims,4);
     WRITELN('File Pos:',filepos(f)-4,' Num anims:',l.anims.num_anims);

     blockread(f,l.Anims.anim,l.Anims.num_anims*32);


     //structs
     blockread(f,l.Structs.num_struct,4);
     WRITELN('File Pos:',filepos(f)-4,' struct:',l.structs.num_struct);

     blockread(f,l.Structs.struct, l.Structs.num_struct*6);


     //ranges
     blockread(f,l.Ranges.num_ranges,4);
     WRITELN('File Pos:',filepos(f)-4,' ranges:',l.ranges.num_ranges);

     blockread(f,l.Ranges.range, l.Ranges.num_ranges*8);


     //bones1
     blockread(f,l.Bones1.Num_bones1,4);
     WRITELN('File Pos:',filepos(f)-4,' bones1:',l.bones1.num_bones1);

     blockread(f,l.Bones1.Bone1, l.Bones1.Num_bones1*2);

     //bones2
     blockread(f,l.Bones2.Num_bones2,4);
     WRITELN('File Pos:',filepos(f)-4,' bones2:',l.bones2.num_bones2);

     blockread(f,l.Bones2.Bone2, l.Bones2.Num_bones2*4);

     //frames
     blockread(f,l.Frames.Num_frames,4);
     WRITELN('File Pos:',filepos(f)-4,' Frames:',l.frames.num_frames);

     blockread(f,l.Frames.frame, l.Frames.Num_frames*2);

     //movables
     blockread(f,l.Movables.Num_movables,4);
     WRITELN('File Pos:',filepos(f)-4,' moveables:',l.movables.num_movables);

     blockread(f,l.movables.movable, l.Movables.Num_movables*18);

     //desconocido1 esto son los static mesh disponibles.
     blockread(f,l.static_table.Num_static,4);
     WRITELN('File Pos:',filepos(f)-4,' static meshes:',l.static_table.num_static);

     blockread(f,l.static_table.static, l.static_table.Num_static*32);

     //obj textures
     //solo tr1/tub and tr2 tiene los obj texturas aqui.
     if tipo<>4 then
     begin
          blockread(f,l.Textures.Num_textures,4);
          WRITELN('File Pos:',filepos(f)-4,' obj textures:',l.textures.num_textures);

          blockread(f,l.Textures.texture, l.Textures.Num_textures*20);
     end;


     //sprites textures
     blockread(f,l.Spr_Textures.Num_spr_textures,4);
     WRITELN('File Pos:',filepos(f)-4,' sprites textures:',l.spr_textures.num_spr_textures);

     blockread(f,l.Spr_Textures.spr_texture, l.Spr_Textures.Num_spr_textures*16);

     //desconocido2 sprites sequencias
     blockread(f,l.Desconocido2.Num_des2,4);
     WRITELN('File Pos:',filepos(f)-4,' sprite sequ:',l.desconocido2.num_des2);
     blockread(f,l.desconocido2.des2, l.Desconocido2.Num_des2*8);

     //if tub file load the palette here
     if tipo=2 then blockread(f,l.Palette,768); //palette

     //cameras
     blockread(f,l.Cameras.Num_cameras,4);
     WRITELN('File Pos:',filepos(f)-4,' cameras:',l.cameras.num_cameras);
     blockread(f,l.Cameras.camera, l.Cameras.Num_cameras*16);

     //sound fxs
     blockread(f,l.Sound_fxs.Num_sound_fxs,4);
     WRITELN('File Pos:',filepos(f)-4,' sound fx:',l.sound_fxs.num_sound_fxs);
     blockread(f,l.Sound_fxs.sound_fx, l.Sound_fxs.Num_sound_fxs*16);

     //boxes
     blockread(f,l.boxes.Num_boxes,4);

     WRITELN('File Pos:',filepos(f)-4,' Boxes:',l.boxes.num_boxes);

     if (tipo=3) or (tipo=4) then
                             blockread(f,l.boxes.box2, l.boxes.Num_boxes*8) else
                             blockread(f,l.boxes.box, l.boxes.Num_boxes*20);

     //overlaps
     blockread(f,l.Overlaps.Num_overlaps,4);
     WRITELN('File Pos:',filepos(f)-4,' overlaps:',l.overlaps.num_overlaps);

     blockread(f,l.Overlaps.overlap, l.Overlaps.Num_overlaps*2);

     //zonas
     l.zones.Num_zones:=l.boxes.Num_boxes;

     if (tipo=3) or (tipo=4) then
     begin
         blockread(f, l.zones.nground_zone1, l.zones.Num_zones*2);
         blockread(f, l.zones.nground_zone2, l.zones.Num_zones*2);
         blockread(f, l.zones.nground_zone3, l.zones.Num_zones*2);
         blockread(f, l.zones.nground_zone4, l.zones.Num_zones*2);
         blockread(f, l.zones.nfly_zone    , l.zones.Num_zones*2);
         //----------
         blockread(f, l.zones.aground_zone1, l.zones.Num_zones*2);
         blockread(f, l.zones.aground_zone2, l.zones.Num_zones*2);
         blockread(f, l.zones.aground_zone3, l.zones.Num_zones*2);
         blockread(f, l.zones.aground_zone4, l.zones.Num_zones*2);
         blockread(f, l.zones.afly_zone    , l.zones.Num_zones*2);
     end //fin cargar zonas para tr2/tr3
     else
     begin
         blockread(f, l.zones.nground_zone1, l.zones.Num_zones*2);
         blockread(f, l.zones.nground_zone2, l.zones.Num_zones*2);
         blockread(f, l.zones.nfly_zone    , l.zones.Num_zones*2);
         //----------
         blockread(f, l.zones.aground_zone1, l.zones.Num_zones*2);
         blockread(f, l.zones.aground_zone2, l.zones.Num_zones*2);
         blockread(f, l.zones.afly_zone    , l.zones.Num_zones*2);
     end;//fin phd/tub

     //animated textures
     blockread(f,l.Anim_textures.Num_anim_textures,4);
     WRITELN('File Pos:',filepos(f)-4,' Anim textures:',l.anim_textures.num_anim_textures);

     blockread(f,l.Anim_textures.anim_texture, l.Anim_textures.Num_anim_textures*2);


     //obj textures
     //solo tr3 tiene los obj texturas aqui.
     if tipo=4 then
     begin
          blockread(f,l.Textures.Num_textures,4);
          WRITELN('File Pos:',filepos(f)-4,' Obj textures:',l.textures.num_textures);
          blockread(f,l.Textures.texture, l.Textures.Num_textures*20);
     end;


     //Items
     blockread(f,l.items.Num_items,4);
     WRITELN('File Pos:',filepos(f)-4,' Items:',l.items.num_items);

     if (tipo=3) or (tipo=4) then
                              blockread(f,l.items.item2, l.items.Num_items*sizeof(titem2)) else
                              blockread(f,l.items.item, l.items.Num_items*sizeof(titem));

     //colormap
     blockread(f,l.Colormap,32*256);


     //if phd file load the palette here
     if tipo=1 then blockread(f,l.Palette,768); //palette

     //desconocido3 cinematic frames
     blockread(f,l.Desconocido3.Num_des3,2);
     WRITELN('File Pos:',filepos(f)-4,' cinematic frames:',l.desconocido3.num_des3);
     blockread(f,l.Desconocido3.des3, l.Desconocido3.Num_des3*16);

     //desconocido4 demo data
     blockread(f,l.Desconocido4.Num_des4,2);
     WRITELN('File Pos:',filepos(f)-4,' demo data:',l.desconocido4.num_des4);
     blockread(f,l.Desconocido4.des4, l.Desconocido4.Num_des4);


     //sound_map
     if (tipo=3) or (tipo=4) then
                  blockread(f,l.sound_map, 740) else
                  blockread(f,l.sound_map, 512);


     //samples info
     blockread(f,l.samples_info.Num_samples_info,4);
     WRITELN('File Pos:',filepos(f)-4,' sample info:',l.samples_info.num_samples_info);
     blockread(f,l.samples_info.sample_info, l.samples_info.Num_samples_info*sizeof(tsample_info));

     //samples
     if (tipo=1) or (tipo=2) then
     begin
         blockread(f,l.samples.samples_size,4);
         getmem(l.samples.buffer, l.samples.samples_size);
         blockread(f,l.samples.buffer^, l.samples.samples_size);
     end;//end si phd or tub

     //samples offsets
     blockread(f,l.samples_offsets.Num_offsets,4);
     WRITELN('File Pos:',filepos(f)-4,' samples offsets:',l.samples_offsets.num_offsets);
     blockread(f,l.samples_offsets.offset, l.samples_offsets.Num_offsets*4);

     close(f);
 end;{load phd}

 tr_testPhd:=resultado;

end;


{***********************************}



function tr_SavePhd(var L:tphd; name:string):byte;
var
f:file;
resultado:byte;
x:word;
tipo:byte; //0=no version, 1=phd, 2=tub, 3=TR2, 4=TR3
begin

 resultado:=0;
 tipo:=0;

    assignfile(f,name);
    rewrite(f,1);
    blockwrite(f,L.version,4);

    if (l.version<>$20) and (l.version<>$2d) and (l.version<>$ff180038) and (l.version<>$ff080038) then begin close(f);L.version:=0;resultado:=2;end;
 {*****************}

     case l.version of
          $20: if (pos('.TUB',name)<>0) or (pos('.tub',name)<>0) then tipo:=2 else tipo:=1;
          $2d:tipo:=3;
          $ff080038,$ff180038:tipo:=4;
     end;//end case


     //si tr2 o tr3 cargar las paletas aqui.
     if (tipo=3) or (tipo=4) then
     begin
          blockwrite(f,l.Palette,768); //palette 256 colors
          blockwrite(f,l.Palette16,1024); //palette 16bit colors
     end;


     blockwrite(f, L.Num_texture_pages,4); {get size textures bitmaps}

     //cargar las texturas bitmaps
     blockwrite(f, l.texture_data^, l.Size_Textures);

     //si tr2 o tr3 cargar las 16bit texturas bitmaps.
     if (tipo=3) or (tipo=4) then
     begin
          blockwrite(f, l.texture_data2^, L.Num_texture_pages*131072);
     end;//


     blockwrite(f, l.dumys,4); //4 bytes segun roseta, yo tenia 6..
     blockwrite(f,l.rooms.num_rooms,2);   {get total rooms}

     {Cargar todos los Rooms.}
     for x:=1 to l.rooms.num_rooms do
     begin
          //Room info
          //Calcular el numero de words necesarios para contener las tablas.

        if (tipo=3) or (tipo=4) then
        l.rooms.room[x].room_info.num_words:=(((l.rooms.room[x].vertices.num_vertices*12)+
                                             (l.rooms.room[x].quads.num_quads*10)+
                                             (l.rooms.room[x].triangles.num_triangles*8)+
                                             (l.rooms.room[x].sprites.num_sprites*4))+8) div 2 else

        l.rooms.room[x].room_info.num_words:=(((l.rooms.room[x].vertices.num_vertices*8)+
                                             (l.rooms.room[x].quads.num_quads*10)+
                                             (l.rooms.room[x].triangles.num_triangles*8)+
                                             (l.rooms.room[x].sprites.num_sprites*4))+8) div 2;



          blockwrite(f,l.rooms.room[x].room_info, sizeof(troom_info) );

          blockwrite(f,l.rooms.room[x].vertices.num_vertices,2);


          //cargar los vertices deacuerdo a la version.
          if (tipo=3) or (tipo=4) then
                  blockwrite(f,l.rooms.room[x].vertices.vertice2, sizeof(tvertice2) * l.rooms.room[x].vertices.num_vertices )
                  else
                  blockwrite(f,l.rooms.room[x].vertices.vertice, sizeof(tvertice) * l.rooms.room[x].vertices.num_vertices );


          blockwrite(f,l.rooms.room[x].quads.num_quads,2);
          blockwrite(f,l.rooms.room[x].quads.quad,  sizeof(tquad) * l.rooms.room[x].quads.num_quads );

          blockwrite(f,l.rooms.room[x].triangles.num_triangles,2);
          blockwrite(f,l.rooms.room[x].triangles.triangle,  sizeof(ttriangle) * l.rooms.room[x].triangles.num_triangles );

          blockwrite(f,l.rooms.room[x].sprites.num_sprites,2);
          blockwrite(f,l.rooms.room[x].sprites.sprite, sizeof(tsprite) * l.rooms.room[x].sprites.num_sprites);


          blockwrite(f,l.rooms.room[x].doors.num_doors,2);
          blockwrite(f,l.rooms.room[x].doors.door, sizeof(tdoor) * l.rooms.room[x].doors.num_doors );


          blockwrite(f,l.rooms.room[x].sectors.largo,2);
          blockwrite(f,l.rooms.room[x].sectors.ancho,2);
          blockwrite(f,l.rooms.room[x].sectors.sector,  sizeof(tsector) * l.rooms.room[x].sectors.largo * l.rooms.room[x].sectors.ancho);
          blockwrite(f,l.rooms.room[x].d0,1);
          blockwrite(f,l.rooms.room[x].lara_light,1);

          //if tr2 o tr3 cargar segunda luz de ambiente en el room
          if (tipo=3) or (tipo=4) then blockwrite(f,l.rooms.room[x].sand_effect,2);
          if (tipo=3) then blockwrite(f,l.rooms.room[x].light_mode,2);

          blockwrite(f,l.rooms.room[x].Source_lights.num_sources,2);

          //if tr2 o tr3 cargar la fuente de luz
          if (tipo=3) or (tipo=4) then
                     blockwrite(f,l.rooms.room[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms.room[x].Source_lights.num_sources ) else
                     blockwrite(f,l.rooms.room[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms.room[x].Source_lights.num_sources );


          blockwrite(f,l.rooms.room[x].Statics.num_static,2);
        //if tr2 o tr3 cargar los statics objects
          if (tipo=3) or (tipo=4) then
                                      blockwrite(f,l.rooms.room[x].statics.static2, sizeof(tstatic2) * l.rooms.room[x].statics.num_static ) else
                                      blockwrite(f,l.rooms.room[x].statics.static, sizeof(tstatic) * l.rooms.room[x].statics.num_static );




          blockwrite(f,l.rooms.room[x].alternate,2);
          blockwrite(f,l.rooms.room[x].water,1);
          blockwrite(f,l.rooms.room[x].d2,1);

          //solo tr3 tiene lo siguiente.
          if tipo=4 then blockwrite(f,l.rooms.room[x].room_color,3);

     end; {fin cargar todos los rooms}


     //floor_data
     blockwrite(f,l.floor_data.num_floor_data,4);
     blockwrite(f,l.floor_data.floor_data, l.floor_data.num_floor_data*2);


     //mesh words
     blockwrite(f,l.meshwords.num_meshwords,4);
     blockwrite(f,l.meshwords.meshword, l.meshwords.num_meshwords*2);


     //mesh pointers
     blockwrite(f,l.Meshpointers.num_meshpointers,4);
     blockwrite(f,l.meshpointers.meshpointer, l.Meshpointers.num_meshpointers *4);

     //anims
     blockwrite(f,l.Anims.num_anims,4);
     blockwrite(f,l.Anims.anim,l.Anims.num_anims*32);


     //structs
     blockwrite(f,l.Structs.num_struct,4);
     blockwrite(f,l.Structs.struct, l.Structs.num_struct*6);


     //ranges
     blockwrite(f,l.Ranges.num_ranges,4);
     blockwrite(f,l.Ranges.range, l.Ranges.num_ranges*8);


     //bones1
     blockwrite(f,l.Bones1.Num_bones1,4);
     blockwrite(f,l.Bones1.Bone1, l.Bones1.Num_bones1*2);

     //bones2
     blockwrite(f,l.Bones2.Num_bones2,4);
     blockwrite(f,l.Bones2.Bone2, l.Bones2.Num_bones2*4);

     //frames
     blockwrite(f,l.Frames.Num_frames,4);
     blockwrite(f,l.Frames.frame, l.Frames.Num_frames*2);

     //movables
     blockwrite(f,l.Movables.Num_movables,4);
     blockwrite(f,l.movables.movable, l.Movables.Num_movables*18);

     //desconocido1 esto son los static mesh disponibles.
     blockwrite(f,l.static_table.Num_static,4);
     blockwrite(f,l.static_table.static, l.static_table.Num_static*32);

     //obj textures
     //solo tr1/tub and tr2 tiene los obj texturas aqui.
     if tipo<>4 then
     begin
          blockwrite(f,l.Textures.Num_textures,4);
          blockwrite(f,l.Textures.texture, l.Textures.Num_textures*20);
     end;


     //sprites textures
     blockwrite(f,l.Spr_Textures.Num_spr_textures,4);
     blockwrite(f,l.Spr_Textures.spr_texture, l.Spr_Textures.Num_spr_textures*16);

     //desconocido2 sprites sequencias
     blockwrite(f,l.Desconocido2.Num_des2,4);
     blockwrite(f,l.desconocido2.des2, l.Desconocido2.Num_des2*8);

     //if tub file load the palette here
     if tipo=2 then blockwrite(f,l.Palette,768); //palette

     //cameras
     blockwrite(f,l.Cameras.Num_cameras,4);
     blockwrite(f,l.Cameras.camera, l.Cameras.Num_cameras*16);

     //sound fxs
     blockwrite(f,l.Sound_fxs.Num_sound_fxs,4);
     blockwrite(f,l.Sound_fxs.sound_fx, l.Sound_fxs.Num_sound_fxs*16);

     //boxes
     blockwrite(f,l.boxes.Num_boxes,4);

     if (tipo=3) or (tipo=4) then
                             blockwrite(f,l.boxes.box2, l.boxes.Num_boxes*8) else
                             blockwrite(f,l.boxes.box, l.boxes.Num_boxes*20);

     //overlaps
     blockwrite(f,l.Overlaps.Num_overlaps,4);
     blockwrite(f,l.Overlaps.overlap, l.Overlaps.Num_overlaps*2);

     //zonas
    if (tipo=3) or (tipo=4) then
     begin
         blockwrite(f, l.zones.nground_zone1, l.zones.Num_zones*2);
         blockwrite(f, l.zones.nground_zone2, l.zones.Num_zones*2);
         blockwrite(f, l.zones.nground_zone3, l.zones.Num_zones*2);
         blockwrite(f, l.zones.nground_zone4, l.zones.Num_zones*2);
         blockwrite(f, l.zones.nfly_zone    , l.zones.Num_zones*2);
         //----------
         blockwrite(f, l.zones.aground_zone1, l.zones.Num_zones*2);
         blockwrite(f, l.zones.aground_zone2, l.zones.Num_zones*2);
         blockwrite(f, l.zones.aground_zone3, l.zones.Num_zones*2);
         blockwrite(f, l.zones.aground_zone4, l.zones.Num_zones*2);
         blockwrite(f, l.zones.afly_zone    , l.zones.Num_zones*2);
     end //fin cargar zonas para tr2/tr3
     else
     begin
         blockwrite(f, l.zones.nground_zone1, l.zones.Num_zones*2);
         blockwrite(f, l.zones.nground_zone2, l.zones.Num_zones*2);
         blockwrite(f, l.zones.nfly_zone    , l.zones.Num_zones*2);
         //----------
         blockwrite(f, l.zones.aground_zone1, l.zones.Num_zones*2);
         blockwrite(f, l.zones.aground_zone2, l.zones.Num_zones*2);
         blockwrite(f, l.zones.afly_zone    , l.zones.Num_zones*2);
     end;//fin phd/tub


     //animated textures
     blockwrite(f,l.Anim_textures.Num_anim_textures,4);
     blockwrite(f,l.Anim_textures.anim_texture, l.Anim_textures.Num_anim_textures*2);


     //obj textures
     //solo tr3 tiene los obj texturas aqui.
     if tipo=4 then
     begin
          blockwrite(f,l.Textures.Num_textures,4);
          blockwrite(f,l.Textures.texture, l.Textures.Num_textures*20);
     end;


     //Items
     blockwrite(f,l.items.Num_items,4);

     if (tipo=3) or (tipo=4) then
                              blockwrite(f,l.items.item2, l.items.Num_items*sizeof(titem2)) else
                              blockwrite(f,l.items.item, l.items.Num_items*sizeof(titem));

     //colormap
     blockwrite(f,l.Colormap,32*256);


     //if phd file load the palette here
     if tipo=1 then blockwrite(f,l.Palette,768); //palette

     //desconocido3 cinematic frames
     blockwrite(f,l.Desconocido3.Num_des3,2);
     blockwrite(f,l.Desconocido3.des3, l.Desconocido3.Num_des3*16);

     //desconocido4 demo data
     blockwrite(f,l.Desconocido4.Num_des4,2);
     blockwrite(f,l.Desconocido4.des4, l.Desconocido4.Num_des4);


     //sound_map
     if (tipo=3) or (tipo=4) then
                  blockwrite(f,l.sound_map, 740) else
                  blockwrite(f,l.sound_map, 512);


     //samples info
     blockwrite(f,l.samples_info.Num_samples_info,4);
     blockwrite(f,l.samples_info.sample_info, l.samples_info.Num_samples_info*sizeof(tsample_info));

     //samples
     if (tipo=1) or (tipo=2) then
     begin
         blockwrite(f,l.samples.samples_size,4);
         blockwrite(f,l.samples.buffer^, l.samples.samples_size);
     end;//end si phd or tub

     //samples offsets
     blockwrite(f,l.samples_offsets.Num_offsets,4);
     blockwrite(f,l.samples_offsets.offset, l.samples_offsets.Num_offsets*4);

     close(f);

  tr_SavePhd:=resultado;

end;





{****************************************************}
{     FUNCIONES Y PROCEDIMIENTOS AUXILIARES          }
{****************************************************}
function seek_vertex(var v:tvertice_list; x,y,z:smallint):word;
var
n,i:word;

begin
  i:=0;
  n:=1;
  while (n<=v.num_vertices) and (i=0) do
  begin
       if (v.vertice[n].x=x) and (v.vertice[n].y=y) and (v.vertice[n].z=z) then i:=n;
       n:=n+1;
  end;{end while}

  seek_vertex:=i;

end;


{*****************************************************}
procedure add_vertex(var v:tvertice_list; x,y,z:smallint; light:byte);
var
k:word;
begin
    k:=seek_vertex(v,x,y,z);
    if k<>0 then v.vertice[k].light:=(light+v.vertice[k].light) div 2;

if (k=0) and (v.num_vertices<3000) then
  begin
     v.num_vertices:=v.num_vertices+1;

     v.vertice[v.num_vertices].x:=x;
     v.vertice[v.num_vertices].y:=y;
     v.vertice[v.num_vertices].z:=z;
     v.vertice[v.num_vertices].light:=light;

     v.vertice2[v.num_vertices].x:=x;
     v.vertice2[v.num_vertices].y:=y;
     v.vertice2[v.num_vertices].z:=z;
     v.vertice2[v.num_vertices].light:=light;

  end;
end;
{*****************************************************}
procedure add_poly4( var poly4:tpoly4_list; x1,y1,z1, x2,y2,z2, x3,y3,z3, x4,y4,z4:smallint; texture:word; light:byte );
begin
    if poly4.num_poly4<6000 then
    begin
       poly4.num_poly4:=poly4.num_poly4+1;

       poly4.poly4[poly4.num_poly4].x1:=x1;
       poly4.poly4[poly4.num_poly4].y1:=y1;
       poly4.poly4[poly4.num_poly4].z1:=z1;


       poly4.poly4[poly4.num_poly4].x2:=x2;
       poly4.poly4[poly4.num_poly4].y2:=y2;
       poly4.poly4[poly4.num_poly4].z2:=z2;

       poly4.poly4[poly4.num_poly4].x3:=x3;
       poly4.poly4[poly4.num_poly4].y3:=y3;
       poly4.poly4[poly4.num_poly4].z3:=z3;

       poly4.poly4[poly4.num_poly4].x4:=x4;
       poly4.poly4[poly4.num_poly4].y4:=y4;
       poly4.poly4[poly4.num_poly4].z4:=z4;

       poly4.poly4[poly4.num_poly4].texture:=texture;
       poly4.poly4[poly4.num_poly4].light:=light;


    end;{endif}

end;
{*****************************************************}
procedure Poly4_2_Quad(var P:tpoly4_list; var Q:tquad_list; var V:tvertice_list);
var
x:word;
begin

   {Addicionar a la tabla de los vertices}
   for x:=1 to p.num_poly4 do
   begin
       add_vertex(v, p.poly4[x].x1, p.poly4[x].y1, p.poly4[x].z1, p.poly4[x].light);
       add_vertex(v, p.poly4[x].x2, p.poly4[x].y2, p.poly4[x].z2, p.poly4[x].light);
       add_vertex(v, p.poly4[x].x3, p.poly4[x].y3, p.poly4[x].z3, p.poly4[x].light);
       add_vertex(v, p.poly4[x].x4, p.poly4[x].y4, p.poly4[x].z4, p.poly4[x].light);
   end;{end for add vertex}

   {Crear los Quads}
   q.num_quads:=p.num_poly4;
   for x:=1 to p.num_poly4 do
   begin
        q.quad[x].p1:=seek_vertex(v,p.poly4[x].x1, p.poly4[x].y1, p.poly4[x].z1)-1;
        q.quad[x].p2:=seek_vertex(v,p.poly4[x].x2, p.poly4[x].y2, p.poly4[x].z2)-1;
        q.quad[x].p3:=seek_vertex(v,p.poly4[x].x3, p.poly4[x].y3, p.poly4[x].z3)-1;
        q.quad[x].p4:=seek_vertex(v,p.poly4[x].x4, p.poly4[x].y4, p.poly4[x].z4)-1;
        q.quad[x].texture:=p.poly4[x].texture;
   end;{end for crear quads}

end;

{*****************************************************}

procedure Build_room_mesh(var P:tpoly4_list; var Q:tquad_list; var T:ttriangle_list; var V:tvertice_list);
var
x:word;
nq,nt:word;
begin
   nq:=0;nt:=0;
   {sin soporte para luz}
   {Addicionar a la tabla de los vertices}
   for x:=1 to p.num_poly4 do
   begin
       add_vertex(v, p.poly4[x].x1, p.poly4[x].y1, p.poly4[x].z1, p.poly4[x].light);
       add_vertex(v, p.poly4[x].x2, p.poly4[x].y2, p.poly4[x].z2, p.poly4[x].light);
       add_vertex(v, p.poly4[x].x3, p.poly4[x].y3, p.poly4[x].z3, p.poly4[x].light);
       add_vertex(v, p.poly4[x].x4, p.poly4[x].y4, p.poly4[x].z4, p.poly4[x].light);
   end;{end for add vertex}

   {Crear los Quads y Trians}

   for x:=1 to p.num_poly4 do
   begin
        if ((p.poly4[x].x4=p.poly4[x].x1) and (p.poly4[x].y4=p.poly4[x].y1) and (p.poly4[x].z4=p.poly4[x].z1)) or
           ((p.poly4[x].x3=p.poly4[x].x2) and (p.poly4[x].y3=p.poly4[x].y2) and (p.poly4[x].z3=p.poly4[x].z2)) then
        begin
            nt:=nt+1;
            t.triangle[nt].p1:=seek_vertex(v,p.poly4[x].x1, p.poly4[x].y1, p.poly4[x].z1)-1;
            t.triangle[nt].p2:=seek_vertex(v,p.poly4[x].x2, p.poly4[x].y2, p.poly4[x].z2)-1;

            if ((p.poly4[x].x3=p.poly4[x].x2) and (p.poly4[x].y3=p.poly4[x].y2) and (p.poly4[x].z3=p.poly4[x].z2)) then
               t.triangle[nt].p3:=seek_vertex(v,p.poly4[x].x4, p.poly4[x].y4, p.poly4[x].z4)-1 else
               t.triangle[nt].p3:=seek_vertex(v,p.poly4[x].x3, p.poly4[x].y3, p.poly4[x].z3)-1;

            t.triangle[nt].texture:=p.poly4[x].texture;
            if t.triangle[nt].texture=$ffff then t.triangle[nt].texture:=0;
        end
        else
        begin
            nq:=nq+1;
            q.quad[nq].p1:=seek_vertex(v,p.poly4[x].x1, p.poly4[x].y1, p.poly4[x].z1)-1;
            q.quad[nq].p2:=seek_vertex(v,p.poly4[x].x2, p.poly4[x].y2, p.poly4[x].z2)-1;
            q.quad[nq].p3:=seek_vertex(v,p.poly4[x].x3, p.poly4[x].y3, p.poly4[x].z3)-1;
            q.quad[nq].p4:=seek_vertex(v,p.poly4[x].x4, p.poly4[x].y4, p.poly4[x].z4)-1;
            q.quad[nq].texture:=p.poly4[x].texture;
        if q.quad[nq].texture=$ffff then q.quad[nq].texture:=0;
        end;//endif

   end;{end for crear quads}
   q.num_quads:=nq;
   t.num_triangles:=nt;

end; {en procedure}


{******************************************************}
procedure add_poly3( var poly3:tpoly3_list; x1,y1,z1, x2,y2,z2, x3,y3,z3:smallint; texture:word; light:byte );
begin
    if poly3.num_poly3<6000 then
    begin
       poly3.num_poly3:=poly3.num_poly3+1;

       poly3.poly3[poly3.num_poly3].x1:=x1;
       poly3.poly3[poly3.num_poly3].y1:=y1;
       poly3.poly3[poly3.num_poly3].z1:=z1;

       poly3.poly3[poly3.num_poly3].x2:=x2;
       poly3.poly3[poly3.num_poly3].y2:=y2;
       poly3.poly3[poly3.num_poly3].z2:=z2;

       poly3.poly3[poly3.num_poly3].x3:=x3;
       poly3.poly3[poly3.num_poly3].y3:=y3;
       poly3.poly3[poly3.num_poly3].z3:=z3;

       poly3.poly3[poly3.num_poly3].texture:=texture;
       poly3.poly3[poly3.num_poly3].light:=light;


    end;{endif}

end;
{*****************************************************}
procedure Poly3_2_Trian(var P:tpoly3_list; var Q:ttriangle_list; var V:tvertice_list);
var
x:word;
begin

   {Addicionar a la tabla de los vertices}
   for x:=1 to p.num_poly3 do
   begin
       add_vertex(v, p.poly3[x].x1, p.poly3[x].y1, p.poly3[x].z1, p.poly3[x].light);
       add_vertex(v, p.poly3[x].x2, p.poly3[x].y2, p.poly3[x].z2, p.poly3[x].light);
       add_vertex(v, p.poly3[x].x3, p.poly3[x].y3, p.poly3[x].z3, p.poly3[x].light);
   end;{end for add vertex}

   {Crear los Triangles}
   q.num_triangles:=p.num_poly3;
   for x:=1 to p.num_poly3 do
   begin
        q.triangle[x].p1:=seek_vertex(v,p.poly3[x].x1, p.poly3[x].y1, p.poly3[x].z1)-1;
        q.triangle[x].p2:=seek_vertex(v,p.poly3[x].x2, p.poly3[x].y2, p.poly3[x].z2)-1;
        q.triangle[x].p3:=seek_vertex(v,p.poly3[x].x3, p.poly3[x].y3, p.poly3[x].z3)-1;
        q.triangle[x].texture:=p.poly3[x].texture;
   end;{end for crear quads}

end;
{*************************************}
//old verson rutine
procedure Generate_Mesh(var poly:tpoly4_list; var tile:tsector_list; texture:word);
var
x,y,z:smallint;
f,c:byte;
light:byte;
ancho,alto,profundo:smallint;
faces:byte;
floor,ceiling,aux:byte;
k,bloques:byte;

begin

//  texture:=170;
   light:=16;

   ancho:=xstep;alto:=ystep;profundo:=zstep; {Dimensiones de cada grid}
   x:=0;
   for c:=1 to tile.ancho do

   begin
       z:=0;
       for f:=1 to tile.largo do

       begin

        floor:=short2byte(get_floor(tile,c,f))+1; if floor<4 then floor:=4;
        ceiling:=short2byte(get_ceiling(tile,c,f))+1;

        bloques:=trunc(int(floor/4));
        if (floor mod 4)<>0 then bloques:=bloques+1;

        y:=32767; {fex}
        for k:=1 to bloques do
        begin
            faces:=0;
            if k<bloques then alto:=ystep else alto:=(floor-((k-1)*4))*(ystep div 4);

            {averiguar si es necesario dibujar todas las caras}

            {front?}
            if f>1 then
            begin
               aux:=short2byte(get_floor(tile,c,f-1))+1;
               if (k*4)>aux then faces:=faces or f_front;
               {pendiente arreglar si solo se ve en parte}
            end;

            {back?}
            if f<tile.largo then
            begin
               aux:=short2byte(get_floor(tile,c,f+1))+1;
               if (k*4)>aux then faces:=faces or f_back;
               {pendiente arreglar si solo se ve en parte}
            end;

            {left?}
            if c>1 then
            begin
               aux:=short2byte(get_floor(tile,c-1,f))+1;
               if (k*4)>aux then faces:=faces or f_left;
               {pendiente arreglar si solo se ve en parte}
            end;

            {right?}
            if c<tile.ancho then
            begin
               aux:=short2byte(get_floor(tile,c+1,f))+1;
               if (k*4)>aux then faces:=faces or f_right;
               {pendiente arreglar si solo se ve en parte}
            end;

            {top?}
            if k=bloques then faces:=faces or f_top;

            {bootom}
            {en floor no es necesario generar el bottom}



                  {************DRAW THE FACES*************}
                  {---Front face-----}
                  if (faces and f_front)=f_front then add_poly4( poly,  x,y-alto,z,    x+ancho,y-alto,z,
                     x+ancho,y,z,     x,y,z,
                        texture,light);

                    {---Back face-----}
                     if (faces and f_back)=f_back then add_poly4( poly,  x+ancho,y-alto,z+profundo,    x,y-alto,z+profundo,
                     x,y,z+profundo,               x+ancho,y,z+profundo,
                                 texture,light);

                    {---izq face-----}
                     if (faces and f_left)=f_left then add_poly4( poly,  x,y-alto,z+profundo,    x,y-alto,z,
                          x,y,z,               x,y,z+profundo,
                               texture,light);

                     {---der face-----}
                     if (faces and f_right)=f_right then add_poly4( poly,  x+ancho,y-alto,z,      x+ancho,y-alto,z+profundo,
                     x+ancho,y,z+profundo,     x+ancho,y,z,
                              texture,light);

                     {---Top face-----}
                      if (faces and f_top)=f_top then add_poly4( poly,  x,y-alto,z+profundo,    x+ancho,y-alto,z+profundo,
                           x+ancho,y-alto,z,     x,y-alto,z,
                              texture,light);

                     {---bottom face-----}
                     if (faces and f_bottom)=f_bottom then add_poly4( poly,  x+ancho,y,z+profundo,    x,y,z+profundo,
                       x,y,z,                   x+ancho,y,z,
                          texture,light);

                    {******END DRAW FACES*********}
               y:=y-ystep;

            end;{end floor bloques}
            z:=z+zstep;
       end;{end filas}
            x:=x+xstep;
   end;{end columnas}
end;
//*********************************
//new rutine
Procedure Generate_Mesh(var poly:tpoly4_list; var tile:tsector_list; var tile_info:ttile_info; var shapes:tshape_list; flags:byte=0; light:integer=16);overload; //new rutine.
var
x,y,z:smallint;
f,c:byte;
ancho,alto,profundo:smallint;
faces:byte;
floor,ceiling,aux:integer;

k,bloques:byte;
cur_altura:integer;
front_t, back_t, left_t, right_t, top_t:integer; //textures en las 5 faces
tindex,tindex2:word;
front1,front2,back1,back2,left1,left2,right1,right2:integer;
aux1,aux2:integer;
floor_tipo,fltipo:byte;
ceiling_tipo,cetipo:byte;
x1,y1,x2,y2,x3,y3,x4,y4:integer;
vx1,vy1,vx2,vy2,vx3,vy3,vx4,vy4:integer;
//fdebug:textfile;
grid1,grid2:integer;
light1,light2,light3,light4,light5:byte;
fidx1,fidx2:word;



begin
//   assignfile(fdebug,'debug.txt');
//   rewrite(fdebug);

   x:=0;
   ancho:=1024;alto:=1024;profundo:=1024; {Dimensiones de cada grid}

//dibujar el floor
   for c:=1 to tile.ancho do

   begin
       z:=0;
       for f:=1 to tile.largo do

       begin

        floor:=short2byte(get_floor(tile,c,f)); //altura del floor

        bloques:=trunc(int(floor/4)); //cuantos bloques completos hay antes del ultimo bloque.

        y:=32767; //se supone que este el lo mas bajo.
        cur_altura:=3; //el bloque mas peque¤o tiene 3 de altura

            tindex:=get_tile_index(tile,c,f);
            front_t:=tile_info[tindex].ffront_texture;
            back_t:=tile_info[tindex].fback_texture;
            left_t:=tile_info[tindex].fleft_texture;
            right_t:=tile_info[tindex].fright_texture;
            top_t:=tile_info[tindex].ftop_texture;
            //lights
            light1:=tile_info[tindex].flight_front;
            light2:=tile_info[tindex].flight_back;
            light3:=tile_info[tindex].flight_left;
            light4:=tile_info[tindex].flight_right;
            light5:=tile_info[tindex].flight_top;


        for k:=1 to bloques do // generar primero los bloques completos antes del bloque final.
        begin
            faces:=0;
            {averiguar si es necesario dibujar todas las caras}
             {front?}
            if f>1 then //si f=1 no generar front.
            begin
             aux:=short2byte(get_floor(tile,c,f-1));

               tindex2:=get_tile_index(tile,c,f-1);
               fltipo:=tile_info[tindex2].ftipo;
               aux1:=shapes.shape[fltipo].back1; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].back2; //segundo punto de la cara vecina


             if ((cur_altura-aux)>=1) then faces:=faces or f_front; //si mayor que 4 entoces se ve toda la cara.
             if (cur_altura=aux) and (aux1<>aux2) then faces:=faces or f_front; //si mayor que 4 entoces se ve toda la cara.

               //si diferencia esta entre 1-3 entonces la cara se ve parcial, no dibujarla aqui.
            end;

            {back?}
            if f<tile.largo then
            begin
               aux:=short2byte(get_floor(tile,c,f+1));

               tindex2:=get_tile_index(tile,c,f+1);
               fltipo:=tile_info[tindex2].ftipo;
               aux1:=shapes.shape[fltipo].front1; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].front2; //segundo punto de la cara vecina
               if ((cur_altura-aux)>=1) then faces:=faces or f_back;
               if (cur_altura=aux) and (aux1<>aux2) then faces:=faces or f_back;
            end;

            {left?}
            if c>1 then
            begin
               aux:=short2byte(get_floor(tile,c-1,f));

               tindex2:=get_tile_index(tile,c-1,f);
               fltipo:=tile_info[tindex2].ftipo;
               aux1:=shapes.shape[fltipo].right1; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].right2; //segundo punto de la cara vecina
               if ((cur_altura-aux)>=1) then faces:=faces or f_left;
               if (cur_altura=aux) and (aux1<>aux2) then faces:=faces or f_left;
            end;

            {right?}
            if c<tile.ancho then
            begin
               aux:=short2byte(get_floor(tile,c+1,f));

               tindex2:=get_tile_index(tile,c+1,f);
               fltipo:=tile_info[tindex2].ftipo;
               aux1:=shapes.shape[fltipo].left1; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].left2; //segundo punto de la cara vecina
               if ((cur_altura-aux)>=1) then faces:=faces or f_right;
               if (cur_altura=aux) and (aux1<>aux2) then faces:=faces or f_right;
            end;

            {top? nunca top en este bucle}
            {bootom}
            {en floor no es necesario generar el bottom}


                  {DRAW THE FACES debajo del floor}
                  {---Front face-----}
     if front_t>=0 then  if (faces and f_front)=f_front then add_poly4( poly,  x,y-alto,z,    x+ancho,y-alto,z,
                     x+ancho,y,z,     x,y,z,
                        front_t,light1);

                    {---Back face-----}
   if back_t>=0 then   if (faces and f_back)=f_back then add_poly4( poly,  x+ancho,y-alto,z+profundo,    x,y-alto,z+profundo,
                   x,y,z+profundo,               x+ancho,y,z+profundo,
                                 back_t,light2);

                    {---izq face-----}
   if left_t>=0 then  if (faces and f_left)=f_left then add_poly4( poly,  x,y-alto,z+profundo,    x,y-alto,z,
                                             x,y,z,               x,y,z+profundo,
                               left_t,light3);

                     {---der face-----}
   if right_t>=0 then     if (faces and f_right)=f_right then add_poly4( poly,  x+ancho,y-alto,z,      x+ancho,y-alto,z+profundo,
                     x+ancho,y,z+profundo,     x+ancho,y,z,
                              right_t,light4);

                    {END DRAW FACES para la current altura en este tile}
                cur_altura:=cur_altura+4;
                y:=y-1024;
             end;{end for bloques}




            {*********************************************}
             {----DIBUJAR EL ULTIMO BLOQUE---- alpha}
             {dibujar tambien las caras parciales}

            floor_tipo:=tile_info[tindex].ftipo;

            front1:=shapes.shape[floor_tipo].front1;
            front2:=shapes.shape[floor_tipo].front2;

            back1:=shapes.shape[floor_tipo].back1;
            back2:=shapes.shape[floor_tipo].back2;

            left1:=shapes.shape[floor_tipo].left1;
            left2:=shapes.shape[floor_tipo].left2;

            right1:=shapes.shape[floor_tipo].right1;
            right2:=shapes.shape[floor_tipo].right2;

            //esto es para saber si el floor y el ceiling son slant.
            fidx1:=shapes.shape[floor_tipo].floor_index;
            floor_tipo:=tile_info[tindex].ctipo;
            fidx2:=shapes.shape[floor_tipo].floor_index;
            //------------------
            floor_tipo:=tile_info[tindex].ftipo;



           //poner la altura del tile actual.
           cur_altura:=short2byte(get_floor(tile,c,f));
           grid1:=trunc((int(cur_altura/4))+1);


            {dibujar cada cara}

             {front?}
            if f>1 then //si f=1 no generar front.
            begin
               //front1 y front2 son la altura de la current face.
               //aux1 y aux2 deven tener la altura de la cara vecina
               //comparar estos 4 valores y dibujar solo las partes visibles.
               aux:=short2byte(get_floor(tile,c,f-1)); //la altura del tile vecino
               tindex:=get_tile_index(tile,c,f-1);
               fltipo:=tile_info[tindex].ftipo;
               aux1:=shapes.shape[fltipo].back1; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].back2; //segundo punto de la cara vecina

               grid2:=trunc((int(aux/4))+1);

               //si la cara vecina esta en tile mayor que este
               if grid2>grid1 then
               begin
                 aux1:=1024;
                 aux2:=1024;
               end; //end

               //si la cara vecina esta en tile menor a este
               if grid1>grid2 then
               begin
                 aux1:=0;
                 aux2:=0;
               end; //end

               //calcular las cordenas de este face. (front)
               x1:=x;
               y1:=y-front1;
               x2:=x+ancho;
               y2:=y-front2;
               x3:=x+ancho;
               y3:=y;
               x4:=x;
               y4:=y;
               //calcular las cordenas del face vecino. (back)
               vx1:=0;
               vy1:=0;
               vx2:=0;
               vy2:=0;
               vx3:=0;
               vy3:=y;
               vx4:=x;
               vy4:=y;
               //--------------------
               // las cordenadas del current face de ve comparase a las del vecino y recrearse de tal manera que solo muestren la parte visible
               //compararlas mediante una funcion, al regresar de la funcion se necesita saber si
               //se necesita generar el face.
               //--------------------

               //si esta cara se ve toda o parcial

              if (front1>aux2) or (front2>aux1) then
              begin
               if front_t>=0 then add_poly4( poly,  x1,y1,z, x2,y2,z,
                                                                x3,y3,z, x4,y4,z,
                                                                         front_t,light1);
//             writeln(fdebug,'Fila:',f:4,' Columna:',c:4,' Front1->',front1,' aux1->',aux1,' Front2->',front2,' aux2->',aux2,' AUX:',AUX,' CUR_ALT:',CUR_ALTURA);
              end;
               //si el face vecino no es el ultimo tile y la altura del current face
               //es menor de 1024 entonces mostrar parcial el face vecino
{             if ((aux-cur_altura)>4) and ((front1<1024) or (front2<1024)) then add_poly4( poly,  vx1,vy1,z, vx2,vy2,z,
                                                                                            vx3,vy3,z, vx4,vy4,z,      }

            end;//end this face.

            {back?}
            if f<tile.largo then
            begin
               aux:=short2byte(get_floor(tile,c,f+1));
               tindex:=get_tile_index(tile,c,f+1);
               fltipo:=tile_info[tindex].ftipo;
               aux1:=shapes.shape[fltipo].front1; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].front2; //segundo punto de la cara vecina

               grid2:=trunc((int(aux/4))+1);

               //si la cara vecina esta en tile mayor que este
               if grid2>grid1 then
               begin
                 aux1:=1024;
                 aux2:=1024;
               end; //end

               //si la cara vecina esta en tile menor a este
               if grid1>grid2 then
               begin
                 aux1:=0;
                 aux2:=0;
               end; //end

               //calcular las cordenas de este face. (back)
               x1:=x+ancho;
               y1:=y-back1;
               x2:=x;
               y2:=y-back2;
               x3:=x;
               y3:=y;
               x4:=x+ancho;
               y4:=y;
               //calcular las cordenas del face vecino. (back)
               vx1:=0;
               vy1:=0;
               vx2:=0;
               vy2:=0;
               vx3:=0;
               vy3:=y;
               vx4:=x;
               vy4:=y;
               //--------------------
               // las cordenadas del current face de ve comparase a las del vecino y recrearse de tal manera que solo muestren la parte visible
               //compararlas mediante una funcion, al regresar de la funcion se necesita saber si
               //se necesita generar el face.
               //--------------------

               //si esta cara se ve toda o parcial
              if (back1>aux2) or (back2>aux1) then
              begin
                 if back_t>=0 then add_poly4( poly,  x1,y1,z+profundo, x2,y2,z+profundo,
                                                                        x3,y3,z+profundo, x4,y4,z+profundo,
                                                                          back_t,light2);
//                          writeln(fdebug,'Fila:',f:4,' Columna:',c:4,' Front1->',back1,' aux1->',aux1,' Front2->',back2,' aux2->',aux2,' AUX:',AUX,' CUR_ALT:',CUR_ALTURA);
              end;
               //si el face vecino no es el ultimo tile y la altura del current face
               //es menor de 1024 entonces mostrar parcial el face vecino
{             if ((aux-cur_altura)>4) and ((front1<1024) or (front2<1024)) then add_poly4( poly,  vx1,vy1,z, vx2,vy2,z,
                                                                                            vx3,vy3,z, vx4,vy4,z,}

            end;//back

            {left}
            if c>1 then
            begin
               aux:=short2byte(get_floor(tile,c-1,f));
               tindex:=get_tile_index(tile,c-1,f);
               fltipo:=tile_info[tindex].ftipo;
               aux1:=shapes.shape[fltipo].right1; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].right2; //segundo punto de la cara vecina

               grid2:=trunc((int(aux/4))+1);

               //si la cara vecina esta en tile mayor que este
               if grid2>grid1 then
               begin
                 aux1:=1024;
                 aux2:=1024;
               end; //end

               //si la cara vecina esta en tile menor a este
               if grid1>grid2 then
               begin
                 aux1:=0;
                 aux2:=0;
               end; //end


               //calcular las cordenas de este face. (left)

               x1:=x;
               y1:=y-left1;
               x2:=x;
               y2:=y-left2;
               x3:=x;
               y3:=y;
               x4:=x;
               y4:=y;



               //calcular las cordenas del face vecino. (back)
               vx1:=0;
               vy1:=0;
               vx2:=0;
               vy2:=0;
               vx3:=0;
               vy3:=y;
               vx4:=x;
               vy4:=y;
               //--------------------
               // las cordenadas del current face de ve comparase a las del vecino y recrearse de tal manera que solo muestren la parte visible
               //compararlas mediante una funcion, al regresar de la funcion se necesita saber si
               //se necesita generar el face.
               //--------------------

               //si esta cara se ve toda o parcial
            if (left1>aux2) or (left2>aux1) then if left_t>=0 then add_poly4( poly,  x1,y1,z+profundo, x2,y2,z,
                                                                        x3,y3,z, x4,y4,z+profundo,
                                                                          left_t,light3);
               //si el face vecino no es el ultimo tile y la altura del current face
               //es menor de 1024 entonces mostrar parcial el face vecino
{            if ((aux-cur_altura)>4) and ((front1<1024) or (front2<1024)) then add_poly4( poly,  vx1,vy1,z, vx2,vy2,z,
                                                                                            vx3,vy3,z, vx4,vy4,z,}
             end;//end this face

            {right}
            if c<tile.ancho then
            begin
               aux:=short2byte(get_floor(tile,c+1,f));
               tindex:=get_tile_index(tile,c+1,f);
               fltipo:=tile_info[tindex].ftipo;
               aux1:=shapes.shape[fltipo].left1; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].left2; //segundo punto de la cara vecina

               grid2:=trunc((int(aux/4))+1);

               //si la cara vecina esta en tile mayor que este
               if grid2>grid1 then
               begin
                 aux1:=1024;
                 aux2:=1024;
               end; //end

               //si la cara vecina esta en tile menor a este
               if grid1>grid2 then
               begin
                 aux1:=0;
                 aux2:=0;
               end; //end


               //calcular las cordenas de este face. (right)

               x1:=x+ancho;
               y1:=y-right1;
               x2:=x+ancho;
               y2:=y-right2;
               x3:=x+ancho;
               y3:=y;
               x4:=x+ancho;
               y4:=y;

               //calcular las cordenas del face vecino. (left)
               vx1:=0;
               vy1:=0;
               vx2:=0;
               vy2:=0;
               vx3:=0;
               vy3:=y;
               vx4:=x;
               vy4:=y;
               //--------------------
               // las cordenadas del current face de ve comparase a las del vecino y recrearse de tal manera que solo muestren la parte visible
               //compararlas mediante una funcion, al regresar de la funcion se necesita saber si
               //se necesita generar el face.
               //--------------------

               //si esta cara se ve toda o parcial
              if (right1>aux2) or (right2>aux1) then if right_t>=0 then add_poly4( poly,  x1,y1,z, x2,y2,z+profundo,
                                                                        x3,y3,z+profundo, x4,y4,z,
                                                                          right_t,light4);
               //si el face vecino no es el ultimo tile y la altura del current face
               //es menor de 1024 entonces mostrar parcial el face vecino
{             if ((aux-cur_altura)>4) and ((front1<1024) or (front2<1024)) then add_poly4( poly,  vx1,vy1,z, vx2,vy2,z,
                                                                                            vx3,vy3,z, vx4,vy4,z,}

            end;//end this face

            {top? si el floor menor que el ceiling entonces generar el top}
            //agregar la pregunta del ceiling cuando se implemente el ceiling

             if (short2byte(get_floor(tile,c,f)) <> short2byte(get_ceiling(tile,c,f))) or (fidx1<>0) or (fidx2<>0) then
             if top_t>=0 then add_poly4( poly,  x,y-back2,z+profundo,   x+ancho,y-back1,z+profundo,
                               x+ancho,y-front2,z,     x,y-front1,z,
                                 top_t,light4);

             {--------------------------------}
             {*********************************************}

            z:=z+1024;
       end;{end filas}
            x:=x+1024;
   end;{end columnas}
//----------------------------------

x:=0;
//dibujar el Ceiling
   for c:=1 to tile.ancho do

   begin
       z:=0;
       for f:=1 to tile.largo do

       begin

        floor:=short2byte(get_ceiling(tile,c,f))+1;//+1 //altura del ceiling
        bloques:=64-trunc(int(floor/4)); //-1;

        y:=-32768; //se supone que este el lo mas alto.
        cur_altura:=255; //el bloque mas peque¤o tiene 3 de altura

            tindex:=get_tile_index(tile,c,f);
            front_t:=tile_info[tindex].cfront_texture;
            back_t:=tile_info[tindex].cback_texture;
            left_t:=tile_info[tindex].cleft_texture;
            right_t:=tile_info[tindex].cright_texture;
            top_t:=tile_info[tindex].ctop_texture;
            //lights
            light1:=tile_info[tindex].clight_front;
            light2:=tile_info[tindex].clight_back;
            light3:=tile_info[tindex].clight_left;
            light4:=tile_info[tindex].clight_right;
            light5:=tile_info[tindex].clight_top;



        for k:=1 to bloques do // generar primero los bloques completos antes del bloque final.
        begin
            faces:=0;
            {averiguar si es necesario dibujar todas las caras}
             {front?}
            if f>1 then //si f=1 no generar front.
            begin
               aux:=short2byte(get_ceiling(tile,c,f-1));
               tindex2:=get_tile_index(tile,c,f-1);
               fltipo:=tile_info[tindex2].ctipo;
               aux1:=shapes.shape[fltipo].back2; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].back1; //segundo punto de la cara vecina

               if (cur_altura-aux)<0 then faces:=faces or f_front; //si mayor que 4 entoces se ve toda la cara.
               if (cur_altura=aux) and (aux1<>aux2) then faces:=faces or f_front; //si mayor que 4 entoces se ve toda la cara.
               //si diferencia esta entre 1-3 entonces la cara se ve parcial, no dibujarla aqui.
            end;

            {back?}
            if f<tile.largo then
            begin
               aux:=short2byte(get_ceiling(tile,c,f+1));
               tindex2:=get_tile_index(tile,c,f+1);
               fltipo:=tile_info[tindex2].ctipo;
               aux1:=shapes.shape[fltipo].front2; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].front1; //segundo punto de la cara vecina
               if (cur_altura-aux)<0 then faces:=faces or f_back;
               if (cur_altura=aux) and (aux1<>aux2) then faces:=faces or f_back;
            end;

            {left?}
            if c>1 then
            begin
               aux:=short2byte(get_ceiling(tile,c-1,f));
               tindex2:=get_tile_index(tile,c-1,f);
               fltipo:=tile_info[tindex2].ctipo;
               aux1:=shapes.shape[fltipo].right2; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].right1; //segundo punto de la cara vecina
               if (cur_altura-aux)<0 then faces:=faces or f_left;
               if (cur_altura=aux) and (aux1<>aux2) then faces:=faces or f_left;
            end;

            {right?}
            if c<tile.ancho then
            begin
               aux:=short2byte(get_ceiling(tile,c+1,f));
               tindex2:=get_tile_index(tile,c+1,f);
               fltipo:=tile_info[tindex2].ctipo;
               aux1:=shapes.shape[fltipo].left2; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].left1; //segundo punto de la cara vecina
               if (cur_altura-aux)<0 then faces:=faces or f_right;
               if (cur_altura=aux) and (aux1<>aux2) then faces:=faces or f_right;
            end;

            {top? nunca top en este bucle}
            {bootom}
            {en floor no es necesario generar el bottom}


                  {DRAW THE FACES debajo del floor}
                  {---Front face-----}
   if front_t>=0 then      if (faces and f_front)=f_front then add_poly4( poly,  x,y-alto,z,    x+ancho,y-alto,z,
                     x+ancho,y,z,     x,y,z,
                        front_t,light1);

                    {---Back face-----}
    if back_t>=0 then                if (faces and f_back)=f_back then add_poly4( poly,  x+ancho,y-alto,z+profundo,    x,y-alto,z+profundo,
                     x,y,z+profundo,               x+ancho,y,z+profundo,
                                 back_t,light2);

                    {---izq face-----}
    if left_t>=0 then                 if (faces and f_left)=f_left then add_poly4( poly,  x,y-alto,z+profundo,    x,y-alto,z,
                                             x,y,z,               x,y,z+profundo,
                               left_t,light3);

                     {---der face-----}
    if right_t>=0 then                 if (faces and f_right)=f_right then add_poly4( poly,  x+ancho,y-alto,z,      x+ancho,y-alto,z+profundo,
                     x+ancho,y,z+profundo,     x+ancho,y,z,
                              right_t,light4);

                    {END DRAW FACES para la current altura en este tile}
                cur_altura:=cur_altura-4;
                y:=y+1024;
             end;{end for bloques}

             y:=y-1024;


            {*********************************************}
             {----DIBUJAR EL ULTIMO BLOQUE---- alpha}
             {dibujar tambien las caras parciales}
//           faces:=0;

            floor_tipo:=tile_info[tindex].ctipo;

            front1:=shapes.shape[floor_tipo].front2;
            front2:=shapes.shape[floor_tipo].front1;
            back1:=shapes.shape[floor_tipo].back2;
            back2:=shapes.shape[floor_tipo].back1;

            left1:=shapes.shape[floor_tipo].left2;
            left2:=shapes.shape[floor_tipo].left1;
            right1:=shapes.shape[floor_tipo].right2;
            right2:=shapes.shape[floor_tipo].right1;

            //esto es para saber si el floor y el ceiling son slant.
            fidx2:=shapes.shape[floor_tipo].floor_index;
            floor_tipo:=tile_info[tindex].ftipo;
            fidx1:=shapes.shape[floor_tipo].floor_index;
            //------------------
            floor_tipo:=tile_info[tindex].ctipo;


           //poner la altura del tile actual.
           cur_altura:=short2byte(get_ceiling(tile,c,f));

           grid1:=trunc((int((cur_altura+1)/4))+1);


            {dibujar cada cara}

             {front?}
            if f>1 then //si f=1 no generar front.
            begin
               //front1 y front2 son la altura de la current face.
               //aux1 y aux2 deven tener la altura de la cara vecina
               //comparar estos 4 valores y dibujar solo las partes visibles.
               aux:=short2byte(get_ceiling(tile,c,f-1)); //la altura del tile vecino
               tindex:=get_tile_index(tile,c,f-1);
               fltipo:=tile_info[tindex].ctipo;
               aux1:=shapes.shape[fltipo].back2; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].back1; //segundo punto de la cara vecina
               grid2:=trunc((int((aux+1)/4))+1);

               //si la cara vecina esta en tile mayor que este
               if grid2<grid1 then
               begin
                 aux1:=1024;
                 aux2:=1024;
               end; //end

               //si la cara vecina esta en tile menor a este
               if grid1<grid2 then
               begin
                 aux1:=0;
                 aux2:=0;
               end; //end

               //calcular las cordenas de este face. (front)
               x1:=x;
               y1:=y;
               x2:=x+ancho;
               y2:=y;
               x3:=x+ancho;
               y3:=y+front1;
               x4:=x;
               y4:=y+front2;
               //calcular las cordenas del face vecino. (back)
               vx1:=0;
               vy1:=0;
               vx2:=0;
               vy2:=0;
               vx3:=0;
               vy3:=y;
               vx4:=x;
               vy4:=y;
               //--------------------
               // las cordenadas del current face de ve comparase a las del vecino y recrearse de tal manera que solo muestren la parte visible
               //compararlas mediante una funcion, al regresar de la funcion se necesita saber si
               //se necesita generar el face.
               //--------------------

               //si esta cara se ve toda o parcial

              if (front1>aux2) or (front2>aux1) then
              begin
                 if front_t>=0 then add_poly4( poly,  x1,y1,z, x2,y2,z,
                                                          x3,y3,z, x4,y4,z,
                                                                   front_t,light1);
//             writeln(fdebug,'Fila:',f:4,' Columna:',c:4,' Front1->',front1,' aux1->',aux1,' Front2->',front2,' aux2->',aux2,' AUX:',AUX,' CUR_ALT:',CUR_ALTURA);
              end;
               //si el face vecino no es el ultimo tile y la altura del current face
               //es menor de 1024 entonces mostrar parcial el face vecino
{             if ((aux-cur_altura)>4) and ((front1<1024) or (front2<1024)) then add_poly4( poly,  vx1,vy1,z, vx2,vy2,z,
                                                                                            vx3,vy3,z, vx4,vy4,z,      }

            end;//end this face.

            {back?}
            if f<tile.largo then
            begin
               aux:=short2byte(get_ceiling(tile,c,f+1));
               tindex:=get_tile_index(tile,c,f+1);
               fltipo:=tile_info[tindex].ctipo;
               aux1:=shapes.shape[fltipo].front2; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].front1; //segundo punto de la cara vecina
               grid2:=trunc((int((aux+1)/4))+1);

               //si la cara vecina esta en tile mayor que este
               if grid2<grid1 then
               begin
                 aux1:=1024;
                 aux2:=1024;
               end; //end

               //si la cara vecina esta en tile menor a este
               if grid1<grid2 then
               begin
                 aux1:=0;
                 aux2:=0;
               end; //end

               //calcular las cordenas de este face. (back)
               x1:=x+ancho;
               y1:=y;
               x2:=x;
               y2:=y;
               x3:=x;
               y3:=y+back1;
               x4:=x+ancho;
               y4:=y+back2;
               //calcular las cordenas del face vecino. (back)
               vx1:=0;
               vy1:=0;
               vx2:=0;
               vy2:=0;
               vx3:=0;
               vy3:=y;
               vx4:=x;
               vy4:=y;
               //--------------------
               // las cordenadas del current face de ve comparase a las del vecino y recrearse de tal manera que solo muestren la parte visible
               //compararlas mediante una funcion, al regresar de la funcion se necesita saber si
               //se necesita generar el face.
               //--------------------

               //si esta cara se ve toda o parcial
              if (back1>aux2) or (back2>aux1) then
              begin
              if back_t>=0 then add_poly4( poly,  x1,y1,z+profundo, x2,y2,z+profundo,
                                                                     x3,y3,z+profundo, x4,y4,z+profundo,
                                                                    back_t,light2);
//                       writeln(fdebug,'Fila:',f:4,' Columna:',c:4,' Front1->',back1,' aux1->',aux1,' Front2->',back2,' aux2->',aux2,' AUX:',AUX,' CUR_ALT:',CUR_ALTURA,' grid1:',grid1,'  Grid2:',grid2);
              end;
               //si el face vecino no es el ultimo tile y la altura del current face
               //es menor de 1024 entonces mostrar parcial el face vecino
{             if ((aux-cur_altura)>4) and ((front1<1024) or (front2<1024)) then add_poly4( poly,  vx1,vy1,z, vx2,vy2,z,
                                                                                            vx3,vy3,z, vx4,vy4,z,}

            end;//back

            {left}
            if c>1 then
            begin
               aux:=short2byte(get_ceiling(tile,c-1,f));
               tindex:=get_tile_index(tile,c-1,f);
               fltipo:=tile_info[tindex].ctipo;
               aux1:=shapes.shape[fltipo].right2; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].right1; //segundo punto de la cara vecina

               grid2:=trunc((int((aux+1)/4))+1);

               //si la cara vecina esta en tile mayor que este
               if grid2<grid1 then
               begin
                 aux1:=1024;
                 aux2:=1024;
               end; //end

               //si la cara vecina esta en tile menor a este
               if grid1<grid2 then
               begin
                 aux1:=0;
                 aux2:=0;
               end; //end


               //calcular las cordenas de este face. (left)

               x1:=x;
               y1:=y;
               x2:=x;
               y2:=y;
               x3:=x;
               y3:=y+left1;
               x4:=x;
               y4:=y+left2;



               //calcular las cordenas del face vecino. (back)
               vx1:=0;
               vy1:=0;
               vx2:=0;
               vy2:=0;
               vx3:=0;
               vy3:=y;
               vx4:=x;
               vy4:=y;
               //--------------------
               // las cordenadas del current face de ve comparase a las del vecino y recrearse de tal manera que solo muestren la parte visible
               //compararlas mediante una funcion, al regresar de la funcion se necesita saber si
               //se necesita generar el face.
               //--------------------

               //si esta cara se ve toda o parcial
            if (left1>aux2) or (left2>aux1) then if left_t>=0 then add_poly4( poly,  x1,y1,z+profundo, x2,y2,z,
                                                                        x3,y3,z, x4,y4,z+profundo,
                                                                          left_t,light3);
               //si el face vecino no es el ultimo tile y la altura del current face
               //es menor de 1024 entonces mostrar parcial el face vecino
{            if ((aux-cur_altura)>4) and ((front1<1024) or (front2<1024)) then add_poly4( poly,  vx1,vy1,z, vx2,vy2,z,
                                                                                            vx3,vy3,z, vx4,vy4,z,}
             end;//end this face

            {right}
            if c<tile.ancho then
            begin
               aux:=short2byte(get_ceiling(tile,c+1,f));
               tindex:=get_tile_index(tile,c+1,f);
               fltipo:=tile_info[tindex].ctipo;
               aux1:=shapes.shape[fltipo].left2; //primer punto de la cara vecina
               aux2:=shapes.shape[fltipo].left1; //segundo punto de la cara vecina

               grid2:=trunc((int((aux+1)/4))+1);

               //si la cara vecina esta en tile mayor que este
               if grid2<grid1 then
               begin
                 aux1:=1024;
                 aux2:=1024;
               end; //end

               //si la cara vecina esta en tile menor a este
               if grid1<grid2 then
               begin
                 aux1:=0;
                 aux2:=0;
               end; //end


               //calcular las cordenas de este face. (right)

               x1:=x+ancho;
               y1:=y;
               x2:=x+ancho;
               y2:=y;
               x3:=x+ancho;
               y3:=y+right1;
               x4:=x+ancho;
               y4:=y+right2;

               //calcular las cordenas del face vecino. (left)
               vx1:=0;
               vy1:=0;
               vx2:=0;
               vy2:=0;
               vx3:=0;
               vy3:=y;
               vx4:=x;
               vy4:=y;
               //--------------------
               // las cordenadas del current face de ve comparase a las del vecino y recrearse de tal manera que solo muestren la parte visible
               //compararlas mediante una funcion, al regresar de la funcion se necesita saber si
               //se necesita generar el face.
               //--------------------

               //si esta cara se ve toda o parcial
             if (right1>aux2) or (right2>aux1) then if right_t>=0 then add_poly4( poly,  x1,y1,z, x2,y2,z+profundo,
                                                                        x3,y3,z+profundo, x4,y4,z,
                                                                          right_t,light4);
               //si el face vecino no es el ultimo tile y la altura del current face
               //es menor de 1024 entonces mostrar parcial el face vecino
{             if ((aux-cur_altura)>4) and ((front1<1024) or (front2<1024)) then add_poly4( poly,  vx1,vy1,z, vx2,vy2,z,
                                                                                            vx3,vy3,z, vx4,vy4,z,}

            end;//end this face

            {top? si el floor menor que el ceiling entonces generar el top}
            //agregar la pregunta del ceiling cuando se implemente el ceiling
       if (short2byte(get_floor(tile,c,f)) <> short2byte(get_ceiling(tile,c,f))) or (fidx1<>0) or (fidx2<>0) then
       if floor_tipo<11 then
                         begin
                         if (flags and 1)=1 then  //si 1 este cuarto es quicksand
                         begin
                           if top_t>=0 then add_poly4( poly,     x,y+back2,z+profundo,   x+ancho,y+back1,z+profundo,
                                                                 x+ancho,y+front2,z,    x,y+front1,z,
                                 top_t,light5);
                           if top_t>=0 then add_poly4( poly,    x,y+front1,z,   x+ancho,y+front2,z,
                                 x+ancho,y+back1,z+profundo,  x,y+back2,z+profundo,
                                 top_t,light5);

                         end// fin si flag=1
                       else
                           if top_t>=0 then add_poly4( poly,    x,y+front1,z,   x+ancho,y+front2,z,
                                 x+ancho,y+back1,z+profundo,  x,y+back2,z+profundo,
                                 top_t,light5);
                       end


       else
            if (flags and 1)=1 then  //si 1 este cuarto es quicksand
                      begin
                           if top_t>=0 then add_poly4( poly,     x,y+front2,z+profundo,    x+ancho,y+front1,z+profundo,
                                                  x+ancho,y+back2,z,    x,y+back1,z,
                                                   top_t,light5);
                           if top_t>=0 then add_poly4( poly,    x,y+back1,z,   x+ancho,y+back2,z,
                                x+ancho,y+front1,z+profundo,  x,y+front2,z+profundo,
                                top_t,light5);

                      end

                    else
                                if top_t>=0 then add_poly4( poly,    x,y+back1,z,   x+ancho,y+back2,z,
                                 x+ancho,y+front1,z+profundo,  x,y+front2,z+profundo,
                                 top_t,light5);



             {--------------------------------}
             {*********************************************}
             //esto es por el room above and below
             //esto solo debe ser si el door es side.
//           tindex:=get_tile_index(tile,c,f);

//           if tile_info[tindex].tipo_portal=2 then
//           if tile.sector[tindex].room_above<>-1 then tile.sector[tindex].ceiling_height:=tile.sector[tindex].floor_height;
// desactivado el truco de usar el room above envez del commando de cambio de cuarto.

            z:=z+1024;
       end;{end filas}
            x:=x+1024;
   end;{end columnas}


//  close(fdebug);
end;



//-------------------------------------------
function val2str(v:real; ancho,decimals:byte):string;
var
resultado:string;
begin
   str(v:ancho:decimals,resultado);
   val2str:=TrimLeft(resultado);
end;
//........................................
procedure dxf_create(var f:textfile; name:string);
begin
   assign(f,name);
   rewrite(f);
writeln(f,'  0');
writeln(f,'SECTION');
writeln(f,'  2');
writeln(f,'HEADER');
writeln(f,'  0');
writeln(f,'ENDSEC');
writeln(f,'  0');
writeln(f,'SECTION');
writeln(f,'  2');
writeln(f,'TABLES');
writeln(f,'  0');
writeln(f,'TABLE');
writeln(f,'  2');
writeln(f,'LAYER');
writeln(f,'  70');
writeln(f,'    153');
{writeln(f,'  0');
writeln(f,'ENDTAB');
writeln(f,'  0');
writeln(f,'ENDSEC');
writeln(f,'  0');
writeln(f,'SECTION');
writeln(f,'  2');
writeln(f,'ENTITIES');}
end;


procedure dxf_face(var f:textfile; color:word;
                   x1,y1,z1,
                   x2,y2,z2,
                   x3,y3,z3,
                   x4,y4,z4:real);
var
lay:string;
begin
lay:='Texture_'+trimleft(inttostr(color));
writeln(f,'  0');
writeln(f,'3DFACE');
writeln(f,'  8');
writeln(f,lay);
writeln(f,' 10');
writeln(f,val2str(x1,10,6));
writeln(f,' 20');
writeln(f,val2str(y1,10,6));
writeln(f,' 30');
writeln(f,val2str(z1,10,6));
writeln(f,' 11');
writeln(f,val2str(x2,10,6));
writeln(f,' 21');
writeln(f,val2str(y2,10,6));
writeln(f,' 31');
writeln(f,val2str(z2,10,6));
writeln(f,' 12');
writeln(f,val2str(x3,10,6));
writeln(f,' 22');
writeln(f,val2str(y3,10,6));
writeln(f,' 32');
writeln(f,val2str(z3,10,6));
writeln(f,' 13');
writeln(f,val2str(x4,10,6));
writeln(f,' 23');
writeln(f,val2str(y4,10,6));
writeln(f,' 33');
writeln(f,val2str(z4,10,6));
//writeln(f,' 62');
//writeln(f,val2str(color,3,0));
end;

procedure dxf_close(var f:textfile);
begin
writeln(f,' 0');
writeln(f,'ENDSEC');
writeln(f,' 0');
writeln(f,'EOF');
close(f);
end;

//-----------------------------------------------------
procedure tr_exportdxf(name:string; room:byte; var L:ttrlevel);
var
f:textfile;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4:real;
textura:word;
scala:integer;
k:word;
tt:array [0..2999] of boolean;
lay:string;

begin
  dxf_create(f,name);
  fillchar(tt,3000,chr(0));
//--------------------------------------------------
for k:=1 to l.rooms[room].quads.num_quads do
begin
   tt[l.rooms[room].quads.quad[k].texture and $0fff]:=true;
end;

for k:=1 to l.rooms[room].triangles.num_triangles do
begin
   tt[l.rooms[room].triangles.triangle[k].texture and $0fff]:=true;
end;



for k:=0 to 2999 do
begin
  if tt[k] then
  begin
    lay:='Texture_'+trimleft(inttostr(k+1));
       writeln(f,'  0');
       writeln(f,'LAYER');
       writeln(f,'  2');
       writeln(f,LAY);
       writeln(f,' 70');
       writeln(f,'  0');
       writeln(f,' 62');
       writeln(f, k+1:6);
       writeln(f,'  6');
       writeln(f,'CONTINUOUS');
  end;
end;

//resto del header
writeln(f,'  0');
writeln(f,'ENDTAB');
writeln(f,'  0');
writeln(f,'ENDSEC');
writeln(f,'  0');
writeln(f,'SECTION');
writeln(f,'  2');
writeln(f,'ENTITIES');

//--------------------------------------------------
  scala:=1000;
   for k:=1 to l.rooms[room].quads.num_quads do
   begin
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

       x1:=x1/scala;
       y1:=(y1/scala)*-1;
       z1:=(z1/scala)*-1;

       x2:=x2/scala;
       y2:=(y2/scala)*-1;
       z2:=(z2/scala)*-1;

       x3:=x3/scala;
       y3:=(y3/scala)*-1;
       z3:=(z3/scala)*-1;

       x4:=x4/scala;
       y4:=(y4/scala)*-1;
       z4:=(z4/scala)*-1;

       textura:=l.rooms[room].quads.quad[k].texture and $0fff;

//     if textura>254 then textura:=254;
       dxf_face(f, textura+1,
        x1,z1,y1,
        x2,z2,y2,
        x3,z3,y3,
        x4,z4,y4);


   end; //fin quads
//.....................................................
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

       x1:=x1/scala;
       y1:=(y1/scala)*-1;
       z1:=(z1/scala)*-1;

       x2:=x2/scala;
       y2:=(y2/scala)*-1;
       z2:=(z2/scala)*-1;

       x3:=x3/scala;
       y3:=(y3/scala)*-1;
       z3:=(z3/scala)*-1;

       x4:=x3;
       y4:=y3;
       z4:=z3;

       textura:=l.rooms[room].triangles.triangle[k].texture and $0fff;

//     if textura>254 then textura:=254;
       dxf_face(f, textura+1,
        x1,z1,y1,
        x2,z2,y2,
        x3,z3,y3,
        x4,z4,y4);

   end; //fin triangles

dxf_close(f);
end;

procedure tr_ImportDxf(name:string; room:byte; var L:ttrlevel);

type
tlayer = record
         name:string;
         color:integer;
end;

tlayer_list = record
              num_layers:word;
              layer: array[1..255] of tlayer;

end;

function find_layer(var lay:tlayer_list; name:string):word;
var
x:word;
resultado:word;
begin
   resultado:=0;
   for x:=1 to lay.num_layers do
   begin
       if lay.layer[x].name=name then resultado:=x;
       if resultado<>0 then break;
   end;
   find_layer:=resultado;
end;



var
f:textfile;
linea:string;
codstr:string;
codigo:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4:integer;
color,layercolor:integer;
layername:string;
lay :tlayer_list;

poly4:tpoly4_list;
poly3:tpoly3_list;
k:integer;
colorb:byte;

begin
  assign(f,name);
  reset(f);
  linea:=' ';
  poly4.num_poly4:=0;
  poly3.num_poly3:=0;
  lay.num_layers:=0;

//---Cargar la tabla de Layers-----
   linea:=' ';
   while (not eof(f)) and (linea<>'ENTITIES') do
   begin
       readln(f,codstr);//leer codigo dato
       readln(f,linea);//leer dato

       IF (codstr='  0') and (linea='LAYER') THEN //if encontro un layer
       begin
           codigo:=-1;
           layername:='';
           layercolor:=-1;
           while codigo<>6 do //si codigo es "6" entonces es el ultimo codigo en el layer
           begin
             readln(f,codstr);//leer codigo dato
             readln(f,linea);//leer dato
             codigo:=strToInt(codstr);
             case codigo of
                2:layername:=linea;
               62:Layercolor:=trunc(strTofloat(linea));
             end;//end case
           end; //end while

       //agregar layername y layercolor a una tabla;
        lay.num_layers:=lay.num_layers+1;
//      if lay.num_layers>255 then lay.num_layers:=255;

        lay.layer[lay.num_layers].name:=layername;
//      lay.layer[lay.num_layers].color:=layercolor; importar la texture usando el nombre del layer.

        pos('_',lay.layer[lay.num_layers].name);
        lay.layer[lay.num_layers].color:=
             strtoint(copy(lay.layer[lay.num_layers].name,
                      pos('_',lay.layer[lay.num_layers].name)+1,4));


       end;//end Layer encontrado.


   end;//end buscar layers




//---- Buscar 3dfaces------
   while not eof(f) do
   begin
       //buscar 3DFACE
       while (linea<>'3DFACE') and (not eof(f)) do
       begin
           readln(f,linea);
       end;

   if linea='3DFACE' then //un face encontrado?
   begin
        x1:=0;y1:=0;z1:=0;
        x2:=0;y2:=0;z2:=0;
        x3:=0;y3:=0;z3:=0;
        x4:=0;y4:=0;z4:=0;
        color:=0;

        codigo:=-1;
        while codigo<>0 do
        begin
             readln(f,codstr);//leer codigo dato
             readln(f,linea);//leer dato
             codigo:=strToInt(codstr);
             case codigo of
                  //layer
                 8: begin layercolor:=find_layer(lay,linea);if layercolor<>0 then color:=lay.layer[layercolor].color; end;
                 //cordenadas x
                10: x1:=round(strTofloat(linea)*1000);
                11: x2:=round(strTofloat(linea)*1000);
                12: x3:=round(strTofloat(linea)*1000);
                13: x4:=round(strTofloat(linea)*1000);
                 //cordenadas y
                20: y1:=round(strTofloat(linea)*-1000);
                21: y2:=round(strTofloat(linea)*-1000);
                22: y3:=round(strTofloat(linea)*-1000);
                23: y4:=round(strTofloat(linea)*-1000);
                 //cordenadas z
                30: z1:=round(strTofloat(linea)*-1000);
                31: z2:=round(strTofloat(linea)*-1000);
                32: z3:=round(strTofloat(linea)*-1000);
                33: z4:=round(strTofloat(linea)*-1000);
                //color
//              62: color:=trunc(strTofloat(linea));

             end;//fin solo codigos que esta rutina soporta

        end;//fin while codigo<>0

   //.... Agregar las cordenadas a la tabla de polys4 y polys3
   if (x4=x3) and
      (y4=y3) and
      (z4=z3) then
                 add_poly3(poly3, x1,z1,y1, x2,z2,y2, x3,z3,y3, color-1, 16)
               else
                 add_poly4(poly4, x1,z1,y1, x2,z2,y2, x3,z3,y3, x4,z4,y4, color-1, 16);


   //...........................................................
   end;// fin una cara encontrada

   end;// fin si no es fin archivo

   //convertir poly4 y poly3 a Quads y Triangles.


   l.rooms[room].vertices.num_vertices:=0;
   l.rooms[room].quads.num_quads:=0;
   l.rooms[room].triangles.num_triangles:=0;

   if poly4.num_poly4>0 then poly4_2_quad(poly4, l.rooms[room].quads, l.rooms[room].vertices);
   if poly3.num_poly3>0 then poly3_2_trian(poly3, l.rooms[room].triangles, l.rooms[room].vertices);
   close(f);
 //poner en vertices2 el contenido de vertice1
    for k:=1 to l.rooms[room].vertices.num_vertices do
    begin
        l.rooms[room].vertices.vertice2[k].x:=l.rooms[room].vertices.vertice[k].x;
        l.rooms[room].vertices.vertice2[k].y:=l.rooms[room].vertices.vertice[k].y;
        l.rooms[room].vertices.vertice2[k].z:=l.rooms[room].vertices.vertice[k].z;
        l.rooms[room].vertices.vertice2[k].light:=l.rooms[room].vertices.vertice[k].light;
        l.rooms[room].vertices.vertice2[k].light0:=l.rooms[room].vertices.vertice[k].light0;
        //
        l.rooms[room].vertices.vertice3[k].x:=l.rooms[room].vertices.vertice2[k].x;
        l.rooms[room].vertices.vertice3[k].y:=l.rooms[room].vertices.vertice2[k].y;
        l.rooms[room].vertices.vertice3[k].z:=l.rooms[room].vertices.vertice2[k].z;

        if l.tipo>=vtr3 then
        begin
           colorb:=31-l.rooms[room].vertices.vertice[k].light;
           l.rooms[room].vertices.vertice2[k].light2:= (colorb shl 10) or (colorb shl 5) or (colorb);
           // 15855 es la mitad de la intensidad color rgb de cada vertice
           if (l.rooms[room].water and 1)=1 then l.rooms[room].vertices.vertice2[k].attrib:=16 or $2000 // or $4000)
                                              else l.rooms[room].vertices.vertice2[k].attrib:=16;
                                             //16 efecto normal, 8192=water efecto
          //si quicksand
          if (l.rooms[room].water and 128)=128 then l.rooms[room].vertices.vertice2[k].attrib:=$2000;

        end
        else
        begin
           l.rooms[room].vertices.vertice2[k].light2:=$ffff;
           l.rooms[room].vertices.vertice2[k].attrib:=0;
        end

    end; //end k

    //if trc fix the quads and triangles.
    for k:=1 to l.rooms[room].quads.num_quads do
    begin
         l.rooms[room].quads.quad2[k].p1:=l.rooms[room].quads.quad[k].p1;
         l.rooms[room].quads.quad2[k].p2:=l.rooms[room].quads.quad[k].p2;
         l.rooms[room].quads.quad2[k].p3:=l.rooms[room].quads.quad[k].p3;
         l.rooms[room].quads.quad2[k].p4:=l.rooms[room].quads.quad[k].p4;
         l.rooms[room].quads.quad2[k].texture:=l.rooms[room].quads.quad[k].texture;
    end;//end quads.

    for k:=1 to l.rooms[room].triangles.num_triangles do
    begin
         l.rooms[room].triangles.triangle2[k].p1:=l.rooms[room].triangles.triangle[k].p1;
         l.rooms[room].triangles.triangle2[k].p2:=l.rooms[room].triangles.triangle[k].p2;
         l.rooms[room].triangles.triangle2[k].p3:=l.rooms[room].triangles.triangle[k].p3;
         l.rooms[room].triangles.triangle2[k].texture:=l.rooms[room].triangles.triangle[k].texture;
    end;//end quads.


end;//end procedure

//...................................................................

procedure Tr_panel_textures(tancho,talto,tcolumns:byte; var L:Ttrlevel; var panel:tpanel_texture);
var
tempo,aux:tbitmap;
num,k:word;
pos:integer;
des:integer;
pal:hpalette;
x1,y1,x2,y2,x3,y3:integer;
c,f,xpos,ypos:integer;
mx1,my1,mx2,my2,mx3,my3,mx4,my4:integer;
flipx,flipy:boolean;
begin

   aux:=tbitmap.create;
   aux.pixelformat:=pf16bit;

// Comvertir las texturas a un big bmp

if l.tipo<vtr2 then //si phd o tub then 8bit textures
begin
   tempo:=tbitmap.create;
   tempo.pixelformat:=pf8bit;
   tempo.width:=256;
   tempo.height:=l.num_texture_pages*256;
   pal2hpal(trgbpaleta(l.palette),pal);
   tempo.palette:=pal;
   xsetbitmapbits(tempo,tempo.width*tempo.height, l.texture_data);
end
else
   begin
     tempo:=tbitmap.create;
     tempo.pixelformat:=pf16bit;
     tempo.width:=256;
     tempo.height:=l.num_texture_pages*256;
     xsetbitmapbits(tempo,(tempo.width*tempo.height)*2, l.texture_data2);
     fix16bitmap(tempo);
   end;
//--------tempo ya es un bitmpap 8 0 16 bits

    //buscar solo texturas de wxh
    k:=0;
    for num:=0 to l.Num_textures-1 do
    begin
        if (abs(l.textures[num].x2-l.textures[num].x1)=tancho-1) and
           (abs(l.textures[num].y3-l.textures[num].y2)=talto-1) and
           (not ( ((l.textures[num].x4=0) and (l.textures[num].y4=0)) or  ( (l.textures[num].mx4=0) and (l.textures[num].my4=0))  ))
           then begin k:=k+1;panel.index[k]:=num;end;
    end;

    panel.width:=tancho;panel.height:=talto;
    panel.columns:=tcolumns;
    panel.num_textures:=k;
    panel.rows:=(k div tcolumns);
    If k>(panel.rows*tcolumns) then panel.rows:=panel.rows+1;

    //se supone que el panel no esta creado.
    if panel.textures=nil then panel.textures:=tbitmap.create;
    panel.textures.pixelformat:=pf16bit;
    panel.textures.width:=(tcolumns*tancho)+tcolumns-1;
    panel.textures.height:=(panel.rows*talto)+panel.rows-1;
    panel.valido:='Valido';

    pos:=0;
    k:=1;
    ypos:=0;
    for f:=1 to panel.rows do
    begin
        xpos:=0;
        for c:=1 to panel.columns do
        begin
          if k>panel.num_textures then break;
          num:=panel.index[k];
          des:=(l.Textures[num].tile and $0fff)*256;

          get_text_coord(l,num,x1,y1,x2,y2);

          //add the displacament
           y1:=des+y1;
           y2:=des+y2;

       //texturemaps
       mx1:=l.Textures[num].mx1;my1:=l.Textures[num].my1;
       mx2:=l.Textures[num].mx2;my2:=l.Textures[num].my2;
       mx3:=l.Textures[num].mx3;my3:=l.Textures[num].my3;
       mx4:=l.Textures[num].mx4;my4:=l.Textures[num].my4;

       //flips?

       if not istriangular(l,num) then
       begin
         if mx1=255 then flipx:=true else flipx:=false;
         if my1=255 then flipy:=true else flipy:=false;
       end
       else
       begin
         if (mx1=255) and (mx1<>mx3) then flipx:=true else flipx:=false;
         if (my1=255) and (my1<>my3) then flipy:=true else flipy:=false;
       end;


          //extraer solo la pieza
          aux.width:=tancho;
          aux.Height:=talto;
          aux.canvas.CopyRect(rect(0,0,tancho,talto),
                                        tempo.Canvas, rect(x1,y1, x2,y2));

       //if flip the texture horizontal
       if flipx then bitmap_flip_hor(aux);

       //if flip the texture vertical
       if flipy then bitmap_flip_ver(aux);

         //agregar al panel

       panel.textures.canvas.CopyRect(rect(xpos,ypos,xpos+tancho,ypos+talto),
                                        aux.Canvas, rect(0,0, tancho,talto));
      //si triangular dibujar una diagonal.
       if (l.Textures[num].x4=0) and
            (l.Textures[num].y4=0) then
            begin
              panel.textures.canvas.pen.Color:=clwhite;
              panel.textures.canvas.moveTo(xpos,ypos);
              panel.textures.canvas.Lineto(xpos+tancho,ypos+talto);
            end;//si triangular
          xpos:=xpos+tancho+1;
          k:=k+1;
        end; //en columns
          ypos:=ypos+talto+1;
     end; //end rows
   tempo.free;
   aux.free;
end;

//....................

Function Tr_panel_getindex(x,y:integer; var panel:tpanel_texture):integer;
var
f,c:real;
fail:boolean;
cuenta:integer;
begin

    result:=0;
    cuenta:=0;

    if panel.valido<>'Valido' then exit;

    fail:=true;
    cuenta:=0;

    while (fail) and (cuenta<11) do
    begin
       fail:=false;
       try
         c:=x/(panel.width+panel.columns-1);if (c-int(c))<>0 then f:=int(c)+1;
         f:=y/(panel.height+1);if (f-int(f))<>0 then f:=int(f)+1;
       except
          fail:=true;
          cuenta:=cuenta+1;
       end;
    end;


    result:=(trunc(f*panel.columns+c))-panel.columns+1;
    if (result>panel.num_textures) or (result<0) then result:=0;
end;




//....................
procedure linea_sector( sec:tsector; var Tile:tsector_list; f1,c1,f2,c2:byte);
begin


while (f1<f2) OR (c1<c2) do
begin
      put_sector( sec, Tile, c1,f1);

    if f1<f2 then f1:=f1+1;
    if c1<c2 then c1:=c1+1;
end;
    put_sector( sec, Tile, c1,f1);
end;
//......................................

procedure bloque_sector( sec:tsector; var Tile:tsector_list; f1,c1,f2,c2:byte);
var
m,n:integer;
begin

for m:=f1 to f2 do
for n:=c1 to c2 do put_sector( sec, Tile, c1,f1);

end;
//------------------------------------------------------
procedure tr_build_boxes(var l:tphd);
const
altura = 128;

type
   tabox = record
           box_no:integer;
           zmin,zmax,
           xmin,xmax:longint;
           floory:smallint;
           overlap_index:smallint;
   end;

var
aux_box: array[1..32,1..32] of tabox;
r:integer;
curbox:integer;
k:word;
fil,col:integer;
tindex:word;
begin

{inicializar los boxes,overlaps y zones}
l.boxes.num_boxes:=0;
l.overlaps.num_overlaps:=0;
l.zones.num_zones:=0;
curbox:=0;

for r:=1 to l.rooms.num_rooms do
begin

    for col:=1 to l.rooms.room[r].sectors.ancho do
    begin
        for fil:=1 to l.rooms.room[r].sectors.largo do
        begin
           tindex:=get_tile_index(l.rooms.room[r].sectors,col,fil);

           if (l.rooms.room[r].sectors.sector[tindex].floor_height<>l.rooms.room[r].sectors.sector[tindex].ceiling_height)
           THEN
           begin
              aux_box[col,fil].box_no:=curbox; curbox:=curbox+1;
              aux_box[col,fil].zmin:=l.rooms.room[r].room_info.zpos_room+((fil-1)*1024);
              aux_box[col,fil].zmax:=aux_box[col,fil].zmin+1024;
              aux_box[col,fil].xmin:=l.rooms.room[r].room_info.xpos_room+((col-1)*1024);
              aux_box[col,fil].xmax:=aux_box[col,fil].xmin+1024;
              aux_box[col,fil].floory:=short2byte(l.rooms.room[r].sectors.sector[tindex].floor_height)*altura;


              if l.rooms.room[r].sectors.sector[tindex].room_below<>255 then
              aux_box[col,fil].floory:=0;

           end //si no es pared.
           else aux_box[col,fil].box_no:=-1;
        end;//fin filas
     end;//fin columnas

     //--------------------------------------------------
     //crear los box/overlaps/zones para este room.
    for col:=1 to l.rooms.room[r].sectors.ancho do
    begin
        for fil:=1 to l.rooms.room[r].sectors.largo do
        begin
              tindex:=get_tile_index(l.rooms.room[r].sectors,col,fil);
              if aux_box[col,fil].box_no>=0 then
              begin
                  word(l.rooms.room[r].sectors.sector[tindex].box_index):=aux_box[col,fil].box_no;
                  if l.tipo=4 then l.rooms.room[r].sectors.sector[tindex].box_index:=(l.rooms.room[r].sectors.sector[tindex].box_index shl 4) or 5;
                  //crear un nuevo box
                  l.boxes.num_boxes:=l.boxes.num_boxes+1;
                  l.boxes.box[l.boxes.num_boxes].xmin:=aux_box[col,fil].xmin;
                  l.boxes.box[l.boxes.num_boxes].xmax:=aux_box[col,fil].xmax;
                  l.boxes.box[l.boxes.num_boxes].zmin:=aux_box[col,fil].zmin;
                  l.boxes.box[l.boxes.num_boxes].zmax:=aux_box[col,fil].zmax;
                  l.boxes.box[l.boxes.num_boxes].floory:=aux_box[col,fil].floory;
                  l.boxes.box[l.boxes.num_boxes].overlap_index:=l.overlaps.num_overlaps;

                  //averiguar y agregar los overlaps

                  //agregar en la lista el nuevo box actual.
                  l.overlaps.num_overlaps:=l.overlaps.num_overlaps+1;
                  l.overlaps.overlap[l.overlaps.num_overlaps]:=aux_box[col,fil].box_no;//sin la marca de fin de la lista.

                  //----hay vecino atras?--------
                  if fil<l.rooms.room[r].sectors.largo then
                  begin
                      k:=get_tile_index(l.rooms.room[r].sectors,col,fil+1);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col,fil+1].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          l.overlaps.num_overlaps:=l.overlaps.num_overlaps+1;
                          l.overlaps.overlap[l.overlaps.num_overlaps]:=aux_box[col,fil+1].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino enfrente?--------
                  if fil>1 then
                  begin
                      k:=get_tile_index(l.rooms.room[r].sectors,col,fil-1);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col,fil-1].floory-aux_box[col,fil].floory)<=altura) then
                     begin
                          l.overlaps.num_overlaps:=l.overlaps.num_overlaps+1;
                          l.overlaps.overlap[l.overlaps.num_overlaps]:=aux_box[col,fil-1].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino a la derecha?--------
                  if col<l.rooms.room[r].sectors.ancho then
                  begin
                      k:=get_tile_index(l.rooms.room[r].sectors,col+1,fil);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col+1,fil].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          l.overlaps.num_overlaps:=l.overlaps.num_overlaps+1;
                          l.overlaps.overlap[l.overlaps.num_overlaps]:=aux_box[col+1,fil].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.

                  //----hay vecino a la izquierda?--------
                  if col>1 then
                  begin
                      k:=get_tile_index(l.rooms.room[r].sectors,col-1,fil);
                      if (aux_box[col,fil].box_no<>-1) and (abs(aux_box[col-1,fil].floory-aux_box[col,fil].floory)<=altura) then
                      begin
                          l.overlaps.num_overlaps:=l.overlaps.num_overlaps+1;
                          l.overlaps.overlap[l.overlaps.num_overlaps]:=aux_box[col-1,fil].box_no;//sin la marca tampoco.
                      end;//fin si agregar este vecino en la lista
                  end;//fin si vecino enfrente.
                  //----------------------------------------

                 //poner la marca de fin de lista
                 l.overlaps.overlap[l.overlaps.num_overlaps]:=l.overlaps.overlap[l.overlaps.num_overlaps] or $8000;
                 //ahora agregar una zona.
                 l.zones.num_zones:=l.zones.num_zones+1;
                 l.zones.nground_zone1[l.zones.num_zones]:=0;
                 l.zones.nground_zone2[l.zones.num_zones]:=0;
                 l.zones.nfly_zone[l.zones.num_zones]:=0;
                 l.zones.aground_zone1[l.zones.num_zones]:=0;
                 l.zones.aground_zone2[l.zones.num_zones]:=0;
                 l.zones.afly_zone[l.zones.num_zones]:=0;

               end
               else
                  begin
                      //solo poner el box_index:=-1;
                      l.rooms.room[r].sectors.sector[tindex].box_index:=-1;
                      if l.tipo=4 then l.rooms.room[r].sectors.sector[tindex].box_index:=(l.rooms.room[r].sectors.sector[tindex].box_index shl 4) or 5;
                  end;

        end;//fin filas
     end;//fin columnas
//-------------------------------------------------------------------------


end;//fin todos los rooms.

end;//fin procedure

//------------------------------------------------

function tr_loaditm(var L:tphd; name:string):byte;
var
f:file;
x,x2:word;
xroom,xsector,xfloor_index:word;
numdata:word;
newdata:word;
signature:string[7];

begin
   if not fileExists(name) then begin tr_loaditm:=1;exit; end;
   assign(f,name);
   reset(f,1);

   //signature primero
   blockread(f,signature,sizeof(signature));
   if signature<>'TPASCAL' then begin tr_loaditm:=2;exit;end;
  //restaurar tabla de items
  blockread(f,l.items.num_items,4);
  if (l.tipo=3) or (l.tipo=4) then
                                 blockread(f,l.items.item2, l.items.Num_items*sizeof(titem2)) else
                                 blockread(f,l.items.item, l.items.Num_items*sizeof(titem));
    //floor_data
   numdata:=l.floor_data.num_floor_data;
   blockread(f,newdata,2);
   l.floor_data.num_floor_data:=l.floor_data.num_floor_data+newdata;
   blockread(f,l.floor_data.floor_data[numdata], newdata*2);

//las cameras
     blockread(f,l.cameras.Num_cameras,4);
     blockread(f,l.cameras.camera, l.cameras.Num_cameras*sizeof(tcamera));

   //restaurar cuantos rooms habia al salvar esto.
   blockread(f,x2,2);

//restaurar los source lights y static meshes, sprites and room flags
  for x:=1 to x2 do
  begin
         //sprites primero.
          blockread(f,l.rooms.room[x].Sprites.num_sprites,2);
          blockread(f,l.rooms.room[x].Sprites.sprite, sizeof(tsprite) * l.rooms.room[x].Sprites.num_sprites );

          //spoot lights
          blockread(f,l.rooms.room[x].Source_lights.num_sources,2);
          if (l.tipo=3) or (l.tipo=4) then
                     blockread(f,l.rooms.room[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms.room[x].Source_lights.num_sources ) else
                     blockread(f,l.rooms.room[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms.room[x].Source_lights.num_sources );

          //static meshs
          blockread(f,l.rooms.room[x].Statics.num_static,2);
          if (l.tipo=3) or (l.tipo=4) then
                                      blockread(f,l.rooms.room[x].statics.static2, sizeof(tstatic2) * l.rooms.room[x].statics.num_static ) else
                                      blockread(f,l.rooms.room[x].statics.static, sizeof(tstatic) * l.rooms.room[x].statics.num_static );

         //room flags


 end; //restaurar todos los static y source lights.



   //restaurar los trigers
   while not eof(f) do
   begin
         blockread(f,xroom,2);
         blockread(f,xsector,2);
         blockread(f,xfloor_index,2);
         l.rooms.room[xroom].sectors.sector[xsector].floor_index:=numdata+xfloor_index;
   end;//fin leer todos los trigers

close(f);
   tr_loaditm:=0;

end;

//------------------------------------------------

procedure tr_saveitm(var L:tphd; name:string);
var
f:file;
x,y:integer;
xfloor_index:word;
numdata:word;
newdata:word;
signature:string[7];
begin
  assign(f,name);
  rewrite(f,1);
  //signature primero
  signature:='TPASCAL';
  blockwrite(f,signature,sizeof(signature));

  //salvar la tabla de items
  blockwrite(f,l.items.num_items,4);
  if (l.tipo=3) or (l.tipo=4) then
                                 blockwrite(f,l.items.item2, l.items.Num_items*sizeof(titem2)) else
                                 blockwrite(f,l.items.item, l.items.Num_items*sizeof(titem));

   //floor_data
   //averiguar cuantos floor datas agrego tritem.
   move(l.floor_data.floor_data[0],numdata,2);
   newdata:=l.floor_data.num_floor_data-numdata;

   blockwrite(f,newdata,2);
   blockwrite(f,l.floor_data.floor_data[numdata],newdata*2);


//las cameras
     blockwrite(f,l.cameras.Num_cameras,4);
     blockwrite(f,l.cameras.camera, l.cameras.Num_cameras*sizeof(tcamera));



   //salvar cuantos rooms habia al salvar esto.
   blockwrite(f,l.rooms.num_rooms,2);

//Salvar Statics mesh and source lights. y sprites, y room flags.
   for x:=1 to l.rooms.num_rooms do
   begin
      //sprites
      blockwrite(f,l.rooms.room[x].Sprites.num_sprites,2);
      blockwrite(f,l.rooms.room[x].Sprites.sprite, sizeof(tsprite) * l.rooms.room[x].Sprites.num_sprites );

      //source lights
          blockwrite(f,l.rooms.room[x].Source_lights.num_sources,2);
          if (l.tipo=3) or (l.tipo=4) then
                     blockwrite(f,l.rooms.room[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms.room[x].Source_lights.num_sources ) else
                     blockwrite(f,l.rooms.room[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms.room[x].Source_lights.num_sources );


       //numero de static meshes
       blockwrite(f,l.rooms.room[x].statics.num_static,2);
         if (l.tipo=3) or (l.tipo=4) then
                                 blockwrite(f,l.rooms.room[x].statics.static2, sizeof(tstatic2) * l.rooms.room[x].statics.num_static ) else
                                 blockwrite(f,l.rooms.room[x].statics.static, sizeof(tstatic) * l.rooms.room[x].statics.num_static );


       //Salvar room flags


   end;//salvar todos los static and sources lights


   //salvar los trigers
   for x:=1 to l.rooms.num_rooms do
   begin
       for y:=1 to l.rooms.room[x].sectors.largo*l.rooms.room[x].sectors.ancho do
       begin
            if  l.rooms.room[x].sectors.sector[y].floor_index>=numdata then
            begin
                blockwrite(f,x,2); //salvar el room number
                blockwrite(f,y,2); //salvar el sector number;
                xfloor_index:=l.rooms.room[x].sectors.sector[y].floor_index-numdata;
                blockwrite(f,xfloor_index,2);
            end;//salver este floor_data
       end;//fin leer todos los sectores;
   end;//fin de scanear all rooms.

close(f);
end;
//---------------------------------------
procedure TR_savemsh(var L:ttrlevel; name:string);
var
f:tzfile;
signature:string[16];
x:word;
aux:longint;
begin
   zassignfile(f,name);
   zrewrite(f,1);
   signature:='TPascal MSH file';
   zblockwrite(f,signature,sizeof(signature));
   //tipo de tr file
   zblockwrite(f,l.tipo,sizeof(l.tipo));
   //num_rooms
   aux:=l.num_rooms;
   zblockwrite(f,aux,sizeof(l.num_rooms));
   //vertices

   for x:=0 to l.num_rooms-1 do
   begin
       zblockwrite(f,l.rooms[x].vertices.num_vertices,2);
       //cargar los vertices deacuerdo a la version.

       if (l.tipo<vtr2) then zblockwrite(f,l.rooms[x].vertices.vertice, sizeof(tvertice) * l.rooms[x].vertices.num_vertices );
       if (l.tipo>vtub) and (l.tipo<vtr5) then zblockwrite(f,l.rooms[x].vertices.vertice2, sizeof(tvertice2) * l.rooms[x].vertices.num_vertices );
       if l.tipo=vtr5 then zblockwrite(f,l.rooms[x].vertices.vertice3, sizeof(tvertice3) * l.rooms[x].vertices.num_vertices );

       if l.tipo<vtr5 then
       begin
         zblockwrite(f,l.rooms[x].quads.num_quads,2);
         zblockwrite(f,l.rooms[x].quads.quad,  sizeof(tquad) * l.rooms[x].quads.num_quads );
         zblockwrite(f,l.rooms[x].triangles.num_triangles,2);
         zblockwrite(f,l.rooms[x].triangles.triangle,  sizeof(ttriangle) * l.rooms[x].triangles.num_triangles );
       end
       else
       begin
         zblockwrite(f,l.rooms[x].quads.num_quads,2);
         zblockwrite(f,l.rooms[x].quads.quad2,  sizeof(tquad2) * l.rooms[x].quads.num_quads );
         zblockwrite(f,l.rooms[x].triangles.num_triangles,2);
         zblockwrite(f,l.rooms[x].triangles.triangle2, sizeof(ttriangle2) * l.rooms[x].triangles.num_triangles );
       end;
        //lara light.
        if l.tipo<vtr5 then zblockwrite(f,l.rooms[x].d0,3) else zblockwrite(f,l.rooms[x].tr5_unknowns.room_color,3);
        //room flags
        zblockwrite(f,l.rooms[x].water,1);

        //salvar source lights.
        //---------------------
        zblockwrite(f,l.rooms[x].Source_lights.num_sources,2);

          //si phd o tub
          if l.tipo<=vtub then zblockwrite(f,l.rooms[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms[x].Source_lights.num_sources );
          //if tr2 o tr3
          if (l.tipo>=vtr2) and (l.tipo<=vtr3) then zblockwrite(f,l.rooms[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms[x].Source_lights.num_sources );
          //si tr4
          if l.tipo=vtr4 then zblockwrite(f,l.rooms[x].Source_lights.source_light3, sizeof(tsource_light3) * l.rooms[x].Source_lights.num_sources );
          //si trc
          if l.tipo=vtr5 then zblockwrite(f,l.rooms[x].Source_lights.source_light4, sizeof(tsource_light4) * l.rooms[x].Source_lights.num_sources );
    end; //end all rooms
    //TRc weather
    if l.tipo=vtr5 then zblockwrite(f,l.tr5_weather,sizeof(l.tr5_weather));

    //salvar las zonas
    aux:=l.num_zones;
    zblockwrite(f,aux, 4);
    zblockwrite(f,l.nground_zone1[0], l.num_zones*2);
    zblockwrite(f,l.nground_zone2[0], l.num_zones*2);

    if l.tipo>vtub then
    begin
       zblockwrite(f,l.nground_zone3[0], l.num_zones*2);
       zblockwrite(f,l.nground_zone4[0], l.num_zones*2);
    end;
       zblockwrite(f,l.nfly_zone[0], l.num_zones*2);

f.compress:=true;
zclosefile(f);
end;

function TR_loadmsh(var L:ttrlevel; name:string):byte;
var
f:tzfile;
signature:string[16];
x:word;
k:word;
tipo:byte;
auxlong:longint;
i:integer;
r,g,b:word;
begin
   zassignfile(f,name);
   zreset(f,1);
   zblockread(f,signature,sizeof(signature));
   if signature<>'TPascal MSH file' then begin tr_loadmsh:=1;zclosefile(f,false);exit;end; //1=invalid msh file format.
   //tipo de tr file
   zblockread(f,tipo,sizeof(l.tipo));
   if (tipo=1) and (l.tipo=vtub) then tipo:=2;
   if (tipo=2) and (l.tipo=vtr1) then tipo:=1;
   if tipo<>l.tipo then begin tr_loadmsh:=2;zclosefile(f,false);exit;end; //2=invalid tr file version

   //num_rooms
   zblockread(f,k,sizeof(l.num_rooms));
   if k>l.num_rooms then k:=l.num_rooms;

   //vertices

   for x:=0 to k-1 do
   begin
       zblockread(f,l.rooms[x].vertices.num_vertices,2);
       //cargar los vertices deacuerdo a la version.
       if (l.tipo<vtr2) then zblockread(f,l.rooms[x].vertices.vertice, sizeof(tvertice) * l.rooms[x].vertices.num_vertices );
       if (l.tipo>vtub) and (l.tipo<vtr5) then zblockread(f,l.rooms[x].vertices.vertice2, sizeof(tvertice2) * l.rooms[x].vertices.num_vertices );
       if l.tipo=vtr5 then zblockread(f,l.rooms[x].vertices.vertice3, sizeof(tvertice3) * l.rooms[x].vertices.num_vertices );

       if l.tipo<vtr5 then
       begin
         zblockread(f,l.rooms[x].quads.num_quads,2);
         zblockread(f,l.rooms[x].quads.quad,  sizeof(tquad) * l.rooms[x].quads.num_quads );
         zblockread(f,l.rooms[x].triangles.num_triangles,2);
         zblockread(f,l.rooms[x].triangles.triangle,  sizeof(ttriangle) * l.rooms[x].triangles.num_triangles );
       end
       else
       begin
         zblockread(f,l.rooms[x].quads.num_quads,2);
         zblockread(f,l.rooms[x].quads.quad2,  sizeof(tquad2) * l.rooms[x].quads.num_quads );
         zblockread(f,l.rooms[x].triangles.num_triangles,2);
         zblockread(f,l.rooms[x].triangles.triangle2, sizeof(ttriangle2) * l.rooms[x].triangles.num_triangles );
       end;
        //lara light.
       if l.tipo<vtr5 then zblockread(f,l.rooms[x].d0,3) else zblockread(f,l.rooms[x].tr5_unknowns.room_color,3);
        //room flags
        zblockread(f,l.rooms[x].water,1);

       //leer source lights.
       //---------------------
          zblockread(f,l.rooms[x].Source_lights.num_sources,2);
          //si phd o tub
          if l.tipo<=vtub then zblockread(f,l.rooms[x].Source_lights.source_light, sizeof(tsource_light) * l.rooms[x].Source_lights.num_sources );
          //if tr2 o tr3
          if (l.tipo>=vtr2) and (l.tipo<=vtr3) then zblockread(f,l.rooms[x].Source_lights.source_light2, sizeof(tsource_light2) * l.rooms[x].Source_lights.num_sources );
          //si tr4
          if l.tipo=vtr4 then zblockread(f,l.rooms[x].Source_lights.source_light3, sizeof(tsource_light3) * l.rooms[x].Source_lights.num_sources );
          //si trc
          if l.tipo=vtr5 then zblockread(f,l.rooms[x].Source_lights.source_light4, sizeof(tsource_light4) * l.rooms[x].Source_lights.num_sources );


     //si tr2-tr4 then fix the vertices
     if l.tipo>=vtr2 then
     for i:=1 to l.rooms[x].vertices.num_vertices do
         begin
            l.rooms[x].vertices.vertice[i].x:=l.rooms[x].vertices.vertice2[i].x;
            l.rooms[x].vertices.vertice[i].y:=l.rooms[x].vertices.vertice2[i].y;
            l.rooms[x].vertices.vertice[i].z:=l.rooms[x].vertices.vertice2[i].z;
            l.rooms[x].vertices.vertice[i].light:=l.rooms[x].vertices.vertice2[i].light;
            l.rooms[x].vertices.vertice[i].light0:=l.rooms[x].vertices.vertice2[i].light0;
          end;

        //si TRC fix the vertices,quads,triangles.
      if l.tipo=vtr5 then
      begin
        for i:=1 to l.rooms[x].vertices.num_vertices do
        begin
            l.rooms[x].vertices.vertice[i].x:=trunc(l.rooms[x].vertices.vertice3[i].x);
            l.rooms[x].vertices.vertice[i].y:=trunc(l.rooms[x].vertices.vertice3[i].y);
            l.rooms[x].vertices.vertice[i].z:=trunc(l.rooms[x].vertices.vertice3[i].z);

            r:=l.rooms[x].vertices.vertice3[i].r div 8;
            g:=l.rooms[x].vertices.vertice3[i].g div 8;
            b:=l.rooms[x].vertices.vertice3[i].b div 8;

            l.rooms[x].vertices.vertice2[i].light2:=0; //reset color
            l.rooms[x].vertices.vertice2[i].light2:= (r shl 10) or (g shl 5) or (b);
        end;

       for i:=1 to l.rooms[x].quads.num_quads do
       begin
           l.rooms[x].quads.quad[i].p1:=l.rooms[x].quads.quad2[i].p1;
           l.rooms[x].quads.quad[i].p2:=l.rooms[x].quads.quad2[i].p2;
           l.rooms[x].quads.quad[i].p3:=l.rooms[x].quads.quad2[i].p3;
           l.rooms[x].quads.quad[i].p4:=l.rooms[x].quads.quad2[i].p4;
           l.rooms[x].quads.quad[i].texture:=l.rooms[x].quads.quad2[i].texture;
       end;

       for i:=1 to l.rooms[x].triangles.num_triangles do
       begin
           l.rooms[x].triangles.triangle[i].p1:=l.rooms[x].triangles.triangle2[i].p1;
           l.rooms[x].triangles.triangle[i].p2:=l.rooms[x].triangles.triangle2[i].p2;
           l.rooms[x].triangles.triangle[i].p3:=l.rooms[x].triangles.triangle2[i].p3;
           l.rooms[x].triangles.triangle[i].texture:=l.rooms[x].triangles.triangle2[i].texture;
       end;
      end; //end if trc.

    end; //end all rooms.

    //TRc weather
    if l.tipo=vtr5 then zblockread(f,l.tr5_weather,sizeof(l.tr5_weather));

    //cargar las zonas
    zblockread(f,auxlong,4);
    if auxlong>l.num_zones then auxlong:=l.num_zones;

    zblockread(f,l.nground_zone1[0], auxlong*2);
    zblockread(f,l.nground_zone2[0], auxlong*2);
    if l.tipo>vtub then
    begin
       zblockread(f,l.nground_zone3[0], auxlong*2);
       zblockread(f,l.nground_zone4[0], auxlong*2);
    end;
       zblockread(f,l.nfly_zone[0], auxlong*2);


zclosefile(f,false);
  TR_loadmsh:=0;
end;
//-------------------------
procedure tr_freephd(var l:tphd);
begin
 if l.valido='Tpascal' then
 begin
     FreeMem(l.texture_data);
     if l.tipo>2 then FreeMem(l.texture_data2);
     if l.tipo<3 then FreeMem(l.samples.buffer);
 end;
 fillchar(L,sizeof(L),chr(0));
end;

//----------------
procedure tr_addpage(var L:tphd; ancho,alto:integer);
var
k,newt:integer;
x1,y1:integer;
p:pointer;
tot:integer;
begin
    newt:=l.Textures.Num_textures+1;
    x1:=0;
    y1:=0;

//agregar espacio en las tablas de texturas.
  //8bit version
  getmem(p,(256*256)*(l.Num_Texture_pages+1));
  fillchar(p^,(256*256)*(l.Num_Texture_pages+1),chr(0));
  move(l.texture_data^,p^,(256*256)*l.Num_Texture_pages);
  freemem(l.texture_data);
  l.texture_data:=p;
  //16bit version
  if l.tipo>2 then
  begin
     getmem(p,(256*256*2)*(l.Num_Texture_pages+1));
     fillchar(p^,(256*256*2)*(l.Num_Texture_pages+1),chr(0));
     move(l.texture_data2^,p^,(256*256*2)*l.Num_Texture_pages);
     freemem(l.texture_data2);
     l.texture_data2:=p;
  end;//fin si hay 16 bit textures

  //actualizar algunos campos.
  l.Num_Texture_pages:=l.Num_Texture_pages+1;
  l.size_textures:=(256*256)*l.Num_Texture_pages;
  tot:=l.Num_Texture_pages-1;

    if ancho=0 then ancho:=64;
    if alto =0 then alto:=64;

    for k:=1 to ((256 div alto)*(256 div ancho))  do
    begin
        fillchar( l.Textures.texture[newt], sizeof(tobjtexture), chr(0));

        l.Textures.texture[newt].attrib:=0;
        l.Textures.texture[newt].tile:=tot;
        l.Textures.texture[newt].x1:=x1;
        l.Textures.texture[newt].mx1:=1;

        l.Textures.texture[newt].y1:=y1;
        l.Textures.texture[newt].my1:=1;

        l.Textures.texture[newt].x2:=x1+ancho-1;
        l.Textures.texture[newt].mx2:=255;

        l.Textures.texture[newt].y2:=y1;
        l.Textures.texture[newt].my2:=1;

        l.Textures.texture[newt].x3:=x1+ancho-1;
        l.Textures.texture[newt].mx3:=255;

        l.Textures.texture[newt].y3:=y1+alto-1;
        l.Textures.texture[newt].my3:=255;

        l.Textures.texture[newt].x4:=x1;
        l.Textures.texture[newt].mx4:=1;

        l.Textures.texture[newt].y4:=y1+alto-1;
        l.Textures.texture[newt].my4:=255;

        x1:=x1+ancho; if x1>=255 then begin x1:=0;y1:=y1+alto;end;
        newt:=newt+1;
    end; //fin amount texturas.
    l.Textures.Num_textures:=l.Textures.Num_textures+((256 div alto)*(256 div ancho));

end;


procedure Tr_tabla_textures(var L:ttrlevel; var tabla:ttabla_textures);
var
pal:hpalette;
tempo:tbitmap;
k:integer;
begin

   tabla.valido:='Valido';
   tabla.num_tiles:=l.Num_textures;
   tabla.cur_texture:=-1;
   tabla.cur_tile:=tbitmap.create;
   tabla.cur_tile.pixelformat:=pf16bit;

// Comvertir las texturas a un big bmp
if l.tipo<vtr2 then //si phd o tub then 8bit textures
begin
   tempo:=tbitmap.create;
   tempo.pixelformat:=pf8bit;
   tempo.width:=256;
   tempo.height:=l.num_texture_pages*256;
   pal2hpal(trgbpaleta(l.palette),pal);
   tempo.palette:=pal;
   xsetbitmapbits(tempo,tempo.width*tempo.height, l.texture_data);
//pasar a 16 bit version.
   tabla.textures:=tbitmap.create;
   tabla.textures.pixelformat:=pf16bit;
   tabla.textures.width:=256;
   tabla.textures.height:=l.num_texture_pages*256;
   tabla.textures.canvas.draw(0,0,tempo);
   tempo.free;
end
else
   begin
     tabla.textures:=tbitmap.create;
     tabla.textures.pixelformat:=pf16bit;
     tabla.textures.width:=256;
     tabla.textures.height:=l.num_texture_pages*256;
     xsetbitmapbits(tabla.textures,(tabla.textures.width*tabla.textures.height)*2, l.texture_data2);
     fix16bitmap(tabla.textures);
   end;
//--------tabla.textures ya es un bitmpap de 16 bits
     tabla.l:=l;
end;
//-------------------------

function fmin(v1,v2:single):single;
begin
    if v1<v2 then fmin:=v1 else fmin:=v2;
end;

function fmax(v1,v2:single):single;
begin
    if v1>v2 then fmax:=v1 else fmax:=v2;
end;
//-----------------------

function tr_Get_texture(num:integer; var tabla:ttabla_textures; tri:boolean=true):tbitmap;
var
des:integer;
x1,y1,x2,y2,x3,y3,x4,y4:integer;
mx1,my1,mx2,my2,mx3,my3,mx4,my4:integer;
flipx,flipy:boolean;

begin
      //el num parece que se necesita en base 0
      tr_Get_texture:=nil;

      if num=tabla.cur_texture then begin result:=tabla.cur_tile;exit;end;

      if (num>(tabla.num_tiles-1)) or (num<0) then
      begin
       tabla.cur_tile.width:=4;
       tabla.cur_tile.height:=4;
       tabla.cur_tile.Canvas.fillrect(rect(0,0,4,4));
       tr_Get_texture:=tabla.cur_tile;
       exit;
      end;

          des:=(tabla.l.Textures[num].tile and $7fff)*256;
          get_text_coord(tabla.l,num,x1,y1,x2,y2);

          //add the displacament
           y1:=des+y1;
           y2:=des+y2;

       //texturemaps
       mx1:=tabla.l.Textures[num].mx1;my1:=tabla.l.Textures[num].my1;
       mx2:=tabla.l.Textures[num].mx2;my2:=tabla.l.Textures[num].my2;
       mx3:=tabla.l.Textures[num].mx3;my3:=tabla.l.Textures[num].my3;
       mx4:=tabla.l.Textures[num].mx4;my4:=tabla.l.Textures[num].my4;

       //flips?

       if not istriangular(tabla.l,num) then
       begin
         if mx1=255 then flipx:=true else flipx:=false;
         if my1=255 then flipy:=true else flipy:=false;
       end
       else
       begin
         if (mx1=255) and (mx1<>mx3) then flipx:=true else flipx:=false;
         if (my1=255) and (my1<>my3) then flipy:=true else flipy:=false;
       end;



  tabla.cur_tile.width:=(x2-x1+1); tabla.cur_tile.height:=(y2-y1+1);
  tabla.cur_tile.canvas.CopyRect(rect(0,0,tabla.cur_tile.width,tabla.cur_tile.height), tabla.textures.Canvas, rect(x1,y1, x2,y2));

   //if flip the texture horizontal
   if flipx then bitmap_flip_hor(tabla.cur_tile);

  //if flip the texture vertical
   if flipy then bitmap_flip_ver(tabla.cur_tile);

  //si triangular dibujar una diagonal.
   if (((tabla.l.textures[num].x4=0) and (tabla.l.textures[num].y4=0)) or  ((tabla.l.textures[num].mx4=0) and (tabla.l.textures[num].my4=0)))
        and tri then
       begin
           tabla.cur_tile.canvas.pen.Color:=clwhite;
           tabla.cur_tile.canvas.moveTo(0,0);
           tabla.cur_tile.canvas.Lineto(tabla.cur_tile.width,tabla.cur_tile.height);
       end;//si triangular

  tabla.cur_texture:=num;
  tr_Get_texture:=tabla.cur_tile;

end;

//****************************************************

//-------------------------
procedure ttrlevel.Opengl_loadTextures(vp: array of tglviewport; colorbits:byte);
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
   a.pixelformat:=pf16bit;
   a.width:=256;
   a.height:=num_texture_pages*256;


//comvertir las texturas a un big bmp;
if tipo<vtr2 then
begin
   c.width:=256;
   c.height:=num_texture_pages*256;
   c.pixelformat:=pf8bit;
   pal2hpal(trgbpaleta(palette),pal);
   c.palette:=pal;
   xsetbitmapbits(c,c.width*c.height, texture_data);
   a.canvas.draw(0,0,c);
end
else
   begin
      xsetbitmapbits(a,(a.width*a.height)*2, texture_data2);
      fix16bitmap(a);
   end;

    step:=100/num_textures;
    position:=0;
   //---
    for num:=0 to num_textures-1 do
    begin
       des:=(Textures[num].tile and $7fff)*256;

       x1:=Textures[num].x1;
       y1:=Textures[num].y1;
       x2:=Textures[num].x2;
       y2:=Textures[num].y2;
       x3:=Textures[num].x3;
       y3:=Textures[num].y3;
       x4:=Textures[num].x4;
       y4:=Textures[num].y4;
       if ((x4=0) and (y4=0)) or ((Textures[num].mx4=0) and (Textures[num].my4=0)) then begin x4:=x3;y4:=y3;end;

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
       opgl_define_texture(num+1,b,colorbits,vp);
        position:=position+step;
        if progressbar<>nil then progressbar.Progress:=progressbar.Progress+trunc(position);
      end; //end for

      a.free;
      b.free;
      c.free;

   if progressbar<>nil then progressbar.Progress:=0;
end;
//---------

procedure xblockread(var bloque:longint; var destino; amount_bytes:longint);
begin
    move(pointer(bloque)^,destino,amount_bytes);
    bloque:=bloque+amount_bytes;
end;

procedure xblockwrite(var p:longint;var data;data_size:longint);
begin
    move(data,pointer(p)^,data_size);
    p:=p+data_size;
end;



procedure update_min_max(var m:tmesh_list; nmesh:integer);
const escala=100;
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4:glfloat;
//--
minx,miny,minz,maxx,maxy,maxz:real;

begin
     if nmesh<0 then exit;

     //reset dimensions
        //inicialize the min & max values
        m.meshes[nmesh].maxx:=-2144883648;
        m.meshes[nmesh].maxy:=-2144883648;
        m.meshes[nmesh].maxz:=-2144883648;

        m.meshes[nmesh].minx:=2144883647;
        m.meshes[nmesh].miny:=2144883647;
        m.meshes[nmesh].minz:=2144883647;

    //--------------
    //text rectangles
    for k:=0 to m.meshes[nmesh].num_textured_rectangles-1 do
    begin
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].z;

       x4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].x;
       y4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].y;
       z4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;
       x4:=(x4/escala);y4:=(y4/escala)*-1;z4:=(z4/escala)*-1;

       //update the minimum
       m.meshes[nmesh].minx:=minvalue( [x1,x2,x3,x4,m.meshes[nmesh].minx]);
       m.meshes[nmesh].miny:=minvalue( [y1,y2,y3,y4,m.meshes[nmesh].miny]);
       m.meshes[nmesh].minz:=minvalue( [z1,z2,z3,z4,m.meshes[nmesh].minz]);

       //update the maximum
       m.meshes[nmesh].maxx:=maxvalue( [x1,x2,x3,x4,m.meshes[nmesh].maxx]);
       m.meshes[nmesh].maxy:=maxvalue( [y1,y2,y3,y4,m.meshes[nmesh].maxy]);
       m.meshes[nmesh].maxz:=maxvalue( [z1,z2,z3,z4,m.meshes[nmesh].maxz]);
     end; //end tex rectangles

    //text triangles
    for k:=0 to m.meshes[nmesh].num_textured_triangles-1 do
    begin
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;

       //update the minimum
       m.meshes[nmesh].minx:=minvalue( [x1,x2,x3,m.meshes[nmesh].minx]);
       m.meshes[nmesh].miny:=minvalue( [y1,y2,y3,m.meshes[nmesh].miny]);
       m.meshes[nmesh].minz:=minvalue( [z1,z2,z3,m.meshes[nmesh].minz]);

       //update the maximum
       m.meshes[nmesh].maxx:=maxvalue( [x1,x2,x3,m.meshes[nmesh].maxx]);
       m.meshes[nmesh].maxy:=maxvalue( [y1,y2,y3,m.meshes[nmesh].maxy]);
       m.meshes[nmesh].maxz:=maxvalue( [z1,z2,z3,m.meshes[nmesh].maxz]);
   end; //end tex triangles
//============

    //colored
    for k:=0 to m.meshes[nmesh].num_colored_rectangles-1 do
    begin
     //sacar las cordenadas;

       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].z;

       x4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].x;
       y4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].y;
       z4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;
       x4:=(x4/escala);y4:=(y4/escala)*-1;z4:=(z4/escala)*-1;

       //update the minimum
       m.meshes[nmesh].minx:=minvalue( [x1,x2,x3,x4,m.meshes[nmesh].minx]);
       m.meshes[nmesh].miny:=minvalue( [y1,y2,y3,y4,m.meshes[nmesh].miny]);
       m.meshes[nmesh].minz:=minvalue( [z1,z2,z3,z4,m.meshes[nmesh].minz]);

       //update the maximum
       m.meshes[nmesh].maxx:=maxvalue( [x1,x2,x3,x4,m.meshes[nmesh].maxx]);
       m.meshes[nmesh].maxy:=maxvalue( [y1,y2,y3,y4,m.meshes[nmesh].maxy]);
       m.meshes[nmesh].maxz:=maxvalue( [z1,z2,z3,z4,m.meshes[nmesh].maxz]);
     end; //end tex rectangles

    //colored triangles
    for k:=0 to m.meshes[nmesh].num_colored_triangles-1 do
    begin
     //sacar las cordenadas;

       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;

       //update the minimum
       m.meshes[nmesh].minx:=minvalue( [x1,x2,x3,m.meshes[nmesh].minx]);
       m.meshes[nmesh].miny:=minvalue( [y1,y2,y3,m.meshes[nmesh].miny]);
       m.meshes[nmesh].minz:=minvalue( [z1,z2,z3,m.meshes[nmesh].minz]);

       //update the maximum
       m.meshes[nmesh].maxx:=maxvalue( [x1,x2,x3,m.meshes[nmesh].maxx]);
       m.meshes[nmesh].maxy:=maxvalue( [y1,y2,y3,m.meshes[nmesh].maxy]);
       m.meshes[nmesh].maxz:=maxvalue( [z1,z2,z3,m.meshes[nmesh].maxz]);
   end; //end tex triangles

   //calcular el desplazamiento.

   minx:=m.meshes[nmesh].minx;
   miny:=m.meshes[nmesh].miny;
   minz:=m.meshes[nmesh].minz;
   maxx:=m.meshes[nmesh].maxx;
   maxy:=m.meshes[nmesh].maxy;
   maxz:=m.meshes[nmesh].maxz;

   m.meshes[nmesh].despx:=(minx+((maxx-minx)/2))*-1;
   m.meshes[nmesh].despy:=(miny+((maxy-miny)/2))*-1;
   m.meshes[nmesh].despz:=(minz+((maxz-minz)/2))*-1;


end;


function find_mesh_pointer(var m:tmesh_list; mpointer:longint):longint;
var
k:integer;
r:longint;
begin
   r:=0;
   for k:=0 to m.num_meshes-1 do
   begin
       if m.meshes[k].mesh_pointer=mpointer then begin r:=k;break;end;
   end;
   find_mesh_pointer:=r;
end;



procedure build_mesh_list(var mesh_list:tmesh_list; var L:ttrlevel);
var
p:longint;
k:integer;
data_end:longint;
dumy:longint;
starting:longint;
data:pointer;
data_size:longint;
chunk_start:longint;
begin
    data:=@l.meshwords[0];
    data_size:=l.num_meshwords*2;

    p:=longint(data);
    data_end:=p+data_size;

    mesh_list.num_meshes:=0;

    chunk_start:=p;

    while p<data_end do
    begin
        starting:=p;
        setlength(mesh_list.meshes,mesh_list.num_meshes+1);

        //inicialize the min & max values
        mesh_list.meshes[mesh_list.num_meshes].maxx:=-2144883648;
        mesh_list.meshes[mesh_list.num_meshes].maxy:=-2144883648;
        mesh_list.meshes[mesh_list.num_meshes].maxz:=-2144883648;

        mesh_list.meshes[mesh_list.num_meshes].minx:=2144883647;
        mesh_list.meshes[mesh_list.num_meshes].miny:=2144883647;
        mesh_list.meshes[mesh_list.num_meshes].minz:=2144883647;

        //meshpointer;
        mesh_list.meshes[mesh_list.num_meshes].mesh_pointer:=p-chunk_start;

        //sphere colision
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].sphere_x,2);
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].sphere_y,2);
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].sphere_z,2);
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].sphere_radius,4);


        //vertices tables
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].num_vertices,2);
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].vertices, mesh_list.meshes[mesh_list.num_meshes].num_vertices*6 );
        //normals
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].num_normals,2);
        if mesh_list.meshes[mesh_list.num_meshes].num_normals>=0 then
           xblockread(p,mesh_list.meshes[mesh_list.num_meshes].normals, mesh_list.meshes[mesh_list.num_meshes].num_normals*6 ) else
           xblockread(p,mesh_list.meshes[mesh_list.num_meshes].lights, abs(mesh_list.meshes[mesh_list.num_meshes].num_normals)*2 );

        //textured rectangular polys
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].num_textured_rectangles,2);
        for k:=1 to mesh_list.meshes[mesh_list.num_meshes].num_textured_rectangles do
        begin
            if l.tipo<vtr4 then xblockread(p,mesh_list.meshes[mesh_list.num_meshes].textured_rectangles[k-1], 10 ) else
                                xblockread(p,mesh_list.meshes[mesh_list.num_meshes].textured_rectangles[k-1], 12 );
        end;

        //textured triangular polys
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].num_textured_triangles,2);
        for k:=1 to mesh_list.meshes[mesh_list.num_meshes].num_textured_triangles do
        begin
            if l.tipo<vtr4 then xblockread(p,mesh_list.meshes[mesh_list.num_meshes].textured_triangles[k-1], 8 ) else
                                xblockread(p,mesh_list.meshes[mesh_list.num_meshes].textured_triangles[k-1], 10 );
        end;


   mesh_list.meshes[mesh_list.num_meshes].num_colored_rectangles:=0;
   mesh_list.meshes[mesh_list.num_meshes].num_colored_triangles:=0;

   if l.tipo<vtr4 then
   begin
        //colored rectangular polys
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].num_colored_rectangles,2);


        for k:=1 to mesh_list.meshes[mesh_list.num_meshes].num_colored_rectangles do
        begin
            xblockread(p,mesh_list.meshes[mesh_list.num_meshes].colored_rectangles[k-1], 10 );
        end;

        //colored triangular polys
        xblockread(p,mesh_list.meshes[mesh_list.num_meshes].num_colored_triangles,2);
        for k:=1 to mesh_list.meshes[mesh_list.num_meshes].num_colored_triangles do
        begin
            xblockread(p,mesh_list.meshes[mesh_list.num_meshes].colored_triangles[k-1], 8 );
        end;

   end;//end if there is colored polys

        //update the max & min dimension

        update_min_max(mesh_list,mesh_list.num_meshes);

        mesh_list.num_meshes:=mesh_list.num_meshes+1;

        if ((p-starting) mod 4)<>0 then xblockread(p,dumy,2);

    end;//end read all mesh data.

//----build the direct mesh_pointer table.
setlength(mesh_list.mesh_pointers,l.num_meshpointers);
for k:=0 to l.num_Meshpointers-1 do
begin
    mesh_list.mesh_pointers[k]:=find_mesh_pointer(mesh_list,l.meshpointers[k]);
end;

end;
//---------------------
procedure update_mesh_data(var mesh_list:tmesh_list; var L:ttrlevel);

var
p:longint;
k,k2:integer;
data_end:longint;
dumy:longint;
starting:longint;
data:pointer;
data_size:longint;
chunk_start:longint;
auxword:smallint;
directmesh:integer;

begin
//--- Primero hay que calcular el nuevo tamaño del meshwords y
//actualizar el rawdata offset de cada mesh.

    p:=0;
    for k:=0 to mesh_list.num_meshes-1 do
    begin
        starting:=p;
        mesh_list.meshes[k].mesh_pointer:=p;
        //sphere colision
        p:=p+10;
        //vertices tables
        p:=p+2+(mesh_list.meshes[k].num_vertices*6);
        //normals
        p:=p+2; //num normals;
        if mesh_list.meshes[k].num_normals>=0 then
           p:=p+(mesh_list.meshes[k].num_normals*6) else
           p:=p+(abs(mesh_list.meshes[k].num_normals)*2);

        //textured rectangular polys
        p:=p+2;
        if l.tipo<vtr4 then p:=p+(mesh_list.meshes[k].num_textured_rectangles*10) else
                            p:=p+(mesh_list.meshes[k].num_textured_rectangles*12);

        //textured triangular polys
        p:=p+2;
        if l.tipo<vtr4 then p:=p+(mesh_list.meshes[k].num_textured_triangles*8) else
                            p:=p+(mesh_list.meshes[k].num_textured_triangles*10);

        if l.tipo<vtr4 then
        begin
          //colored rectangular polys
          p:=p+2;
          p:=p+(mesh_list.meshes[k].num_colored_rectangles*10);
          //textured triangular polys
          p:=p+2;
          p:=p+(mesh_list.meshes[k].num_colored_triangles*8);
        end;//si we have colored polys.
        //dumy word if needed
        if ((p-starting) mod 4)<>0 then p:=p+2;
    end;//end all meshes.

//now resize meshwords.
l.num_meshwords:=p div 2;

//-------------------------------------
// now just put the raw data.

    data:=@l.meshwords[0];
    p:=longint(data);

    for k:=1 to mesh_list.num_meshes do
    begin
        starting:=p;
        //sphere colision
        xblockwrite(p,mesh_list.meshes[k-1].sphere_x,2);
        xblockwrite(p,mesh_list.meshes[k-1].sphere_y,2);
        xblockwrite(p,mesh_list.meshes[k-1].sphere_z,2);
        xblockwrite(p,mesh_list.meshes[k-1].sphere_radius,4);

        //vertices tables
        xblockwrite(p,mesh_list.meshes[k-1].num_vertices,2);
        xblockwrite(p,mesh_list.meshes[k-1].vertices, mesh_list.meshes[k-1].num_vertices*6 );
        //normals
        xblockwrite(p,mesh_list.meshes[k-1].num_normals,2);

        if mesh_list.meshes[k-1].num_normals>=0 then
           xblockwrite(p,mesh_list.meshes[k-1].normals, mesh_list.meshes[k-1].num_normals*6 ) else
           xblockwrite(p,mesh_list.meshes[k-1].lights, abs(mesh_list.meshes[k-1].num_normals)*2 );

        //textured rectangular polys
        xblockwrite(p,mesh_list.meshes[k-1].num_textured_rectangles,2);
        for k2:=1 to mesh_list.meshes[k-1].num_textured_rectangles do
        begin
            if l.tipo<vtr4 then xblockwrite(p,mesh_list.meshes[k-1].textured_rectangles[k2-1], 10 ) else
                                xblockwrite(p,mesh_list.meshes[k-1].textured_rectangles[k2-1], 12 );
        end;

        //textured triangular polys
        xblockwrite(p,mesh_list.meshes[k-1].num_textured_triangles,2);
        for k2:=1 to mesh_list.meshes[k-1].num_textured_triangles do
        begin
            if l.tipo<vtr4 then xblockwrite(p,mesh_list.meshes[k-1].textured_triangles[k2-1], 8 ) else
                                xblockwrite(p,mesh_list.meshes[k-1].textured_triangles[k2-1], 10 );
        end;


   if l.tipo<vtr4 then
   begin
        //colored rectangular polys
        xblockwrite(p,mesh_list.meshes[k-1].num_colored_rectangles,2);


        for k2:=1 to mesh_list.meshes[k-1].num_colored_rectangles do
        begin
            xblockwrite(p,mesh_list.meshes[k-1].colored_rectangles[k2-1], 10 );
        end;

        //colored triangular polys
        xblockwrite(p,mesh_list.meshes[k-1].num_colored_triangles,2);
        for k2:=1 to mesh_list.meshes[k-1].num_colored_triangles do
        begin
            xblockwrite(p,mesh_list.meshes[k-1].colored_triangles[k2-1], 8 );
        end;

   end;//end if there is colored polys

     if ((p-starting) mod 4)<>0 then xblockwrite(p,dumy,2);

  end;//end write all mesh data.

//now let's update the mshpointers at the level.
for k:=0 to l.num_Meshpointers-1 do
begin
    directmesh:=mesh_list.mesh_pointers[k];
    l.Meshpointers[k]:=mesh_list.meshes[directmesh].mesh_pointer;
end;

end;
//---------------------




//-------------
procedure Draw_mesh(var m:tmesh_list; var L:ttrlevel; nmesh:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false);
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4,
xpos,zpos:glfloat;
room:integer;
texture:word;
mx1,my1,mx2,my2,mx3,my3,mx4,my4:integer;
escala:real;
r,g,b:byte;
begin
  if (nmesh>(m.num_meshes-1)) or (nmesh<0) then exit;

  //fix the escala
  escala:=100 / scale;

if not centered then
begin
//rotate y scalar de world cordinates for this mesh.
  glpushmatrix;
  gltranslatef(x,y,z);
  GlRotatef(angle,0,1,0);
  x:=0;y:=0;z:=0;
end;
//---------------

//center the model in the disired conrdinate.

if centered then
begin
  x:=m.meshes[nmesh].despx;
  y:=m.meshes[nmesh].despy;
  z:=m.meshes[nmesh].despz;
end;

  xstart_buffer;

  //draw rectangles
  for k:=0 to m.meshes[nmesh].num_textured_rectangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].z;

       x4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].x;
       y4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].y;
       z4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;
       x4:=(x4/escala);y4:=(y4/escala)*-1;z4:=(z4/escala)*-1;

    texture:=m.meshes[nmesh].textured_rectangles[k].texture and $7fff;
    xglbindtexture(gl_texture_2d,texture+1);
    xset_perspective_correct(perspective_correct);

    //get the texture map
    if l.textures[texture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[texture].my1<=1 then my1:=0 else my1:=1;
    if l.textures[texture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[texture].my2<=1 then my2:=0 else my2:=1;
    if l.textures[texture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[texture].my3<=1 then my3:=0 else my3:=1;
    if l.textures[texture].mx4<=1 then mx4:=0 else mx4:=1;if l.textures[texture].my4<=1 then my4:=0 else my4:=1;

    xglBegin(GL_quads);
            xgltexcoord2f(mx1,my1);
            xglVertex3f(x1+x,y1+y,z1+z);

            xgltexcoord2f(mx2,my2);
            xglVertex3f(x2+x,y2+y,z2+z);

            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

            xgltexcoord2f(mx4,my4);
            xglVertex3f(x4+x,y4+y,z4+z);

   xglEnd;

 end;//end all rectangles this mesh


  //draw triangles
  for k:=0 to m.meshes[nmesh].num_textured_triangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;


    texture:=m.meshes[nmesh].textured_triangles[k].texture and $7fff;
    xglbindtexture(gl_texture_2d,texture+1);
    xset_perspective_correct(perspective_correct);

    //get the texture map
    if l.textures[texture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[texture].my1<=1 then my1:=0 else my1:=1;
    if l.textures[texture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[texture].my2<=1 then my2:=0 else my2:=1;
    if l.textures[texture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[texture].my3<=1 then my3:=0 else my3:=1;

   //for some reason i am having problems with ATIs cards where
   //rendering tringles in a displaylist they are colored with the last
   //previus color used!!, so i am going to draw triangles using rectangles.

  xglBegin(GL_quads);
            xgltexcoord2f(mx1,my1);
            xglVertex3f(x1+x,y1+y,z1+z);
            xgltexcoord2f(mx2,my2);
            xglVertex3f(x2+x,y2+y,z2+z);
            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

    xglEnd;

 end;//end all triangles this mesh

//colored faces

if l.tipo<vtr4 then
begin
  xglBegin(GL_quads); //no need to change textures so all can be
                     //in one glbegin glend.
  //draw rectangles
  for k:=0 to m.meshes[nmesh].num_colored_rectangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].z;

       x4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].x;
       y4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].y;
       z4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].z;


       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;
       x4:=(x4/escala);y4:=(y4/escala)*-1;z4:=(z4/escala)*-1;

            xglVertex3f(x1+x,y1+y,z1+z);
            xglVertex3f(x2+x,y2+y,z2+z);
            xglVertex3f(x3+x,y3+y,z3+z);
            xglVertex3f(x4+x,y4+y,z4+z);

 end;//end all rectangles this mesh


  //draw triangles
  for k:=0 to m.meshes[nmesh].num_colored_triangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;


            xglVertex3f(x1+x,y1+y,z1+z);
            xglVertex3f(x2+x,y2+y,z2+z);
            xglVertex3f(x3+x,y3+y,z3+z);
            xglVertex3f(x3+x,y3+y,z3+z);

 end;//end all triangles this mesh
 xglend;

end; //end si version < tr4

  //draw the buffer;
  xend_buffer;

if not centered then glpopmatrix;


end;

//---------------------------

procedure Draw_mesh2(var m:tmesh_list; var L:ttrlevel; nmesh:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false);
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4,
xpos,zpos:glfloat;
room:integer;
texture:word;
mx1,my1,mx2,my2,mx3,my3,mx4,my4:integer;
escala:real;
r,g,b:byte;
name:cardinal;
begin
  if (nmesh>(m.num_meshes-1)) or (nmesh<0) then exit;

  //fix the escala
  escala:=100 / scale;

if not centered then
begin
//rotate y scalar de world cordinates for this mesh.
  glpushmatrix;
  gltranslatef(x,y,z);
  GlRotatef(angle,0,1,0);
  x:=0;y:=0;z:=0;
end;
//---------------

//center the model in the disired conrdinate.

if centered then
begin
  x:=m.meshes[nmesh].despx;
  y:=m.meshes[nmesh].despy;
  z:=m.meshes[nmesh].despz;
end;

  xstart_buffer;

  //draw rectangles
  for k:=0 to m.meshes[nmesh].num_textured_rectangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].z;

       x4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].x;
       y4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].y;
       z4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;
       x4:=(x4/escala);y4:=(y4/escala)*-1;z4:=(z4/escala)*-1;


    //get texture id
    texture:=m.meshes[nmesh].textured_rectangles[k].texture and $7fff;
    case m.draw_mode of
         1:begin xglbindtexture(gl_texture_2d, m.solid_texture);xset_perspective_correct(perspective_correct);end; //solid mode
         2:begin xglbindtexture(gl_texture_2d,texture+1);xset_perspective_correct(perspective_correct);end; //texture mode
    end;

    //get the texture map
    if l.textures[texture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[texture].my1<=1 then my1:=0 else my1:=1;
    if l.textures[texture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[texture].my2<=1 then my2:=0 else my2:=1;
    if l.textures[texture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[texture].my3<=1 then my3:=0 else my3:=1;
    if l.textures[texture].mx4<=1 then mx4:=0 else mx4:=1;if l.textures[texture].my4<=1 then my4:=0 else my4:=1;

    //put name
    tlongword(name).word1:=nmesh+1;
    tlongword(name).word2:=k;
    xGlloadname(name);

    xglBegin(GL_quads);
            xgltexcoord2f(mx1,my1);
            xglVertex3f(x1+x,y1+y,z1+z);

            xgltexcoord2f(mx2,my2);
            xglVertex3f(x2+x,y2+y,z2+z);

            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

            xgltexcoord2f(mx4,my4);
            xglVertex3f(x4+x,y4+y,z4+z);

   xglEnd;

 end;//end all rectangles this mesh


  //draw triangles
  for k:=0 to m.meshes[nmesh].num_textured_triangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;


    texture:=m.meshes[nmesh].textured_triangles[k].texture and $7fff;
    case m.draw_mode of
         1:begin xglbindtexture(gl_texture_2d, m.solid_texture);xset_perspective_correct(perspective_correct);end; //solid mode
         2:begin xglbindtexture(gl_texture_2d,texture+1);xset_perspective_correct(perspective_correct);end; //texture mode
    end;

    //get the texture map
    if l.textures[texture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[texture].my1<=1 then my1:=0 else my1:=1;
    if l.textures[texture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[texture].my2<=1 then my2:=0 else my2:=1;
    if l.textures[texture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[texture].my3<=1 then my3:=0 else my3:=1;

   //for some reason i am having problems with ATIs cards where
   //rendering tringles in a displaylist they are colored with the last
   //previus color used!!, so i am going to draw triangles using rectangles.


    //put name
  tlongword(name).word1:=nmesh+1;
  tlongword(name).word2:=k+1000;
  xGlloadname(name);

  xglBegin(GL_quads);
            xgltexcoord2f(mx1,my1);
            xglVertex3f(x1+x,y1+y,z1+z);
            xgltexcoord2f(mx2,my2);
            xglVertex3f(x2+x,y2+y,z2+z);
            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

    xglEnd;

 end;//end all triangles this mesh


xend_buffer; //draw buffer;

if l.tipo<vtr4 then
begin

//colored faces
//becouse i can't to draw colored colors with teh right color, i am going to
//draw it all in red color, just to let the user known that which are colored faces.

GlPolygonMode(GL_FRONT_AND_BACK,GL_fill);
GLdisable(gl_texture_2d);
glshademodel(gl_flat);

xstart_buffer;

xglcolor3ub(255,0,0);

  //draw rectangles
  for k:=0 to m.meshes[nmesh].num_colored_rectangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].z;

       x4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].x;
       y4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].y;
       z4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].z;


       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;
       x4:=(x4/escala);y4:=(y4/escala)*-1;z4:=(z4/escala)*-1;

     //put name
     tlongword(name).word1:=nmesh+1;
     tlongword(name).word2:=k+2000;
     xGlloadname(name);

     xglBegin(GL_quads);
            xglVertex3f(x1+x,y1+y,z1+z);
            xglVertex3f(x2+x,y2+y,z2+z);
            xglVertex3f(x3+x,y3+y,z3+z);
            xglVertex3f(x4+x,y4+y,z4+z);
      xglend;
 end;//end all rectangles this mesh


  //draw triangles
  for k:=0 to m.meshes[nmesh].num_colored_triangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;

     //put name
     tlongword(name).word1:=nmesh+1;
     tlongword(name).word2:=k+3000;
     xGlloadname(name);

     xglBegin(GL_quads);
            xglVertex3f(x1+x,y1+y,z1+z);
            xglVertex3f(x2+x,y2+y,z2+z);
            xglVertex3f(x3+x,y3+y,z3+z);
            xglVertex3f(x3+x,y3+y,z3+z);
     xglend;

 end;//end all triangles this mesh

//back to original state

//draw the buffer;
  xend_buffer;

if m.draw_mode=0 then
begin
 GlPolygonMode(GL_FRONT_AND_BACK,GL_line);
 glcolor3ub(m.r,m.g,m.b);
end
else
begin
 GlPolygonMode(GL_FRONT_AND_BACK,GL_fill);
 GLenable(gl_texture_2d);
 glcolor3ub(255,255,255);
end;

end; //end si version < tr4


if not centered then glpopmatrix;


end;


procedure Draw_mesh3(var m:tmesh_list; var l:ttrlevel; nmesh:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false; pickable:boolean=true); //render with lights.
var
k:integer;
x1,y1,z1,
x2,y2,z2,
x3,y3,z3,
x4,y4,z4,
xpos,zpos:glfloat;
room:integer;
texture:word;
mx1,my1,mx2,my2,mx3,my3,mx4,my4:integer;
escala:real;
r,g,b:byte;
light1,light2,light3,light4:smallint;
color1,color2,color3,color4:byte;

name:cardinal;
begin
  if (nmesh>(m.num_meshes-1)) or (nmesh<0) then exit;

  IF  m.meshes[nmesh].num_normals>=0 then
  begin
     if pickable then Draw_mesh2(m,l,nmesh,x,y,z,angle,scale,centered,perspective_correct)
                 else Draw_mesh(m,l,nmesh,x,y,z,angle,scale,centered,perspective_correct);
    exit;
  end;

  //fix the escala
  escala:=100 / scale;

if not centered then
begin
//rotate y scalar de world cordinates for this mesh.
  glpushmatrix;
  gltranslatef(x,y,z);
  GlRotatef(angle,0,1,0);
  x:=0;y:=0;z:=0;
end;
//---------------

//center the model in the disired conrdinate.

if centered then
begin
  x:=m.meshes[nmesh].despx;
  y:=m.meshes[nmesh].despy;
  z:=m.meshes[nmesh].despz;
end;

  xstart_buffer;

  //draw rectangles
  for k:=0 to m.meshes[nmesh].num_textured_rectangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p1].z;
       light1:=m.meshes[nmesh].lights[ m.meshes[nmesh].textured_rectangles[k].p1];

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p2].z;
       light2:=m.meshes[nmesh].lights[ m.meshes[nmesh].textured_rectangles[k].p2];

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p3].z;
       light3:=m.meshes[nmesh].lights[ m.meshes[nmesh].textured_rectangles[k].p3];

       x4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].x;
       y4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].y;
       z4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_rectangles[k].p4].z;
       light4:=m.meshes[nmesh].lights[ m.meshes[nmesh].textured_rectangles[k].p4];

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;
       x4:=(x4/escala);y4:=(y4/escala)*-1;z4:=(z4/escala)*-1;

       //calc the color.
       if l.tipo<vtr3 then
       begin
           color1:=trunc(light1/128.498039);
           color2:=trunc(light2/128.498039);
           color3:=trunc(light3/128.498039);
           color4:=trunc(light4/128.498039);
       end //end version tr1,tr2
       else
       begin
          if light1>8191 then light1:=8191;if light2>8191 then light2:=8191;
          if light3>8191 then light3:=8191;if light4>8191 then light4:=8191;
           color1:=trunc(light1/32.121568);
           color2:=trunc(light2/32.121568);
           color3:=trunc(light3/32.121568);
           color4:=trunc(light4/32.121568);
       end;//end version tr3,tr4,tr5

       color1:=255-color1;color2:=255-color2;
       color3:=255-color3;color4:=255-color4;

    //get texture id
    texture:=m.meshes[nmesh].textured_rectangles[k].texture and $7fff;
    case m.draw_mode of
         1:begin xglbindtexture(gl_texture_2d, m.solid_texture);xset_perspective_correct(perspective_correct);end; //solid mode
         2:begin xglbindtexture(gl_texture_2d,texture+1);xset_perspective_correct(perspective_correct);end; //texture mode
    end;

    //get the texture map
    if l.textures[texture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[texture].my1<=1 then my1:=0 else my1:=1;
    if l.textures[texture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[texture].my2<=1 then my2:=0 else my2:=1;
    if l.textures[texture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[texture].my3<=1 then my3:=0 else my3:=1;
    if l.textures[texture].mx4<=1 then mx4:=0 else mx4:=1;if l.textures[texture].my4<=1 then my4:=0 else my4:=1;

    //put name
    tlongword(name).word1:=nmesh+1;
    tlongword(name).word2:=k;
    if pickable then xGlloadname(name);

    xglBegin(GL_quads);
            xglcolor3ub(color1,color1,color1);
            xgltexcoord2f(mx1,my1);
            xglVertex3f(x1+x,y1+y,z1+z);

            xglcolor3ub(color2,color2,color2);
            xgltexcoord2f(mx2,my2);
            xglVertex3f(x2+x,y2+y,z2+z);

            xglcolor3ub(color3,color3,color3);
            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

            xglcolor3ub(color4,color4,color4);
            xgltexcoord2f(mx4,my4);
            xglVertex3f(x4+x,y4+y,z4+z);

   xglEnd;

 end;//end all rectangles this mesh


  //draw triangles
  for k:=0 to m.meshes[nmesh].num_textured_triangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p1].z;
       light1:=m.meshes[nmesh].lights[ m.meshes[nmesh].textured_triangles[k].p1];

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p2].z;
       light2:=m.meshes[nmesh].lights[ m.meshes[nmesh].textured_triangles[k].p2];

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].textured_triangles[k].p3].z;
       light3:=m.meshes[nmesh].lights[ m.meshes[nmesh].textured_triangles[k].p3];

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;


       //calc the color.
       if l.tipo<vtr3 then
       begin
           color1:=trunc(light1/128.498039);
           color2:=trunc(light2/128.498039);
           color3:=trunc(light3/128.498039);
       end //end version tr1,tr2
       else
       begin
          if light1>8191 then light1:=8191;if light2>8191 then light2:=8191;
          if light3>8191 then light3:=8191;
           color1:=trunc(light1/32.121568);
           color2:=trunc(light2/32.121568);
           color3:=trunc(light3/32.121568);
       end;//end version tr3,tr4,tr5

       color1:=255-color1;color2:=255-color2;
       color3:=255-color3;


    texture:=m.meshes[nmesh].textured_triangles[k].texture and $7fff;
    case m.draw_mode of
         1:begin xglbindtexture(gl_texture_2d, m.solid_texture);xset_perspective_correct(perspective_correct);end; //solid mode
         2:begin xglbindtexture(gl_texture_2d,texture+1);xset_perspective_correct(perspective_correct);end; //texture mode
    end;

    //get the texture map
    if l.textures[texture].mx1<=1 then mx1:=0 else mx1:=1;if l.textures[texture].my1<=1 then my1:=0 else my1:=1;
    if l.textures[texture].mx2<=1 then mx2:=0 else mx2:=1;if l.textures[texture].my2<=1 then my2:=0 else my2:=1;
    if l.textures[texture].mx3<=1 then mx3:=0 else mx3:=1;if l.textures[texture].my3<=1 then my3:=0 else my3:=1;

   //for some reason i am having problems with ATIs cards where
   //rendering tringles in a displaylist they are colored with the last
   //previus color used!!, so i am going to draw triangles using rectangles.


    //put name
  tlongword(name).word1:=nmesh+1;
  tlongword(name).word2:=k+1000;
  if pickable then xGlloadname(name);

  xglBegin(GL_quads);
            xglcolor3ub(color1,color1,color1);
            xgltexcoord2f(mx1,my1);
            xglVertex3f(x1+x,y1+y,z1+z);

            xglcolor3ub(color2,color2,color2);
            xgltexcoord2f(mx2,my2);
            xglVertex3f(x2+x,y2+y,z2+z);

            xglcolor3ub(color3,color3,color3);
            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

            xglcolor3ub(color3,color3,color3);
            xgltexcoord2f(mx3,my3);
            xglVertex3f(x3+x,y3+y,z3+z);

    xglEnd;

 end;//end all triangles this mesh


xend_buffer; //draw buffer;

if l.tipo<vtr4 then
begin

//colored faces
//becouse i can't to draw colored colors with teh right color, i am going to
//draw it all in red color, just to let the user known that which are colored faces.

GlPolygonMode(GL_FRONT_AND_BACK,GL_fill);
GLdisable(gl_texture_2d);
glshademodel(gl_flat);

xstart_buffer;

xglcolor3ub(255,0,0);

  //draw rectangles
  for k:=0 to m.meshes[nmesh].num_colored_rectangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p3].z;

       x4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].x;
       y4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].y;
       z4:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_rectangles[k].p4].z;


       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;
       x4:=(x4/escala);y4:=(y4/escala)*-1;z4:=(z4/escala)*-1;

     //put name
     tlongword(name).word1:=nmesh+1;
     tlongword(name).word2:=k+2000;
     if pickable then xGlloadname(name);

     xglBegin(GL_quads);
            xglVertex3f(x1+x,y1+y,z1+z);
            xglVertex3f(x2+x,y2+y,z2+z);
            xglVertex3f(x3+x,y3+y,z3+z);
            xglVertex3f(x4+x,y4+y,z4+z);
      xglend;
 end;//end all rectangles this mesh


  //draw triangles
  for k:=0 to m.meshes[nmesh].num_colored_triangles-1 do
  begin
     //draw the rectangle
     //sacar las cordenadas;
       x1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].x;
       y1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].y;
       z1:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p1].z;

       x2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].x;
       y2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].y;
       z2:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p2].z;

       x3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].x;
       y3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].y;
       z3:=m.meshes[nmesh].vertices[ m.meshes[nmesh].colored_triangles[k].p3].z;

       x1:=(x1/escala);y1:=(y1/escala)*-1;z1:=(z1/escala)*-1;
       x2:=(x2/escala);y2:=(y2/escala)*-1;z2:=(z2/escala)*-1;
       x3:=(x3/escala);y3:=(y3/escala)*-1;z3:=(z3/escala)*-1;

     //put name
     tlongword(name).word1:=nmesh+1;
     tlongword(name).word2:=k+3000;
     if pickable then xGlloadname(name);

     xglBegin(GL_quads);
            xglVertex3f(x1+x,y1+y,z1+z);
            xglVertex3f(x2+x,y2+y,z2+z);
            xglVertex3f(x3+x,y3+y,z3+z);
            xglVertex3f(x3+x,y3+y,z3+z);
     xglend;

 end;//end all triangles this mesh

//back to original state

//draw the buffer;
  xend_buffer;

if m.draw_mode=0 then
begin
 GlPolygonMode(GL_FRONT_AND_BACK,GL_line);
 glcolor3ub(m.r,m.g,m.b);
end
else
begin
 GlPolygonMode(GL_FRONT_AND_BACK,GL_fill);
 GLenable(gl_texture_2d);
 glcolor3ub(255,255,255);
end;

glshademodel(gl_smooth);

end; //end si version < tr4


if not centered then glpopmatrix;


end; //end procedure


//---------------------------
//function for know if the texture is triangular

function IsTriangular(var l:ttrlevel; num:integer):boolean;
begin
   istriangular:=((l.textures[num].x4=0) and (l.textures[num].y4=0)) or  ( (l.textures[num].mx4=0) and (l.textures[num].my4=0));
end;

procedure Draw_movable(var m:tmesh_list; var l:ttrlevel; movable:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false; rx_adjust:real=0;ry_adjust:real=0;rz_adjust:real=0);//para el editor
var
k:integer;
num_meshes,mesh_p,mesh_tree:integer;
kk:integer;
flag:integer;
ix,iy,iz:real;
cx,cy,cz:real;
x_aligned,y_aligned,z_aligned:real;
frameofset:cardinal;

bx: array [1..5] of real;
by: array [1..5] of real;
bz: array [1..5] of real;
p:integer;
escala:real;

procedure vpush;
begin
    p:=p+1;
    if p>5 then p:=5;
    bx[p]:=cx;
    by[p]:=cy;
    bz[p]:=cz;
end;

procedure vpop;
begin
   cx:=bx[p];
   cy:=by[p];
   cz:=bz[p];

   p:=p-1;
   if p=0 then p:=1;
end;


begin
    p:=0;
    fillchar(bx[1],20,0);
    fillchar(by[1],20,0);
    fillchar(bz[1],20,0);

    if L.valido<>'Tpascal' then exit;
    if (movable+1)>l.num_Movables then exit;

    escala:=100/scale;

    Num_meshes:=l.movables[movable].nummeshes;

    mesh_p:=l.movables[movable].startmesh;
    kk:=m.mesh_pointers[mesh_p];
    mesh_tree:=l.movables[movable].meshtree-4;

    //aligment of this movable over the floor
    frameofset:=l.movables[movable].frameoffset div 2;
    x_aligned:=l.frames[frameofset+6]/escala;
    y_aligned:=(l.frames[frameofset+7]*-1)/escala;
    z_aligned:=(l.frames[frameofset+8]*-1)/escala;

    cx:=0;cy:=0;cz:=0;

    //before draw move the world coordinates.
    glpushmatrix;
    gltranslatef(x,y,z);
    // now do rotate with rotate adjustment.
    GlRotatef(rx_adjust,1,0,0); //x
    GlRotatef(angle+ry_adjust,0,1,0); //y
    GlRotatef(rz_adjust,0,0,1); //z

    for k:=1 to num_meshes do
    begin

       if k=1 then
       begin
          if not centered then
          begin cx:=x_aligned;cy:=y_aligned;cz:=z_aligned;end;
        end
        else
        begin
           flag:=l.bones2[mesh_tree];
           ix  :=(l.bones2[mesh_tree+1])/escala;
           iy  :=(l.bones2[mesh_tree+2]*-1)/escala;
           iz  :=(l.bones2[mesh_tree+3]*-1)/escala;
           if (flag and 1)=1 then vpop;
           if (flag and 2)=2 then vpush;

            cx:=cx+ix;cy:=cy+iy;cz:=cz+iz;

        end;

        draw_mesh(  m,l,kk,cx,cy,cz, 0,scale,false,perspective_correct);

        mesh_p:=mesh_p+1;
        kk:=m.mesh_pointers[mesh_p];
        mesh_tree:=mesh_tree+4;
    end;

    glpopmatrix;

end;

//-------------------

procedure Draw_movable2(var m:tmesh_list; var l:ttrlevel; movable:integer; x,y,z:real; angle:word; scale:glfloat=1; centered:boolean=false; perspective_correct:boolean=false);
var
k:integer;
num_meshes,mesh_p,mesh_tree:integer;
kk:integer;
flag:integer;
ix,iy,iz:real;
cx,cy,cz:real;
x_aligned,y_aligned,z_aligned:real;
frameofset:cardinal;

bx: array [1..5] of real;
by: array [1..5] of real;
bz: array [1..5] of real;
p:integer;
escala:real;

procedure vpush;
begin
    p:=p+1;
    if p>5 then p:=5;
    bx[p]:=cx;
    by[p]:=cy;
    bz[p]:=cz;
end;

procedure vpop;
begin
   cx:=bx[p];
   cy:=by[p];
   cz:=bz[p];

   p:=p-1;
   if p=0 then p:=1;
end;


begin
    p:=0;
    fillchar(bx[1],20,0);
    fillchar(by[1],20,0);
    fillchar(bz[1],20,0);

    if L.valido<>'Tpascal' then exit;
    if (movable+1)>l.num_Movables then exit;

    escala:=100/scale;

    Num_meshes:=l.movables[movable].nummeshes;

    mesh_p:=l.movables[movable].startmesh;
    kk:=m.mesh_pointers[mesh_p];
    mesh_tree:=l.movables[movable].meshtree-4;

    //aligment of this movable over the floor
    frameofset:=l.movables[movable].frameoffset div 2;
    x_aligned:=l.frames[frameofset+6]/escala;
    y_aligned:=(l.frames[frameofset+7]*-1)/escala;
    z_aligned:=(l.frames[frameofset+8]*-1)/escala;

    cx:=0;cy:=0;cz:=0;

    //before draw move the world coordinates.
    glpushmatrix;
    gltranslatef(x,y,z);
    // now do rotate
    GlRotatef(angle,0,1,0);


    for k:=1 to num_meshes do
    begin

       if k=1 then
       begin
          if not centered then
          begin cx:=x_aligned;cy:=y_aligned;cz:=z_aligned;end;
        end
        else
        begin
           flag:=l.bones2[mesh_tree];
           ix  :=(l.bones2[mesh_tree+1])/escala;
           iy  :=(l.bones2[mesh_tree+2]*-1)/escala;
           iz  :=(l.bones2[mesh_tree+3]*-1)/escala;
           if (flag and 1)=1 then vpop;
           if (flag and 2)=2 then vpush;

            cx:=cx+ix;cy:=cy+iy;cz:=cz+iz;

        end;

        draw_mesh2(  m,l,kk,cx,cy,cz, 0,scale,false,perspective_correct);

        mesh_p:=mesh_p+1;
        kk:=m.mesh_pointers[mesh_p];
        mesh_tree:=mesh_tree+4;
    end;

    glpopmatrix;

end;

//------------------
procedure get_text_coord(var l:ttrlevel; num:integer; var rx1:integer; var ry1:integer; var rx2:integer; var ry2:integer);
var
  x1,x2,x3,x4,y1,y2,y3,y4:integer;
begin
  x1:=l.Textures[num].x1; y1:=l.Textures[num].y1;
  x2:=l.Textures[num].x2; y2:=l.Textures[num].y2;
  x3:=l.Textures[num].x3; y3:=l.Textures[num].y3;
  x4:=l.Textures[num].x4; y4:=l.Textures[num].y3;

  if istriangular(l,num) then  begin x4:=x3;y4:=y3;end;
  rx1:=minintvalue([x1,x2,x3,x4]);
  ry1:=minintvalue([y1,y2,y3,y4]);

  rx2:=maxintvalue([x1,x2,x3,x4]);
  ry2:=maxintvalue([y1,y2,y3,y4]);

end;

//calc Tomb Raider Normals
Procedure Calc_TRNormals(x1,y1,z1,
                       x2,y2,z2,
                       x3,y3,z3:glfloat;
                       var nx:glfloat;
                       var ny:glfloat;
                       var nz:glfloat);

var
vec1_x,vec1_y,vec1_z:real;
vec2_x,vec2_y,vec2_z:real;
k:integer;
leng:real;
begin


       //calc vectors
       vec1_x := x2 - x1;
       vec1_y := y2 - y1;
       vec1_z := z2 - z1;
       vec2_x := x3 - x1;
       vec2_y := y3 - y1;
       vec2_z := z3 - z1;

       nx := (vec1_y*vec2_z) - (vec1_z*vec2_y);
       ny := (vec1_z*vec2_x) - (vec1_x*vec2_z);
       nz := (vec1_x*vec2_y) - (vec1_y*vec2_x);

      leng:=sqrt(nx*nx + ny*ny + nz*nz);
      if leng<>0 then
      begin
        nx:=nx/leng;
        ny:=ny/leng;
        nz:=nz/leng;
     end;

      nx:=nx*-16300;
      ny:=ny*-16300;
      nz:=nz*-16300;

end;


{*****************************************************}

end.

