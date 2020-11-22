@rem ������ע�͵ĵط�����Ҫ�޸ģ������ط�����Ҫ�޸ģ������Ӱ������ִ��ʧ��

set JAVA_HOME=D:\sss\soft\jdk
set ANT_HOME=D:\sss\soft\apache-ant-1.9.13-bin\apache-ant-1.9.13
set GRADLE_HOME=D:\sss\soft\gradle-4.4-all-win\gradle-4.4
set MAVEN_HOME=D:\sss\soft\apache-maven-3.3.9
set CI_ROOT=D:\sss\soft\CodeDEX_V3_Win64
set COMPILER_HOME=%CI_ROOT%\CodeDEX_V3\tool\tools\compiler-extract
set FORTIFY_HOME=%CI_ROOT%\CodeDEX_V3\tool\tools\fortify_17.20
set COVERITY_HOME=%CI_ROOT%\CodeDEX_V3\tool\tools\coverity_2019.03
set MARS_HOME=%CI_ROOT%\CodeDEX_V3\tool\tools\codemars_Newest
set SECMISSILE_HOME=%CI_ROOT%\CodeDEX_V3\tool\tools\secmissile_19.10
set CODEDEX_TOOL=%CI_ROOT%\CodeDEX_V3\tool\7za\Windows
set PATH=%JAVA_HOME%\bin;%ANT_HOME%\bin;%MAVEN_HOME%\bin;%GRADLE_HOME%\bin;%FORTIFY_HOME%\bin;%COVERITY_HOME%\bin;%COMPILER_HOME%\bin;%PATH%
set FORTIFY_BUILD_ID=sss
set language=java

set WORKSPACE=#WORKSPACE#
set SRC_ROOT=#SRC_ROOT#
set inter_dir=#inter_dir#
set PROJECT_NAME=#PROJECT_NAME#

set cov_tmp_dir=%inter_dir%\cov_tmp
set for_tmp_dir=%inter_dir%\for_tmp
set mas_tmp_dir=%inter_dir%\mas_tmp

rmdir /q /s %inter_dir%
md %inter_dir%

rem ���뵽�����ļ�(pom.xml)Ŀ¼��%SRC_ROOT%Ϊ��Ŀ¼
cd %SRC_ROOT%/ctsReport

rem Fortify
rem �޸��Լ��Ĺ�����������ӹ�������
call cov-build --dir %cov_tmp_dir% mvn clean package -Dmaven.test.skip=true -U -Parm -s settings.xml
@if "%errorlevel%" NEQ "0" (
	echo Build Failure
	exit
)

call %COMPILER_HOME%\bin\compiler-extract.bat -fh %FORTIFY_HOME% -lang %language% -dir %inter_dir% -b %FORTIFY_BUILD_ID% -fm 3g
if "%errorlevel%" NEQ "0" exit

cd %inter_dir%
%FORTIFY_HOME%\bin\sourceanalyzer.exe -b %FORTIFY_BUILD_ID% -Dcom.fortify.sca.ProjectRoot=%for_tmp_dir% -export-build-session %FORTIFY_BUILD_ID%.mbs -Xmx3g
if "%errorlevel%" NEQ "0" exit

cd %inter_dir%
%CODEDEX_TOOL%\7za a -tzip fortify.zip %FORTIFY_BUILD_ID%.mbs
if "%errorlevel%" NEQ "0" exit

rem CodeMars
cd %inter_dir%
call %MARS_HOME%\CodeMars.bat  -j -source %SRC_ROOT%  -output %inter_dir% -codedexPrj %PROJECT_NAME%
if "%errorlevel%" NEQ "0" exit

cd %inter_dir%
ren CodeMars.zip codemars.zip
if "%errorlevel%" NEQ "0" exit

rem Secmissile
cd %SECMISSILE_HOME%
SecMissile.bat "projectname=%PROJECT_NAME%@@sourcepath=%SRC_ROOT%@@indexpackagepath=%inter_dir%@@ipaddress=@@multisourcepath=@@pythonfiledir=%SECMISSILE_HOME%@@tool=hi"
if "%errorlevel%" NEQ "0" exit