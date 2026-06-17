unit uAppEvents;

// Alle Event-Interfaces der Anwendung zentral definiert.
// Neue Module fügen hier ihre Interfaces ein — keine anderen Units müssen geändert werden.
// GUIDs bitte im IDE mit Strg+Shift+G neu generieren.

interface

type
  // --- Delphi Kunden ---
  IOpenKundenEvent = interface
    ['{A1000001-1111-1111-1111-000000000001}']
  end;

  IKundenResultEvent = interface
    ['{A1000001-1111-1111-1111-000000000002}']
    function GetResultText: string;
    property ResultText: string read GetResultText;
  end;

  // --- Delphi Artikel ---
  IOpenArtikelEvent = interface
    ['{A1000002-1111-1111-1111-000000000001}']
  end;

  IArtikelResultEvent = interface
    ['{A1000002-1111-1111-1111-000000000002}']
    function GetResultText: string;
    property ResultText: string read GetResultText;
  end;

  // --- Python Kunden ---
  IOpenPyKundenEvent = interface
    ['{A1000003-1111-1111-1111-000000000001}']
  end;

  // --- Python Artikel ---
  IOpenPyArtikelEvent = interface
    ['{A1000004-1111-1111-1111-000000000001}']
  end;

// --- Implementierungen ---

  TOpenKundenEvent = class(TInterfacedObject, IOpenKundenEvent)
  end;

  TKundenResultEvent = class(TInterfacedObject, IKundenResultEvent)
  private
    FText: string;
    function GetResultText: string;
  public
    constructor Create(const AText: string);
  end;

  TOpenArtikelEvent = class(TInterfacedObject, IOpenArtikelEvent)
  end;

  TArtikelResultEvent = class(TInterfacedObject, IArtikelResultEvent)
  private
    FText: string;
    function GetResultText: string;
  public
    constructor Create(const AText: string);
  end;

  TOpenPyKundenEvent = class(TInterfacedObject, IOpenPyKundenEvent)
  end;

  TOpenPyArtikelEvent = class(TInterfacedObject, IOpenPyArtikelEvent)
  end;

implementation

constructor TKundenResultEvent.Create(const AText: string);
begin
  inherited Create;
  FText := AText;
end;

function TKundenResultEvent.GetResultText: string;
begin
  Result := FText;
end;

constructor TArtikelResultEvent.Create(const AText: string);
begin
  inherited Create;
  FText := AText;
end;

function TArtikelResultEvent.GetResultText: string;
begin
  Result := FText;
end;

end.
