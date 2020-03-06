(*******************************************************************************
*                                                                              *
* TLocalisation - Localisation Form v1.3                                       *
* Copyright Somicronic 1999 - All rights reserved                              *
*                                                                              *
*******************************************************************************)

unit Localise;

(*
		 Localise the captions (or assimilated text properties), short and long hints
   as well as TStrings like properties, depending on the component's tag value:
   tag >= 0 			: localise all known text properties
   -tag and 1 = 0	:	do not localise captions
   -tag and 2 = 0	:	do not localise hints
   -tag and 4 = 0	:	do not localise strings
*)

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ULocalisation, ComCtrls, Buttons{$IfDef Delphi4+}, ImgList{$EndIf};

const
  DeleteWithUndo = TRUE;
	// Dialog box constants
  ButtonKinds : array [0..8] of TBitBtnKind = (bkYes, bkNo, bkOk, bkCancel,
																	    bkAbort, bkRetry, bkIgnore, bkAll, bkHelp);
  ButtonSize : Integer = 87;
  ButtonSpacing : Integer = 16;
  MinMargin : Integer = 10;

type
	// Class definition for the localisation form
	TLocalisation = class(TForm)
		TreeView: TTreeView;
		ButtonExit: TButton;
		Language: TLabel;
		ButtonSave: TButton;
		ImageList: TImageList;
		ComboBoxLanguage: TComboBox;
    Constants: TListBox;
    cbSecondaryLanguage: TComboBox;
    ButtonNextNewElement: TButton;
    DialogCaptions: TListBox;
    ButtonCaptions: TListBox;
    EditText: TEdit;
		procedure FormCreate(Sender: TObject);
		procedure OnElementEdited( Sender: TObject; Node: TTreeNode; var S: string);
		procedure OnClickSave(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure cbLanguageChange(Sender: TObject);
		procedure OnClickExit(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure OnElementEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
		procedure ComboBoxLanguageDrawItem(Control: TWinControl;
			Index: Integer; Rect: TRect; State: TOwnerDrawState);
		procedure FormShow(Sender: TObject);
		procedure FormActivate(Sender: TObject);
		procedure TreeViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure cbSecondaryLanguageChange(Sender: TObject);
    procedure ButtonNextClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDeactivate(Sender: TObject);
    procedure EditTextKeyPress(Sender: TObject; var Key: Char);
	private
		{ Déclarations privées }
    minWidth: integer;
    minHeight: integer;
		sLangFileAvailable: TLangFileAvailable;
		LanguageFileName: string[255];
		selectedLanguage: integer;			// selected language index in const list
		sLanguageCode: word;						// selected language code
		currentDirectory: string;
		dataChanged: boolean;   		// flag: element edited or not
		secFormList: TFormList;			// list of forms, components & their properties
		fFormList: TFormList;				// list of forms, components & their properties
    FOnLanguageChange: TNotifyEvent;
    FOnCreateWindow: TNotifyEvent;
		procedure WMGetMinMaxInfo( var Message: TWMGetMinMaxInfo ); message WM_GETMINMAXINFO;
		procedure DeleteInvalidReferences( delForms: boolean );
		procedure RefreshFormList;
		procedure Spread;
		procedure ToggleNodeBulletColour( node: TTreeNode );
		procedure ToggleBulletColour( all: boolean );
    procedure SetAllBulletsToGreen;
    procedure SetLanguageCode( newLang: word );
		function SaveCurrentLanguage: boolean;
		{ Déclarations publiques }
	public
  	createDefaultLanguageFile: boolean;
		procedure CreateForm( InstanceClass: TComponentClass; var Reference );
    procedure CopyToClipboard;
		function MessageBox(Text, Caption: string; Flags: Longint): Integer;
		function MessageDlgPos(const Msg: string; DlgType: TMsgDlgType;
							  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer): Word;
    procedure RefreshTreeView;
    function NbLangFilesAvail: integer;
    property OnLanguageChange: TNotifyEvent read FOnLanguageChange write FOnLanguageChange;
    property OnCreateWindow: TNotifyEvent read FOnCreateWindow write FOnCreateWindow;
    property LanguageFilesAvailable: TLangFileAvailable read sLangFileAvailable;
    property LanguageCode: word read sLanguageCode write SetLanguageCode;
	end;


var
	Localisation: TLocalisation;

implementation

{$R *.DFM}

uses
  ShellAPI, ExtCtrls, Clipbrd;

const
  CRLF = #13#10;
  // Message indexes
	msgChangeAll = 0;
	msgConfirmSave = 1;

type
  TMessageForm = class(TForm)
  private
    procedure HelpButtonClick(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent); {$IfDef Delphi4+} reintroduce;{$EndIf}
  end;

var
  ButtonWidths: array[TMsgDlgBtn] of integer;  // initialized to zero

constructor TMessageForm.CreateNew(AOwner: TComponent);
var
  NonClientMetrics: TNonClientMetrics;
begin
  inherited CreateNew(AOwner);
  NonClientMetrics.cbSize := sizeof(NonClientMetrics);
  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
    Font.Handle := CreateFontIndirect(NonClientMetrics.lfMessageFont);
end;

procedure TMessageForm.HelpButtonClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

// Create a list of all the forms already instantiated in the application
// read the possible default language file, which updates the list, update the components
// dynamically in the application and display a tree view of all the text strings
procedure TLocalisation.FormCreate(Sender: TObject);
var
	i: integer;
	oldFileName, fileName: string;
begin
	sLanguageCode := 0;
  FOnLanguageChange := nil;
  FOnCreateWindow := nil;
	TreeView.tag := -7;
	TreeView.Visible := FALSE;
  EditText.Visible := FALSE;
  cbSecondaryLanguage.Visible := FALSE;
  ButtonSave.Visible := FALSE;
  ButtonNextNewElement.Visible := FALSE;
  ComboBoxLanguage.Top := ButtonExit.Top + ButtonExit.Height - ComboBoxLanguage.Height;
	currentDirectory := ExtractFilePath( Application.ExeName );
	if( AnsiLastChar(currentDirectory)^ <> '\' ) then
		currentDirectory := currentDirectory + '\';
	LanguageFileName := ChangeFileExt( ExtractFileName(Application.ExeName), '' );
	minWidth := ButtonExit.Left + ButtonExit.Width + 20;
	minHeight := 80;
  SetBounds( Left, Top, minWidth, minHeight );
	dataChanged := FALSE;
  secFormList := TFormList.Create;
	fFormList := TFormList.Create;
  fFormList.TreeView := TreeView;
	fFormList.BrowseAppComponents();	// scan the app's components & fill fFormList
  for i := 0 to ComboBoxLanguage.Items.Count - 1 do
  	cbSecondaryLanguage.Items.Add( ComboBoxLanguage.Items[i] );
	// Check all the available language files and rename them if necessary
	for i := 0 to NbOfLanguages do
	begin
    if( i = 0 ) then
    begin
      oldFileName := currentDirectory + LanguageFileName + '.' + DefLangFileSuffix;
      fileName := currentDirectory + LanguageFileName
                + '_' + DefLangFileSuffix + LangFileExt;
    end
    else
    begin
      oldFileName := currentDirectory + LanguageFileName + '.' + langFileSuffix[i];
      fileName := currentDirectory + LanguageFileName
                + '_' + langFileSuffix[i] + LangFileExt;
    end;
    // Rename language files with old names
    if( FileExists(oldFileName) ) then
    begin
      if( FileExists(fileName) ) then
        DeleteFile( oldFileName )
      else
        RenameFile( oldFileName, fileName );
    end;
    if( i > 0 ) then
		  sLangFileAvailable[i] := FileExists(fileName);
	end;
	// Read the default language file (if it exists)
	fileName := currentDirectory + LanguageFileName
            + '_' + DefLangFileSuffix + LangFileExt;
	if( FileExists(fileName) ) then
    if( fFormList.ReadLanguageFile(fileName) ) then
      sLanguageCode := fFormList.LanguageCode;
  if( sLanguageCode <> 0 ) then
  begin
		for i := 1 to NbOfLanguages do
			if( langFileCode[i] = sLanguageCode ) then
				selectedLanguage := i - 1;
		fFormList.UpdateAppComponents();        // dynamically update the app's components
		createDefaultLanguageFile := TRUE;
	end
	else
	begin
		TreeView.Enabled := FALSE;
		buttonSave.Enabled := FALSE;
		selectedLanguage := -1;
		createDefaultLanguageFile := FALSE;
	end;
	ComboBoxLanguage.ItemIndex := selectedLanguage;
  ButtonNextNewElement.SetBounds( ButtonNextNewElement.Left, cbSecondaryLanguage.Top,
																	ButtonNextNewElement.Width, cbSecondaryLanguage.Height - 1 );
end;

// Destructor deletes the fFormList
procedure TLocalisation.FormDestroy(Sender: TObject);
begin
	secFormList.Free;
	fFormList.Free;
end;

procedure TLocalisation.RefreshFormList;
begin
	Screen.Cursor := crHourGlass;
  fFormList.Empty;
	fFormList.BrowseAppComponents;	// scan the app's components & fill fFormList
  RefreshTreeView;
	Screen.Cursor := crDefault;
end;

// Min Window size
procedure TLocalisation.WMGetMinMaxInfo( var Message: TWMGetMinMaxInfo );
begin
	inherited;
  Message.MinMaxInfo.ptMinTrackSize := Point( minWidth, minHeight );
  if( Visible and (ButtonSave <> nil) ) then
    if( not(ButtonSave.Visible) ) then
      Message.MinMaxInfo.ptMaxTrackSize := Point( minWidth, minHeight );
end;

procedure TLocalisation.FormShow(Sender: TObject);
begin
	SetWindowPos( Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE );
	Language.Repaint;
end;

procedure TLocalisation.FormDeactivate(Sender: TObject);
begin
	if( Visible ) then
		SetWindowPos( Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE );
end;

procedure TLocalisation.FormResize(Sender: TObject);
begin
	if( TreeView.Visible ) then
	  TreeView.SetBounds( TreeView.Left, TreeView.Top,
    										Width - 2 * TreeView.Left, Height - TreeView.Top - 40 );
	if( EditText.Visible ) then
	  EditText.Width := TreeView.Width + TreeView.Left - EditText.Left;
end;

// Check for closed windows
procedure TLocalisation.FormActivate(Sender: TObject);
var
	i, j: integer;
	formsDestroyed, formFound: boolean;
	pFormInfo: TFormInfo;
	form: TForm;
  ScreenFormsList: TList;
begin
	formsDestroyed := FALSE;
  ScreenFormsList := TList.Create;
  for i := 0 to Screen.FormCount - 1 do
  	ScreenFormsList.Add( Screen.Forms[i] );
	// Find the windows that do no exist any longer and de-reference them
	for i := 0 to ScreenFormsList.Count - 1 do
	begin
		pFormInfo := TFormInfo( ScreenFormsList.items[i] );
		form := TForm( pFormInfo.Component );
    // Find out whether the given form is still instantiated
		if( form <> nil ) then
    begin
      j := 0;
      formFound := FALSE;
      while( not(formFound) and (j < ScreenFormsList.Count) ) do
      begin
        if( form = ScreenFormsList.Items[j] ) then
          formFound := TRUE
        else
          j := j + 1;
      end;
			if( not(formFound) ) then
				form := nil;
    end;
		if( form = nil ) then
		begin
			// Find the forms with matching class names
			j := 0;
			formFound := FALSE;
			formsDestroyed := TRUE;
			while( (j < ScreenFormsList.Count - 1) and not(formFound) ) do
			begin
				if( TForm(ScreenFormsList.Items[j]).ClassName = pFormInfo.itClassName ) then
				begin
					formFound := TRUE;
					pFormInfo.ReferenceForm( Screen.Forms[j] );
				end;
				j := j + 1;
			end;
			if( not(formFound) ) then						// cancel the reference
				pFormInfo.Component := nil;
		end;
	end;
  ScreenFormsList.Free;
	if( formsDestroyed ) then
		fFormList.UpdateTreeView();
  if( TreeView.Visible and TreeView.Enabled ) then
	  ActiveControl := TreeView;
end;

// Find the text in the edit box if the [Enter] key is pressed
procedure TLocalisation.EditTextKeyPress(Sender: TObject; var Key: Char);
begin
	if( Key = #13 ) then
  	ButtonNextClick( Sender );
end;

// Find the text in the edit box or skip to the next red bullet from the current selection,
// or from the beginning
procedure TLocalisation.ButtonNextClick(Sender: TObject);
var
	i: integer;
  otherString: ShortString;
  itemString: TItemString;
  text: string;
	node: TTreeNode;
  found, caseSense, redBullets: boolean;
begin
	node := TreeView.Selected;
  if( node = nil ) then
	  node := TreeView.Items.GetFirstNode
	else
  	node := node.GetNext;
  found := FALSE;
  // Find the next red bullet
  if( (EditText.Text = '') or (LowerCase(EditText.Text) = '^x') ) then
  begin
  	redBullets := ( EditText.Text = '' );
    // One loop until the end, then if needed, one from the begining
  	i := 1;
    while( not(found) and (i <= 2) ) do
    begin
    	if( i = 2 ) then
	      node := TreeView.Items.GetFirstNode;
      while( not(found) and (node <> nil) ) do
      begin
        if( redBullets ) then
        begin
        	if( node.ImageIndex >= 2 ) then
          	found := TRUE;
        end
        else
        	if( (node.ImageIndex mod 2 = 1) and (node.Parent <> nil) ) then   
          	if( node.Parent.ImageIndex mod 2 = 0 ) then
		          found := TRUE;
        if( not(found) ) then
          node := node.GetNext;
      end;
      i := i + 1;
    end;
  end
  else
  // Find the next occurrence of the given string
  begin
  	// Case sensitive if some caps are found
  	otherString := AnsiLowerCase( EditText.Text );
    caseSense := not( otherString = EditText.Text );
    if( caseSense ) then
    	otherString := EditText.Text;
    // One loop until the end, then if needed, one from the begining
    i := 1;
    while( not(found) and (i <= 2) ) do
    begin
    	if( i = 2 ) then
	      node := TreeView.Items.GetFirstNode;
      while( not(found) and (node <> nil) ) do
      begin
      	if( Node.Data <> nil ) then
        begin
          // text := TCompInfo(Node.Data).Strings[Node.StateIndex]; // with underlined char
          itemString := TCompInfo(Node.Data).ItemString[Node.StateIndex]; // no underlined char
          if( itemString <> nil ) then
        	  text := itemString.Text;
        end
        else
        begin
        	Beep;
          text := node.Text;
          StripUnderlineChar( text );
        end;
        if( not(caseSense) ) then
          text := AnsiLowerCase(text);
        if( Pos(otherString, text) > 0 ) then
          found := TRUE
        else
          node := node.GetNext;
      end;
      i := i + 1;
    end;
  end;
  if( found ) then
  begin
    cbSecondaryLanguage.ItemIndex := -1;
    cbSecondaryLanguageChange( cbSecondaryLanguage );
    if( node <> nil ) then
	    TreeView.Selected := node;
    if( TreeView.Enabled ) then
      ActiveControl := TreeView;
  end;
end;

procedure TLocalisation.CopyToClipboard;
var
  i, j, k: integer;
  pFormInfo: TFormInfo;
  pCompInfo, secCompInfo: TCompInfo;
  pItemStr: TItemString;
  compString: string;
  TranslatedStrings: TStringList;
begin
  TranslatedStrings := TStringList.Create;
  compString := ' ' + #9 + ComboboxLanguage.Text;
  if( cbSecondaryLanguage.Text <> '' ) then
    compString := compString + #9 + ' ' + #9 + cbSecondaryLanguage.Text;
  TranslatedStrings.Add( compString );
  secCompInfo := nil;
  for i := 0 to fFormList.Count - 1 do
  begin
    pFormInfo := fFormList.Items[i];
    TranslatedStrings.Add( '' );
    for j := -1 to pFormInfo.CompList.Count - 1 do
    begin
      if( j = -1 ) then
        pCompInfo := pFormInfo
      else
        pCompInfo := pFormInfo.CompList.Items[j];
      if( cbSecondaryLanguage.Text <> '' ) then
        secCompInfo := secFormList.FindSameComp( pCompInfo );
      for k := -3 to pCompInfo.NumberOfStrings - 1 do
      begin
        pItemStr := pCompInfo.ItemString[k];
        if( pItemStr <> nil ) then
        begin
          compString := pItemStr.Text;
          if( compString <> '' ) then
          begin
            if( pCompInfo.NewFlag[k] ) then
              compString := '>'  + #9 + compString
            else
              compString := ' '  + #9 + compString;
          end;
          if( secCompInfo <> nil ) then
          begin
            pItemStr := secCompInfo.ItemString[k];
            if( pItemStr <> nil ) then
            begin
              if( secCompInfo.NewFlag[k] ) then
                compString := compString + #9 + '>' + #9 + pItemStr.Text
              else
                compString := compString + #9 + ' ' + #9 + pItemStr.Text;
            end;
          end;
          if( compString <> '' ) then
            TranslatedStrings.Add( compString );
        end;
      end;
    end;
  end;
  Clipboard.Open;
  Clipboard.SetTextBuf( TranslatedStrings.GetText );
  Clipboard.Close;
  TranslatedStrings.Free;
end;

procedure TLocalisation.TreeViewChange(Sender: TObject; Node: TTreeNode);
var
	fieldIndex: integer;
  texte: string;
	pCompInfo, secCompInfo: TCompInfo;
  pItemStr: TItemString;
begin
  texte := '';
	if( Node <> nil ) then
  begin
    pCompInfo := TCompInfo( Node.Data );
    if( fFormList.IsCompValid(pCompInfo) ) then
    begin
      fieldIndex := Node.StateIndex;
      secCompInfo := secFormList.FindSameComp( pCompInfo );
    	// Find the translation in the secondary language
    	if( secCompInfo <> nil ) then
      begin
      	pItemStr := secCompInfo.ItemString[fieldIndex];
        if( pItemStr <> nil ) then
        	texte := pItemStr.Text;
      end;
      // Return string information in the Hint
	    TreeView.Hint := pCompInfo.itClassName + ' : ' + pCompInfo.itName + '.';
      case ( fieldIndex ) of
        -1:	TreeView.Hint := TreeView.Hint + 'Caption';
        -2:	TreeView.Hint := TreeView.Hint + 'ShortHint';
        -3:	TreeView.Hint := TreeView.Hint + 'LongHint';
        else
        	TreeView.Hint := TreeView.Hint + 'Strings[' + IntToStr(fieldIndex) + ']';
      end;
    end;
  end;
  if( texte <> '' ) then
	  EditText.Text := texte;
end;

// When a node is edited, change the corresponding entry (caption, hint, strings...)
// and if other components have the same entry, give the user the possibility
// to update them as well
procedure TLocalisation.OnElementEdited( Sender: TObject; Node: TTreeNode; var S: string );
var
	count: integer;
	text, oldText: string;
	pItemStr: TItemString;
	pCompInfo: TCompInfo;
	fieldIndex: integer;
	changeAll: integer;
 	otherNode: TTreeNode;
begin
	changeAll := IDNO;
	pCompInfo := TCompInfo(Node.Data);
	if( fFormList.IsCompValid(pCompInfo) ) then
  begin
    fieldIndex := Node.StateIndex;
    pItemStr := pCompInfo.ItemString[fieldIndex];
    oldText := Node.Text;
    if( (fieldIndex >= -3) and (fieldIndex < pCompInfo.NumberOfStrings) and (oldText <> S) ) then
    begin
      StripUnderlineChar( oldText );
      Node.Text := S;
      if( TCompInfo(Node.data).Component = nil ) then
        Node.ImageIndex := 1
      else
        Node.ImageIndex := 0;
      Node.SelectedIndex := Node.ImageIndex;
      // Find out whether several occurrences of the given string exist
      if( pItemStr <> nil ) then
      begin
        if( pItemStr.StringList <> nil ) then
        begin
          count := pItemStr.StringList.Count;
          if( count > 1 ) then
          begin
            changeAll := Application.MessageBox( PChar(Constants.Items[msgChangeAll]
                                                       + CRLF + '(' + IntToStr(count) + ')'),
                                                 '', MB_YESNOCANCEL or MB_ICONQUESTION );
            if( changeAll = IDYES ) then
            begin
              Screen.Cursor := crHourGlass;
              // Update the entries in the tree view
              otherNode := TTreeView(Sender).Items.GetFirstNode;
              while( otherNode <> nil ) do
              begin
                text := otherNode.Text;
                StripUnderlineChar( text );
                if( text = oldText ) then
                begin
                  otherNode.Text := S;
                  if( TCompInfo(otherNode.data).Component = nil ) then
                    otherNode.ImageIndex := 1
                  else
                    otherNode.ImageIndex := 0;
                  otherNode.SelectedIndex := otherNode.ImageIndex;
                end;
                otherNode := otherNode.GetNext;
              end;
              // Add the components that have the same text to the list
              pItemStr.SetString( S );
              Screen.Cursor := crDefault;
            end;
          end;
        end;
      end;
      if( changeAll = IDNO ) then
        pCompInfo.ChangeString( Node.StateIndex, S, TRUE, TRUE )
      else if( changeAll = IDCANCEL ) then
        S := pCompInfo.ItemString[Node.StateIndex].Text;
      dataChanged := ( changeAll <> IDCANCEL );
    end;
  end;
end;

// Key event handler
procedure TLocalisation.OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	case( Key ) of
    VK_ESCAPE:	Close;
    VK_F2:			if( ssShift in Shift ) then        // open the window
    							Spread;
    VK_F3:			ButtonNextNewElement.Click;        // find the text / the red bullets
    VK_F5:			if( ssShift in Shift ) then
			            RefreshFormList                  // re-scan the forms & components
			          else                               
			            RefreshTreeView;                 // simply refresh the treeview
    VK_F9:			if( (ssShift in Shift) and ((ssAlt in Shift) or (ssCtrl in Shift)) ) then
    							SetAllBulletsToGreen
    						else
									ToggleBulletColour( ssShift in Shift );
		VK_DELETE:	if( ssShift in Shift ) then
			            DeleteInvalidReferences( ssAlt in Shift );
    else
      if( (Key = Ord('C')) and (ssCtrl in Shift) ) then
        if( TreeView.IsEditing ) then begin end
        else
          if( ActiveControl <> EditText ) then
            CopyToClipboard;
  end;
end;

// Edit the text in the selected node when [F2] is pressed
procedure TLocalisation.TreeViewKeyDown(Sender: TObject; var Key: Word;
																				Shift: TShiftState);
var
	selectedNode: TTreeNode;
begin
	if( (Key = VK_F2) and not(ssShift in Shift) ) then
	begin
		selectedNode := TTreeView(Sender).Selected;
		if( selectedNode <> nil ) then
			selectedNode.EditText;
	end;
end;

// Change the colour of the bullet for the given node
procedure TLocalisation.ToggleNodeBulletColour( node: TTreeNode );
var
	pCompInfo: TCompInfo;
begin
  if( node <> nil ) then
  begin
    pCompInfo := node.Data;
    if( fFormList.IsCompValid(pCompInfo) ) then
    begin
      pCompInfo.NewFlag[node.StateIndex] := not( pCompInfo.NewFlag[node.StateIndex] );
      case( node.ImageIndex ) of
        0: node.ImageIndex := 2;
        1: node.ImageIndex := 3;
        2: node.ImageIndex := 0;
        3: node.ImageIndex := 1;
      end;
      node.SelectedIndex := node.ImageIndex;
      dataChanged := TRUE;
    end;
  end;
end;

// Change the colour of the currently selected element or for all elements
procedure TLocalisation.ToggleBulletColour( all: boolean );
var
	node: TTreeNode;
begin
	TreeView.Items.BeginUpdate;
	if( not(all) ) then
  	ToggleNodeBulletColour( TreeView.Selected )
  else
  begin
    node := TreeView.Items.GetFirstNode;
    while( node <> nil ) do
    begin
			ToggleNodeBulletColour( node );
      node := node.GetNext;
    end;
    dataChanged := TRUE;
  end;
  TreeView.Items.EndUpdate;
end;

// Change all the bullets to green
procedure TLocalisation.SetAllBulletsToGreen;
var
	node: TTreeNode;
	pCompInfo: TCompInfo;
begin
	TreeView.Items.BeginUpdate;
  node := TreeView.Items.GetFirstNode;
  while( node <> nil ) do
  begin
    pCompInfo := node.Data;
    if( fFormList.IsCompValid(pCompInfo) ) then
    begin
    	if( not(dataChanged) ) then
      	dataChanged := pCompInfo.NewFlag[node.StateIndex];		// will be changed to FALSE
      pCompInfo.NewFlag[node.StateIndex] := FALSE;
      if( node.ImageIndex >= 2 ) then
      begin
        node.ImageIndex := node.ImageIndex - 2;
        node.SelectedIndex := node.ImageIndex;
      end;
    end;
    node := node.GetNext;
  end;
  TreeView.Items.EndUpdate;
end;

// Display the window where the selected component is placed
procedure TLocalisation.OnElementEditing(Sender: TObject; Node: TTreeNode;
																					var AllowEdit: Boolean);
var
	i: integer;
	form: TForm;
	pCompInfo: TCompInfo;
	parentItem: TComponent;
  formFound, componentFound: boolean;
begin
	pCompInfo := TCompInfo(Node.Data);
	if( fFormList.IsCompValid(pCompInfo) ) then
	begin
		form := TForm(pCompInfo.ParentForm.Component);
    // Find out whether the given form is still present
		if( form <> nil ) then
    begin
      i := 0;
      formFound := FALSE;
      while( not(formFound) and (i < Screen.FormCount) ) do
        if( form = Screen.Forms[i] ) then
          formFound := TRUE
        else
          i := i + 1;
      if( not(formFound) ) then
        form := nil;
    end;
    // And if so, display it
		if( form <> nil ) then
		begin
			parentItem := pCompInfo.Component;
      i := 0;
      componentFound := (parentItem = form);
      // Find out whether the component still exists
      while( not(componentFound) and (i < form.ComponentCount) ) do
      begin
      	if( form.Components[i] = parentItem ) then
        	componentFound := TRUE
        else
	      	i := i + 1;
      end;
			if( not(componentFound) ) then
     		pCompInfo.Component := nil
      else
      // Look for special parents like tab sheets
			begin
				while( (parentItem <> nil) and
							 (parentItem <> pCompInfo.ParentForm.Component) ) do
				begin
					if( parentItem is TTabSheet ) then		// display the relevant sheet
						TTabSheet(parentItem).PageControl.ActivePage := TTabSheet(parentItem);
					parentItem := parentItem.GetParentComponent;
				end;
			end;
		end;
	end;
end;

procedure DeleteToWasteBin( fichier: TFileName; allowUndo: boolean );
var
	pFileName: array[0..255] of char;
  struct: TSHFileOpStruct;
begin
  if( allowUndo ) then
  begin
    FillChar( pFileName, SizeOf(pFileName), 0 );
    StrPCopy( pFileName, ExpandFileName(fichier)+#0#0 );
    struct.Wnd := 0;
    struct.wFunc := FO_DELETE;
    struct.pFrom := pFileName;
    struct.pTo := nil;
    struct.fAnyOperationsAborted := FALSE;
    struct.hNameMappings := nil;
    struct.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION or FOF_SILENT;
    SHFileOperation( struct )
  end
  else
    DeleteFile( fichier );
end;

function TLocalisation.SaveCurrentLanguage: boolean;
var
	fileName, backupFileName: TFileName;
  backupFileExt: string;
begin
	Result := FALSE;
	if( (selectedLanguage > -1) and (selectedLanguage < NbOfLanguages) ) then
	begin
		fileName := currentDirectory + LanguageFileName + '_'
              + langFileSuffix[selectedLanguage+1] + LangFileExt;
    backupFileExt := '.~' + Copy( LangFileExt, 2, 2 );
    backupFileName := ChangeFileExt( fileName, backupFileExt );
    if( FileExists(backupFileName) ) then
      DeleteToWasteBin( backupFileName, DeleteWithUndo );
    RenameFile( fileName, backupFileName );
		Result := fFormList.WriteLanguageFile( fileName );
		dataChanged := FALSE;
		sLangFileAvailable[selectedLanguage + 1] := FileExists(fileName);
    if( createDefaultLanguageFile ) then
			CopyFile( pChar(fileName), pChar(currentDirectory + LanguageFileName
                                       + '_' + DefLangFileSuffix + LangFileExt), FALSE );
  end;
end;

// When the Save button is pressed, do it
procedure TLocalisation.OnClickSave(Sender: TObject);
begin
	if( SaveCurrentLanguage ) then
	begin
		ComboBoxLanguage.Repaint;
		fFormList.UpdateTreeView;							// show the tree view
	end;
end;

procedure TLocalisation.SetLanguageCode( newLang: word );
var
	i, sel: integer;
  fileName: TFileName;
begin
	sel := -1;
  i := 1;
  while( (i < NbOfLanguages) and (sel = -1) ) do
		if( langFileCode[i] = newLang ) then
    	sel := i
    else
    	i := i + 1;
  if( sel <> -1 ) then
  begin
  	fileName := currentDirectory + LanguageFileName
              + '_' + langFileSuffix[sel] + LangFileExt;
    sLangFileAvailable[sel] := FileExists( fileName );
	  ComboBoxLanguage.Repaint;
    if( sLangFileAvailable[sel] ) then
    begin
    	ComboBoxLanguage.ItemIndex := sel - 1;
      cbLanguageChange( self );
    end;
  end;
end;

// Returns the number of language files available
function TLocalisation.NbLangFilesAvail: integer;
var
	i: integer;
begin
	Result := 0;
	for i := 0 to NbOfLanguages - 1 do
  	if( sLangFileAvailable[i] ) then
    	Result := Result + 1;
end;
 
// When the comboBox selection changes, offer the user to save the changes, if any
// declare all the caption, hint & string texts as new and update them with
// the new language strings, then dynamically update the components and
// update the tree view representation.
procedure TLocalisation.cbLanguageChange(Sender: TObject);
var
	mbRep: integer;
	fileName: string;
  langName: array[0..79] of char;
  readOK: boolean;
begin
	TreeView.Enabled := TRUE;
	buttonSave.Enabled := TRUE;
	if( dataChanged or (selectedLanguage <> ComboBoxLanguage.ItemIndex) ) then
	begin
		if( dataChanged ) then
    	mbRep := Application.MessageBox( PChar(Constants.Items[msgConfirmSave]), '',
																			 MB_YESNOCANCEL or MB_ICONQUESTION )
    else
    	mbRep := IDNO;
    if( mbRep = IDCANCEL ) then
      ComboBoxLanguage.ItemIndex := selectedLanguage
    else
    begin
			if( mbRep = IDYES ) then
				SaveCurrentLanguage;
      selectedLanguage := ComboBoxLanguage.ItemIndex;
      fileName := currentDirectory + LanguageFileName
                + '_' + langFileSuffix[selectedLanguage+1] + LangFileExt;
      if( FileExists(fileName) ) then
        readOK := fFormList.ReadLanguageFile( fileName );
      sLanguageCode := fFormList.LanguageCode;
      if( readOK ) then
      begin
        VerLanguageName( sLanguageCode, @langName, SizeOf(langName)-1 );
        if( ComboboxLanguage.Items[ComboboxLanguage.ItemIndex] <> langName ) then
          ComboBoxLanguage.Hint := langName
        else
          ComboBoxLanguage.Hint := '';
        (* for i := 1 to NbOfLanguages do
          if( langFileCode[i] = sLanguageCode ) then
            selectedLanguage := i - 1;									*)
        fFormList.UpdateAppComponents();					// update the components
        if( createDefaultLanguageFile ) then
          CopyFile( pChar(fileName),
                    pChar(currentDirectory + LanguageFileName
                          + '_' + DefLangFileSuffix + LangFileExt), FALSE );
        dataChanged := FALSE;
      end
      else
        if( (selectedLanguage >= 0) and (selectedLanguage < NbOfLanguages) ) then
          fFormList.LanguageCode := langFileCode[selectedLanguage + 1];
      RefreshTreeView;
      if( TreeView.Visible ) then
	      ActiveControl := TreeView;
      ComboBoxLanguage.ItemIndex := selectedLanguage;
      // Change the help file
      Application.HelpFile := currentDirectory + LanguageFileName + '_'
                              + langFileSuffix[selectedLanguage+1] + '.hlp';
      if( Assigned(FOnLanguageChange) ) then
        FOnLanguageChange( self );
    end;
  end;
end;

procedure TLocalisation.cbSecondaryLanguageChange(Sender: TObject);
var
	selectedLanguage: integer;
  fileName: TFileName;
  langName: array[0..79] of char;
begin
	selectedLanguage := cbSecondaryLanguage.ItemIndex;
  secFormList.Empty;
  if( (selectedLanguage >= 0) and (selectedLanguage < NbOfLanguages) ) then
  begin
    VerLanguageName( selectedLanguage, @langName, SizeOf(langName)-1 );
    if( cbSecondaryLanguage.Items[cbSecondaryLanguage.ItemIndex] <> langName ) then
      cbSecondaryLanguage.Hint := langName
    else
      cbSecondaryLanguage.Hint := '';
    fileName := currentDirectory + LanguageFileName
              + '_' + langFileSuffix[selectedLanguage+1] + LangFileExt;
    if( FileExists(fileName) ) then
      secFormList.ReadLanguageFile( fileName );		// read the file & update secFormList
    if( TreeView.Selected <> nil ) then
	    TreeViewChange( nil, TreeView.Selected );
  end;
end;

// Display non existing languages in italics
procedure TLocalisation.ComboBoxLanguageDrawItem(Control: TWinControl;
	Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
	if( index >= NbOfLanguages ) then
		exit;
	if( sLangFileAvailable[index+1] ) then
	begin
		TComboBox(Control).Canvas.Font.Color := TComboBox(Control).Font.Color;
		TComboBox(Control).Canvas.Font.Style :=
															TComboBox(Control).Font.Style - [fsItalic];
	end
	else
	begin
		TComboBox(Control).Canvas.Font.Color := clGrayText;
		TComboBox(Control).Canvas.Font.Style :=
															TComboBox(Control).Font.Style + [fsItalic];
	end;
	if( odSelected in State ) then
		TComboBox(Control).Canvas.Font.Color := clHighlightText;
	if( index < TCustomComboBox(Control).Items.Count ) then
		TComboBox(Control).Canvas.TextRect( Rect, Rect.Left + 1, Rect.Top + 2,
																				TComboBox(Control).Items[index] );
end;


procedure TLocalisation.OnClickExit(Sender: TObject);
begin
	Close;
end;

// Spread the window and show the treeView
procedure TLocalisation.Spread;
begin
	if( not(TreeView.Visible) ) then
  begin
    minWidth := 2 * TreeView.Left + TreeView.Width;
    minHeight := TreeView.Top + TreeView.Height + 40;
    SetBounds( Left, Top, minWidth, minHeight );
    ButtonSave.Visible := TRUE;
    ButtonNextNewElement.Visible := TRUE;
    TreeView.Visible := TRUE;
    EditText.Visible := TRUE;
    EditText.Text := '';
    EditText.Visible := TRUE;
    cbSecondaryLanguage.Visible := TRUE;
    AutoScroll := FALSE;
    RefreshTreeView;
    if( TreeView.Enabled ) then
      ActiveControl := TreeView;
  end;
end;

// Delete all references to non existing windows
procedure TLocalisation.DeleteInvalidReferences( delForms: boolean );
begin
	if( fFormList.DeleteInvalidReferences(delForms) ) then
	begin
		if( selectedLanguage <> -1 ) then
		begin
			dataChanged := TRUE;
			buttonSave.Enabled := TRUE;
		end;
	  RefreshTreeView;
	end;
end;

// Replacement for TApplication.CreateForm
// Add the newly created form to the form list and localise it
procedure TLocalisation.CreateForm( InstanceClass: TComponentClass; var Reference );
var
	formFound: boolean;
	i: integer;
	form: TForm;
	pFormInfo: TFormInfo;
  Instance: TComponent;
begin
	// Application.CreateForm( FormClass, Reference );
  Instance := TComponent( InstanceClass.NewInstance );
  TComponent( Reference ) := Instance;
  try
    Instance.Create( Application );
  except
    TComponent(Reference) := nil;
    Instance.Free;
    Instance := nil;
    raise;
  end;
	if( @Reference <> nil ) then
		if( TComponent(Reference) is TForm ) then
		begin
			form := TForm( Reference );
			// Search a pFormInfo model to copy the strings from
			formFound := FALSE;
			i := 0;
			while( (i < fFormList.Count) and not(formFound) ) do
			begin
				pFormInfo := TFormInfo( fFormList.Items[i] );
				if( pFormInfo.itClassName = form.ClassName ) then
				begin
					formFound := TRUE;
					pFormInfo.ReferenceForm( form );
          RefreshTreeView;	//fFormList.UpdateTreeView();
				end;
				i := i + 1;
			end;
			// If no model was found, create one
			if( not(formFound) ) then
			begin
				pFormInfo := fFormList.AddForm( form );
				if( pFormInfo.BrowseChildComponents ) then
					pFormInfo.ShowFormComponents( TreeView )
				else
					fFormList.RemoveForm( pFormInfo );
				if( selectedLanguage <> -1 ) then
					dataChanged := TRUE;
			end;
      if( Assigned(FOnCreateWindow) ) then
        FOnCreateWindow( self );
		end;
end;

// Replacement for TApplication.MessageBox
function TLocalisation.MessageBox(Text, Caption: string; Flags: Longint): Integer;
var
  ActiveWindow: HWnd;
  WindowList: Pointer;
begin
  ActiveWindow := GetActiveWindow;
  WindowList := DisableTaskWindows(0);
  try
    Result := Windows.MessageBoxEx( Handle, PChar(Text), PChar(Caption), Flags, sLanguageCode );
  finally
    EnableTaskWindows(WindowList);
    SetActiveWindow(ActiveWindow);
  end;
end;

// Used by TLocalisation.MessageDlgPos
function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of Char;
begin
  for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

// Replacement for Dialogs.MessageDlgPos
function TLocalisation.MessageDlgPos(const Msg: string; DlgType: TMsgDlgType;
											  Buttons: TMsgDlgButtons; HelpCtx: Longint; X, Y: Integer): Word;
const
  HelpFileName = '';
  mcHorzMargin = 8;                                                       
  mcVertMargin = 8;
  mcHorzSpacing = 10;
  mcVertSpacing = 10;
  mcButtonWidth = 50;
  mcButtonHeight = 14;
  mcButtonSpacing = 4;
  IconIDs: array[TMsgDlgType] of PChar = (IDI_EXCLAMATION, IDI_HAND,
    IDI_ASTERISK, IDI_QUESTION, nil);
  ButtonNames: array[TMsgDlgBtn] of string = (
    'Yes', 'No', 'OK', 'Cancel', 'Abort', 'Retry', 'Ignore', 'All', 'NoToAll',
    'YesToAll', 'Help');
  ModalResults: array[TMsgDlgBtn] of Integer = (
    mrYes, mrNo, mrOk, mrCancel, mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll,
    mrYesToAll, 0);
var
	msgForm: TMessageForm;
  DialogUnits: TPoint;
  i: integer;
  HorzMargin, VertMargin, HorzSpacing, VertSpacing, ButtonWidth,
  ButtonHeight, ButtonSpacing, ButtonCount, ButtonGroupWidth,
  IconTextWidth, IconTextHeight, L, ALeft: Integer;
  B, DefaultButton, CancelButton: TMsgDlgBtn;
  IconID: PChar;
  TextRect: TRect;
begin
  msgForm := TMessageForm.CreateNew(Application);
  with msgForm do
  try
    {$IFDEF Delphi4+} BiDiMode := Application.BiDiMode; {$ENDIF Delphi4+}
    BorderStyle := bsDialog;
    Canvas.Font := Font;
    DialogUnits := GetAveCharSize(Canvas);
    HorzMargin := MulDiv(mcHorzMargin, DialogUnits.X, 4);
    VertMargin := MulDiv(mcVertMargin, DialogUnits.Y, 8);
    HorzSpacing := MulDiv(mcHorzSpacing, DialogUnits.X, 4);
    VertSpacing := MulDiv(mcVertSpacing, DialogUnits.Y, 8);
    ButtonWidth := MulDiv(mcButtonWidth, DialogUnits.X, 4);
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    begin
      if B in Buttons then
      begin
        i := Integer( B );
        if( (ButtonWidths[B] = 0) and
            (i >= 0) and (i < ButtonCaptions.Items.Count) ) then
        begin
          TextRect := Rect(0,0,0,0);
          Windows.DrawText( canvas.handle,
            PChar(ButtonCaptions.Items[I]), -1,
            TextRect, DT_CALCRECT or DT_LEFT or DT_SINGLELINE
            {$IFDEF Delphi4+} or DrawTextBiDiModeFlagsReadingOnly{$ENDIF Delphi4+});
          with TextRect do ButtonWidths[B] := Right - Left + 8;
        end;
        if ButtonWidths[B] > ButtonWidth then
          ButtonWidth := ButtonWidths[B];
      end;
    end;
    ButtonHeight := MulDiv(mcButtonHeight, DialogUnits.Y, 8);
    ButtonSpacing := MulDiv(mcButtonSpacing, DialogUnits.X, 4);
    SetRect(TextRect, 0, 0, Screen.Width div 2, 0);
    DrawText(Canvas.Handle, PChar(Msg), Length(Msg), TextRect,
      DT_EXPANDTABS or DT_CALCRECT or DT_WORDBREAK
      {$IFDEF Delphi4+} or DrawTextBiDiModeFlagsReadingOnly{$ENDIF Delphi4+});
    IconID := IconIDs[DlgType];
    IconTextWidth := TextRect.Right;
    IconTextHeight := TextRect.Bottom;
    if IconID <> nil then
    begin
      Inc(IconTextWidth, 32 + HorzSpacing);
      if IconTextHeight < 32 then IconTextHeight := 32;
    end;
    ButtonCount := 0;
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if B in Buttons then Inc(ButtonCount);
    ButtonGroupWidth := 0;
    if ButtonCount <> 0 then
      ButtonGroupWidth := ButtonWidth * ButtonCount + ButtonSpacing * (ButtonCount - 1);
    if( IconTextWidth > ButtonGroupWidth ) then
	    ClientWidth := IconTextWidth
    else
	    ClientWidth := ButtonGroupWidth;
    ClientWidth := ClientWidth + HorzMargin * 2;
    ClientHeight := IconTextHeight + ButtonHeight + VertSpacing + VertMargin * 2;
    Left := (Screen.Width div 2) - (Width div 2);
    Top := (Screen.Height div 2) - (Height div 2);
    i := Integer(DlgType) - Integer( Low(TMsgDlgType) );
    if( (DlgType <> mtCustom) and (i >= 0) and (i < DialogCaptions.Items.Count)) then
      Caption := DialogCaptions.Items.Strings[i]
    else
      Caption := Application.Title;
    if IconID <> nil then
      with TImage.Create(msgForm) do
      begin
        Name := 'Image';
        Parent := msgForm;
        Picture.Icon.Handle := LoadIcon(0, IconID);
        SetBounds(HorzMargin, VertMargin, 32, 32);
      end;
    with TLabel.Create(msgForm) do
    begin
      Name := 'Message';
      Parent := msgForm;
      WordWrap := True;
      Caption := Msg;
      BoundsRect := TextRect;
      ALeft := IconTextWidth - TextRect.Right + HorzMargin;
      {$IFDEF Delphi4+}
      BiDiMode := Result.BiDiMode;
      if UseRightToLeftAlignment then
        ALeft := Result.ClientWidth - ALeft - Width;
      {$ENDIF Delphi4+}
      SetBounds(ALeft, VertMargin, TextRect.Right, TextRect.Bottom);
    end;
    if mbOk in Buttons then DefaultButton := mbOk else
      if mbYes in Buttons then DefaultButton := mbYes else
        DefaultButton := mbRetry;
    if mbCancel in Buttons then CancelButton := mbCancel else
      if mbNo in Buttons then CancelButton := mbNo else
        CancelButton := mbOk;
    L := (ClientWidth - ButtonGroupWidth) div 2;
    for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      if B in Buttons then
        with TButton.Create(msgForm) do
        begin
          Name := ButtonNames[B];
          Parent := msgForm;
          i := Integer( B );
          if( (i >= 0) and (i < ButtonCaptions.Items.Count) ) then
            Caption := ButtonCaptions.Items.Strings[i];
          ModalResult := ModalResults[B];
          if B = DefaultButton then Default := True;
          if B = CancelButton then Cancel := True;
          SetBounds(L, IconTextHeight + VertMargin + VertSpacing,
            ButtonWidth, ButtonHeight);
          Inc(L, ButtonWidth + ButtonSpacing);
          if B = mbHelp then
            OnClick := TMessageForm(msgForm).HelpButtonClick;
        end;
    HelpContext := HelpCtx;
    HelpFile := HelpFileName;
    if X >= 0 then Left := X;
    if Y >= 0 then Top := Y;
    Result := ShowModal;
  finally
    Free;
  end;
end;

procedure TLocalisation.RefreshTreeView;
var
	index, count: integer;
	found: boolean;
	node: TTreeNode;
  pCompInfo: TCompInfo;
begin
	if( TreeView.Visible ) then
  begin
  	count := TreeView.Items.Count;
    node := TreeView.Selected;
    if( node <> nil ) then
    begin
    	pCompInfo := TCompInfo( node.Data );   
      index := node.AbsoluteIndex;
    end
    else
    begin
			pCompInfo := nil;
      index := -1;
    end;
		fFormList.ShowAppComponents();			// show the components' strings
    found := FALSE;
    if( (pCompInfo <> nil) and (count <> TreeView.Items.Count) ) then
    begin
    	node := TreeView.Items.GetFirstNode;
      while( not(found) and (node <> nil) ) do
      	if( node.Data = pCompInfo ) then
        	found := TRUE
        else
	      	node := node.GetNext;
    end;
    if( found and (node <> nil) ) then
	    TreeView.Selected := node
    else
    	if( (index > -1) and (index < TreeView.Items.Count) and (count = TreeView.Items.Count) ) then
				TreeView.Selected := TreeView.Items[index];
  end;
end;

procedure TLocalisation.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
	mbRep: integer;
begin
	CanClose := TRUE;
	if( dataChanged = TRUE ) then
  begin
  	mbRep := Application.MessageBox(PChar(Constants.Items[msgConfirmSave]), '',
																		MB_YESNOCANCEL or MB_ICONQUESTION );
    if( mbRep = IDYES ) then
			buttonSave.Click
    else
	    if( mbRep = IDCANCEL ) then
				CanClose := FALSE;
  end;
end;

procedure TLocalisation.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	TreeView.Visible := FALSE;
  EditText.Visible := FALSE;
  EditText.Visible := FALSE;
  cbSecondaryLanguage.Visible := FALSE;
  ButtonSave.Visible := FALSE;
  ButtonNextNewElement.Visible := FALSE;
	minWidth := ButtonExit.Left + ButtonExit.Width + 20;
	minHeight := 80;
  SetBounds( Left, Top, minWidth, minHeight );
  cbSecondaryLanguage.ItemIndex := -1;
  EditText.Text := '';
	Action := caHide;
end;

procedure InitButtonWidths;
var
  B: TMsgDlgBtn;
begin
  for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    ButtonWidths[B] := 0;
end;

initialization
  InitButtonWidths;

end.
