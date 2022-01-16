unit UPNPLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 12-5-2007 18:39:45 from Type Library described below.

// ************************************************************************  //
// Type Lib: c:\windows\system32\upnp.dll (1)
// LIBID: {DB3442A7-A2E9-4A59-9CB5-F5C1A5D901E5}
// LCID: 0
// Helpfile: 
// HelpString: UPnP 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\STDOLE2.TLB)
// Errors:
//   Hint: Symbol 'Type' renamed to 'type_'
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  UPNPLibMajorVersion = 1;
  UPNPLibMinorVersion = 0;

  LIBID_UPNPLib: TGUID = '{DB3442A7-A2E9-4A59-9CB5-F5C1A5D901E5}';

  IID_IUPnPDeviceFinder: TGUID = '{ADDA3D55-6F72-4319-BFF9-18600A539B10}';
  CLASS_UPnPDeviceFinder: TGUID = '{E2085F28-FEB7-404A-B8E7-E659BDEAAA02}';
  IID_IUPnPDevices: TGUID = '{FDBC0C73-BDA3-4C66-AC4F-F2D96FDAD68C}';
  IID_IUPnPDevice: TGUID = '{3D44D0D1-98C9-4889-ACD1-F9D674BF2221}';
  IID_IUPnPServices: TGUID = '{3F8C8E9E-9A7A-4DC8-BC41-FF31FA374956}';
  IID_IUPnPService: TGUID = '{A295019C-DC65-47DD-90DC-7FE918A1AB44}';
  CLASS_UPnPDevices: TGUID = '{B9E84FFD-AD3C-40A4-B835-0882EBCBAAA8}';
  CLASS_UPnPDevice: TGUID = '{A32552C5-BA61-457A-B59A-A2561E125E33}';
  CLASS_UPnPServices: TGUID = '{C0BC4B4A-A406-4EFC-932F-B8546B8100CC}';
  CLASS_UPnPService: TGUID = '{C624BA95-FBCB-4409-8C03-8CCEEC533EF1}';
  IID_IUPnPDescriptionDocument: TGUID = '{11D1C1B2-7DAA-4C9E-9595-7F82ED206D1E}';
  CLASS_UPnPDescriptionDocument: TGUID = '{1D8A9B47-3A28-4CE2-8A4B-BD34E45BCEEB}';
  IID_IUPnPDeviceHostSetup: TGUID = '{6BD34909-54E7-4FBF-8562-7B89709A589A}';
  CLASS_UPnPDeviceHostSetup: TGUID = '{B4609411-C81C-4CCE-8C76-C6B50C9402C6}';
  IID_IUPnPDeviceDocumentAccess: TGUID = '{E7772804-3287-418E-9072-CF2B47238981}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IUPnPDeviceFinder = interface;
  IUPnPDeviceFinderDisp = dispinterface;
  IUPnPDevices = interface;
  IUPnPDevicesDisp = dispinterface;
  IUPnPDevice = interface;
  IUPnPDeviceDisp = dispinterface;
  IUPnPServices = interface;
  IUPnPServicesDisp = dispinterface;
  IUPnPService = interface;
  IUPnPServiceDisp = dispinterface;
  IUPnPDescriptionDocument = interface;
  IUPnPDescriptionDocumentDisp = dispinterface;
  IUPnPDeviceHostSetup = interface;
  IUPnPDeviceDocumentAccess = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  UPnPDeviceFinder = IUPnPDeviceFinder;
  UPnPDevices = IUPnPDevices;
  UPnPDevice = IUPnPDevice;
  UPnPServices = IUPnPServices;
  UPnPService = IUPnPService;
  UPnPDescriptionDocument = IUPnPDescriptionDocument;
  UPnPDeviceHostSetup = IUnknown;


// *********************************************************************//
// Interface: IUPnPDeviceFinder
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {ADDA3D55-6F72-4319-BFF9-18600A539B10}
// *********************************************************************//
  IUPnPDeviceFinder = interface(IDispatch)
    ['{ADDA3D55-6F72-4319-BFF9-18600A539B10}']
    function FindByType(const bstrTypeURI: WideString; dwFlags: LongWord): IUPnPDevices; safecall;
    function CreateAsyncFind(const bstrTypeURI: WideString; dwFlags: LongWord; 
                             const punkDeviceFinderCallback: IUnknown): Integer; safecall;
    procedure StartAsyncFind(lFindData: Integer); safecall;
    procedure CancelAsyncFind(lFindData: Integer); safecall;
    function FindByUDN(const bstrUDN: WideString): IUPnPDevice; safecall;
  end;

