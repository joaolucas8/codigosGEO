@echo off
REM Eleva o script para rodar como administrador
REM Verifica se o script está sendo executado como administrador
openfiles >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Este script precisa ser executado como administrador.
    pause
    exit /b
)

REM Altera a política de execução do PowerShell para Unrestricted
powershell -Command "Set-ExecutionPolicy Unrestricted -Force"

REM exibe a nova política de execução
powershell -Command "Get-ExecutionPolicy"

echo A politica de execucao foi alterada para Unrestricted.

timeout 2

REM requerimentos

echo Instalando o MS201032
pushd "F:\Scripts DATAENGINEER\requirements"
start /wait MS201032.exe /silent /quiet /S
popd

echo Instalando o MS201064
pushd "F:\Scripts DATAENGINEER\requirements"
start /wait MS201064.exe /silent /quiet /S 
popd

echo Instalando o MS201332
pushd "F:\Scripts DATAENGINEER\requirements"
start /wait MS201332.exe /silent /quiet /S
popd

echo Instalando o MS201364
pushd "F:\Scripts DATAENGINEER\requirements"
start /wait MS201364.exe /silent /quiet /S
popd

echo Instalando o MS201564
pushd "F:\Scripts DATAENGINEER\requirements"
start /wait MS201564.exe /silent /quiet /S
popd

echo Instalando o MSredistributable32
pushd "F:\Scripts DATAENGINEER\requirements"
start /wait MSredistributable32.exe /silent /quiet /S
popd

echo Instalando o MSredistributable64
pushd "F:\Scripts DATAENGINEER\requirements"
start /wait MSredistributable64.exe /silent /quiet /S
popd

timeout 3

echo Instalando o winlog
pushd "F:\Scripts DATAENGINEER"
start /wait winlog.exe --silent

timeout 5

REM Adiciona "C:\Program Files\Oracle\VirtualBox" à variável de ambiente Path
setx PATH "%PATH%;C:\Program Files\Oracle\VirtualBox"

echo Variavel de ambiente adicionada com sucesso.

timeout 7

vboxmanage import "%~dp0GLX-Virtual.ova"

timeout 10

mode con lines=22 col=86

:: Primeira Parte: Reduzir o Volume Existente

:: Listar discos disponíveis
echo list disk > list.txt
diskpart /s list.txt
del /f list.txt
echo:

:: Listar volumes no disco selecionado
echo list volume > list_volumes.txt
echo select disk 0 >> list_volumes.txt
diskpart /s list_volumes.txt
del /f list_volumes.txt

:: Criar comandos para reduzir o volume
echo select disk 0 > reduce.txt
echo select volume 0 >> reduce.txt
echo shrink desired=120000 >> reduce.txt

:: Executar comandos para reduzir o volume
diskpart /s reduce.txt
del /f reduce.txt

echo:
echo Operacao de reducao concluida.
timeout 1


:: Segunda Parte: Criar um Novo Volume Simples no Espaco Nao Alocado

:: Criar comandos para criar uma nova partição
echo select disk 0 > create_volume.txt
echo create partition primary size=120000 >> create_volume.txt
echo format fs=ntfs quick >> create_volume.txt
echo assign >> create_volume.txt

:: Executar comandos para criar a nova partição
diskpart /s create_volume.txt
del /f create_volume.txt

echo:
echo Operacao de criacao do volume concluida.

REM CONFIGURAÇÃO DATAENGINEER

@echo off
pushd %~dp0
Powershell.exe -File "%~dp0workgroup.ps1"

REM Definir a variável com o novo nome do computador
set NovoNome=DATAENGINEER-PC

REM Exibir o nome atual do computador
echo O nome atual do computador é: %computername%
wmic computersystem where name="%computername%" call rename name="%NovoNome%"

REM Verificar se o comando de renomeação foi bem-sucedido
if %errorlevel% neq 0 (
    echo Falha ao renomear o computador.
    pause
    exit /b %errorlevel%
)
timeout 5


REM Desabilitar o Firewall para o perfil de dominio
netsh advfirewall set domainprofile state off

REM Desabilitar o Firewall para o perfil privado
netsh advfirewall set privateprofile state off

REM Desabilitar o Firewall para o perfil público
netsh advfirewall set publicprofile state off

REM Exibir mensagem de conclusão
echo Firewall do Windows desabilitado para todos os perfis.



REM Este script desabilita o horário automático no Windows.

REM Desabilitar a sincronização automática de horário
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v Type /t REG_SZ /d NoSync /f

REM Desabilitar a atualização automática de fuso horário
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\AutoTimeZoneUpdate" /v Enabled /t REG_DWORD /d 0 /f

REM Verificar se os comandos foram bem-sucedidos
if %errorlevel% neq 0 (
    echo Falha ao desabilitar o horário automático.
    pause
    exit /b %errorlevel%
)

REM Exibir mensagem de conclusão
echo Horario automatico desabilitado com sucesso.

REM

@echo off
REM Criar um novo plano de energia baseado no "Alto desempenho"
powercfg /duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

