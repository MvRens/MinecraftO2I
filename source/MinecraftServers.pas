unit MinecraftServers;

interface
uses
  Classes;


type
  TMinecraftServerState = (mssClosed, mssClosing, mssOpening, mssOpen);

  TMinecraftServer = class(TCollectionItem)
  private
    FAddress: string;
    FDescription: string;
    FState: TMinecraftServerState;
    FLastSeen: Cardinal;

    FIP: string;
    FPort: Integer;

    procedure SetAddress(const Value: string);
  public
    property Address: string read FAddress write SetAddress;
    property Description: string read FDescription write FDescription;
    property State: TMinecraftServerState read FState write FState;
    property LastSeen: Cardinal read FLastSeen write FLastSeen;

    property IP: string read FIP;
    property Port: Integer read FPort;
  end;


  TMinecraftServers = class(TCollection)
  private
    function GetItem(Index: Integer): TMinecraftServer;
    procedure SetItem(Index: Integer; Value: TMinecraftServer);
  public
    constructor Create;

    function Add(const AAddress, ADescription: string): TMinecraftServer; overload;
    function Add(const AAddress, ADescription: string; out AExisting: Boolean): TMinecraftServer; overload;

    function Find(const AAddress: string): TMinecraftServer;
    function FindItemID(ID: Integer): TMinecraftServer;

    property Items[Index: Integer]: TMinecraftServer read GetItem write SetItem; default;
  end;


implementation
uses
  SysUtils,
  Windows;


{ TMinecraftWorlds }
constructor TMinecraftServers.Create;
begin
  inherited Create(TMinecraftServer);
end;


function TMinecraftServers.Add(const AAddress, ADescription: string): TMinecraftServer;
var
  existing: Boolean;

begin
  Result := Add(AAddress, ADescription, existing);
end;


function TMinecraftServers.Add(const AAddress, ADescription: string; out AExisting: Boolean): TMinecraftServer;
begin
  Result := Find(AAddress);
  if not Assigned(Result) then
  begin
    Result := TMinecraftServer(inherited Add);
    Result.Address := AAddress;
    AExisting := False;
  end else
    AExisting := True;

  Result.Description := ADescription;
  Result.LastSeen := GetTickCount;
end;


function TMinecraftServers.Find(const AAddress: string): TMinecraftServer;
var
  itemIndex: Integer;

begin
  Result := nil;

  for itemIndex := Pred(Count) downto 0 do
    if SameText(Items[itemIndex].Address, AAddress) then
    begin
      Result := Items[itemIndex];
      break;
    end;
end;


function TMinecraftServers.FindItemID(ID: Integer): TMinecraftServer;
begin
  Result := TMinecraftServer(inherited FindItemID(ID));
end;


function TMinecraftServers.GetItem(Index: Integer): TMinecraftServer;
begin
  Result  := TMinecraftServer(inherited GetItem(Index));
end;


procedure TMinecraftServers.SetItem(Index: Integer; Value: TMinecraftServer);
begin
  inherited SetItem(Index, Value);
end;


{ TMinecraftServer }
procedure TMinecraftServer.SetAddress(const Value: string);
var
  portSepPos: Integer;

begin
  FAddress := Value;
  FIP := '';
  FPort := 0;

  portSepPos := Pos(':', Value);
  if portSepPos > 0 then
  begin
    FIP := Copy(Value, 1, Pred(portSepPos));
    FPort := StrToIntDef(Copy(Value, Succ(portSepPos), MaxInt), 0);
  end;
end;

end.
