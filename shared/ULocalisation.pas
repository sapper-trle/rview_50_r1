(*******************************************************************************
*                                                                              *
* TLocalisation - Localisation Form v1.3                                       *
* Copyright Somicronic 1999 - All rights reserved                              *
*                                                                              *
*******************************************************************************)

unit ULocalisation;

(*
		 Localise the captions (or assimilated text properties), short and long hints
   as well as TStrings like properties, depending on the component's tag value:
   tag >= 0 			: localise all known text properties
   -tag and 1 = 0	:	do not localise captions
   -tag and 2 = 0	:	do not localise hints
   -tag and 4 = 0	:	do not localise strings
*)

{$IFNDEF VER80}
  {$DEFINE Delphi2+}
  {$IFNDEF VER90}
    {$DEFINE Bcc1+}
    {$IFNDEF VER93}
      {$DEFINE Delphi3+}
      {$IFNDEF VER100}
        {$DEFINE Bcc3+}
        {$IFNDEF VER110}
          {$DEFINE Delphi4+}
          {$IFNDEF VER120}
            {$IFNDEF VER125}
              {$IFNDEF VER130}
              {$ENDIF VER130}
            {$ENDIF VER125}
          {$ENDIF VER120}
        {$ENDIF VER110}
      {$ENDIF VER100}
    {$ENDIF VER90}
  {$ENDIF VER93}
{$ENDIF VER80}

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ComCtrls,
  StdCtrls, TypInfo;

const
	DefLangFileSuffix = 'def';
	LanguageFileVersion: string[7] = 'LFv01.3';

	UnderlineChar = '&';
  TranslateNumbers = FALSE;              // ignore text properties consisting of a number
  MaxRecursDepth = 3;                    // max recursion depth

  // Allow dynamically copies of components, whose addresses are held in the
  // original components' tags
  // (e.g. menus may be dynamically copied from popup menus and inserted in the main menu)
	AllowComponentCopies = TRUE;
  // Lowest address possible for a component
  // (not crucial, just used to speed up the processing of tag values)
	LowestCompAddress = 1024;

	NbOfLanguages = 9;
  LangFileExt = '.lng';
  langFileSuffix: array [1..NbOfLanguages] of string
										= ( 'fr', 'uk', 'us', 'de', 'it', 'es', 'se', 'po', 'kr' );
	langFileCode: array [1..NbOfLanguages] of word
										= ( $040C, $0809, $0409, $0407, $0410, $080A, $041D, $0816, $0412 );


type
	TLangFileAvailable = array[1..NbOfLanguages] of boolean;
	TCompInfo = class;
	TFormInfo = class;
	TFormList = class;

	// String used as a caption or a hint by one or more components
	TItemString = class(TObject)
	private
		fText: ShortString;  			// the text
		fStrList: TList;					// list of all the components using the string
	public
		constructor Create;
		destructor Destroy; override;
		property Text: ShortString read fText;
		property StringList: TList read fStrList;
		procedure SetString( newTextString: string );
	end;

	TItem = record
  	itemString: TItemString;    // text
    posUnderCar: byte;          // position of underlined char
    new: boolean;               // new or already translated
  end;

	// Information about one component, or several identical components in case there
	// are several instances of the same window
	TCompInfo = class(TObject)
	private
		fComponent: TComponent;
		fCaptionItemStr,
		fShortHintItemStr,
		fLongHintItemStr: TItemString;	// pointers to item strings
		posUnderCar: integer;						// caption's underlined character
		fNewCapt, fNewSHint,
    fNewLHint: boolean; 						// flag indicating whether the text has been added
		fItemStringList: TList;					// list of items' strings (e.g. in list/combo boxes)
		fParentForm: TFormInfo;					// pointer to the parent form
	protected
		constructor Create( givenComponent: TComponent; givenParentForm: TFormInfo );
		destructor Destroy; override;
		procedure SetComponent( newPtrComponent: TComponent ); virtual;
    function GetNewFlag( index: integer ): boolean;
    procedure SetNewFlag( index: integer; new: boolean );
    function GetPosUnderlinedChar( index: integer ): integer;
    procedure SetPosUnderlinedChar( index, position: integer );
		function GetItemString( fieldIndex: integer ): TItemString;
		procedure SetItemString( fieldIndex: integer; itemStr: TItemString );
		function GetString( fieldIndex: integer ): ShortString;
		procedure SetString( fieldIndex: integer; itemField: ShortString );
		procedure NewStringElement;
		procedure AddString( fieldIndex: integer; itemField: string; stripUndChar: boolean );
		procedure AddNewString( fieldIndex: integer; itemField: string; stripUndChar: boolean );
    function GetNumberOfStrings: integer;
		function GetForm: boolean;
    function SetItemComponent( pComponent: TComponent ): boolean;
    function GetItemComponent: boolean;
		function GetOrSetMostComponents( bGetCtrl: boolean; pComponent: TComponent ): boolean;
	public
		itName, itClassName: ShortString;	// name of the component & its class
		function GetStringList: TList;
		procedure UpdateItem( pComponent: TComponent );
		procedure UpdateFormItems;
		procedure ChangeString( fieldIndex: integer; itemField: string;
    												update, stripUndChar: boolean );
		function BrowseChildComponents: boolean;
		property Component: TComponent read fComponent write SetComponent;
    property NewFlag[Index: Integer]: boolean read GetNewFlag write SetNewFlag;
    property PosUnderlinedChar[Index: Integer]: integer read GetPosUnderlinedChar write SetPosUnderlinedChar;
    property ItemString[index: Integer]: TItemString read GetItemString;
    property Strings[Index: Integer]: ShortString read GetString write SetString;
    property NumberOfStrings: integer read GetNumberOfStrings;
		property ParentForm: TFormInfo read fParentForm;
	end;

	// Information about a form, including a list of its components
	TFormInfo = class(TCompInfo)
	private
		fFormList: TFormList;							// pointer to the object string list
		fCompInfoList: TList;          		// list of all the components that it owns
	protected
		procedure SetComponent( newPtrComponent: TComponent ); override;
	public
		constructor Create( givenForm: TForm; givenFormList: TFormList );
		destructor Destroy; override;
		procedure ReferenceForm( form: TForm );
		function AddChild( fComponent: TComponent ): TCompInfo;		  // add a component
		procedure RemoveChild( pCompInfo: TCompInfo );							// remove a component
		function GetStringList: TList;
		procedure ShowFormComponents( TreeView: TTreeView );
		property CompList: TList read fCompInfoList;
	end;

	// List of all the application forms; includes a pointer to the global list of strings
	TFormList = class(TList)
	private
    fLanguageCode: Word;
		fStrList: TList;		// global list of all the strings in the application
    fTreeView: TTreeView;
		UpdatingTreeView: boolean;
  protected
    procedure SetTreeView( pTreeView: TTreeView );
    procedure EncodeString( var aString: ShortString );
    procedure DecodeString( var aString: ShortString );
	public
		constructor Create;
		destructor Destroy; override;
		procedure Empty;
    function ReadLanguageFile( fileName: string ): boolean;
    function WriteLanguageFile( fileName: string ): boolean;
		function AddForm( pForm: TForm ): TFormInfo;							// add a form
		procedure RemoveForm( pFormInfo: TFormInfo );							// remove a form
		procedure BrowseAppComponents;
		procedure UpdateAppComponents;
		procedure UpdateTreeView;
		procedure ShowAppComponents;
		function DeleteInvalidReferences( delForms: boolean ): boolean;
		function FindSameComp( pCompInfo: TCompInfo ): TCompInfo;
		function IsCompValid( pCompInfo: TCompInfo ): boolean;
    property LanguageCode: Word read fLanguageCode write fLanguageCode;
		property StringList: TList read fStrList;
    property TreeView: TTreeView read fTreeView write SetTreeView;
	end;

function StripUnderlineChar( var str: string ): integer;
function RetLanguageIndex( langCode: word ): integer;

implementation

var
  counter: integer;

const
  maxNberStrings = 5000;							// record limits in the localisation file
  maxNberForms = 500;
  maxNberItems = 2000;
  maxNberComponentStrings = 1000;


(*	Language file format:

			LanguageFileVersion: string[7];		// "LFvxx.x"
			sLanguageCode: word;
			// applicationName: string[25];
			// applicationVersion: string[5];
			numberOfStrings: integer
				string1.length: byte;
				string1.text: string;						// coded
				string2...
			numberOfWindows: integer;
				Form1.name: string;
				Form1.className: string;
				Form1.indexCaption: string;
				Form1.numberOfComponents: integer;
					Component1.name: string;
					Component1.className: string;
					Component1.indexCaption: integer;				// first byte = position of underlined char
					Component1.indexShortHint: integer;			// 3 remaining bytes:
					Component1.indexLongHint: integer;      // index in the string list (0 = empty)
					numberOfStrings
						Component1.string1: string;
						Component1.string1.index: integer;
						Component1.string2...
					Component2...
				Form2...

*)

