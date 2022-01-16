unit EnumInterface;

interface
uses
  ActiveX,
  Classes;

type
  IEnumInterface = interface
    ['{8C7D0A6A-5AC6-4411-938C-F48C914559F3}']
    function GetCurrent(): IDispatch;

    procedure Reset();
    function Next(): Boolean;

    property Current: IDispatch read GetCurrent;
  end;


  TEnumInterface = class(TInterfacedObject, IEnumInterface)
  private
    FEnumerator:    IEnumVARIANT;
    FCurrent:       IDispatch;
    FCurrentVar:    OleVariant;
  protected
    function GetCurrent(): IDispatch;

    procedure Reset();
    function Next(): Boolean;
  public
    constructor Create(AEnumerator: IInterface);
  end;


  function CollectInterfaces(AEnumerator: IInterface; ADest: TInterfaceList): Boolean;


implementation
uses
  ComObj;


{ Helper functions }
function CollectInterfaces(AEnumerator: IInterface; ADest: TInterfaceList): Boolean;
var
  enumInterface:    IEnumInterface;

begin
  Result        := False;
  enumInterface := TEnumInterface.Create(AEnumerator);
  try
    while enumInterface.Next() do
    begin
      ADest.Add(enumInterface.Current);
      Result  := True;
    end;
  finally
    enumInterface := nil;
  end;
end;


{ TEnumInterface }
constructor TEnumInterface.Create(AEnumerator: IInterface);
begin
  inherited Create();

  FEnumerator := (AEnumerator as IEnumVARIANT);
  Reset();
end;


function TEnumInterface.GetCurrent(): IDispatch;
begin
  Result  := FCurrent;
end;


procedure TEnumInterface.Reset();
begin
  OleCheck(FEnumerator.Reset());
end;


function TEnumInterface.Next(): Boolean;
var
  fetched: Cardinal;

begin
  FCurrent  := nil;
  Result    := (FEnumerator.Next(1, FCurrentVar, fetched) = S_OK);

  if Result then
    FCurrent  := IDispatch(FCurrentVar);
end;

end.
