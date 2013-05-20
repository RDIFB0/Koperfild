////////////////////////////////////////////////////////////
// �������� ��� ������� by AnXIouS aka ���������� �.�.    //
// ��� ��������� ���� ������������ ������ � ����� WASM    //
// ��� Ring0 � WinXP, � �����-����� ������ ���� � ������- //
// �������� WinAPI � ������ ��������.                    //
//////////////////////////////////////////////////////////// 

program Koperfild2;

uses
  windows,
  messages,
  commctrl,
  Ring0, // ����� ���
  TLHelp32;

{$R 'icon.res'}
{$R 'XPMan.res'}
{$R 'Version.res'}
{$R 'bitmaps.res'}

Var
  WinClass : TWndClass;   //���������� ������ TWndClass ��� �������� �������� ����
  hInst : HWND;           //������� ����������
  Handle : HWND;          //��������� �������
  Msg : TMSG;             //���������
  hFont : HWND;           //������� ������
  Bevel1 : HWND;          //TBevel
  Bevel2 : HWND;          //TBevel
  Button1 : HWND;         //TButton
  Button2 : HWND;         //TButton
  List : HWND;            //TListView
  CheckBox1 : HWND;
  Bmp: HBITMAP;
VAR
  Init: Boolean;
  MyPID: DWord;
  MyEPROCESS: DWord;
  PID: DWord;
  EPROCESS: DWord;
  pHandle: HWND;
  //
  PeHa: THandle;
  ProcStruct: TProcessEntry32;

Const
  PName = 'Koperfield 2';

procedure SetHint(AWnd: HWnd; HintText: String);
var
 TH   : TTOOLINFO;
 Hint : HWnd;
begin
 Hint:=CreateWindowEx(0,TOOLTIPS_CLASS,nil,0,0,0,0,0,AWnd,0,hInstance,nil);
 TH.uId:=AWnd;
 TH.hinst:=hInstance;
 TH.uFlags:=TTF_TRANSPARENT or TTF_IDISHWND or TTF_SUBCLASS;
 TH.lpszText:=PChar(HintText);
 SendMessage(Hint,TTM_ADDTOOL,0,LongInt(@TH));
end;

