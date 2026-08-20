inherited frmGuiTemplate4: TfrmGuiTemplate4
  Caption = 'frmGuiTemplate4'
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 2
  ExplicitTop = 2
  TextHeight = 15
  inherited pnlStamm: TPanel
    StyleElements = [seFont, seClient, seBorder]
    inherited pnlStammFelder: TPanel
      StyleElements = [seFont, seClient, seBorder]
      inherited rbtnbleft: TRibbonButtonBar
        StyleElements = [seFont, seClient, seBorder]
      end
    end
  end
  inherited rbnpnl1: TRibbonPanel
    StyleElements = [seFont, seClient, seBorder]
    TopPanel.StyleElements = [seFont, seClient, seBorder]
  end
end