function RetLanguageIndex( langCode: word ): integer;
var
  i: integer;
begin
  i := 1;
  Result := -1;
  while( (Result = -1) and (i <= NbOfLanguages) ) do
    if( langFileCode[i] = langCode ) then
      Result := i
    else
      i := i + 1;
end;

procedure FixDisappearingSysMenu( form: TForm );
var
	Size: integer;
begin
  // Delphi bug? (disappearing system menu) fix
  if( form <> nil ) then
  begin
    if( (form.FormStyle = fsMDIChild) and (form.WindowState = wsMaximized) ) then
    begin
      SetWindowLong(form.Handle, GWL_STYLE,
                    GetWindowLong(form.Handle, GWL_STYLE) or WS_SYSMENU );
      Size := form.ClientWidth + (Longint(form.ClientHeight) shl 16);
      SendMessage(form.Handle, WM_SIZE, SIZE_RESTORED, Size);
      SendMessage(form.Handle, WM_SIZE, SIZE_MAXIMIZED, Size);
    end;
  end;
end;

function GetShortHintFrom( totalHint: string ): string;
begin
	{$IFDEF Delphi3+}
	Result := GetShortHint( totalHint )
	{$ELSE}
	Result := totalHint;
	{$ENDIF Delphi3+}
end;

function GetLongHintFrom( totalHint: string ): string;
var
	longHint: string;
begin
	{$IFDEF Delphi3+}
	longHint := GetLongHint( totalHint );
	if( longHint <> GetShortHint(totalHint) ) then
		Result := longHint
	else
		Result := '';
	{$ELSE}
	Result := '';
	{$ENDIF Delphi3+}
end;

function StripUnderlineChar( var str: string ): integer;
var
	i, len: integer;
begin
	Result := 0;
  len := Length(str);
  if( len > 1 ) then
  begin
    i := 1;
    while( (Result = 0) and (i < len) ) do
    begin
      if( str[i] = UnderlineChar ) then
        if( str[i+1] <> UnderlineChar ) then
          Result := i;
      i := i + 1;
    end;
    if( Result > 0 ) then
    	Delete( str, Result, 1 );
  end;
end;

// Get the caption of a form
function TCompInfo.GetForm: boolean;
var
	appForm: TForm;
begin
	appForm := TForm( Component );
	if(	appForm.caption <> '' ) then
	begin
		itName := appForm.name;
		AddNewString( -1, appForm.caption, TRUE );
		Result := TRUE;
	end
	else
		Result := FALSE;
end;

// Get or set the string elements of most components
function TCompInfo.GetOrSetMostComponents( bGetCtrl: boolean; pComponent: TComponent ): boolean;
var
  i, tag, depth: integer;
  pParentForm: TComponent;
  compntCopy: boolean;
	value: Extended;
  bCaption, bHint, bStrings: boolean;
	captionText, hintText, longHintText: ShortString;

  function GetOrSetEmbeddedStrings( bGetCtrl: boolean; pObject: TObject;
                                    typeInfo: PTypeInfo ): boolean;
  var
    i, j, nbStrings,
    nbProps, nbSecndProps, propIndex: integer;
    bLocalHint, textNumber: boolean;
    typesToGet: TTypeKinds;
    propInfo: PPropInfo;
    propName: ShortString;
    propString: string;
    secndTypeInfo: PTypeInfo;
    propValue: TObject;
    collItem: TCollectionItem;
    pList, pSecndList: PPropList;
  begin
    depth := depth + 1;
    Result := FALSE;
    typesToGet := [];
    bLocalHint := bHint and (depth = 1);
    if( bCaption or bStrings ) then
      Include( typesToGet, tkClass );
    if( bCaption or bLocalHint ) then
    	Include( typesToGet, tkLString );
    // Allocate the property list
    nbProps := GetTypeData(typeInfo)^.PropCount;
    if( (nbProps > 0) and (typesToGet <> [])) then
    begin
      GetMem( pList, nbProps * SizeOf(Pointer) );
      try
        nbProps := GetPropList( typeInfo, typesToGet, pList );
        i := 0;
        // Go through all the properties
        while( (bCaption or bLocalHint or bStrings) and (i < nbProps) ) do
        begin
          propInfo := pList^[i];
          if( propInfo^.PropType^.Kind = tkLString ) then
          begin
            propName := propInfo^.Name;
            // Look for a caption (or assimilated text property)
            if( bCaption ) then
            begin
              if( (CompareText(propName, 'Caption') = 0) or (Pos('Text', propName) > 0) ) then
              begin
                bCaption := FALSE;		// stop looking for captions
                if( bGetCtrl ) then
                begin
                  propString := GetStrProp( pObject, propInfo );
                  // If numbers are not allowed
                  if( not(TranslateNumbers) ) then
                    textNumber := TextToFloat( PChar(propString), value, fvExtended )
                  else
                    textNumber := FALSE;
                  if( not(textNumber) and (propString <> '') and (propString <> '-') ) then
                  begin
                    AddNewString( -1, propString, TRUE );
                    Result := TRUE;
                  end;
                end
                else
                begin
                  SetStrProp( pObject, propInfo, captionText );
                  Result := TRUE;
                end;
              end;
            end;
            // Look for a hint (short and long)
            if( bLocalHint ) then
            begin
              if( CompareText(propName, 'Hint') = 0 ) then
              begin
                bHint := FALSE;       // stop looking for a hint
                bLocalHint := FALSE;
                if( bGetCtrl ) then
                begin
                  propString := GetStrProp( pObject, propInfo );
                  AddNewString( -2, GetShortHintFrom(propString), TRUE );
                  AddNewString( -3, GetLongHintFrom(propString), TRUE );
                  if( not(Result) ) then
                    Result := ( propString <> '' );
                end
                else
                begin
                  SetStrProp( pObject, propInfo, hintText );
                  Result := TRUE;
                end;
              end;
            end;
          end
          else
          // Look for strings and subclasses which might have a text property
          begin
            propValue := TObject( GetOrdProp(pObject, propInfo) );
            if( propValue <> nil ) then
            begin
              // TStrings or TStringList or other derived types
              if( bStrings and (propValue is TStrings) ) then
              begin
                nbStrings := TStrings(propValue).Count;  
                if( not(bGetCtrl) ) then
                  if( nbStrings <> NumberOfStrings ) then
                    nbStrings := 0;
                if( nbStrings > 0 ) then
                begin
                  if( bGetCtrl ) then                    // get the strings
                    for j := 0 to nbStrings - 1 do
                      AddNewString( j, TStrings(propValue).Strings[j], TRUE )
                  else
                  begin                                  // set the strings
                    TStrings(propValue).BeginUpdate;
                    for j := 0 to nbStrings - 1 do
                      TStrings(propValue).Strings[j] := GetString(j);
                    TStrings(propValue).EndUpdate;
                  end;
                  Result := TRUE;
                  bStrings := FALSE;
                end;
              end
              else
              // TTreeNodes
              if( bStrings and (propValue is TTreeNodes) ) then
              begin
                nbStrings := TTreeNodes(propValue).Count;
                if( not(bGetCtrl) ) then
                  if( nbStrings <> NumberOfStrings ) then
                    nbStrings := 0;
                if( nbStrings > 0 ) then
                begin
                  if( bGetCtrl ) then                    // get the strings
                    for j := 0 to nbStrings - 1 do
                      AddNewString( j, TTreeNodes(propValue).Item[j].Text, TRUE )
                  else                                   // set the strings
                    for j := 0 to nbStrings - 1 do
                      TTreeNodes(propValue).Item[j].Text := GetString(j);
                  Result := TRUE;
                  bStrings := FALSE;
                end;
              end
              else
              // TCollection
              if( bStrings and (propValue is TCollection) ) then
              begin
                nbStrings := TCollection(propValue).Count;
                if( not(bGetCtrl) ) then
                  if( nbStrings <> NumberOfStrings ) then
                    nbStrings := 0;
                // If the number of collection items is not null
                if( nbStrings > 0 ) then
                begin
                  // Get the property list for the first collection item
                  secndTypeInfo := TCollection(propValue).Items[0].ClassInfo;
                  nbSecndProps := GetTypeData(secndTypeInfo)^.PropCount;
                  // If the number of properties is not null
                  if( nbSecndProps > 0 ) then
                  begin
                    // Allocate the property list
                    GetMem( pSecndList, nbSecndProps * SizeOf(Pointer) );
                    try
                      // And get the properties that hold long strings
                      nbSecndProps := GetPropList( secndTypeInfo, [tkLString], pSecndList );
                      j := 0;
                      propIndex := -1;
                      // Look for a property named 'Caption' or containing 'Text'
                      // and save its index in the list
                      while( (j < nbSecndProps) and (propIndex = -1) ) do
                        if( (CompareText(PPropInfo(pSecndList^[j])^.Name, 'Caption') = 0) or
                            (Pos('Text', PPropInfo(pSecndList^[j])^.Name) > 0) ) then
                          propIndex := j
                        else
                          j := j + 1;
                      // If such a property was found, retrieve its string for all
                      // collection items
                      if( propIndex <> -1 ) then
                      begin
                        for j := 0 to nbStrings - 1 do
                        begin
                          collItem := TCollection(propValue).Items[j];
                          secndTypeInfo := collItem.ClassInfo;
                          nbSecndProps := GetPropList( secndTypeInfo, [tkLString], pSecndList );
                          // Check that the index is below the upper limit
                          if( propIndex < nbSecndProps ) then
                          begin
                            if( bGetCtrl ) then
                            begin
                              propString := GetStrProp( collItem, pSecndList^[propIndex] );
                              AddNewString( j, propString, TRUE );
                            end
                            else
                              SetStrProp( collItem, pSecndList^[propIndex], GetString(j) );
                          end;
                        end;
                        Result := TRUE;
                        bStrings := FALSE;
                      end;
                    except
                    end;
                    FreeMem( pSecndList );
                  end;
                end;
              end
              else
                // Search for captions recursively through embedded properties
                if( bCaption and (depth < MaxRecursDepth) and not(propValue is TComponent)
                    and not(propValue is TGraphic) and not(propValue is TGraphicsObject)
                    {$IfDef Delphi4+}and not(propValue is TSizeConstraints){$EndIf} ) then
                  Result := GetOrSetEmbeddedStrings( bGetCtrl, propValue, propValue.ClassInfo )
                            or Result;
            end;
          end;
          i := i + 1;
        end;
      except
      end;
      FreeMem( pList );
    end;
    depth := depth - 1;
  end;

