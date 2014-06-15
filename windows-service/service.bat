@echo off
rem Licensed to the Apache Software Foundation (ASF) under one or more
rem contributor license agreements.  See the NOTICE file distributed with
rem this work for additional information regarding copyright ownership.
rem The ASF licenses this file to You under the Apache License, Version 2.0
rem (the "License"); you may not use this file except in compliance with
rem the License.  You may obtain a copy of the License at
rem
rem     http://www.apache.org/licenses/LICENSE-2.0
rem
rem Unless required by applicable law or agreed to in writing, software
rem distributed under the License is distributed on an "AS IS" BASIS,
rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem See the License for the specific language governing permissions and
rem limitations under the License.
setlocal ENABLEDELAYEDEXPANSION
set CURRENT_DIR=%cd%

rem 
cd ..
set HORNETQ_HOME=%cd%
set HORNETQ_BIN_DIR=%HORNETQ_HOME%\bin
set HORNETQ_CONFIG_DIR=%HORNETQ_HOME%\config\stand-alone\non-clustered

set EXECUTABLE=%HORNETQ_HOME%\bin\hornetq-x86_64.exe

rem Memory settings
set MEMORY_INITIAL_SIZE=512
set MEMORY_MAXIMUM_SIZE=1024

rem Service settings
set SERVICE_NAME=HornetQ
set SERVICE_DISPLAYNAME=HornetQ Messaging System
set SERVICE_DESCRIPTION=HornetQ Messaging System
set SERVICE_LOGPATH=%HORNETQ_HOME%\logs

rem 
if "x%1x" == "xx" goto showUsage
set SERVICE_CMD=%1
if /i %SERVICE_CMD% == install goto doInstall
if /i %SERVICE_CMD% == remove goto doRemove
if /i %SERVICE_CMD% == uninstall goto doRemove
echo Unknown parameter "%1"

:showUsage
echo Usage: service.bat install/uninstall
goto end

:doInstall
rem Install service
set CLASSPATH=%HORNETQ_CONFIG_DIR%;%HORNETQ_HOME%\schemas\
for /R lib %%A in (*.jar) do (
  set CLASSPATH=!CLASSPATH!;%%A
)
echo %CLASSPATH%
set JVM_OPTIONS=-XX:+UseParallelGC;-XX:+AggressiveOpts;-XX:+UseFastAccessorMethods;-Dhornetq.config.dir=%HORNETQ_CONFIG_DIR%;-Djava.util.logging.manager=org.jboss.logmanager.LogManager;-Djava.util.logging.config.file=%HORNETQ_CONFIG_DIR%\logging.properties;-Djava.library.path=.
"%EXECUTABLE%" //IS//%SERVICE_NAME% --DisplayName "%SERVICE_DISPLAYNAME%" --Description "%SERVICE_DESCRIPTION%" --Classpath "%CLASSPATH%" --StartMode jvm --StartClass org.hornetq.integration.bootstrap.HornetQBootstrapServer --StartParams hornetq-beans.xml --StopMode jvm --StopClass java.lang.System --StopMethod exit --StopParams 1 --Jvm auto --JvmOptions "%JVM_OPTIONS%" --JvmMs %MEMORY_INITIAL_SIZE% --JvmMx %MEMORY_MAXIMUM_SIZE% --LogPath "%SERVICE_LOGPATH%" --StdOutput auto --StdError auto
echo The service '%SERVICE_NAME%' has been installed.
goto end

:doRemove
rem Remove service
"%EXECUTABLE%" //DS//%SERVICE_NAME%
echo The service '%SERVICE_NAME%' has been removed
goto end

:end
cd "%CURRENT_DIR%"