REM Capturar o GUID do novo plano de energia
for /f "tokens=2 delims={}" %%i in ('powercfg /list ^| find "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"') do (
    set GUID=%%i
)

REM Renomear o plano para "Alto Desempenho Personalizado"
powercfg /changename %GUID% "Alto Desempenho Personalizado"

REM Definir o novo plano como ativo
powercfg /setactive %GUID%

REM Configurar o plano de energia para nunca desligar o vídeo (em modo AC - conectado à energia)
powercfg /change monitor-timeout-ac 0

REM Configurar o plano de energia para nunca desligar o vídeo (em modo DC - bateria)
powercfg /change monitor-timeout-dc 0

REM Configurar o plano de energia para nunca suspender a atividade do computador (em modo AC - conectado à energia)
powercfg /change standby-timeout-ac 0

REM Configurar o plano de energia para nunca suspender a atividade do computador (em modo DC - bateria)
powercfg /change standby-timeout-dc 0

REM Exibir mensagem de conclusão
echo Plano de energia "Alto Desempenho Personalizado" criado e configurado com sucesso.



REM Este script desabilita as atualizações automáticas do Windows.

REM Criar a chave de registro para desabilitar as atualizações automáticas
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f

REM Verificar se o comando foi bem-sucedido
if %errorlevel% neq 0 (
    echo Falha ao desabilitar as atualizações automáticas do Windows.
    pause
    exit /b %errorlevel%
)

REM Exibir mensagem de conclusão
echo As atualizacoes automaticas do Windows foram desabilitadas

timeout /t 10

REM COMPARTILHAMENTO DE PASTAS

@echo off
set "shared_folder=C:\COMPARTILHADA"
set "username=Todos"

REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\Csc\Parameters" /V FormatDatabase /T REG_DWORD /D 1 /F
REG ADD "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Lsa" /V LimitBlankPasswordUse /T REG_DWORD /D 0 /F

rem Etapa 1: Compartilhar a pasta
echo Compartilhando a pasta %shared_folder%...
net share COMPARTILHADA="%shared_folder%" /grant:%username%,FULL

rem Etapa 2: Configurar permissões de compartilhamento
echo Configurando permissoes de compartilhamento para o usuario %username%...
icacls "%shared_folder%" /grant %username%:(OI)(CI)F /T

rem Etapa 3: Configurar permissões de segurança
echo Configurando permissoes de segurança...
icacls "%shared_folder%" /inheritance:r
icacls "%shared_folder%" /grant:r %username%:(OI)(CI)F /T

timeout 5

REM banco de dados
@echo off

netsh wlan disconnect

echo "O wifi foi desconectado!"

netsh interface show interface
netsh interface set interface "Ethernet" admin=disable
echo "Rede Ethernet desativada"

pushd %~dp0
echo instalando o SQL

REM Muda o diretório para a pasta de documentos do usuário
pushd "F:\Scripts DATAENGINEER"


REM Inicia a instalação do arquivo MSI em modo silencioso e aceita todas as permissões
start /wait msiexec /i mysql-connector-odbc-8.0.18-winx64.msi /qn

echo SQL Server foi instalado com sucesso

timeout 5


REM configura odbc via powershell após a instalação
Powershell.exe -File "%~dp0configodbc.ps1"

timeout 5
netsh wlan disconnect

echo "O wifi foi ativado!"

netsh interface show interface
netsh interface set interface "Ethernet" admin=enable
echo "Rede Ethernet ativa"

REM SMPCLIENT
@echo off
setlocal enabledelayedexpansion

echo Instalando o SMP Client

rem Navega até o diretório do instalador
pushd "F:\Scripts DATAENGINEER\SMP_V2.6.42\Client\Volume"

start /wait setup.exe /q /acceptlicenses yes /r:n

popd

timeout 5


REM instalacao de softwares basicos
@echo off

echo Instalando o adobe
pushd "F:\Scripts DATAENGINEER\softwares-basicos"
start /wait adobe.exe /quiet /norestart /S
popd

echo Instalando o Chrome
pushd "F:\Scripts DATAENGINEER\softwares-basicos"
start /wait Chrome.exe /norestart /S
popd

echo Instalando o putty
pushd "F:\Scripts DATAENGINEER\softwares-basicos"
start /wait msiexec /i putty.msi /norestart /qn
popd

echo Instalando o TeamViewer
pushd "F:\Scripts DATAENGINEER\softwares-basicos"
start /wait TeamViewer.exe /norestart /S


echo Instalando o CuteWriter
pushd "F:\Scripts DATAENGINEER\softwares-basicos"
start /wait CuteWriter.exe /norestart /silent
popd

echo Instalando o winrar
pushd "F:\Scripts DATAENGINEER\softwares-basicos"
start /wait winrar.exe /norestart /S
popd


echo Instalando o synergy
pushd "F:\Scripts DATAENGINEER\softwares-basicos"
start /wait msiexec /i synergy.msi /norestart /qn
popd

echo Instalando o notepad
pushd "F:\Scripts DATAENGINEER\softwares-basicos"
start /wait notepad.exe /norestart /S
popd

pause