begin
  Result := FALSE;
  depth := 0;
  if( bGetCtrl ) then
	  pComponent := Component;
  if( pComponent <> nil ) then
  begin
    tag := pComponent.Tag;
    // Find out whether the component has a copy and if so, get its address (tag value)
  	if( AllowComponentCopies and bGetCtrl and (tag > LowestCompAddress) ) then
    begin
      pParentForm := ParentForm.Component;		// not checked...
      i := 0;
      compntCopy := FALSE;
      // Make sure such a copy really exists
      while( not(compntCopy) and (i < pParentForm.ComponentCount) ) do
        if( pParentForm.Components[i] = Pointer(pComponent.Tag) ) then
        	compntCopy := TRUE
        else
	        i := i + 1;
      if( compntCopy ) then
        tag := TComponent( pComponent.Tag ).Tag;
    end;
  	// Find out the types of data (caption, hint, strings) we are looking for
  	bCaption := ((tag >= 0) or (-tag and 1 = 0));
    bHint := ((tag >= 0) or (-tag and 2 = 0));
    bStrings := ((tag >= 0) or (-tag and 4 = 0));
    captionText := '';
    hintText := '';
    longHintText := '';
    // When setting the text, get the relevant strings from the pCompInfo object
		if( not(bGetCtrl) ) then
    begin
      if( bCaption ) then
      begin
	      captionText := GetString( -1 );
        bCaption := ( Length(captionText) > 0 );
      end;
      if( bHint ) then
      begin
        hintText := GetString( -2 );
        longHintText := GetString( -3 );
        if( longHintText <> '' ) then
          hintText := hintText + '|' + longHintText;
        bHint := ( Length(hintText) > 0 );
      end;
      if( bStrings ) then
        bStrings := ( NumberOfStrings > 0 );
    end;
    Result := GetOrSetEmbeddedStrings( bGetCtrl, pComponent, pComponent.ClassInfo );
  end;
end;

function TCompInfo.GetItemComponent: boolean;
begin
	Result := GetOrSetMostComponents( TRUE, nil );
end;

function TCompInfo.SetItemComponent( pComponent: TComponent ): boolean;
var
  index: integer;
  cbChange: TNotifyEvent;
begin
  // Save the current index of listboxes & comboboxes (deactivate their OnChange event)
  if( pComponent is TCustomComboBox ) then
  begin
    cbChange := TComboBox(pComponent).OnChange;
    TComboBox(pComponent).OnChange := nil;
    index := TCustomComboBox(pComponent).ItemIndex;
  end
  else if( pComponent is TCustomListBox ) then
    index := TCustomListBox(pComponent).ItemIndex
  else
    index := -1;
  // Change the component text property(ies)
	Result := GetOrSetMostComponents( FALSE, pComponent );
  // Assign the saved index to the listbox / combobox (restore its OnChange event)
  if( index <> - 1 ) then
  begin
    if( pComponent is TCustomComboBox ) then
    begin
      TCustomComboBox(pComponent).ItemIndex := index;
      TComboBox(pComponent).OnChange := cbChange;
    end
    else if( pComponent is TCustomListBox ) then
      TCustomListBox(pComponent).ItemIndex := index;
  end;
end;

// Change an item's caption/hint properties in the application dynamically
procedure TCompInfo.UpdateItem( pComponent: TComponent );
var
	i: integer;
  pParentForm: TForm;
  pComp: TComponent;
  componentOK, lookForCopy, copyFound: boolean;
begin
	if( pComponent <> nil ) then
  begin
  	copyFound := FALSE;
  	pParentForm := TForm( ParentForm.Component );
    if( pParentForm = pComponent ) then
	  	componentOK := TRUE
    else
    begin
	  	componentOK := FALSE;
      if( pParentForm <> nil ) then
      begin
        lookForCopy := AllowComponentCopies and (pComponent.Tag > LowestCompAddress);
      	// Search among the form components
        i := pParentForm.ComponentCount - 1;
        while( (i >= 0) and not(componentOK and (copyFound or not(lookForCopy))) ) do
        begin
          pComp := pParentForm.Components[i];
          if( pComp = pComponent ) then
            componentOK := TRUE
          else
            if( lookForCopy ) then
              if( pComp = Pointer(pComponent.Tag) ) then
                copyFound := TRUE;
          i := i - 1;
        end;
      end;
    end;
    if( componentOK ) then
    begin
    	SetItemComponent( pComponent );
      if( copyFound ) then
      	SetItemComponent( TComponent(pComponent.Tag) );
    end;
  end;
end;

// Update the text properties of all the components of all referenced forms
procedure TCompInfo.UpdateFormItems;
var
	i: integer;
	fComponent: TComponent;
	pFormInfo: TFormInfo;
	form: TForm;
begin
	pFormInfo := ParentForm;
	if( pFormInfo.Component <> nil ) then
		form := TForm( ParentForm.Component )
	else
		form := nil;
	// Find the forms with matching class names
	for i := 0 to Screen.FormCount - 1 do
	begin
		if( (Screen.Forms[i].ClassName = pFormInfo.itClassName) {and
				(Screen.Forms[i] <> form)} ) then
		begin
			if( self is TFormInfo ) then
      begin
				fComponent := Screen.Forms[i];
        FixDisappearingSysMenu( TForm(fComponent) );
        TForm(fComponent).Repaint;
      end
			else
				fComponent := Screen.Forms[i].FindComponent( itName );
			UpdateItem( fComponent );
		end;
	end;
end;


// Object holding a text that may be used by any form/component of the
// application as a caption or a hint or a string.
// Maintains a list of all the components that use it.
constructor TItemString.Create;
begin
	inherited Create;
	fStrList := TList.Create;		// create the list of components that use the string
end;

destructor TItemString.Destroy;
begin
	fStrList.Clear;            // remove all the pointers to the components
	fStrList.Free;             // delete the list
	inherited Destroy;
end;

// Change the text and modify all the concerned components
procedure TItemString.SetString( newTextString: string );
var
	i, j, posChar: integer;
	pCompInfo: TCompInfo;
  ScreenFormsList: TList;
  found: boolean;
begin
  posChar := StripUnderlineChar( newTextString );
	fText := newTextString;
  ScreenFormsList := TList.Create;
  for i := 0 to Screen.FormCount - 1 do
  	ScreenFormsList.Add( Screen.Forms[i] );
	for i := 0 to StringList.Count - 1 do
	begin
		pCompInfo := StringList.items[i];
    // Set the position of the underlined char for all the components
    j := -3;
    found := FALSE;
    while( not(found) and (j < pCompInfo.NumberOfStrings) ) do
    begin
    	found := ( pCompInfo.ItemString[j] = self );
      if( found ) then
		    pCompInfo.PosUnderlinedChar[j] := posChar
      else
      	j := j + 1;
    end;
    // Check that the parent form still exists
    if( ScreenFormsList.IndexOf(pCompInfo.ParentForm.Component) <> -1 ) then
			pCompInfo.UpdateItem( pCompInfo.Component );
	end;
  ScreenFormsList.Free;
end;

//
//	TFormList
//