// *********************************************************************//
// DispIntf:  IUPnPDeviceFinderDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {ADDA3D55-6F72-4319-BFF9-18600A539B10}
// *********************************************************************//
  IUPnPDeviceFinderDisp = dispinterface
    ['{ADDA3D55-6F72-4319-BFF9-18600A539B10}']
    function FindByType(const bstrTypeURI: WideString; dwFlags: LongWord): IUPnPDevices; dispid 1610744809;
    function CreateAsyncFind(const bstrTypeURI: WideString; dwFlags: LongWord; 
                             const punkDeviceFinderCallback: IUnknown): Integer; dispid 1610744812;
    procedure StartAsyncFind(lFindData: Integer); dispid 1610744813;
    procedure CancelAsyncFind(lFindData: Integer); dispid 1610744814;
    function FindByUDN(const bstrUDN: WideString): IUPnPDevice; dispid 1610744811;
  end;

// *********************************************************************//
// Interface: IUPnPDevices
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {FDBC0C73-BDA3-4C66-AC4F-F2D96FDAD68C}
// *********************************************************************//
  IUPnPDevices = interface(IDispatch)
    ['{FDBC0C73-BDA3-4C66-AC4F-F2D96FDAD68C}']
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(const bstrUDN: WideString): IUPnPDevice; safecall;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[const bstrUDN: WideString]: IUPnPDevice read Get_Item; default;
  end;

// *********************************************************************//
// DispIntf:  IUPnPDevicesDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {FDBC0C73-BDA3-4C66-AC4F-F2D96FDAD68C}
// *********************************************************************//
  IUPnPDevicesDisp = dispinterface
    ['{FDBC0C73-BDA3-4C66-AC4F-F2D96FDAD68C}']
    property Count: Integer readonly dispid 1610747309;
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[const bstrUDN: WideString]: IUPnPDevice readonly dispid 0; default;
  end;

// *********************************************************************//
// Interface: IUPnPDevice
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3D44D0D1-98C9-4889-ACD1-F9D674BF2221}
// *********************************************************************//
  IUPnPDevice = interface(IDispatch)
    ['{3D44D0D1-98C9-4889-ACD1-F9D674BF2221}']
    function Get_IsRootDevice: WordBool; safecall;
    function Get_RootDevice: IUPnPDevice; safecall;
    function Get_ParentDevice: IUPnPDevice; safecall;
    function Get_HasChildren: WordBool; safecall;
    function Get_Children: IUPnPDevices; safecall;
    function Get_UniqueDeviceName: WideString; safecall;
    function Get_FriendlyName: WideString; safecall;
    function Get_type_: WideString; safecall;
    function Get_PresentationURL: WideString; safecall;
    function Get_ManufacturerName: WideString; safecall;
    function Get_ManufacturerURL: WideString; safecall;
    function Get_ModelName: WideString; safecall;
    function Get_ModelNumber: WideString; safecall;
    function Get_Description: WideString; safecall;
    function Get_ModelURL: WideString; safecall;
    function Get_UPC: WideString; safecall;
    function Get_SerialNumber: WideString; safecall;
    function IconURL(const bstrEncodingFormat: WideString; lSizeX: Integer; lSizeY: Integer; 
                     lBitDepth: Integer): WideString; safecall;
    function Get_Services: IUPnPServices; safecall;
    property IsRootDevice: WordBool read Get_IsRootDevice;
    property RootDevice: IUPnPDevice read Get_RootDevice;
    property ParentDevice: IUPnPDevice read Get_ParentDevice;
    property HasChildren: WordBool read Get_HasChildren;
    property Children: IUPnPDevices read Get_Children;
    property UniqueDeviceName: WideString read Get_UniqueDeviceName;
    property FriendlyName: WideString read Get_FriendlyName;
    property type_: WideString read Get_type_;
    property PresentationURL: WideString read Get_PresentationURL;
    property ManufacturerName: WideString read Get_ManufacturerName;
    property ManufacturerURL: WideString read Get_ManufacturerURL;
    property ModelName: WideString read Get_ModelName;
    property ModelNumber: WideString read Get_ModelNumber;
    property Description: WideString read Get_Description;
    property ModelURL: WideString read Get_ModelURL;
    property UPC: WideString read Get_UPC;
    property SerialNumber: WideString read Get_SerialNumber;
    property Services: IUPnPServices read Get_Services;
  end;

