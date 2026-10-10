# Zgradi spletno stran SOLZA iz predloge in vsebin v _gradnja/strani
# Zagon (v mapi repozitorija):  powershell -ExecutionPolicy Bypass -File _gradnja\zgradi.ps1
#
# Vsaka datoteka v _gradnja/strani ima na vrhu glavo:
#   ---
#   url: /ciscenje-jogijev/
#   naslov: Naslov strani (title)
#   opis: Opis za Google (meta description)
#   slika: /assets/img/... (neobvezno, slika za deljenje)
#   drobtine: Storitve=/storitve/ | Čiščenje jogijev   (neobvezno)
#   robots: noindex   (neobvezno)
#   ---
# V vsebini lahko uporabite {{kontakt}}, {{cta}}, {{povezave}} in {{drobtine}}.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding $false
function Read-Utf8($p) { [IO.File]::ReadAllText($p, $utf8) }
function Write-Utf8($p, $t) {
  $dir = Split-Path -Parent $p
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
  [IO.File]::WriteAllText($p, $t, $utf8)
}

$predloga = Read-Utf8 "$PSScriptRoot\predloga.html"
$deli = @{}
Get-ChildItem "$PSScriptRoot\deli\*.html" | ForEach-Object { $deli[$_.BaseName] = (Read-Utf8 $_.FullName).TrimEnd() }

$danes = Get-Date -Format 'yyyy-MM-dd'
$verzija = Get-Date -Format 'yyyyMMddHHmm'
$sitemap = New-Object System.Collections.Generic.List[string]

foreach ($f in Get-ChildItem "$PSScriptRoot\strani\*.html" | Sort-Object Name) {
  $raw = (Read-Utf8 $f.FullName) -replace "`r`n", "`n"
  if ($raw -notmatch '(?s)^---\n(.*?)\n---\n(.*)$') { throw "Manjka glava v $($f.Name)" }
  $glavaTxt = $Matches[1]; $vsebina = $Matches[2]
  $glava = @{}
  foreach ($line in $glavaTxt -split "`n") {
    if ($line -match '^\s*([a-z_]+)\s*:\s*(.*)$') { $glava[$Matches[1]] = $Matches[2].Trim() }
  }
  $url = $glava['url']
  foreach ($k in 'url', 'naslov', 'opis') { if (-not $glava[$k]) { throw "Manjka '$k' v $($f.Name)" } }
  $slika = if ($glava['slika']) { $glava['slika'] } else { '/assets/img/solza-og.jpg' }
  $robots = if ($glava['robots']) { $glava['robots'] } else { 'index, follow' }

  # Drobtine
  $drobHtml = ''; $drobShema = ''
  if ($glava['drobtine']) {
    $deli_d = @(@{ ime = 'Domov'; url = '/' })
    foreach ($d in $glava['drobtine'] -split '\|') {
      $d = $d.Trim(); $p = $d -split '=', 2
      $deli_d += @{ ime = $p[0].Trim(); url = $(if ($p.Count -gt 1) { $p[1].Trim() } else { $url }) }
    }
    $li = @(); $el = @(); $i = 1
    foreach ($d in $deli_d) {
      if ($i -lt $deli_d.Count) { $li += "<li><a href=""$($d.url)"">$($d.ime)</a></li>" }
      else { $li += "<li aria-current=""page"">$($d.ime)</li>" }
      $el += "{ ""@type"": ""ListItem"", ""position"": $i, ""name"": ""$($d.ime)"", ""item"": ""https://solza.si$($d.url)"" }"
      $i++
    }
    $drobHtml = "<nav class=""crumbs"" aria-label=""Drobtine""><ol>$($li -join '')</ol></nav>"
    $drobShema = "  <script type=""application/ld+json"">`n  { ""@context"": ""https://schema.org"", ""@type"": ""BreadcrumbList"", ""itemListElement"": [`n    $($el -join ",`n    ")`n  ] }`n  </script>"
  }

  foreach ($k in $deli.Keys) { $vsebina = $vsebina.Replace("{{$k}}", $deli[$k]) }
  $vsebina = $vsebina.Replace('{{drobtine}}', $drobHtml)

  $html = $predloga.Replace('{{vsebina}}', $vsebina.TrimEnd()).
    Replace('{{naslov}}', $glava['naslov']).
    Replace('{{opis}}', $glava['opis']).
    Replace('{{url}}', $url).
    Replace('{{slika}}', $slika).
    Replace('{{robots}}', $robots).
    Replace('{{shema_drobtine}}', $drobShema).
    Replace('{{leto}}', (Get-Date).Year.ToString()).
    Replace('{{verzija}}', $verzija)

  # Označi trenutno stran v glavnem meniju
  $i = $html.IndexOf('</header>')
  $glavaHtml = $html.Substring(0, $i).Replace("<a href=""$url"">", "<a href=""$url"" aria-current=""page"">")
  $html = $glavaHtml + $html.Substring($i)

  if ($html -match '\{\{[a-z_]+\}\}') { throw "Nezamenjan del $($Matches[0]) v $($f.Name)" }

  $izhod = if ($url -eq '/') { 'index.html' } elseif ($url -match '\.html$') { $url.TrimStart('/') } else { $url.Trim('/') + '/index.html' }
  Write-Utf8 (Join-Path $root $izhod) ($html -replace "`n", "`r`n")
  Write-Host "  $url  ->  $izhod"

  if ($robots -notmatch 'noindex') {
    $sitemap.Add("  <url><loc>https://solza.si$url</loc><lastmod>$danes</lastmod></url>")
  }
}

$xml = "<?xml version=""1.0"" encoding=""UTF-8""?>`n<urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">`n$($sitemap -join "`n")`n</urlset>`n"
Write-Utf8 (Join-Path $root 'sitemap.xml') $xml
Write-Host "Zgrajeno: $($sitemap.Count) strani v sitemap.xml"