// Object managing a list of forms and creating/deleting the global list of strings
constructor TFormList.Create;
begin
	inherited Create;
	fStrList := TList.Create;		// list of all the strings
  UpdatingTreeView := FALSE;
  fTreeView := nil;
	fLanguageCode := 0;
end;

// Create a formItem object and add it to the form list
function TFormList.AddForm( pForm: TForm ): TFormInfo;
var
	pFormInfo: TFormInfo;
begin
	pFormInfo := TFormInfo.Create( pForm, self );		// create the component
	Add( pFormInfo );																// add to the list
	Result := pFormInfo;										// return a pointer to the component
end;

// Delete the formItem and remove it from the list
procedure TFormList.RemoveForm( pFormInfo: TFormInfo );
begin
	Remove( pFormInfo );										// remove the component from the list
	pFormInfo.Free;												  // delete the object
end;

// Remove all the components and strings
procedure TFormList.Empty;
var
	i: integer;
begin
	while( Count > 0 ) do                     	     // remove all the components
		RemoveForm( Last );
	for i := 0 to StringList.Count - 1 do       		 // remove all the stringItems
		TItemString( StringList.Items[i] ).Free;
	StringList.Clear;
end;

// Delete the components (clear the list) and the string list
destructor TFormList.Destroy;
begin
	Empty;
	fStrList.Free;												  // delete the string list
	inherited Destroy;
end;

procedure TFormList.SetTreeView( pTreeView: TTreeView );
begin
	fTreeView := pTreeView;
	if( (fTreeView <> nil) and (fTreeView.Visible) ) then
		ShowAppComponents;
end;

procedure TFormList.DecodeString( var aString: ShortString );
var
	i, l: ShortInt;
begin
	l := Length(aString);
	for i := 2 to l do
		aString[i] := chr( ord(aString[i]) + ord(aString[1]) );
	if( l > 0 ) then
		aString[1] := chr( ord(aString[1]) + 31 );
end;

// Retrieves the position of the underlined char, the flag new and the real index
procedure ChangeIndex( var index: integer; var indexChar: byte; var newFlag: boolean;
											 stripUndChar, readNewFlags: boolean );
begin
  if( readNewFlags ) then
  begin
    newFlag := ( index and $80000000 <> 0 );
    index := index and $7FFFFFFF;
  end;
  if( not(stripUndChar) ) then
  begin
    indexChar := index shr 24;
    index := index and $FFFFFF;
  end;
end;

// Read the localisation file and update the form & component properties
function TFormList.ReadLanguageFile( fileName: string ): boolean;
var
	readOK, compOK: BOOL;
  stripUndChar, readNewFlags, newFlag: boolean;
  indexChar: byte;
	i, j, k, l, index1, index2, index3,
	nberForms, nberStrings1, nberStrings2, nberItems: integer;
	nberBytes, bytesRead: DWORD;
	versionNo, versionSecNo: SmallInt;
	lfVersion, name, className, fText,
  itemName, itemClassName: ShortString;
	pCompInfo: TCompInfo;	   // item information: name, caption, hint, strings ...
	pFormInfo: TFormInfo;    // form information, including a list of it components
	tmpStringList: TStringList;
	pItemStr: TItemString;
	fileHnd: THandle;
begin
  // Set all the "new" flags to TRUE for the captions, hints & strings
  for i := 0 to Count - 1 do
  begin
    pFormInfo := Items[i];
    pFormInfo.NewFlag[-1] := TRUE;
    for j := 0 to pFormInfo.CompList.Count - 1 do
    begin
      pCompInfo := pFormInfo.CompList.items[j];
      for k := -3 to pCompInfo.NumberOfStrings - 1 do
        pCompInfo.NewFlag[k] := TRUE;
    end;
  end;
	fileHnd := CreateFile( pChar(fileName), GENERIC_READ, 0, nil,
													OPEN_EXISTING, 0, 0 );
	if( fileHnd <> INVALID_HANDLE_VALUE ) then
	begin
		tmpStringList := TStringList.Create;
		// Check the version number
		lfVersion := '';
		ReadFile( fileHnd, lfVersion[0], 1, bytesRead, nil );
		nberBytes := integer( lfVersion[0] );
		if( nberBytes < 255 ) then
			readOK := ReadFile( fileHnd, lfVersion[1], nberBytes, bytesRead, nil )
    else
			readOK := FALSE;
		if( readOK ) then
    begin
      if( Copy(lfVersion, 1, 3) = Copy(LanguageFileVersion, 1, 3) ) then
      begin
        versionNo := StrToInt( Copy(lfVersion, 4, 2) );
        versionSecNo := StrToInt( Copy(lfVersion, 7, 1) );
        stripUndChar := not( (versionNo >= 2) or (versionSecNo >= 2) );
        readNewFlags := (versionNo >= 2) or (versionSecNo >= 3);
        readOK := TRUE;
      end
      else
        readOK := FALSE;
    end;
		if( readOK ) then
		begin
			// Read the language code
			ReadFile( fileHnd, fLanguageCode, SizeOf(fLanguageCode), bytesRead, nil );
			// Read the filename
			ReadFile( fileHnd, fText[0], 1, bytesRead, nil );
			nberBytes := integer( fText[0] );
      if( nberBytes < 255 ) then
				ReadFile( fileHnd, fText[1], nberBytes, bytesRead, nil )
      else
        readOK := FALSE;
			// Read the number of strings and load them
			if( readOK ) then
      begin
				ReadFile( fileHnd, nberStrings1, SizeOf(nberStrings1), bytesRead, nil );
        if( nberStrings1 < maxNberStrings ) then
        begin
	        for i := 1 to nberStrings1 do
          begin
            ReadFile( fileHnd, fText[0], 1, bytesRead, nil );
            nberBytes := integer( fText[0] );
            ReadFile( fileHnd, fText[1], nberBytes, bytesRead, nil );
            DecodeString( fText );
            tmpStringList.Add( fText );
          end;
        end
        else
        	readOK := FALSE;
      end;
			if( readOK ) then
      begin
				ReadFile( fileHnd, nberForms, SizeOf(nberForms), bytesRead, nil );
        if( nberForms > maxNberForms ) then
        	readOK := FALSE;
      end;
			i := 0;
		end;
    // For each form
		while( readOK and (i < nberForms) ) do
		begin
			i := i + 1;
			ReadFile( fileHnd, name[0], 1, bytesRead, nil );
			nberBytes := integer( name[0] );														// name
      if( nberBytes < 255 ) then
      begin
				ReadFile( fileHnd, name[1], nberBytes, bytesRead, nil );
				DecodeString( name );
      end
      else
        readOK := FALSE;
      if( readOK ) then                                           // className
      begin
				ReadFile( fileHnd, className[0], 1, bytesRead, nil );
				nberBytes := integer( className[0] );
        if( nberBytes < 255 ) then
        begin
          ReadFile( fileHnd, className[1], nberBytes, bytesRead, nil );
          DecodeString( className );
        end
        else
        	readOK := FALSE;
      end;
      if( readOK ) then                                           // caption
      begin
        ReadFile( fileHnd, index1, SizeOf(index1), bytesRead, nil );
        if( readNewFlags ) then
        begin
	        newFlag := ( index1 and $80000000 <> 0 );
          index1 := index1 and $7FFFFFFF;
        end;
        ReadFile( fileHnd, nberItems, SizeOf(nberItems), bytesRead, nil );
        if( nberItems > maxNberItems ) then
          readOK := FALSE;
      end;
			j := 0;
			itemClassName := '';
			// Go through the list of windows until a matching class name is found
			if( readOK ) then
			begin
				while( (j < Count) and (className <> itemClassName) ) do
				begin
					pFormInfo := Items[j];
					itemClassName := pFormInfo.itClassName;
					j := j + 1;
				end;
				if( className <> itemClassName ) then
					pFormInfo := AddForm( nil );
				pFormInfo.itName := name;
				pFormInfo.itClassName := className;
				if( (index1 > 0) and (index1 <= nberStrings1) ) then
        begin
					pFormInfo.ChangeString( -1, tmpStringList.Strings[index1-1], FALSE, stripUndChar );
	        if( readNewFlags ) then
          	pFormInfo.NewFlag[-1] := newFlag;
        end;
			end;
			k := 0;
      // and for each of the form components
			while( readOK and (k < nberItems) ) do
			begin
				k := k + 1;
        ReadFile( fileHnd, name[0], 1, bytesRead, nil );          // name
        nberBytes := integer( name[0] );
        if( nberBytes < 255 ) then
        begin
          ReadFile( fileHnd, name[1], nberBytes, bytesRead, nil );
          DecodeString( name );
        end
        else
          readOK := FALSE;
        if( readOK ) then                                         // className
        begin
          ReadFile( fileHnd, className[0], 1, bytesRead, nil );
          nberBytes := integer( className[0] );
          if( nberBytes < 255 ) then
          begin
            ReadFile( fileHnd, className[1], nberBytes, bytesRead, nil );
            DecodeString( className );
          end
          else
            readOK := FALSE;
        end;
	      if( readOK ) then																					// caption & hints
        begin
          ReadFile( fileHnd, index1, SizeOf(index1), bytesRead, nil );
          ReadFile( fileHnd, index2, SizeOf(index2), bytesRead, nil );
          if( (versionNo > 1) or (versionSecNo > 0) ) then
            ReadFile( fileHnd, index3, SizeOf(index3), bytesRead, nil )
          else
            index3 := 0;
          ReadFile( fileHnd, nberStrings2, SizeOf(nberStrings2), bytesRead, nil );
          if( nberStrings2 > maxNberComponentStrings ) then
          	readOK := FALSE;
        end;
	      if( readOK ) then
        begin
          j := 0;
          itemName := '';
          itemClassName := '';
          // Go through the list of components until a matching name is found
          while( (j < pFormInfo.CompList.Count) and
                 ((name <> itemName) {or (className <> itemClassName)}) ) do
          begin
            pCompInfo := pFormInfo.CompList.items[j];
            itemName := pCompInfo.itName;
            itemClassName := pCompInfo.itClassName;
            j := j + 1;
          end;
          // If the component does not exist
          compOK := TRUE;
          if( name = '' ) then
            nberStrings2 := 0
          else
          begin
            if( (name <> itemName) {or (className <> itemClassName)} ) then
            begin
              pCompInfo := pFormInfo.AddChild( nil );
              compOK := FALSE;
            end;
            pCompInfo.itName := name;
            pCompInfo.itClassName := className;
            // Caption index with position of underlined char and new flag
            ChangeIndex( index1, indexChar, newFlag, stripUndChar, readNewFlags );
            if( (index1 > 0) and (index1 <= nberStrings1) ) then
            begin
              pCompInfo.ChangeString( -1, tmpStringList.Strings[index1-1], FALSE, stripUndChar );
              if( not(stripUndChar) ) then
                pCompInfo.PosUnderlinedChar[-1] := indexChar;
              if( readNewFlags ) then
                pCompInfo.NewFlag[-1] := newFlag;
              compOK := TRUE;
            end;
            // Short hint index with new flag
            ChangeIndex( index2, indexChar, newFlag, FALSE, readNewFlags );
            if( (index2 > 0) and (index2 <= nberStrings1) ) then
            begin
              pCompInfo.ChangeString( -2, tmpStringList.Strings[index2-1], FALSE, stripUndChar );
              if( readNewFlags ) then
                pCompInfo.NewFlag[-2] := newFlag;
              compOK := TRUE;
            end;
            // Long hint index with new flag
            ChangeIndex( index3, indexChar, newFlag, FALSE, readNewFlags );
            if( (index3 > 0) and (index3 <= nberStrings1) ) then
            begin
              pCompInfo.ChangeString( -3, tmpStringList.Strings[index3-1], FALSE, stripUndChar );
              if( readNewFlags ) then
                pCompInfo.NewFlag[-3] := newFlag;
              compOK := TRUE;
            end;
          end;
        end;
				// Read the component's strings
				l := 0;
				while( readOK and (l < nberStrings2) ) do                 // strings
				begin
					l := l + 1;
					ReadFile( fileHnd, index1, SizeOf(index1), bytesRead, nil );
					readOK := readOK and ( SizeOf(index1) = bytesRead );
					ChangeIndex( index1, indexChar, newFlag, stripUndChar, readNewFlags );
					if( (index1 > 0) and (index1 <= nberStrings1) ) then
          begin
						pCompInfo.ChangeString( l - 1, tmpStringList.Strings[index1-1], FALSE, stripUndChar );
            if( not(stripUndChar) ) then
            	pCompInfo.PosUnderlinedChar[l-1] := indexChar;
	          if( readNewFlags ) then
            	pCompInfo.NewFlag[l-1] := newFlag;
            compOK := TRUE;
          end;
				end;
        if( not(compOK) ) then
          pCompInfo.Free; //pFormInfo.RemoveChild( pCompInfo );
			end;
		end;
		tmpStringList.Free;
		CloseHandle( fileHnd );
		Result := readOK;
	end
	else
		Result := FALSE;
