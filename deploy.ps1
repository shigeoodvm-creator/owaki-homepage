# owaki-homepage を Cloudflare Pages に公開する
#
# 使い方:  .\deploy.ps1
#
# 注意: homepage フォルダを直接 deploy すると、内部メモ（*.md）や
#       access-form\Code.gs まで公開されてしまう。
#       そのため、公開して良いファイルだけを一時フォルダにコピーしてから deploy する。

$ErrorActionPreference = 'Stop'
$src   = $PSScriptRoot
$stage = Join-Path $env:TEMP ("owaki-homepage-deploy-" + [guid]::NewGuid().ToString('N').Substring(0,8))

New-Item -ItemType Directory -Path $stage -Force | Out-Null
try {
    # 公開対象のみコピー
    Copy-Item (Join-Path $src 'index.html')       $stage
    Copy-Item (Join-Path $src 'form-endpoint.js') $stage
    Copy-Item (Join-Path $src 'images')           $stage -Recurse

    Write-Host "公開するファイル:" -ForegroundColor Cyan
    Get-ChildItem $stage -Recurse -File | ForEach-Object {
        Write-Host ("  " + $_.FullName.Substring($stage.Length + 1))
    }

    Push-Location $stage
    try {
        npx wrangler pages deploy . --project-name owaki-homepage --commit-dirty=true
    } finally {
        Pop-Location
    }
}
finally {
    Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
}