// *********************************************************************//
// DispIntf:  IUPnPDeviceDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3D44D0D1-98C9-4889-ACD1-F9D674BF2221}
// *********************************************************************//
  IUPnPDeviceDisp = dispinterface
    ['{3D44D0D1-98C9-4889-ACD1-F9D674BF2221}']
    property IsRootDevice: WordBool readonly dispid 1610747809;
    property RootDevice: IUPnPDevice readonly dispid 1610747810;
    property ParentDevice: IUPnPDevice readonly dispid 1610747811;
    property HasChildren: WordBool readonly dispid 1610747812;
    property Children: IUPnPDevices readonly dispid 1610747813;
    property UniqueDeviceName: WideString readonly dispid 1610747814;
    property FriendlyName: WideString readonly dispid 1610747815;
    property type_: WideString readonly dispid 1610747816;
    property PresentationURL: WideString readonly dispid 1610747817;
    property ManufacturerName: WideString readonly dispid 1610747818;
    property ManufacturerURL: WideString readonly dispid 1610747819;
    property ModelName: WideString readonly dispid 1610747820;
    property ModelNumber: WideString readonly dispid 1610747821;
    property Description: WideString readonly dispid 1610747822;
    property ModelURL: WideString readonly dispid 1610747823;
    property UPC: WideString readonly dispid 1610747824;
    property SerialNumber: WideString readonly dispid 1610747825;
    function IconURL(const bstrEncodingFormat: WideString; lSizeX: Integer; lSizeY: Integer; 
                     lBitDepth: Integer): WideString; dispid 1610747827;
    property Services: IUPnPServices readonly dispid 1610747828;
  end;

// *********************************************************************//
// Interface: IUPnPServices
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F8C8E9E-9A7A-4DC8-BC41-FF31FA374956}
// *********************************************************************//
  IUPnPServices = interface(IDispatch)
    ['{3F8C8E9E-9A7A-4DC8-BC41-FF31FA374956}']
    function Get_Count: Integer; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_Item(const bstrServiceId: WideString): IUPnPService; safecall;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
    property Item[const bstrServiceId: WideString]: IUPnPService read Get_Item; default;
  end;

// *********************************************************************//
// DispIntf:  IUPnPServicesDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {3F8C8E9E-9A7A-4DC8-BC41-FF31FA374956}
// *********************************************************************//
  IUPnPServicesDisp = dispinterface
    ['{3F8C8E9E-9A7A-4DC8-BC41-FF31FA374956}']
    property Count: Integer readonly dispid 1610745809;
    property _NewEnum: IUnknown readonly dispid -4;
    property Item[const bstrServiceId: WideString]: IUPnPService readonly dispid 0; default;
  end;

// *********************************************************************//
// Interface: IUPnPService
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {A295019C-DC65-47DD-90DC-7FE918A1AB44}
// *********************************************************************//
  IUPnPService = interface(IDispatch)
    ['{A295019C-DC65-47DD-90DC-7FE918A1AB44}']
    function QueryStateVariable(const bstrVariableName: WideString): OleVariant; safecall;
    function InvokeAction(const bstrActionName: WideString; vInActionArgs: OleVariant; 
                          var pvOutActionArgs: OleVariant): OleVariant; safecall;
    function Get_ServiceTypeIdentifier: WideString; safecall;
    procedure AddCallback(const pUnkCallback: IUnknown); safecall;
    function Get_Id: WideString; safecall;
    function Get_LastTransportStatus: Integer; safecall;
    property ServiceTypeIdentifier: WideString read Get_ServiceTypeIdentifier;
    property Id: WideString read Get_Id;
    property LastTransportStatus: Integer read Get_LastTransportStatus;
  end;

