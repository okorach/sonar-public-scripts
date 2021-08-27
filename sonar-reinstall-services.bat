set SONAR_HOME_LTS="C:\SonarQube\sonarqube-lts"
set SONAR_HOME_LATEST="C:\SonarQube\sonarqube-latest"

set WRAPPER_CONF_LTS="C:\SonarQube\wrapper.lts.conf"
set WRAPPER_CONF_LATEST="C:\SonarQube\wrapper.latest.conf"

set LTS_SERVICE_NAME="SonarQube-LTS"
set LATEST_SERVICE_NAME="SonarQube-LATEST"

sc stop %LTS_SERVICE_NAME%
sc stop %LATEST_SERVICE_NAME%

:: Wait for services to stop
timeout /T 30

sc delete %LTS_SERVICE_NAME%
sc delete %LATEST_SERVICE_NAME%

sc create %LTS_SERVICE_NAME% binPath="\"%SONAR_HOME_LTS%\bin\windows-x86-64\wrapper.exe\" -s \"%WRAPPER_CONF_LTS%\""
sc create %LATEST_SERVICE_NAME% binPath="\"%SONAR_HOME_LATEST%\bin\windows-x86-64\wrapper.exe\" -s \"%WRAPPER_CONF_LATEST%\""

sc start  %LTS_SERVICE_NAME%
sc start  %LATEST_SERVICE_NAME%

pause