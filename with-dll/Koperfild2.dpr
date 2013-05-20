program Koperfild2;

uses
  windows,
  messages,
  commctrl; //Используемые модули

{$R 'icon.res'}
{$R 'XPMan.res'}
{$R 'Version.res'}
{$R 'bitmaps.res'}

var
  WinClass : TWndClass; //переменная класса TWndClass для создания главного окна
  hInst : HWND; //хандлер приложения
  Handle : HWND; //локальный хандлер
  Msg : TMSG; //сообщение
  hFont : HWND; //хандлер шрифта
  Bevel1 : HWND; //TBevel
  Bevel2 : HWND; //TBevel
  Button1 : HWND; //TButton
  Button2 : HWND; //TButton
  List : HWND; //TListView
  CheckBox1 : HWND;
  Bmp: HBITMAP;
VAR
  MyPID: DWord;
  PID: DWord;
  pHandle: HWND;

Type
 THide = function (pid: DWORD; HideOnlyFromTaskManager: BOOL): BOOL; stdcall;

Const
 PName = 'Koperfield 2';

//function HideProcess(pid: DWORD; HideOnlyFromTaskManager: BOOL): BOOL; stdcall;  external '007.dll';

procedure SetHint(AWnd: HWnd; HintText: String);
var
 TH: TTOOLINFO;
 Hint : HWnd;
begin
Hint := CreateWindowEx(0, TOOLTIPS_CLASS, nil, 0, 0, 0, 0, 0, AWnd, 0, hInstance, nil);
TH.uId := AWnd;
TH.hinst  := hInstance;
TH.uFlags := TTF_TRANSPARENT or TTF_IDISHWND or TTF_SUBCLASS;
TH.lpszText := PChar(HintText);
SendMessage(Hint, TTM_ADDTOOL, 0, LongInt(@TH));
end;

{ ##################################################################### }

Function HideProcess(Const Pid: Dword; OFTM: Bool): Boolean;
Var
 hndDLLHandle: THandle;
 Hide: THide;
Begin
 Result:=False;
 try
  hndDLLHandle := loadLibrary ( '007.Dll' );
  if hndDLLHandle <> 0 then
  Begin
   @Hide:=GetProcAddress ( hndDLLHandle, 'HideProcess' );
   if Addr ( Hide ) <> nil Then
   Begin
    Hide(Pid, OFTM);
    Result:=True;
   End
   Else MessageBox(0,'Function not Found','ErroR!',0)
  End
   Else MessageBox(0,'Dll not Found','ErroR!',0)
 finally
  freeLibrary ( hndDLLHandle );
 end;
End;

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

procedure FormCreate;
Begin
 MyPID:=GetCurrentProcessId();
  EnableWindow(Button1, True);
  If not HideProcess(MyPid, True) then Beep(400,100);
  ///
  RegHotKeyS;
  pHandle:=0;
  PID:=0;
  ///
  If ParamStr(1) = '/m' then Minimize;
End;

procedure FormClose;
Begin
 UnRegHotKeyS;
 ShowWindow(pHandle,SW_SHOW);
End;

procedure Kill(B: Boolean);
Begin
 If B then SendMessage(Handle,WM_DESTROY,0,0)
 else
 Begin
  SendMessage(pHandle,WM_DESTROY,0,0);
  pHandle:=0;
  PID:=0;
  SendMessage(CheckBox1, BM_SETCHECK, 0, 0);
 End;
End;

procedure HideProg;
Begin
 //MessageBox(0,'Text','Cap',0);
 If pHandle = 0 then
 Begin
  pHandle:=GetForegroundWindow;
  GetWindowThreadProcessId(pHandle,PID);
  If not HideProcess(PID,True) then Beep(400,100);
  ShowWindow(pHandle,SW_HIDE);
  SendMessage(CheckBox1, BM_SETCHECK, 1, 0);
 End
  Else
 Begin
  ShowWindow(pHandle,SW_SHOW);
  pHandle:=0;
  PID:=0;
  SendMessage(CheckBox1, BM_SETCHECK, 0, 0);
 End;
End;

procedure ShutDown; //процедура завершения программы
begin
  FormClose;
  DeleteObject(hFont); //удаление шрифта
  UnRegisterClass('TAPIxForm', hInst); //удаление окна
  ExitProcess(hInst); //закрытие программы
end;

function WindowProc(hwnd, msg, wparam, lparam: longint): longint; stdcall; //обработчик сообщений
begin
  Result := DefWindowProc(hwnd, msg, wparam, lparam);
  case Msg of

 WM_COMMAND:
 if (lParam = Button1) and (HiWord(wParam) = BN_CLICKED) then
  //OnClick компонента Button1
  begin
   Minimize;
  end
 else
 if (lParam = Button2) and (HiWord(wParam) = BN_CLICKED) then
  //OnClick компонента Button2
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

// Тута начинается прога
begin
hInst := GetModuleHandle(nil);
  with WinClass do
  begin
   Style := CS_PARENTDC; //стиль класса главного окна
   hIcon := LoadIcon(hInst, MAKEINTRESOURCE('ICON')); //иконка программы
   lpfnWndProc := @WindowProc; //назначение обработчика сообщений
   hInstance := hInst;
   hbrBackground := COLOR_BTNFACE + 1; //цвет окна
   lpszClassName := 'TAPIxForm'; //класс окна
   hCursor := LoadCursor(0, IDC_ARROW); //активный курсор
  end;
InitCommonControls;
RegisterClass(WinClass); //регистрация класса в системе

// Создание главного окна программы
Handle := CreateWindowEx(0, 'TAPIxForm', 'Koperfield 2',
WS_DLGFRAME or WS_VISIBLE or WS_MINIMIZEBOX or WS_SYSMENU,
237, 128, 200, 250,
0, 0,
hInst, nil);

// Создание шрифта
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
'[ Спрятатся ]',
WS_CHILD or BS_TEXT or WS_VISIBLE or BS_DEFPUSHBUTTON or WS_DISABLED,
8, 188, 84, 22, Handle, Button1, hInst, nil);
SendMessage(Button1, WM_SETFONT, hFont, 0);
SetHint(Button1, 'Cпрятатся');


Button2 := CreateWindow(
'Button',
'[ Выйти ]',
WS_CHILD or BS_TEXT or WS_VISIBLE or BS_DEFPUSHBUTTON,
100, 188, 84, 22, Handle, Button2, hInst, nil);
SendMessage(Button2, WM_SETFONT, hFont, 0);
SetHint(Button2, 'Выйти');

CheckBox1 := CreateWindow(
'Button',
'' ,
WS_CHILD or BS_CHECKBOX or WS_VISIBLE,
168, 12, 14, 14, Handle, 0, hInst, nil);
SendMessage(CheckBox1, WM_SETFONT, hFont, 0);
SetHint(CheckBox1, 'Есть ли спрятанная программа');

BEGIN
 FormCreate;
END;


  // Цикл сбора сообщений
  while(GetMessage(Msg, 0, 0, 0)) do
  begin
    TranslateMessage(Msg); //прием сообщений
    DispatchMessage(Msg); //удаление сообщений из очереди
  end;
  end.

