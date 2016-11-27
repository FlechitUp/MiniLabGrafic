unit ParseMath;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, fpexprpars,Dialogs;

type
  TParseMath = Class

  Private
      FParser: TFPExpressionParser;
      identifier: array of TFPExprIdentifierDef;
      Procedure AddFunctions();


  Public

      Expression: string;
      function NewValue( Variable:string; Value: Double ): Double;
      procedure AddVariable( Variable: string; Value: Double );
      function Evaluate(): Double;
      constructor create();
//      constructor create2();
      destructor destroy;

  end;

implementation


constructor TParseMath.create;
begin
   FParser:= TFPExpressionParser.Create( nil );
   FParser.Builtins := [bcMath];
   AddFunctions();
   //FParser.Identifiers.AddFloatVariable( 'x', 0);
end;

destructor TParseMath.destroy;
begin
    FParser.Destroy;
end;

function TParseMath.NewValue( Variable: string; Value: Double ): Double;
begin
    FParser.IdentifierByName(Variable).AsFloat:= Value;

end;

function TParseMath.Evaluate(): Double;
begin
     FParser.Expression:= Expression;
     Result:= FParser.Evaluate.ResFloat;
end;

function IsNumber(AValue: TExprFloat): Boolean;
begin
  result := not (IsNaN(AValue) or IsInfinite(AValue) or IsInfinite(-AValue));
end;

