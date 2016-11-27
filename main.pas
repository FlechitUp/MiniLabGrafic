unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uCmdBox, TAGraph, Forms, Controls, Graphics,
  Dialogs, ComCtrls, Grids, ValEdit, ExtCtrls, ShellCtrls, EditBtn, Menus,
  ParseMath, StdCtrls, ColorBox, spktoolbar, spkt_Tab, spkt_Pane, spkt_Buttons,
  TAChartUtils, TASeries, TAFuncSeries, spkt_Checkboxes;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    cboxColorFuncion: TColorBox;
    chkMostrarValores: TCheckBox;
    chkEscogerN: TCheckBox;
    chkMostrarPuntos: TCheckBox;
    chkUsarPloteo: TCheckBox;
    ediN: TEdit;
    Panel1: TPanel;
    Plotchar: TChart;
    CmdBox: TCmdBox;
    dEdit: TDirectoryEdit;
    lblCommandHistory: TLabel;
    lblCommandHistory1: TLabel;
    lblFileManager: TLabel;
    pgcRight: TPageControl;
    Funcion: TFuncSeries;
    EjeX: TConstantLine;
    EjeY: TConstantLine;
    Plotear: TLineSeries;
    pnlArvhivos: TPanel;
    pnlCommand: TPanel;
    pnlPlot: TPanel;
    slvFiles: TShellListView;
    stvDirectories: TShellTreeView;
    spkcheckSeePlot: TSpkCheckbox;
    SpkLargeButton1: TSpkLargeButton;
    SpkLargeButton2: TSpkLargeButton;
    SpkLargeButton3: TSpkLargeButton;
    SpkLargeButton4: TSpkLargeButton;
    SpkLargeButton5: TSpkLargeButton;
    SpkPane1: TSpkPane;
    SpkPane2: TSpkPane;
    SpkPane3: TSpkPane;
    spkRdoPlotIn: TSpkRadioButton;
    spkRdoPlotEx: TSpkRadioButton;
    SpkTab1: TSpkTab;
    SpkToolbar1: TSpkToolbar;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    StatusBar1: TStatusBar;
    tbtnClosePlot: TToolButton;
    tshcomandos: TTabSheet;
    tshVariables: TTabSheet;
    tBarPlot: TToolBar;
    tvwHistory: TTreeView;
    ValueListEditor1: TValueListEditor;
    procedure chkUsarPloteoChange(Sender: TObject);
    procedure CmdBoxInput(ACmdBox: TCmdBox; Input: string);
    procedure dEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure spkcheckSeePlotClick(Sender: TObject);
    procedure tbtnClosePlotClick(Sender: TObject);

    procedure FuncionCalculate(const AX: Double; out AY: Double);

    Procedure GraficarFuncion();
    Procedure GraficarFuncionConPloteo();

  private
    { private declarations }
    ListVar: TStringList;
    Parse: TParseMath;
    CBOfunction,
    Xminimo,
    Xmaximo: String;


    function f( x: Double ): Double;
    Procedure DetectarIntervalo();

  //  function f( x: Double ): Double;
  //  Procedure DetectarIntervalo();

    procedure StartCommand();

  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}


function obter_elemento(posi :Integer ; str_ : String): String;
var
  i, adetect :Integer;
  aux, aux1 : String;
begin
  //ShowMessage('obter_elemento '+str_);
  aux1 := str_;
  aux := copy( aux1,8,Length(aux1)-8);
  aux := ';'+aux;

  for i:=0 to posi do
  begin
     adetect := Pos(';',aux);
     aux := copy( aux , adetect+1 , Length(aux) );
  end;

  adetect:= Pos(';',aux);
  if adetect >0 then
  begin
     delete (aux ,adetect, Length(aux)+1-adetect );

  end;
  //ShowMessage('obter_elemento Resp '+aux);
  obter_elemento := aux;
end;

{ TfrmMain }


Procedure TfrmMain.DetectarIntervalo();
var
    PosCorcheteIni, PosCorcheteFin, PosSeparador: Integer;
    PosicionValidad: Boolean;
    funcion_set : String ;
begin
    //funcion_set := cboFuncion.Text;
    funcion_set := CBOfunction;

    Xminimo := obter_elemento(1,funcion_set);
    Xminimo := Trim( Xminimo );

    Xmaximo := obter_elemento(2,funcion_set);
    Xmaximo := Trim( Xmaximo );

end;

function TfrmMain.f( x: Double ): Double;
begin
     //parse.Expression:= Trim(cboFuncion.Text);
     parse.Expression := obter_elemento(0,CBOfunction);
     Parse.NewValue('x' , x );
     Result:= Parse.Evaluate();
end;

Procedure TfrmMain.GraficarFuncion();
begin
    Plotear.Clear;
    with Funcion do begin
      Active:= False;

      Extent.XMax:= StrToFloat( Xmaximo );
      Extent.XMin:= StrToFloat( Xminimo );

      Extent.UseXMax:= true;
      Extent.UseXMin:= true;
      Funcion.Pen.Color:=  cboxColorFuncion.Colors[ cboxColorFuncion.ItemIndex ];

      Active:= True;

  end;
end;

Procedure TfrmMain.GraficarFuncionConPloteo();
var i: Integer;
    Max, Min, h, NewX: Real;

