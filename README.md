# SOLZA čistilni servis – solza.si

Statična spletna stran, objavljena prek GitHub Pages.

## Kako je zgrajena

Strani se ne urejajo neposredno v `index.html` ali v mapah, ampak v mapi `_gradnja`:

- `_gradnja/predloga.html` – skupna glava, meni, noga in SEO oznake za vse strani
- `_gradnja/deli/` – deli, ki se ponavljajo (kontaktni obrazec, poziv k akciji, povezave)
- `_gradnja/strani/` – vsebina posamezne strani (ena datoteka = ena stran)
- `_gradnja/zgradi.ps1` – skripta, ki iz vsega zgradi končne HTML datoteke in `sitemap.xml`

Po spremembi zaženite (Windows PowerShell, v mapi repozitorija):

```
powershell -ExecutionPolicy Bypass -File _gradnja\zgradi.ps1
```

in objavite (commit + push) vse spremenjene datoteke.

## Nova stran

1. Kopirajte obstoječo datoteko v `_gradnja/strani/` (npr. `12-stoli.html`).
2. Na vrhu spremenite `url`, `naslov`, `opis` in `drobtine`.
3. Napišite vsebino, zaženite gradnjo.
4. Dodajte povezavo na novo stran v meni ali nogo (`predloga.html`) in na sorodne strani.

## Slike

Optimizirane slike so v `assets/img/` v dveh velikostih (`-700.jpg` in `-1400.jpg`).
Nove fotografije pred objavo pomanjšajte na največ 1400 px širine.
