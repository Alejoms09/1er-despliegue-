param(
    [string]$Project = "1er-despliegue-",
    [string]$ApiService = "1er-despliegue-",
    [string]$DbService = "Postgres"
)

$ErrorActionPreference = "Stop"

function Invoke-Railway {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [switch]$AllowFailure
    )

    Write-Host ">> railway $($Arguments -join ' ')" -ForegroundColor Cyan
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & npx @railway/cli @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }

    if (-not $AllowFailure -and $exitCode -ne 0) {
        $text = ($output | Out-String).Trim()
        throw "Fallo comando Railway (exit $exitCode): $text"
    }

    return @{
        ExitCode = $exitCode
        Output = $output
    }
}

Write-Host "Validando sesion de Railway..." -ForegroundColor Yellow
$whoami = Invoke-Railway -Arguments @("whoami") -AllowFailure
if ($whoami.ExitCode -ne 0) {
    throw "No hay sesion activa. Ejecuta en una terminal interactiva: npx @railway/cli login"
}

Write-Host "Enlazando proyecto y servicio..." -ForegroundColor Yellow
$link = Invoke-Railway -Arguments @("link", "-p", $Project, "-s", $ApiService) -AllowFailure
if ($link.ExitCode -ne 0) {
    Write-Host "No se pudo enlazar servicio directo. Intentando solo proyecto..." -ForegroundColor DarkYellow
    Invoke-Railway -Arguments @("link", "-p", $Project) | Out-Null
}

Write-Host "Creando servicio PostgreSQL si no existe..." -ForegroundColor Yellow
$addDb = Invoke-Railway -Arguments @("add", "--database", "postgres", "--service", $DbService) -AllowFailure
if ($addDb.ExitCode -ne 0) {
    $dbText = ($addDb.Output | Out-String)
    if ($dbText -match "already" -or $dbText -match "exists") {
        Write-Host "PostgreSQL ya existe. Continuando..." -ForegroundColor DarkYellow
    } else {
        throw "No se pudo crear Postgres: $dbText"
    }
}

Write-Host "Configurando variables de entorno para la API..." -ForegroundColor Yellow
$pgHost = "PGHOST=`${{$DbService.PGHOST}}"
$pgPort = "PGPORT=`${{$DbService.PGPORT}}"
$pgDatabase = "PGDATABASE=`${{$DbService.PGDATABASE}}"
$pgUser = "PGUSER=`${{$DbService.PGUSER}}"
$pgPassword = "PGPASSWORD=`${{$DbService.PGPASSWORD}}"

Invoke-Railway -Arguments @(
    "variable",
    "set",
    "-s",
    $ApiService,
    $pgHost,
    $pgPort,
    $pgDatabase,
    $pgUser,
    $pgPassword
) | Out-Null

Write-Host "Haciendo redeploy del servicio API..." -ForegroundColor Yellow
Invoke-Railway -Arguments @("redeploy", "-s", $ApiService, "-y") | Out-Null

Write-Host "Generando dominio publico..." -ForegroundColor Yellow
$domain = Invoke-Railway -Arguments @("domain", "-s", $ApiService) -AllowFailure
if ($domain.ExitCode -ne 0) {
    Write-Host "No se pudo generar dominio automaticamente. Revisa Railway > Settings > Networking." -ForegroundColor DarkYellow
} else {
    $domainText = ($domain.Output | Out-String).Trim()
    Write-Host $domainText -ForegroundColor Green
}

Write-Host ""
Write-Host "Listo. Cuando termine el redeploy, prueba:" -ForegroundColor Green
Write-Host "  GET /" -ForegroundColor Green
Write-Host "  GET /api/tasks" -ForegroundColor Green