end;

procedure TFormList.EncodeString( var aString: ShortString );
var
	i, l: ShortInt;
begin
	l := Length(aString);
	if( l > 0 ) then
		aString[1] := chr( ord(aString[1]) - 31 );
	for i := 2 to l do
		aString[i] := chr( ord(aString[i]) - ord(aString[1]) );
end;

// Write the form & component properties
function TFormList.WriteLanguageFile( fileName: string ): boolean;
var
	i, j, k, index, index1, index2, index3,
	nberStrings, nberForms, nberItems, counter: integer;
	nberBytes, bytesWritten, filePos: DWORD;
	languageFileName, text: ShortString;
	pCompInfo: TCompInfo;	 // item information: name, caption, hint, strings...
	pFormInfo: TFormInfo;  // form information, including a list of its components
	fileHnd: THandle;
begin
	fileHnd := CreateFile( pChar(fileName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, 0, 0 );
  Result := ( fileHnd <> INVALID_HANDLE_VALUE );
	if( Result ) then
	begin
		// Write the version number followed by the language code
		WriteFile( fileHnd, LanguageFileVersion[0], 1, bytesWritten, nil );
		nberBytes := integer( LanguageFileVersion[0] );
		WriteFile( fileHnd, LanguageFileVersion[1], nberBytes, bytesWritten, nil );
		WriteFile( fileHnd, fLanguageCode, SizeOf(fLanguageCode), bytesWritten, nil );
		// Write the filename
		languageFileName := ExtractFileName( fileName );
		WriteFile( fileHnd, languageFileName[0], 1, bytesWritten, nil );
		nberBytes := integer( languageFileName[0] );
		WriteFile( fileHnd, languageFileName[1], nberBytes, bytesWritten, nil );
		// Write the number of strings followed by the strings themselves
		nberStrings := StringList.Count;
		WriteFile( fileHnd, nberStrings, SizeOf(nberStrings), bytesWritten, nil );
		for i := 0 to nberStrings - 1 do
		begin
			text := TItemString(StringList.items[i]).Text;
			EncodeString( text );
			WriteFile( fileHnd, text[0], 1, bytesWritten, nil );
			nberBytes := integer( text[0] );
			WriteFile( fileHnd, text[1], nberBytes, bytesWritten, nil );
		end;
		nberForms := Count;
		WriteFile( fileHnd, nberForms, SizeOf(nberForms), bytesWritten, nil );
		for i := 0 to nberForms - 1 do
		begin
      // Form name
			pFormInfo := Items[i];
			text := pFormInfo.itName;
			EncodeString( text );
			WriteFile( fileHnd, text[0], 1, bytesWritten, nil );
			nberBytes := integer( text[0] );
			WriteFile( fileHnd, text[1], nberBytes, bytesWritten, nil );
      // Form classname
			text := pFormInfo.itClassName;
			EncodeString( text );
			WriteFile( fileHnd, text[0], 1, bytesWritten, nil );
			nberBytes := integer( text[0] );
			WriteFile( fileHnd, text[1], nberBytes, bytesWritten, nil );
      // Form caption
			index := StringList.IndexOf( pFormInfo.ItemString[-1] ) + 1;
			if( pFormInfo.fNewCapt ) then
      	index := index or $80000000
      else
      	index := index and not($80000000);
			WriteFile( fileHnd,	index, SizeOf(index), bytesWritten, nil );
      // Form component count
			nberItems := pFormInfo.CompList.Count;
      filePos := SetFilePointer( fileHnd, 0, nil, FILE_CURRENT );
			WriteFile( fileHnd, nberItems, SizeOf(nberItems), bytesWritten, nil );
      counter := 0;
      // Form components
			for j := 0 to nberItems - 1 do
			begin
				pCompInfo := pFormInfo.CompList.items[j];
				index1 := StringList.IndexOf( pCompInfo.ItemString[-1] ) + 1;
				index2 := StringList.IndexOf( pCompInfo.ItemString[-2] ) + 1;
				index3 := StringList.IndexOf( pCompInfo.ItemString[-3] ) + 1;
				nberStrings := pCompInfo.NumberOfStrings;
				text := pCompInfo.itName;
        if( (text <> '') and
            ((index1 > 0) or (index2 > 0) or (index3 > 0) or (nberStrings > 0)) ) then
        begin
          counter := counter + 1;
          // Component name
          EncodeString( text );
          WriteFile( fileHnd, text[0], 1, bytesWritten, nil );
          nberBytes := integer( text[0] );
          WriteFile( fileHnd, text[1], nberBytes, bytesWritten, nil );
          // Component class name (no longer used)
          text := pCompInfo.itClassName;
          EncodeString( text );
          WriteFile( fileHnd, text[0], 1, bytesWritten, nil );
          nberBytes := integer( text[0] );
          WriteFile( fileHnd, text[1], nberBytes, bytesWritten, nil );
          // Caption index
          index1 := index1 + pCompInfo.PosUnderlinedChar[-1] shl 24;
          if( pCompInfo.fNewCapt ) then
            index1 := index1 or $80000000
          else
            index1 := index1 and not( $80000000 );
          WriteFile( fileHnd, index1, SizeOf(index1), bytesWritten, nil );
          // Short hint index
          if( pCompInfo.fNewSHint ) then
            index2 := index2 or $80000000
          else
            index2 := index2 and not($80000000);
          WriteFile( fileHnd, index2, SizeOf(index2), bytesWritten, nil );
          // Long hint index
          if( pCompInfo.fNewLHint ) then
            index3 := index3 or $80000000
          else
            index3 := index3 and not($80000000);
          WriteFile( fileHnd, index3, SizeOf(index3), bytesWritten, nil );
          // String indexes
          WriteFile( fileHnd, nberStrings, SizeOf(nberStrings), bytesWritten, nil );
          for k := 0 to nberStrings - 1 do
          begin
            index := StringList.IndexOf( pCompInfo.ItemString[k] ) + 1 +
                     pCompInfo.PosUnderlinedChar[k] shl 24;
            if( pCompInfo.NewFlag[k] ) then
              index := index or $80000000
            else
              index := index and not($80000000);
            WriteFile( fileHnd, index, SizeOf(index), bytesWritten, nil );
          end;
        end;
			end;
      // If the number of components written is lower than expected, update the file
      if( counter <> nberItems ) then
      begin
        SetFilePointer( fileHnd, filePos, nil, FILE_BEGIN );
        nberItems := counter;
        WriteFile( fileHnd, nberItems, SizeOf(nberItems), bytesWritten, nil );
        SetFilePointer( fileHnd, 0, nil, FILE_END );
      end;
		end;
		CloseHandle( fileHnd );
	end;
end;

// Function that goes through all the forms of the application and browse all
// of its components recursively using BrowseChildComponents
procedure TFormList.BrowseAppComponents;
var
	i: integer;
	appForm: TForm;
	pFormInfo: TFormInfo;  // form information, including a list of it components
begin
	if( Count > 0 ) then
		Empty;
	// Browse the application forms
	i := 0;
	repeat
		appForm := Screen.Forms[i];
		i := i + 1;
		pFormInfo := AddForm( appForm );
		if( not(pFormInfo.BrowseChildComponents) ) then
			RemoveForm( pFormInfo );
	until( i = Screen.FormCount );
end;

// Display the component hierarchy (form/components) in the tree view
procedure TFormList.ShowAppComponents;
var
	i: integer;
	pFormInfo: TFormInfo;  // form information, including a list of it components
begin
	if( UpdatingTreeView or (TreeView = nil) ) then
		exit;
	UpdatingTreeView := TRUE;
	Screen.Cursor := crHourGlass;
	TreeView.Items.BeginUpdate;
	TreeView.Items.Clear;
	for i := 0 to Count - 1 do			// go through all the forms
	begin
		pFormInfo := TFormInfo( Items[i] );
		pFormInfo.ShowFormComponents( TreeView );
	end;
	TreeView.Items.EndUpdate;
	Screen.Cursor := crDefault;
	UpdatingTreeView := FALSE;
end;

// Go through all the components of all static & registered dynamic forms and
// update their caption/hint properties within the application
procedure TFormList.UpdateAppComponents;
var
	i, j: integer;
	pCompInfo: TCompInfo;	 // item information: name, caption, hint, ...
	pFormInfo: TFormInfo;  // form information, including a list of it components
begin
	for i := 0 to Count - 1 do
	begin
		pFormInfo := TFormInfo( Items[i] );
		for j := 0 to pFormInfo.CompList.Count - 1 do
		begin
			pCompInfo := pFormInfo.CompList.items[j];
			pCompInfo.UpdateFormItems();
		end;
		pFormInfo.UpdateFormItems();
	end;
end;

// Go through the tree view and update it (new entries are not added)
procedure TFormList.UpdateTreeView;
var
	i, componentExists, fieldIndex: integer;
	treeNode: TTreeNode;                          
	pParentForm: TFormInfo;
	pCompInfo: TCompInfo;
	nodesToDelete: TList;
begin
	if( UpdatingTreeView or (TreeView = nil) ) then
		exit;
  UpdatingTreeView := TRUE;
  TreeView.Items.BeginUpdate;
  Screen.Cursor := crHourGlass;
  nodesToDelete := TList.Create;
	try
    // First remove all invalid parent nodes (corresponding to pFormInfo)
    treeNode := TreeView.Items.GetFirstNode;
    while( treeNode <> nil ) do
    begin
      pCompInfo := treeNode.Data;
      if( IndexOf(pCompInfo) = -1 ) then
        nodesToDelete.Add( treeNode );
      treeNode := treeNode.GetNextSibling;
    end;
    // Delete the nodes corresponding to non-existing forms
    for i := 0 to nodesToDelete.Count - 1 do
      TTreeNode(nodesToDelete.Items[i]).Delete;
    nodesToDelete.Clear;
    // Look for invalid references in all the nodes of the tree view
    treeNode := TreeView.Items.GetFirstNode;
    while( treeNode <> nil ) do
    begin
      pCompInfo := treeNode.Data;
      // Remove all invalid references
      if( pCompInfo <> nil ) then
      begin
        if( IndexOf(pCompInfo) <> -1 ) then
          pParentForm := TFormInfo(pCompInfo)		// keep track of the current form
        else
          if( pParentForm.CompList.IndexOf(pCompInfo) = -1 ) then
            pCompInfo := nil;
      end;
      if( pCompInfo <> nil ) then
      begin
        if( pCompInfo.Component <>  nil ) then
          componentExists := 0
        else
          componentExists := 1;
        fieldIndex := treeNode.StateIndex;
        if( (fieldIndex >= -3) and (fieldIndex < pCompInfo.NumberOfStrings) ) then
        begin
          treeNode.Text := pCompInfo.GetString(fieldIndex);
          if( pCompInfo.NewFlag[fieldIndex] ) then
            treeNode.ImageIndex := 2 + componentExists
          else
            treeNode.ImageIndex := 0 + componentExists;
          treeNode.SelectedIndex := treeNode.ImageIndex;
        end;
      end
      else
        nodesToDelete.Add( treeNode );
      treeNode := treeNode.GetNext;
    end;
    // Delete the nodes corresponding to non-existing items
    for i := 0 to nodesToDelete.Count - 1 do
      TTreeNode(nodesToDelete.Items[i]).Delete;
  except
  end;
  nodesToDelete.Free;
  Screen.Cursor := crDefault;
  TreeView.Items.EndUpdate;
	UpdatingTreeView := FALSE;
end;

// Delete all references to non existing components in instanciated forms
// If delForms is TRUE, remove non existing forms as well
function TFormList.DeleteInvalidReferences( delForms: boolean ): boolean;
var
	i, j: integer;
	pCompInfo: TCompInfo;
	pFormInfo: TFormInfo;
	formsToRemove, compsToRemove: TList;
begin
	formsToRemove := TList.Create;
	compsToRemove := TList.Create;
	Result := FALSE;
	// Find unreferenced windows
	for i := 0 to Count - 1 do
	begin
		pFormInfo := Items[i];
		if( pFormInfo.Component = nil ) then
		begin
			Result := TRUE;
			formsToRemove.Add( pFormInfo );
		end;
	end;
	// Destroy the windows found
  if( delForms ) then
		for i := 0 to formsToRemove.Count - 1 do
			RemoveForm( TFormInfo(formsToRemove.Items[i]) )
  else
    Result := FALSE;
	// Find unreferenced components
	for i := 0 to Count - 1 do
	begin
		pFormInfo := Items[i];
    if( formsToRemove.IndexOf(pFormInfo) = -1 ) then
    begin
    	compsToRemove.Clear;
      for j := 0 to pFormInfo.CompList.Count - 1 do
      begin
        pCompInfo := pFormInfo.CompList.Items[j];
        if( pCompInfo.Component = nil ) then
        begin
          Result := TRUE;
          compsToRemove.Add( pCompInfo );
        end;
      end;
      for j := 0 to compsToRemove.Count - 1 do
        pFormInfo.RemoveChild( TCompInfo(compsToRemove.Items[j]) );
    end;
	end;
  formsToRemove.Free;
	compsToRemove.Free;
end;

// Find the component item corresponding to pCompInfo (pointing to the same component)
function TFormList.FindSameComp( pCompInfo: TCompInfo ): TCompInfo;
var
	i, j: integer;
  pFormInfo: TFormInfo;
	tmpOrgItemInfo: TCompInfo;
begin
  Result := nil;
  if( pCompInfo <> nil ) then
  begin
    i := 0;
    while( (i < Count) and (Result = nil) ) do
    begin
      pFormInfo := TFormInfo( Items[i] );
      if( (pFormInfo.itName = pCompInfo.itName) and
          (pFormInfo.itClassName = pCompInfo.itClassName) ) then
        Result := pFormInfo
      else
      begin
        j := 0;
        while( (j < pFormInfo.CompList.Count) and (Result = nil) ) do
        begin
          tmpOrgItemInfo := TCompInfo( pFormInfo.CompList.Items[j] );
          if( (tmpOrgItemInfo.ParentForm.itName = pCompInfo.ParentForm.itName) ) then
            if( tmpOrgItemInfo.itName = pCompInfo.itName ) then
              Result := tmpOrgItemInfo;
          j := j + 1;
        end;
        i := i + 1;
      end;
    end;
  end;
end;

// Find out whether the component exists in the list
function TFormList.IsCompValid( pCompInfo: TCompInfo ): boolean;
var
	i: integer;
  pFormInfo: TFormInfo;
begin
  Result := FALSE;
  if( pCompInfo <> nil ) then
  begin
    i := 0;
    while( not(Result) and (i < Count) ) do
    begin
      pFormInfo := TFormInfo( Items[i] );
      if( pFormInfo = pCompInfo  ) then
        Result := TRUE
      else
      	Result := ( pFormInfo.CompList.IndexOf(pCompInfo) <> -1 );
      i := i + 1;
    end;
  end;
end;

//
// TFormInfo
//

// Object holding information about a form, including a list of its components
// Derived from TCompInfo, which includes information about the component it refers to
// NOTE: the ParentForm member, inherited from TCompInfo, should be set to self
// when calling the inherited constructor (the form is its own parent)
constructor TFormInfo.Create( givenForm: TForm; givenFormList: TFormList );
begin
	fCompInfoList := TList.Create;				 // create the list of items
	fFormList := givenFormList;						 // pointer to the fFormList
	inherited Create( givenForm, self );   // call the inherited TCompInfo.Create
end;

destructor TFormInfo.Destroy;
begin
	SetComponent( nil );		
	while( CompList.Count > 0 ) do
		TCompInfo( CompList.Last ).Free;
	if( fFormList.IndexOf(self) <> -1 ) then
		fFormList.Remove( self );
	CompList.Clear;
	fCompInfoList.Free;												// delete the list of components
	inherited Destroy;
end;

// In the pFormInfo structure, add a reference to the form, update the
// pointers to the existing components and add the new components
procedure TFormInfo.ReferenceForm( form: TForm );
var
	j, k: integer;
	pComponent: TComponent;
	pCompInfo: TCompInfo;
	componentFound: boolean;
begin
	SetComponent( form );
	UpdateItem( form );
	// Browse through the form components
	for j := 0 to form.ComponentCount - 1 do
	begin
		pComponent := form.Components[j];
		// And find a matching component in TFormInfo's list of pCompInfo
		k := 0;
		componentFound := FALSE;
		while( (k < CompList.Count) and (not(componentFound)) ) do
		begin
			pCompInfo := CompList.items[k];
			if( pCompInfo.itName = pComponent.Name ) then
			begin
				componentFound := TRUE;
				pCompInfo.SetComponent( pComponent );
			end;
			k := k + 1;
		end;
		if( not(componentFound) ) then
			pCompInfo := AddChild( pComponent );
		if( not(pCompInfo.BrowseChildComponents) ) then
			RemoveChild( pCompInfo )
		else
			pCompInfo.UpdateItem( pComponent );
	end;
  FixDisappearingSysMenu( form );
end;

// Set a new pointer to a component, provided that none existed before
procedure TFormInfo.SetComponent( newPtrComponent: TComponent );
var
	i: integer;
	newForm: TForm;
begin
	if( newPtrComponent <> nil ) then
  	if( not(newPtrComponent is TForm) ) then
    	exit;
  newForm := TForm( newPtrComponent );
  fComponent := newForm;
  if( newForm <> nil ) then
    if( not(newForm.HandleAllocated) ) then
      newForm := nil;
  if( newForm = nil ) then		// de-reference all the owned components
    for i := 0 to CompList.Count - 1 do
      TCompInfo( CompList.Items[i] ).SetComponent( nil );
end;

// Create a child component and add it to the list of components
function TFormInfo.AddChild( fComponent: TComponent ): TCompInfo;
var
	pCompInfo: TCompInfo;
begin
	pCompInfo := TCompInfo.Create( fComponent, ParentForm );		// create the component
	CompList.Add( pCompInfo );                     // add the component to the list
	Result := pCompInfo;
end;

// Remove the child component from the list of components and delete it
procedure TFormInfo.RemoveChild( pCompInfo: TCompInfo );
begin
	CompList.Remove( pCompInfo );
	pCompInfo.Free;
end;

function TFormInfo.GetStringList: TList;
begin
	Result := fFormList.StringList;
end;

// Display the form components in the tree view
procedure TFormInfo.ShowFormComponents( TreeView: TTreeView );
var
	j, k, formExists, componentExists: integer;
	pCompInfo: TCompInfo;	// item information: name, caption, hint, ...
	childTreeNode, treeNode: TTreeNode;
	componentString: string;
begin
	TreeView.Items.BeginUpdate;
	if( Component <>  nil ) then
		formExists := 0
	else
		formExists := 1;
	treeNode :=
		TreeView.Items.AddObject( TreeView.Selected, GetString(-1), self );
	treeNode.StateIndex := -1;
	if( fNewCapt ) then		// new items are shown with a red dot
		treeNode.ImageIndex := 2 + formExists
	else
		treeNode.ImageIndex := 0 + formExists;
	treeNode.SelectedIndex := treeNode.ImageIndex;
	for j := 0 to CompList.Count - 1 do
	begin
		pCompInfo := CompList.items[j];
		if( pCompInfo.Component <>  nil ) then
			componentExists := 0
		else
			componentExists := 1;
		for k := -3 to pCompInfo.NumberOfStrings -1 do	// add the strings, if any
		begin
			componentString := pCompInfo.GetString(k);
			if( componentString <> '' ) then
			begin
				childTreeNode :=
					TreeView.Items.AddChildObject( treeNode, componentString, pCompInfo );
				if( pCompInfo.NewFlag[k] ) then
					childTreeNode.ImageIndex := 2 + componentExists
				else
					childTreeNode.ImageIndex := 0 + componentExists;
				childTreeNode.SelectedIndex := childTreeNode.ImageIndex;
				childTreeNode.StateIndex := k;
			end;
		end;
	end;
	TreeView.Items.EndUpdate;
end;

//
// TCompInfo
//

// Object holding information about a component, among which a pointer to the
// given component, pointers to a string or strings corresponding to the
// caption and/or the hint, a pointer to the parent form
constructor TCompInfo.Create( givenComponent: TComponent; givenParentForm: TFormInfo );
begin
	inherited Create;
	fItemStringList := TList.Create;
	SetComponent( givenComponent ); 	// add the pointer to the relevant component
	fParentForm := givenParentForm;		// set the pointer to the parent form
	fCaptionItemStr := nil;							// no caption yet!
	fShortHintItemStr := nil;						// no hint yet either
	fLongHintItemStr := nil;						//  			"
	fNewCapt := TRUE;
	fNewSHint := TRUE;
	fNewLHint := TRUE;
end;

// Destructor deletes all the "new" string flags, the string and flag lists
destructor TCompInfo.Destroy;
var
	i: integer;
	pItemStr: TItemString;
begin
	// Remove references to the item in the string list
	for i := -3 to fItemStringList.Count - 1 do
	begin
    pItemStr := ItemString[i];
		if( pItemStr <> nil ) then
		begin
			if( pItemStr.StringList.IndexOf(self) <> -1 ) then
				pItemStr.StringList.Remove(self);
			if( pItemStr.StringList.Count = 0 ) then
			begin
				GetStringList.Remove( pItemStr );
				pItemStr.Free;
			end;
		end;
    if( i >= 0 ) then
      dispose( fItemStringList.Items[i] );
	end;
	fItemStringList.Free;                         // delete the string list
  if( not(self is TFormInfo) ) then
    if( ParentForm.CompList.IndexOf(self) <> -1 ) then
      ParentForm.CompList.Remove( self );
	inherited Destroy;
end;

// Set a new pointer to a component 
procedure TCompInfo.SetComponent( newPtrComponent: TComponent );
begin
	// if( (fComponent = nil) or (newPtrComponent = nil) ) then  (provided that none existed before : NO!!!)
		fComponent := newPtrComponent;
end;

function TCompInfo.GetStringList: TList;
begin
	Result := ParentForm.GetStringList;
end;

function TCompInfo.GetNewFlag( index: integer ): boolean;
begin
  case( index ) of
    -1: 	Result := fNewCapt;
    -2:   Result := fNewSHint;
    -3:   Result := fNewLHint;
    else  if( (index >= 0) and (index < fItemStringList.Count) ) then
            Result := TItem(fItemStringList[index]^).new
          else
            Result := FALSE;
  end;
end;

procedure TCompInfo.SetNewFlag( index: integer; new: boolean );
begin
  case( index ) of
    -1: 	fNewCapt := new;
    -2:   fNewSHint := new;
    -3:   fNewLHint := new;
    else  if( (index >= 0) and (index < fItemStringList.Count) ) then
	    			TItem(fItemStringList[index]^).new := new;
  end
end;

function TCompInfo.GetPosUnderlinedChar( index: integer ): integer;
begin
  case( index ) of
    -1: 	Result := posUnderCar;
    else  if( (index >= 0) and (index < fItemStringList.Count) ) then
            Result := TItem(fItemStringList[index]^).posUnderCar
          else
            Result := 0;
  end;
end;

procedure TCompInfo.SetPosUnderlinedChar( index, position: integer );
begin
  case( index ) of
    -1: 	posUnderCar := position;
    else  if( (index >= 0) and (index < fItemStringList.Count) ) then
    				TItem(fItemStringList[index]^).posUnderCar := position;
  end;
end;

function TCompInfo.GetItemString( fieldIndex: integer ): TItemString;
begin
  case( fieldIndex ) of     // get the pItemStr pointed by the relevant field:
    -1: Result := fCaptionItemStr;								// caption, if itemField = -1
    -2: Result := fShortHintItemStr;    					// short hint, if itemField = -2
    -3: Result := fLongHintItemStr;     					// long hint, if itemField = -3
   else if( (fieldIndex >= 0) and (fieldIndex < fItemStringList.Count) ) then
	   			Result := TItem(fItemStringList[fieldIndex]^).itemString		// or string index
   			else
        	Result := nil;
  end;
end;

procedure TCompInfo.SetItemString( fieldIndex: integer; itemStr: TItemString );
begin
  case( fieldIndex ) of     // get the pItemStr pointed by the relevant field:
    -1: fCaptionItemStr := itemStr;								// caption, if itemField = -1
    -2: fShortHintItemStr := itemStr;    					// short hint, if itemField = -2
    -3: fLongHintItemStr := itemStr;     					// long hint, if itemField = -3
   else if( (fieldIndex >= 0) and (fieldIndex < fItemStringList.Count) ) then
   			begin
        	//if( itemStr <> nil ) then
	   				TItem(fItemStringList[fieldIndex]^).itemString := itemStr		// or string index
          (* else
          begin
       			pItem := fItemStringList[fieldIndex];
            dispose( pItem );
            fItemStringList.Delete( fieldIndex );
          end;	*)
        end;
  end
end;


// Retrieve the caption/hint/string, if there is one, or return an empty string
function TCompInfo.GetString( fieldIndex: integer ): ShortString;
var
	posCar: integer;
  pItemStr: TItemString;
begin
	Result := '';
  pItemStr := ItemString[fieldIndex];
  if( pItemStr = nil ) then
  	Result := ''
  else
  begin
  	Result := pItemStr.Text;
    posCar := PosUnderlinedChar[fieldIndex];
    if( (posCar > 0) and (posCar <= Length(Result)) ) then
      Insert( UnderlineChar, Result, posCar );
  end;
end;

procedure TCompInfo.NewStringElement;
var
	pItem: ^TItem;
begin
	new( pItem );
  pItem.itemString := nil;                // add a dummy pointer to a TItemString
	pItem.new := TRUE;                      // add the "new" flag
  pItem.posUnderCar := 0;									// position of the underlined char
	fItemStringList.Add( pItem );
end;

// Function that changes the item's caption, hint or one of its strings
// (depending on the value of fieldIndex).
// If it is the only item (form/componenet) to use this particular text string,
// delete the pItemStr object; otherwise, remove itself from the item pointer
// list maintained by the pItemStr object.
// Then check whether an pItemStr already has the given string (itemField) and
// if so, add itself to the list of pointers pItemStr; otherwise, create a
// new pItemStr with the relevant string entry, and pointer to itself.
procedure TCompInfo.AddString( fieldIndex: integer; itemField: string;
															 stripUndChar: boolean );
var
	i, strListCount: integer;
	fText: string;
	pItemStr: TItemString;
begin
	if( fieldIndex > fItemStringList.Count ) then
		exit;
	if( fieldIndex = fItemStringList.Count ) then
		NewStringElement;
  // Find the position of the underlined char
  if( stripUndChar and (fieldIndex >= -1) ) then
  	PosUnderlinedChar[fieldIndex] := StripUnderlineChar( itemField );
  pItemStr := ItemString[fieldIndex];
	if( pItemStr <> nil ) then
		if( pItemStr.Text = itemField ) then		  // if the strings are the same
			exit;                                   // exit...
	if( pItemStr <> nil ) then			      // if the field points to a valid pItemStr
	begin
		pItemStr.StringList.Remove( self );	      // if in the list, remove itself from it
		if( pItemStr.StringList.Count = 0 ) then
		begin																		  // if no other items use this string,
			GetStringList.Remove( pItemStr );		    // remove the pItemStr entry
			pItemStr.Free;											    // from the global list & delete it
		end;
	end;
	if( itemField = '' ) then 		// if the desired text is an empty string
    pItemStr := nil
  else                          // if the desired text is not an empty string
	begin
		// Go through the whole list to check whether the text already exists
    strListCount := GetStringList.Count;
		if( strListCount > 0 ) then		        // provided that it is not empty
		begin
			i := 0;
			repeat
				i := i + 1;
				fText := TItemString( GetStringList.items[i-1] ).Text;
			until( (i = strListCount) or (itemField = fText) );
		end
		else                                  // otherwise it contains no text
			fText := '';
		if( itemField = fText ) then         	    // EITHER the text has been
			pItemStr := GetStringList.items[i-1]		// found among the itemStrings
		else
		begin																			// OR it has not, in which case
			pItemStr := TItemString.Create;					// create a new one, which holds
			pItemStr.fText := itemField;				    // the relevant text, and add
			GetStringList.Add( pItemStr );					// it to the global string list
		end;
		pItemStr.StringList.Add( self );	    // add oneself to the pItemStr's CompList
	end;
  SetItemString( fieldIndex, pItemStr );
end;

// Add the string if no string existed previously
procedure TCompInfo.AddNewString( fieldIndex: integer; itemField: string;
																	stripUndChar: boolean );
begin
	if( ItemString[fieldIndex] = nil ) then
		AddString( fieldIndex, itemField, stripUndChar );
end;

// Return the number of strings
function TCompInfo.GetNumberOfStrings: integer;
begin
	Result := fItemStringList.Count;
end;

// Change the item's caption/hint/string, reset the fNewCapt/newHint flag(s)
procedure TCompInfo.SetString( fieldIndex: integer; itemField: ShortString );
begin
	AddString( fieldIndex, itemField, TRUE );
  NewFlag[fieldIndex] := FALSE;
end;

// Change the item's caption/hint/string, reset the fNewCapt/newHint flag(s)
// and update the component's caption/hint properties within the application
procedure TCompInfo.ChangeString( fieldIndex: integer; itemField: string;
																	update, stripUndChar: boolean );
begin
	AddString( fieldIndex, itemField, stripUndChar );
  NewFlag[fieldIndex] := FALSE;
  if( update ) then
		UpdateFormItems();
end;

// Recursive function that goes through all the child components of the component
// (called by BrowseAppComponents)
function TCompInfo.BrowseChildComponents: boolean;
var
	i: integer;
	browseSuccess, browseChildSuccess: boolean;
	childItemInfo: TCompInfo;
	itemComponent: TComponent;
begin
	browseSuccess := FALSE;
	itClassName := Component.ClassName;
	itemComponent := Component;
  // Check whether it is an ad hoc component and get its properties accordingly
  // Start with the caption and strings
  if( itemComponent is TForm ) then
    browseSuccess := GetForm
  else
  	if( itemComponent.Name <> '' ) then
    	browseSuccess := GetItemComponent;
  // If successful, save the component name
  if( browseSuccess ) then
    itName := itemComponent.name
  else
    itName := '';
	if( (itName = '') and not(itemComponent is TForm) ) then
		browseSuccess := FALSE;
	// Check out all the component's sub-components
	for i := 0 to Component.ComponentCount - 1 do
	begin
		childItemInfo := ParentForm.AddChild( Component.Components[i] );
		browseChildSuccess := childItemInfo.BrowseChildComponents;
		if( browseChildSuccess = FALSE ) then
			ParentForm.RemoveChild( childItemInfo );
		// browseSuccess := browseChildSuccess or browseSuccess;
	end;
	Result := browseSuccess;    
end;

end.
