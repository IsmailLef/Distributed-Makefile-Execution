@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%"=="" @echo off
@rem ##########################################################################
@rem
@rem  app startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.
@rem This is normally unused
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and APP_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if %ERRORLEVEL% equ 0 goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\app.jar;%APP_HOME%\lib\utilities.jar;%APP_HOME%\lib\spark-sql_2.12-3.0.0.jar;%APP_HOME%\lib\spark-catalyst_2.12-3.0.0.jar;%APP_HOME%\lib\spark-core_2.12-3.0.0.jar;%APP_HOME%\lib\list.jar;%APP_HOME%\lib\commons-text-1.10.0.jar;%APP_HOME%\lib\hadoop-client-2.7.4.jar;%APP_HOME%\lib\hadoop-common-2.7.4.jar;%APP_HOME%\lib\gson-2.8.2.jar;%APP_HOME%\lib\spark-network-shuffle_2.12-3.0.0.jar;%APP_HOME%\lib\spark-network-common_2.12-3.0.0.jar;%APP_HOME%\lib\commons-lang3-3.12.0.jar;%APP_HOME%\lib\univocity-parsers-2.8.3.jar;%APP_HOME%\lib\spark-sketch_2.12-3.0.0.jar;%APP_HOME%\lib\spark-launcher_2.12-3.0.0.jar;%APP_HOME%\lib\spark-kvstore_2.12-3.0.0.jar;%APP_HOME%\lib\spark-unsafe_2.12-3.0.0.jar;%APP_HOME%\lib\spark-tags_2.12-3.0.0.jar;%APP_HOME%\lib\orc-core-1.5.10.jar;%APP_HOME%\lib\orc-mapreduce-1.5.10.jar;%APP_HOME%\lib\hive-storage-api-2.7.1.jar;%APP_HOME%\lib\parquet-hadoop-1.10.1.jar;%APP_HOME%\lib\parquet-column-1.10.1.jar;%APP_HOME%\lib\metrics-json-4.1.1.jar;%APP_HOME%\lib\jackson-module-scala_2.12-2.10.0.jar;%APP_HOME%\lib\jackson-module-paranamer-2.10.0.jar;%APP_HOME%\lib\jackson-databind-2.10.0.jar;%APP_HOME%\lib\chill_2.12-0.9.5.jar;%APP_HOME%\lib\xbean-asm7-shaded-4.15.jar;%APP_HOME%\lib\unused-1.0.0.jar;%APP_HOME%\lib\avro-mapred-1.8.2-hadoop2.jar;%APP_HOME%\lib\avro-ipc-1.8.2.jar;%APP_HOME%\lib\avro-1.8.2.jar;%APP_HOME%\lib\json4s-jackson_2.12-3.6.6.jar;%APP_HOME%\lib\json4s-core_2.12-3.6.6.jar;%APP_HOME%\lib\paranamer-2.8.jar;%APP_HOME%\lib\chill-java-0.9.5.jar;%APP_HOME%\lib\hadoop-mapreduce-client-app-2.7.4.jar;%APP_HOME%\lib\hadoop-mapreduce-client-jobclient-2.7.4.jar;%APP_HOME%\lib\hadoop-mapreduce-client-shuffle-2.7.4.jar;%APP_HOME%\lib\hadoop-mapreduce-client-common-2.7.4.jar;%APP_HOME%\lib\hadoop-mapreduce-client-core-2.7.4.jar;%APP_HOME%\lib\hadoop-yarn-client-2.7.4.jar;%APP_HOME%\lib\hadoop-yarn-server-nodemanager-2.7.4.jar;%APP_HOME%\lib\hadoop-yarn-server-common-2.7.4.jar;%APP_HOME%\lib\hadoop-yarn-common-2.7.4.jar;%APP_HOME%\lib\jaxb-api-2.2.2.jar;%APP_HOME%\lib\activation-1.1.1.jar;%APP_HOME%\lib\curator-recipes-2.7.1.jar;%APP_HOME%\lib\hadoop-auth-2.7.4.jar;%APP_HOME%\lib\curator-framework-2.7.1.jar;%APP_HOME%\lib\curator-client-2.7.1.jar;%APP_HOME%\lib\zookeeper-3.4.14.jar;%APP_HOME%\lib\javax.servlet-api-3.1.0.jar;%APP_HOME%\lib\commons-math3-3.4.1.jar;%APP_HOME%\lib\spotbugs-annotations-3.1.9.jar;%APP_HOME%\lib\arrow-vector-0.15.1.jar;%APP_HOME%\lib\arrow-memory-0.15.1.jar;%APP_HOME%\lib\jsr305-3.0.2.jar;%APP_HOME%\lib\jul-to-slf4j-1.7.30.jar;%APP_HOME%\lib\jcl-over-slf4j-1.7.30.jar;%APP_HOME%\lib\slf4j-log4j12-1.7.30.jar;%APP_HOME%\lib\stream-2.9.6.jar;%APP_HOME%\lib\metrics-jvm-4.1.1.jar;%APP_HOME%\lib\metrics-graphite-4.1.1.jar;%APP_HOME%\lib\metrics-jmx-4.1.1.jar;%APP_HOME%\lib\metrics-core-4.1.1.jar;%APP_HOME%\lib\orc-shims-1.5.10.jar;%APP_HOME%\lib\parquet-encoding-1.10.1.jar;%APP_HOME%\lib\parquet-common-1.10.1.jar;%APP_HOME%\lib\parquet-format-2.4.0.jar;%APP_HOME%\lib\apacheds-kerberos-codec-2.0.0-M15.jar;%APP_HOME%\lib\apacheds-i18n-2.0.0-M15.jar;%APP_HOME%\lib\api-asn1-api-1.0.0-M20.jar;%APP_HOME%\lib\api-util-1.0.0-M20.jar;%APP_HOME%\lib\slf4j-api-1.7.30.jar;%APP_HOME%\lib\hadoop-hdfs-2.7.4.jar;%APP_HOME%\lib\log4j-1.2.17.jar;%APP_HOME%\lib\compress-lzf-1.0.3.jar;%APP_HOME%\lib\snappy-java-1.1.7.5.jar;%APP_HOME%\lib\lz4-java-1.7.1.jar;%APP_HOME%\lib\zstd-jni-1.4.4-3.jar;%APP_HOME%\lib\RoaringBitmap-0.7.45.jar;%APP_HOME%\lib\commons-net-3.1.jar;%APP_HOME%\lib\scala-xml_2.12-1.2.0.jar;%APP_HOME%\lib\scala-reflect-2.12.10.jar;%APP_HOME%\lib\scala-parser-combinators_2.12-1.1.2.jar;%APP_HOME%\lib\json4s-ast_2.12-3.6.6.jar;%APP_HOME%\lib\json4s-scalap_2.12-3.6.6.jar;%APP_HOME%\lib\scala-library-2.12.10.jar;%APP_HOME%\lib\jersey-container-servlet-2.30.jar;%APP_HOME%\lib\jersey-container-servlet-core-2.30.jar;%APP_HOME%\lib\jersey-server-2.30.jar;%APP_HOME%\lib\jersey-client-2.30.jar;%APP_HOME%\lib\jersey-hk2-2.30.jar;%APP_HOME%\lib\jersey-media-jaxb-2.30.jar;%APP_HOME%\lib\jersey-common-2.30.jar;%APP_HOME%\lib\netty-all-4.1.47.Final.jar;%APP_HOME%\lib\ivy-2.4.0.jar;%APP_HOME%\lib\oro-2.0.8.jar;%APP_HOME%\lib\pyrolite-4.30.jar;%APP_HOME%\lib\py4j-0.10.9.jar;%APP_HOME%\lib\commons-crypto-1.0.0.jar;%APP_HOME%\lib\janino-3.0.16.jar;%APP_HOME%\lib\commons-compiler-3.0.16.jar;%APP_HOME%\lib\antlr4-runtime-4.7.1.jar;%APP_HOME%\lib\commons-httpclient-3.1.jar;%APP_HOME%\lib\httpclient-4.2.5.jar;%APP_HOME%\lib\commons-codec-1.10.jar;%APP_HOME%\lib\hadoop-yarn-api-2.7.4.jar;%APP_HOME%\lib\protobuf-java-2.5.0.jar;%APP_HOME%\lib\commons-configuration-1.6.jar;%APP_HOME%\lib\commons-lang-2.6.jar;%APP_HOME%\lib\aircompressor-0.10.jar;%APP_HOME%\lib\threeten-extra-1.5.0.jar;%APP_HOME%\lib\parquet-jackson-1.10.1.jar;%APP_HOME%\lib\jackson-mapper-asl-1.9.13.jar;%APP_HOME%\lib\jackson-jaxrs-1.9.13.jar;%APP_HOME%\lib\jackson-xc-1.9.13.jar;%APP_HOME%\lib\jackson-core-asl-1.9.13.jar;%APP_HOME%\lib\jackson-annotations-2.10.0.jar;%APP_HOME%\lib\jackson-core-2.10.0.jar;%APP_HOME%\lib\commons-compress-1.8.1.jar;%APP_HOME%\lib\xz-1.5.jar;%APP_HOME%\lib\kryo-shaded-4.0.2.jar;%APP_HOME%\lib\hadoop-annotations-2.7.4.jar;%APP_HOME%\lib\leveldbjni-all-1.8.jar;%APP_HOME%\lib\guava-16.0.1.jar;%APP_HOME%\lib\audience-annotations-0.5.0.jar;%APP_HOME%\lib\netty-3.10.6.Final.jar;%APP_HOME%\lib\shims-0.7.45.jar;%APP_HOME%\lib\jakarta.ws.rs-api-2.1.6.jar;%APP_HOME%\lib\hk2-locator-2.6.1.jar;%APP_HOME%\lib\hk2-api-2.6.1.jar;%APP_HOME%\lib\hk2-utils-2.6.1.jar;%APP_HOME%\lib\jakarta.inject-2.6.1.jar;%APP_HOME%\lib\jakarta.annotation-api-1.3.5.jar;%APP_HOME%\lib\osgi-resource-locator-1.0.3.jar;%APP_HOME%\lib\jakarta.validation-api-2.0.2.jar;%APP_HOME%\lib\javassist-3.25.0-GA.jar;%APP_HOME%\lib\arrow-format-0.15.1.jar;%APP_HOME%\lib\flatbuffers-java-1.9.0.jar;%APP_HOME%\lib\minlog-1.3.0.jar;%APP_HOME%\lib\objenesis-2.5.1.jar;%APP_HOME%\lib\commons-cli-1.2.jar;%APP_HOME%\lib\xmlenc-0.52.jar;%APP_HOME%\lib\commons-io-2.4.jar;%APP_HOME%\lib\commons-collections-3.2.2.jar;%APP_HOME%\lib\jetty-sslengine-6.1.26.jar;%APP_HOME%\lib\jsp-api-2.1.jar;%APP_HOME%\lib\htrace-core-3.1.0-incubating.jar;%APP_HOME%\lib\jetty-util-6.1.26.jar;%APP_HOME%\lib\xercesImpl-2.9.1.jar;%APP_HOME%\lib\aopalliance-repackaged-2.6.1.jar;%APP_HOME%\lib\commons-digester-1.8.jar;%APP_HOME%\lib\jline-0.9.94.jar;%APP_HOME%\lib\xml-apis-1.3.04.jar;%APP_HOME%\lib\guice-3.0.jar;%APP_HOME%\lib\commons-beanutils-1.7.0.jar;%APP_HOME%\lib\httpcore-4.2.4.jar;%APP_HOME%\lib\jettison-1.1.jar;%APP_HOME%\lib\stax-api-1.0-2.jar;%APP_HOME%\lib\javax.inject-1.jar;%APP_HOME%\lib\aopalliance-1.0.jar;%APP_HOME%\lib\cglib-2.2.1-v20090111.jar


@rem Execute app
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %APP_OPTS%  -classpath "%CLASSPATH%" scheduler.app.App %*

:end
@rem End local scope for the variables with windows NT shell
if %ERRORLEVEL% equ 0 goto mainEnd

:fail
rem Set variable APP_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
set EXIT_CODE=%ERRORLEVEL%
if %EXIT_CODE% equ 0 set EXIT_CODE=1
if not ""=="%APP_EXIT_CONSOLE%" exit %EXIT_CODE%
exit /b %EXIT_CODE%

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