begin
    Funcion.Active:= False;
    Plotear.Clear;
    Max:=  StrToFloat( Xmaximo );
    Min:=  StrToFloat( Xminimo ) ;

    if chkEscogerN.Checked then
       h:= 1 / StrToFloat( ediN.Text )

    else
        h:= (Max - Min) /( 10 * Max );

    if chkMostrarValores.Checked then
       Plotear.Marks.Style:= smsValue
    else
       Plotear.Marks.Style:= smsNone;

    Plotear.ShowPoints:= chkMostrarPuntos.Checked;

    NewX:= StrToFloat( Xminimo );
    Plotear.LinePen.Color:= cboxColorFuncion.Colors[ cboxColorFuncion.ItemIndex ];  ;

    while NewX < Max do begin
       Plotear.AddXY( NewX, f( NewX ) );
       NewX:= NewX + h;

    end;



end;



procedure TfrmMain.dEditChange(Sender: TObject);
begin
  if DirectoryExists(dEdit.Text) then
  stvDirectories.Root:= dEdit.Text;
end;

procedure TfrmMain.StartCommand();
begin
   CmdBox.StartRead( clBlack, clWhite,  'MiniLab-->', clBlack, clWhite);
end;

procedure TfrmMain.CmdBoxInput(ACmdBox: TCmdBox; Input: string);
var FinalLine: string;

  procedure AddVariable( EndVarNamePos: integer );
  var PosVar: Integer;
    const NewVar= -1;
  begin

    PosVar:= ListVar.IndexOfName( trim( Copy( FinalLine, 1, EndVarNamePos  ) ) );

    with ValueListEditor1 do
    case PosVar of
         NewVar: begin
                  ListVar.Add(  FinalLine );
                  Parse.AddVariable( ListVar.Names[ ListVar.Count - 1 ], StrToFloat( ListVar.ValueFromIndex[ ListVar.Count - 1 ]) );
                  Cells[ 0, RowCount - 1 ]:= ListVar.Names[ ListVar.Count - 1 ];
                  Cells[ 1, RowCount - 1 ]:= ListVar.ValueFromIndex[ ListVar.Count - 1 ];
                  RowCount:= RowCount + 1;

         end else begin
              ListVar.Delete( PosVar );
              ListVar.Insert( PosVar,  FinalLine );
              Cells[ 0, PosVar + 1 ]:= ListVar.Names[ PosVar ] ;
              Cells[ 1, PosVar + 1 ]:= ListVar.ValueFromIndex[ PosVar ];
              Parse.NewValue( ListVar.Names[ PosVar ], StrToFloat( ListVar.ValueFromIndex[ PosVar ] ) ) ;

          end;

    end;


  end;

  procedure Execute();
  begin
      Parse.Expression:= Input ;
      CmdBox.TextColors(clBlack,clWhite);
      CmdBox.Writeln( LineEnding +  FloatToStr( Parse.Evaluate() )  + LineEnding);


  end;


begin
  Input:= Trim(Input);
  case input of
       'help': ShowMessage( 'help ');
       'exit': Application.Terminate;
       'clear': begin CmdBox.Clear; StartCommand() end;
       'clearhistory': CmdBox.ClearHistory;

        else begin
             FinalLine:=  StringReplace ( Input, ' ', '', [ rfReplaceAll ] );
             if Pos( '=', FinalLine ) > 0 then
                AddVariable( Pos( '=', FinalLine ) - 1 )
             else if Pos( 'grafic', FinalLine ) > 0 then
             begin
                  CBOfunction := FinalLine;
                  DetectarIntervalo();

                  if chkUsarPloteo.Checked then
                       GraficarFuncionConPloteo()
                 else
                      GraficarFuncion();
             end

             else
                Execute;

        end;

  end;
  StartCommand()
end;

procedure TfrmMain.chkUsarPloteoChange(Sender: TObject);
begin
  Panel1.Enabled:=chkUsarPloteo.Checked;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  CmdBox.StartRead( clBlack, clWhite,  'MiniLab-->', clBlack, clWhite);

  with ValueListEditor1 do begin
    Cells[ 0, 0]:= 'Nombre';
    Cells[1, 0]:= 'Valor';
    Clear;

  end;

  ListVar:= TStringList.Create;
  Parse:= TParseMath.create();
  Parse.AddVariable('x',0.0);

end;


procedure TfrmMain.FuncionCalculate(const AX: Double; out AY: Double);
begin
  AY := f( AX )
end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  ListVar.Destroy;
  Parse.Destroy;
end;

procedure TfrmMain.spkcheckSeePlotClick(Sender: TObject);
begin
  pnlPlot.Visible:= not pnlPlot.Visible;
  cboxColorFuncion.Visible := not cboxColorFuncion.Visible ;
  chkUsarPloteo.Visible := not chkUsarPloteo.Visible ;
  if spkcheckSeePlot.Checked = False then
  begin
    Panel1.Enabled:=cboxColorFuncion.Visible;
    chkUsarPloteo.Checked:=spkcheckSeePlot.Checked;
  end;
end;

procedure TfrmMain.tbtnClosePlotClick(Sender: TObject);
begin
  spkcheckSeePlot.Checked:= False;
  pnlPlot.Visible:= False;
  cboxColorFuncion.Visible:=False;
  Panel1.Enabled:= False;
   chkUsarPloteo.Visible := not chkUsarPloteo.Visible ;
end;

end.