// *********************************************************************//
// DispIntf:  IUPnPServiceDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {A295019C-DC65-47DD-90DC-7FE918A1AB44}
// *********************************************************************//
  IUPnPServiceDisp = dispinterface
    ['{A295019C-DC65-47DD-90DC-7FE918A1AB44}']
    function QueryStateVariable(const bstrVariableName: WideString): OleVariant; dispid 1610746309;
    function InvokeAction(const bstrActionName: WideString; vInActionArgs: OleVariant; 
                          var pvOutActionArgs: OleVariant): OleVariant; dispid 1610746310;
    property ServiceTypeIdentifier: WideString readonly dispid 1610746311;
    procedure AddCallback(const pUnkCallback: IUnknown); dispid 1610746312;
    property Id: WideString readonly dispid 1610746313;
    property LastTransportStatus: Integer readonly dispid 1610746314;
  end;

// *********************************************************************//
// Interface: IUPnPDescriptionDocument
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {11D1C1B2-7DAA-4C9E-9595-7F82ED206D1E}
// *********************************************************************//
  IUPnPDescriptionDocument = interface(IDispatch)
    ['{11D1C1B2-7DAA-4C9E-9595-7F82ED206D1E}']
    function Get_ReadyState: Integer; safecall;
    procedure Load(const bstrUrl: WideString); safecall;
    procedure LoadAsync(const bstrUrl: WideString; const pUnkCallback: IUnknown); safecall;
    function Get_LoadResult: Integer; safecall;
    procedure Abort; safecall;
    function RootDevice: IUPnPDevice; safecall;
    function DeviceByUDN(const bstrUDN: WideString): IUPnPDevice; safecall;
    property ReadyState: Integer read Get_ReadyState;
    property LoadResult: Integer read Get_LoadResult;
  end;

// *********************************************************************//
// DispIntf:  IUPnPDescriptionDocumentDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {11D1C1B2-7DAA-4C9E-9595-7F82ED206D1E}
// *********************************************************************//
  IUPnPDescriptionDocumentDisp = dispinterface
    ['{11D1C1B2-7DAA-4C9E-9595-7F82ED206D1E}']
    property ReadyState: Integer readonly dispid -525;
    procedure Load(const bstrUrl: WideString); dispid 1610748309;
    procedure LoadAsync(const bstrUrl: WideString; const pUnkCallback: IUnknown); dispid 1610748310;
    property LoadResult: Integer readonly dispid 1610748311;
    procedure Abort; dispid 1610748312;
    function RootDevice: IUPnPDevice; dispid 1610748313;
    function DeviceByUDN(const bstrUDN: WideString): IUPnPDevice; dispid 1610748314;
  end;

// *********************************************************************//
// Interface: IUPnPDeviceHostSetup
// Flags:     (256) OleAutomation
// GUID:      {6BD34909-54E7-4FBF-8562-7B89709A589A}
// *********************************************************************//
  IUPnPDeviceHostSetup = interface(IUnknown)
    ['{6BD34909-54E7-4FBF-8562-7B89709A589A}']
    function AskIfNotAlreadyEnabled(out pbEnabled: WordBool): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: IUPnPDeviceDocumentAccess
// Flags:     (0)
// GUID:      {E7772804-3287-418E-9072-CF2B47238981}
// *********************************************************************//
  IUPnPDeviceDocumentAccess = interface(IUnknown)
    ['{E7772804-3287-418E-9072-CF2B47238981}']
    function GetDocumentURL(out pbstrDocument: WideString): HResult; stdcall;
  end;

// *********************************************************************//
// The Class CoUPnPDeviceFinder provides a Create and CreateRemote method to          
// create instances of the default interface IUPnPDeviceFinder exposed by              
// the CoClass UPnPDeviceFinder. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUPnPDeviceFinder = class
    class function Create: IUPnPDeviceFinder;
    class function CreateRemote(const MachineName: string): IUPnPDeviceFinder;
  end;

// *********************************************************************//
// The Class CoUPnPDevices provides a Create and CreateRemote method to          
// create instances of the default interface IUPnPDevices exposed by              
// the CoClass UPnPDevices. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUPnPDevices = class
    class function Create: IUPnPDevices;
    class function CreateRemote(const MachineName: string): IUPnPDevices;
  end;