{ ##################################################################### }

procedure RegHotKeyS;
Begin
 If not RegisterHotKey(Handle,619,MOD_CONTROL,32) then              //CTRL+PROBEL
    MessageBox(0,'Unable to assign Ctrl+Spase as hotkey.',
    PName,MB_ICONEXCLAMATION);
 If not RegisterHotKey(Handle,629,MOD_ALT,32) then                  //ALT+PROBEL
    MessageBox(0,'Unable to assign Alt+Spase as hotkey.',
    PName,MB_ICONEXCLAMATION);
 If not RegisterHotKey(Handle,639,MOD_ALT or MOD_CONTROL,88) then   //CTRL+ALT+X
    MessageBox(0,'Unable to assign Ctrl+Alt+X as hotkey.',
    PName,MB_ICONEXCLAMATION);
 If not RegisterHotKey(Handle,649,MOD_ALT or MOD_CONTROL,90) then   //CTRL+ALT+Z
    MessageBox(0,'Unable to assign Ctrl+Alt+Z as hotkey.',
    PName,MB_ICONEXCLAMATION)
End;

procedure UnRegHotKeyS;
Begin
 UnRegisterHotKey(hInst,619); //CTRL+PROBEL
 UnRegisterHotKey(hInst,629); //ALT+PROBEL
 UnRegisterHotKey(hInst,639); //CTRL+ALT+X
 UnRegisterHotKey(hInst,649); //CTRL+ALT+Z
End;

procedure Minimize;
Begin
 ShowWindow(Handle,SW_HIDE);
End;

procedure MyShow;
Begin
 ShowWindow(Handle,SW_SHOW);
End;
        
procedure FormClose;
Begin
 UnRegHotKeyS;
 If Init then
 Begin
  If MyEPROCESS <> 0 then ShowProcess(MyEPROCESS);
  FreeRing0Library();
 End;
End;

procedure ShutDown;     //��������� ���������� ���������
begin
  FormClose;
  DeleteObject(hFont);  //�������� ������
  UnRegisterClass('TAPIxForm', hInst); //�������� ����
  ExitProcess(hInst);    //�������� ���������
end;

procedure FormCreate;
Begin
 MyPID:=GetCurrentProcessId();
 Init:=InitialzeRing0Library(CALL_GATE); // ���������� ���-����
 If Init then                            // ���� ����� �� �������
 Begin
  EnableWindow(Button1, True);
  MyEPROCESS:=HideProcess(MyPid);
  ///
  RegHotKeyS;
  pHandle:=0;
  MyPID:=0;
  PID:=0;
  MyEPROCESS:=0;
  EPROCESS:=0;
  ///
  If ParamStr(1) = '/m' then Minimize;
 End;
End;

procedure Kill(B: Boolean);
Begin
 If B then SendMessage(Handle,WM_DESTROY,0,0)
 else
 Begin
  SendMessage(pHandle,WM_DESTROY,0,0);
  pHandle:=0;
  PID:=0;
  EPROCESS:=0;
  SendMessage(CheckBox1, BM_SETCHECK, 0, 0);
 End;
End;

Procedure Freaze(ID: DWORD; F: Boolean);
var
 H: DWORD;
Begin
 PeHa:=CreateToolHelp32Snapshot(TH32CS_SnapProcess,0);
  If PeHa = INVALID_HANDLE_VALUE then Exit;
 H:=INVALID_HANDLE_VALUE;
 ////
 ProcStruct.dwSize:=SizeOf(ProcStruct);
  If Process32First(PeHa,ProcStruct) then
  begin
   Repeat
    If ProcStruct.th32ProcessID = ID then
    begin
     H:=ProcStruct.th32ParentProcessID;
     Break;
    end;
   Until not Process32Next(PeHa,ProcStruct);
  end;
 CloseHandle(PeHa);
 ////
 IF F THEN
  SuspendThread(H)
 ELSE
  ResumeThread(H);
End;

procedure HideProg;
Begin
 If pHandle = 0 then
 Begin
  pHandle:=GetForegroundWindow;
  ShowWindow(pHandle,SW_HIDE);
  GetWindowThreadProcessId(pHandle,PID);
   //Freaze(PID,True);
  EPROCESS:=HideProcess(PID);
  SendMessage(CheckBox1, BM_SETCHECK, 1, 0);
 End
  Else
 Begin
  ShowProcess(EPROCESS);
  ShowWindow(pHandle,SW_SHOW);
   //Freaze(PID,False);
  pHandle:=0;
  PID:=0;
  EPROCESS:=0;
  SendMessage(CheckBox1, BM_SETCHECK, 0, 0);
 End;
End;  

function WindowProc(hwnd, msg, wparam, lparam: longint): longint; stdcall; //���������� ���������
begin
  Result := DefWindowProc(hwnd, msg, wparam, lparam);
  case Msg of

 WM_COMMAND:
 if (lParam = Button1) and (HiWord(wParam) = BN_CLICKED) then
  begin
   Minimize;
  end
 else
 if (lParam = Button2) and (HiWord(wParam) = BN_CLICKED) then
  begin
    ShutDown;
  end;

 WM_HOTKEY:
 If wParam = 619 then
  HideProg
 else
 if wParam = 629 then
  MyShow
 else
 if wParam = 639 then
  Kill(True)
 else
 if wParam = 649 then
  Kill(False);

 WM_DESTROY: ShutDown;
  end;
end;

// ���� ���������� �����
begin
 hInst := GetModuleHandle(nil);
  with WinClass do
  begin
   Style := CS_PARENTDC;                              //����� ������ �������� ����
   hIcon := LoadIcon(hInst, MAKEINTRESOURCE('ICON')); //������ ���������
   lpfnWndProc := @WindowProc;                        //���������� ����������� ���������
   hInstance := hInst;
   hbrBackground := COLOR_BTNFACE + 1;                //���� ����
   lpszClassName := 'TAPIxForm';                      //����� ����
   hCursor := LoadCursor(0, IDC_ARROW);               //�������� ������
  end;
InitCommonControls;
RegisterClass(WinClass);                              //����������� ������ � �������
/////////////////
 IF FindWindow('TAPIxForm','Koperfield 2') <> 0 Then
 Begin
  MessageBox(0,'Already running','Err0r',0);
  ExitProcess(hInst);
 End;
/////////////////
// �������� �������� ���� ���������
Handle := CreateWindowEx(0, 'TAPIxForm', 'Koperfield 2',
WS_DLGFRAME or WS_VISIBLE or WS_MINIMIZEBOX or WS_SYSMENU,
237, 128, 200, 250,
0, 0,
hInst, nil);

// �������� ������
hFont := CreateFont(
-11, 0, 0, 0, 0, 0, 0, 0,
DEFAULT_CHARSET,
OUT_DEFAULT_PRECIS,
CLIP_DEFAULT_PRECIS,
DEFAULT_QUALITY,
DEFAULT_PITCH or FF_DONTCARE, 'Arial');

List := CreateWindow(
'Static',
'',
WS_CHILD or WS_VISIBLE or SS_BITMAP,
0, 0, 200, 250,Handle, 0, hInst, nil);
SendMessage(List,WM_SETFONT, hFont, 0);
Bmp:= LoadBitmap(hInstance, MAKEINTRESOURCE('Image1'));
SendMessage(List, STM_SETIMAGE, IMAGE_BITMAP, Bmp);

Bevel1 := CreateWindowEx(
0,
'Static',
'' ,
WS_CHILD or WS_VISIBLE or SS_ETCHEDFRAME,
4, 4, 186, 210, Handle, 0, hInst, nil);
SendMessage(Bevel1, WM_SETFONT, hFont, 0);


Bevel2 := CreateWindowEx(
0,
'Static',
'' ,
WS_CHILD or WS_VISIBLE or SS_ETCHEDFRAME,
8, 8, 178, 178, Handle, 0, hInst, nil);
SendMessage(Bevel2, WM_SETFONT, hFont, 0);


Button1 := CreateWindow(
'Button',
'[ ��������� ]',
WS_CHILD or BS_TEXT or WS_VISIBLE or BS_DEFPUSHBUTTON or WS_DISABLED,
8, 188, 84, 22, Handle, Button1, hInst, nil);
SendMessage(Button1, WM_SETFONT, hFont, 0);
SetHint(Button1, 'C��������');


Button2 := CreateWindow(
'Button',
'[ ����� ]',
WS_CHILD or BS_TEXT or WS_VISIBLE or BS_DEFPUSHBUTTON,
100, 188, 84, 22, Handle, Button2, hInst, nil);
SendMessage(Button2, WM_SETFONT, hFont, 0);
SetHint(Button2, '�����');

CheckBox1 := CreateWindow(
'Button',
'' ,
WS_CHILD or BS_CHECKBOX or WS_VISIBLE,
168, 12, 14, 14, Handle, 0, hInst, nil);
SendMessage(CheckBox1, WM_SETFONT, hFont, 0);
SetHint(CheckBox1, '���� �� ���������� ���������');

BEGIN
 FormCreate;
END;


  // ���� ����� ���������
  while(GetMessage(Msg, 0, 0, 0)) do
  begin
    TranslateMessage(Msg); //����� ���������
    DispatchMessage(Msg); //�������� ��������� �� �������
  end;
  end.