Procedure ExprTan( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and ((frac(x - 0.5) / pi) <> 0.0) then
      Result.resFloat := tan(x)

   else
     Result.resFloat := NaN;
end;

Procedure ExprSin( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   Result.resFloat := sin(x)

end;

Procedure ExprCos( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
   x := ArgToFloat( Args[ 0 ] );
   Result.resFloat := cos(x)

end;

Procedure ExprLn( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
    x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and (x > 0) then
      Result.resFloat := ln(x)

   else
     Result.resFloat := NaN;

end;

Procedure ExprLog( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
    x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and (x > 0) then
      Result.resFloat := ln(x) / ln(10)

   else
     Result.resFloat := NaN;

end;

Procedure ExprSQRT( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x: Double;
begin
    x := ArgToFloat( Args[ 0 ] );
   if IsNumber(x) and (x > 0) then
      Result.resFloat := sqrt(x)

   else
     Result.resFloat := NaN;

end;

Procedure ExprPower( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  x,y: Double;
begin
    x := ArgToFloat( Args[ 0 ] );
    y := ArgToFloat( Args[ 1 ] );


     Result.resFloat := power(x,y);

end;


Procedure ExprBiseccion( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  a,b,xn,e,e1,sig,n,auxe:Float;
  cont:Integer;
  funct:String;
  MiParse,MiParse2:TParseMath;
begin
    a := ArgToFloat( Args[ 0 ] );
    b := ArgToFloat( Args[ 1 ] );
    e := ArgToFloat( Args[ 2 ] );
    funct :=  Args[ 3 ].ResString ;
    MiParse:=TParseMath.create();
    MiParse2:=TParseMath.create();
    MiParse.AddVariable('x',a);
    MiParse2.AddVariable('x',b);
    e1:=e+1;
    n:=1;
    cont:=0;
    xn:=a;
    MiParse.Expression:=funct;
    MiParse2.Expression:=funct;
  while(e1>e)do
  begin
    cont:=cont+1;
    auxe:=xn;
    xn:=RoundTo((a+b)/2,-4);
    MiParse2.NewValue('x',xn);
    if(MiParse2.Evaluate()=0)then
    begin
      e1:=MiParse2.Evaluate();
    end
    else
    begin
      e1:=abs(xn-auxe);
    end;
    n:=n+1;
    MiParse.NewValue('x',a);
    sig:=MiParse.Evaluate()*MiParse2.Evaluate();

    if(sig>0)then
    begin
      a:=xn;
    end;
    if(sig<0)then
    begin
      b:=xn;
    end;
    end;


    Result.resFloat := xn;

end;

function Derivadas(var x:Float;var t:string;var h:Float):Float;
var
  MiParse: TParseMath;
  MiParse2: TParseMath;
Begin
  //Derivada:=(Fun(x+h)-Fun(x))/h;
  MiParse:= TParseMath.create();
  MiParse2:= TParseMath.create();
  MiParse.AddVariable( 'x', x+h );
  MiParse2.AddVariable( 'x', x );
  MiParse.Expression:= t;
  MiParse2.Expression:= t;
  Derivadas:=(MiParse.Evaluate()-MiParse2.Evaluate())/h;
end;

Procedure ExprFalpos( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  a,b,xn,e,e1,sig,n,auxe:Float;
  cont:Integer;
  funct:String;
  MiParse,MiParse2:TParseMath;
begin
    a := ArgToFloat( Args[ 0 ] );
    b := ArgToFloat( Args[ 1 ] );
    e := ArgToFloat( Args[ 2 ] );
    funct :=  Args[ 3 ].ResString ;
    MiParse:=TParseMath.create();
    MiParse2:=TParseMath.create();
    MiParse.AddVariable('x',a);
    MiParse2.AddVariable('x',b);
    e1:=e+1;
    n:=1;
    cont:=0;
    xn:=a;
    MiParse.Expression:=funct;
    MiParse2.Expression:=funct;
  while(e1>e)do
  begin
    cont:=cont+1;
    //auxe:=xn;
    MiParse.NewValue('x',a);
    MiParse2.NewValue('x',b);
    auxe:=xn;
    xn:=RoundTo(a-(MiParse.Evaluate()*(b-a)/(MiParse2.Evaluate()-MiParse.Evaluate())),-4);
    MiParse2.NewValue('x',xn);
    if(MiParse2.Evaluate()=0)then
    begin
      e1:=MiParse2.Evaluate();
    end
    else
    begin
      e1:=abs(xn-auxe);
    end;
    n:=n+1;
    MiParse.NewValue('x',a);
    sig:=MiParse.Evaluate()*MiParse2.Evaluate();

    if(sig>0)then
    begin
      a:=xn;
    end;
    if(sig<0)then
    begin
      b:=xn;
    end;
    end;
    Result.resFloat := xn;
end;

Procedure ExprSecante( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  xn,xn1,e,e1,n,h:Float;
  MiParse: TParseMath;
  cont:Integer;
  t:String;
begin
  MiParse:= TParseMath.create();
  xn := ArgToFloat( Args[ 0 ] );
  e := ArgToFloat( Args[ 1 ] );
  t:= Args[ 2 ].ResString ;
  MiParse.AddVariable( 'x', xn );
  MiParse.Expression:=t;
  e1:=e+1;
  h:=e/10;
  n:=1;
  cont:=0;
  while(e1>e)do
  begin
  cont:=cont+1;
  xn1:=RoundTo(xn-(MiParse.Evaluate()/Derivadas(xn,t,h)),-4);
  e1:=abs(xn1-xn);
  xn:=xn1;
  n:=n+1;
  MiParse.NewValue('x',xn);
  end;
  Result.resFloat := xn;
end;

Procedure ExprTrapecio( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  m_function:TParseMath;
  la,i,h,lb,resp,fa,fb,sum:Float;
  n:Integer;
  fun:String;
begin
  m_function:=TParseMath.create();
  m_function.AddVariable('x',0);
  fun:=Args[ 2 ].ResString ;
  m_function.Expression:=fun;
  la:=ArgToFloat( Args[ 0 ] );
  lb:=ArgToFloat( Args[ 1 ] );
  n:={StrToInt(numN.Text)}10000;
  h:=(lb-la)/n;
  m_function.NewValue('x',la);
  fa:=m_function.Evaluate();
  m_function.NewValue('x',lb);
  fb:=m_function.Evaluate();
  sum:=0;
  //for i:=
  i:=la+h;
  repeat
    m_function.NewValue('x',i);
    sum:=sum+m_function.Evaluate();
    i:=i+h;
  until i>=lb;
  resp:=RoundTo(0.5*h*(fa+fb)+h*sum,-6);
  Result.resFloat := resp;

end;

Procedure ExprSimpson( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  m_function:TParseMath;
  la,i,h,lb,resp,fa,fb,sump,sumi:Float;
  n:Integer;
  fun:String;
begin
  m_function:=TParseMath.create();
  m_function.AddVariable('x',0);
  fun:=Args[ 2 ].ResString ;
  m_function.Expression:=fun;
  la:=ArgToFloat( Args[ 0 ] );
  lb:=ArgToFloat( Args[ 1 ] );
  n:={StrToInt(numN.Text)}12;
  h:=(lb-la)/power(2,n);
  m_function.NewValue('x',la);
  fa:=m_function.Evaluate();
  m_function.NewValue('x',lb);
  fb:=m_function.Evaluate();
  sump:=0;
  sumi:=0;
  i:=la+h;
  repeat
    m_function.NewValue('x',i);
    sumi:=sumi+m_function.Evaluate();
    i:=i+2*h;
    //ShowMessage('hola!!');
  until i>=lb;

  i:=la+2*h;
  repeat
    m_function.NewValue('x',i);
    sump:=sump+m_function.Evaluate();
    i:=i+2*h;
    //ShowMessage('hola!!');
  until i>=lb-h;

  resp:=RoundTo((h/3)*(fa+fb)+(2*h/3)*sump+(4*h/3)*sumi,-6);
  Result.resFloat := resp;

end;



function evaluar(valorX : float ; valorY: float;  funcion : String ) : float;
var
   MiParse : TParseMath;
begin
  Miparse := TParseMath.create();
  MiParse.AddVariable('x',valorX);
  MiParse.AddVariable('y',valorY);
  MiParse.Expression:=funcion;
  evaluar := MiParse.Evaluate();
end;


procedure ExpEuler( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  h,y_n1,y_n, x_n, xf: float;
  i,j,n : Integer;
  fun :String;

begin
    fun :=Args[0].ResString;
    x_n := ArgToFloat(Args[1]);
    xf := ArgToFloat(Args[2]);
    y_n := ArgToFloat(Args[3]);

    n := Args[4].ResInteger;

    h := (xf-x_n)/n;


    for i:= 2 to n+1 do
    begin
        y_n1 := y_n+h*evaluar(x_n,y_n,fun);
        x_n := x_n+h;
        {
        StringGrid1.Cells[0,i]:=IntToStr(i-1);
        StringGrid1.Cells[1,i]:=FloatToStr(x_n);
        StringGrid1.Cells[2,i]:=FloatToStr(y_n1);
        }
        y_n := y_n1;

    end;
       {
    while x_n <= xf do
    begin
      y_n1 := y_n+h*evaluar(x_n,y_n,fun);
      x_n := x_n+h;
      y_n := y_n1;
    end;
          }

    Result.ResFloat:=(y_n1);
end;


Procedure ExpHeun( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  fun :String;
  h,y_nE,y_n1,y_n, x_n,xf, resp1: float;
  i,j,n : Integer;

begin

    fun :=Args[0].ResString;
    x_n := ArgToFloat(Args[1]);
    xf := ArgToFloat(Args[2]);
    y_n := ArgToFloat(Args[3]);

    n := Args[4].ResInteger;
    h := (xf-x_n)/n;


    for i:= 2 to n+1 do
    begin
        resp1 := evaluar(x_n,y_n,fun);
        y_nE := y_n+h*resp1; //Hallo Euler
        x_n := x_n+h;
        //y_n := y_nE;
        y_n1 := y_n+h*(resp1+evaluar(x_n,y_nE,fun))/2;
       { StringGrid1.Cells[0,i] := IntToStr(i-1);
        StringGrid1.Cells[1,i] := FloatToStr(x_n);
        StringGrid1.Cells[2,i] := FloatToStr(y_n1);}
        y_n := y_n1;
    end;
    //y_n1:=y_n1+1;
    Result.ResFloat:=(y_n1);
    //Result.ResString:='a';
end;




Procedure ExpRK3( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
   fun : String;
   x_0 ,xf,y_0 ,h ,k1 ,k2 ,k3 ,y_1: float;
   i,i1,j : Integer;
begin
   fun := Args[0].ResString;
   x_0 := ArgToFloat(Args[1]);
   y_0 := ArgToFloat(Args[2]);
   h := ArgToFloat(Args[3]);
   xf:=   ArgToFloat(Args[4]);
   i1 := Round((xf - x_0)/h);


 for i := 2 to  i1+1 do
 begin
     k1 := h*evaluar(x_0,y_0,fun);
     k2 := h*evaluar(x_0 + (h/2), y_0 + (k1/2),fun);
     k3 := h*evaluar(x_0 + h, y_0 - k1 +2*k2 ,fun);
     y_1 := y_0 + (k1 + 4*k2 + k3)/6;

     x_0 := x_0 + h;
     y_0 := y_1;

     { LLenado de String Grid }
     {    StringGrid2.Cells[0, i] := FloatToStr(i-1);
         StringGrid2.Cells[1,i] := FloatToStr(x_0);
         StringGrid2.Cells[2,i] := FloatToStr(k1);
         StringGrid2.Cells[3,i] := FloatToStr(k2);
         StringGrid2.Cells[4,i] := FloatToStr(k3);
         StringGrid2.Cells[6,i] := FloatToStr(y_1);}
     { End LLenado de String Grid }


    Result.ResFloat:=(y_1);
 end;

end;


procedure ExpRK4( var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
   fun : String;
   x_0 ,y_0 ,xf ,h ,k1 ,k2 ,k3 ,k4 ,y_1: float;
   i,i1,j : Integer;
begin
   fun := Args[0].ResString;
   x_0 := ArgToFloat(Args[1]);
   y_0 := ArgToFloat(Args[2]);
   h := ArgToFloat(Args[3]);
   xf:=   ArgToFloat(Args[4]);
   i1 := Round((xf - x_0)/h);


 for i := 2 to  i1 +1do
 begin
     k1 := evaluar(x_0,y_0,fun)*h;
     k2 := evaluar(x_0 + (h/2), y_0 + (k1/2),fun)*h;
     k3 := evaluar(x_0 + (h/2), y_0 + (k2/2),fun)*h;
     k4 := evaluar(x_0 + h , y_0 + k3,fun)*h;
     y_1 := y_0 + (k1 + 2*k2 + 2*k3 +k4)/6;

     x_0 := x_0 + h;
     y_0 := y_1;


     Result.ResFloat:=(y_1);
 end;

end;



Procedure TParseMath.AddFunctions();
begin
   with FParser.Identifiers do begin
       AddFunction('tan', 'F', 'F', @ExprTan);
       AddFunction('sin', 'F', 'F', @ExprSin);
       AddFunction('sen', 'F', 'F', @ExprSin);
       AddFunction('cos', 'F', 'F', @ExprCos);
       AddFunction('ln', 'F', 'F', @ExprLn);
       AddFunction('log', 'F', 'F', @ExprLog);
       AddFunction('sqrt', 'F', 'F', @ExprSQRT);
       AddFunction('power', 'F', 'FF', @ExprPower); //two arguments 'FF'
       AddFunction('biseccion','F','FFFS',@ExprBiseccion);
       AddFunction('falpos','F','FFFS',@ExprFalpos);
       AddFunction('secante','F','FFS',@ExprSecante);
       AddFunction('trapecio','F','FFS',@ExprTrapecio);
       AddFunction('simpson','F','FFS',@ExprSimpson);

       AddFunction('rk3','F','SFFFF',@ExpRK3);
       AddFunction('rk4','F','SFFFF',@ExpRK4);
       AddFunction('euler','S','SFFFF',@ExpEuler);
       AddFunction('heun','F','SFFFF',@ExpHeun);

   end

end;

procedure TParseMath.AddVariable( Variable: string; Value: Double );
var Len: Integer;
begin
   Len:= length( identifier ) + 1;
   SetLength( identifier, Len ) ;
   identifier[ Len - 1 ]:= FParser.Identifiers.AddFloatVariable( Variable, Value);


end;

end.
