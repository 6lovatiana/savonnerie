@echo off
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-8.0.504.1-hotspot"
"%JAVA_HOME%\bin\java.exe" -cp ".;build-file\lib\ojdbc6-11.jar" TestOracle
pause
