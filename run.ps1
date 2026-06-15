$GITHUB_USERNAME= "jandersn01"
$GITHUB_EMAIL= "jandersonsantos030@gmail.com"

$SERVICE_NAME= "order"
$RELEASE_VERSION= "v1.2.3"

Write-Host "Installing Go protobuf plugins..."

go install google.golang.org/protobuf/cmd/protoc-gen-go@latest 
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

$GOPATH= go env GOPATH
$GO_BIN = Join-Path $GOPATH "bin"

$env:PATH = "$env:PATH;$GO_BIN"

Write-Host "Generating Go source code"

if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: Go não encontrado no PATH."
    exit 1
}

if (-not (Get-Command protoc -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: protoc não encontrado no PATH."
    Write-Host "Instale o Protocol Buffers Compiler antes de rodar este script."
    exit 1
}

if (-not (Get-Command protoc-gen-go -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: protoc-gen-go não encontrado."
    exit 1
}

if (-not (Get-Command protoc-gen-go-grpc -ErrorAction SilentlyContinue)) {
    Write-Host "ERRO: protoc-gen-go-grpc não encontrado."
    exit 1
}

if (-not (Test-Path ".\$SERVICE_NAME")) {
    Write-Host "ERRO: pasta .\$SERVICE_NAME não encontrada."
    Write-Host "Você precisa rodar este script dentro da pasta microservices-proto."
    Write-Host "Também confira se existe uma pasta chamada $SERVICE_NAME com arquivos .proto dentro."
    exit 1
}

Write-Host "Generating Go source code..."

if (-not (Test-Path ".\golang")) {
    New-Item -ItemType Directory -Path ".\golang" | Out-Null
}

protoc `
  --go_out=.\golang `
  --go_opt=paths=source_relative `
  --go-grpc_out=.\golang `
  --go-grpc_opt=paths=source_relative `
  ".\$SERVICE_NAME\*.proto"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERRO: falha ao gerar os arquivos Go com protoc."
    exit 1
}

Write-Host "Generated Go source code files:"

Get-ChildItem ".\golang\$SERVICE_NAME"

Set-Location ".\golang\$SERVICE_NAME"

go mod init "github.com/$GITHUB_USERNAME/microservices-proto/golang/$SERVICE_NAME"

go mod tidy

Write-Host "Done."