// *********************************************************************//
// The Class CoUPnPDevice provides a Create and CreateRemote method to          
// create instances of the default interface IUPnPDevice exposed by              
// the CoClass UPnPDevice. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUPnPDevice = class
    class function Create: IUPnPDevice;
    class function CreateRemote(const MachineName: string): IUPnPDevice;
  end;

// *********************************************************************//
// The Class CoUPnPServices provides a Create and CreateRemote method to          
// create instances of the default interface IUPnPServices exposed by              
// the CoClass UPnPServices. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUPnPServices = class
    class function Create: IUPnPServices;
    class function CreateRemote(const MachineName: string): IUPnPServices;
  end;

// *********************************************************************//
// The Class CoUPnPService provides a Create and CreateRemote method to          
// create instances of the default interface IUPnPService exposed by              
// the CoClass UPnPService. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUPnPService = class
    class function Create: IUPnPService;
    class function CreateRemote(const MachineName: string): IUPnPService;
  end;

// *********************************************************************//
// The Class CoUPnPDescriptionDocument provides a Create and CreateRemote method to          
// create instances of the default interface IUPnPDescriptionDocument exposed by              
// the CoClass UPnPDescriptionDocument. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUPnPDescriptionDocument = class
    class function Create: IUPnPDescriptionDocument;
    class function CreateRemote(const MachineName: string): IUPnPDescriptionDocument;
  end;

// *********************************************************************//
// The Class CoUPnPDeviceHostSetup provides a Create and CreateRemote method to          
// create instances of the default interface IUnknown exposed by              
// the CoClass UPnPDeviceHostSetup. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUPnPDeviceHostSetup = class
    class function Create: IUnknown;
    class function CreateRemote(const MachineName: string): IUnknown;
  end;

implementation

uses ComObj;

class function CoUPnPDeviceFinder.Create: IUPnPDeviceFinder;
begin
  Result := CreateComObject(CLASS_UPnPDeviceFinder) as IUPnPDeviceFinder;
end;

class function CoUPnPDeviceFinder.CreateRemote(const MachineName: string): IUPnPDeviceFinder;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UPnPDeviceFinder) as IUPnPDeviceFinder;
end;

class function CoUPnPDevices.Create: IUPnPDevices;
begin
  Result := CreateComObject(CLASS_UPnPDevices) as IUPnPDevices;
end;

class function CoUPnPDevices.CreateRemote(const MachineName: string): IUPnPDevices;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UPnPDevices) as IUPnPDevices;
end;

class function CoUPnPDevice.Create: IUPnPDevice;
begin
  Result := CreateComObject(CLASS_UPnPDevice) as IUPnPDevice;
end;

class function CoUPnPDevice.CreateRemote(const MachineName: string): IUPnPDevice;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UPnPDevice) as IUPnPDevice;
end;

class function CoUPnPServices.Create: IUPnPServices;
begin
  Result := CreateComObject(CLASS_UPnPServices) as IUPnPServices;
end;

class function CoUPnPServices.CreateRemote(const MachineName: string): IUPnPServices;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UPnPServices) as IUPnPServices;
end;

class function CoUPnPService.Create: IUPnPService;
begin
  Result := CreateComObject(CLASS_UPnPService) as IUPnPService;
end;

class function CoUPnPService.CreateRemote(const MachineName: string): IUPnPService;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UPnPService) as IUPnPService;
end;

class function CoUPnPDescriptionDocument.Create: IUPnPDescriptionDocument;
begin
  Result := CreateComObject(CLASS_UPnPDescriptionDocument) as IUPnPDescriptionDocument;
end;

class function CoUPnPDescriptionDocument.CreateRemote(const MachineName: string): IUPnPDescriptionDocument;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UPnPDescriptionDocument) as IUPnPDescriptionDocument;
end;

class function CoUPnPDeviceHostSetup.Create: IUnknown;
begin
  Result := CreateComObject(CLASS_UPnPDeviceHostSetup) as IUnknown;
end;

class function CoUPnPDeviceHostSetup.CreateRemote(const MachineName: string): IUnknown;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UPnPDeviceHostSetup) as IUnknown;
end;

end.
