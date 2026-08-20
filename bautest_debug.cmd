@echo off
rem Baut einen Konsolen-Pruefstand mit denselben Suchpfaden wie die IDE.
call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
cd /d C:\Users\weiss\source\repos\Heisenberg
set JV=C:\Users\weiss\source\repos\jvcl\jvcl
set TMPDCU=C:\Users\weiss\AppData\Local\Temp\claude\C--Users-weiss-Documents-Anthropic-Sitzung1\b81a12a3-253f-4b8e-9892-3eb15ab29b16\scratchpad\dcu3
if not exist "%TMPDCU%" mkdir "%TMPDCU%"
set JC=C:\Users\weiss\source\repos\jcl\jcl
dcc64 -B -Q -DDEBUG;PRUEFSTAND ^
 -NSSystem;System.Win;Winapi;Vcl;Vcl.Imaging;Data;Data.Win;Datasnap;Web;Soap;Xml ^
 -U"Tools;Ribbon;Win64\Debug;%JC%\lib\d37\win64;%JV%\lib\D37\win64;%JV%\common;%JV%\run;C:\Users\weiss\source\repos\DelphiAnthropic\source;C:\Users\weiss\source\repos\delphi-event-bus\source;C:\Users\weiss\source\repos\Python4Delphi\python4delphi\Source;C:\Users\weiss\source\repos\Virtual-TreeView\Source;C:\Users\weiss\source\repos\RibbonFramework\Lib" ^
 -I"Tools;%JV%\common;%JC%\source\include" ^
 -R"Tools;Ribbon;%JV%\Resources" ^
 -NU"%TMPDCU%" -E. %1
