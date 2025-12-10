# Skrypt do konwersji INSTRUKCJA_OBSLUGI.md do Word
# Wymaga zainstalowanego Pandoc: https://pandoc.org/installing.html

$ErrorActionPreference = "Stop"

# Sprawdź czy Pandoc jest zainstalowany
try {
    $pandocVersion = pandoc --version 2>&1 | Select-Object -First 1
    Write-Host "Znaleziono Pandoc: $pandocVersion" -ForegroundColor Green
} catch {
    Write-Host "BLAD: Pandoc nie jest zainstalowany!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Aby zainstalowac Pandoc:" -ForegroundColor Yellow
    Write-Host "1. Pobierz instalator z: https://github.com/jgm/pandoc/releases/latest" -ForegroundColor Yellow
    Write-Host "2. Lub zainstaluj przez Chocolatey: choco install pandoc" -ForegroundColor Yellow
    Write-Host "3. Lub zainstaluj przez winget: winget install --id JohnMacFarlane.Pandoc" -ForegroundColor Yellow
    exit 1
}

# Sciezki
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mdFile = Join-Path $scriptDir "INSTRUKCJA_OBSLUGI.md"
$outputFile = Join-Path $scriptDir "INSTRUKCJA_OBSLUGI.docx"

# Sprawdz czy plik zrodlowy istnieje
if (-not (Test-Path $mdFile)) {
    Write-Host "BLAD: Nie znaleziono pliku $mdFile" -ForegroundColor Red
    exit 1
}

Write-Host "Konwertuje $mdFile do Word..." -ForegroundColor Cyan

# Konwersja
try {
    pandoc $mdFile `
        -o $outputFile `
        --from markdown `
        --to docx `
        --standalone `
        --toc `
        --toc-depth=4 `
        --reference-links
    
    if (Test-Path $outputFile) {
        Write-Host "Plik utworzony: $outputFile" -ForegroundColor Green
        Write-Host "Modyfikuje obrazy (skala 50%, wysrodkowanie)..." -ForegroundColor Cyan
        
        # Modyfikuj obrazy w dokumencie Word
        try {
            $fullPath = (Resolve-Path $outputFile).Path
            
            # Sprawdz czy plik jest otwarty w Word
            $fileOpen = $false
            try {
                $wordCheck = New-Object -ComObject Word.Application
                $wordCheck.Visible = $false
                foreach ($doc in $wordCheck.Documents) {
                    if ($doc.FullName -eq $fullPath) {
                        $fileOpen = $true
                        break
                    }
                }
                $wordCheck.Quit()
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wordCheck) | Out-Null
            } catch {
                # Ignoruj błędy sprawdzania
            }
            
            if ($fileOpen) {
                Write-Host "UWAGA: Plik $outputFile jest otwarty w Word!" -ForegroundColor Yellow
                Write-Host "Prosze zamknac plik i uruchomic skrypt ponownie." -ForegroundColor Yellow
                Write-Host "Pominieto modyfikacje obrazow." -ForegroundColor Yellow
            } else {
                $word = New-Object -ComObject Word.Application
                $word.Visible = $false
                $word.DisplayAlerts = 0  # wdAlertsNone
                
                # Otworz plik
                $doc = $word.Documents.Open($fullPath)
            
                $imageCount = 0
                foreach ($inlineShape in $doc.InlineShapes) {
                    if ($inlineShape.Type -eq 3) {
                        $inlineShape.LockAspectRatio = $true
                        $inlineShape.Width = $inlineShape.Width * 0.5
                        $inlineShape.Range.ParagraphFormat.Alignment = 1
                        $imageCount++
                    }
                }
                
                # Obsluga obrazow w ksztaltach (Shapes)
                foreach ($shape in $doc.Shapes) {
                    if ($shape.Type -eq 13 -or $shape.Type -eq 11) {
                        $shape.LockAspectRatio = $true
                        $shape.Width = $shape.Width * 0.5
                        $shape.Left = ($doc.PageSetup.PageWidth - $shape.Width) / 2
                        $imageCount++
                    }
                }
                
                Write-Host "Zmodyfikowano $imageCount obrazow" -ForegroundColor Green
                
                # Dodaj naglowki
                Write-Host "Dodaje naglowki..." -ForegroundColor Cyan
                
                # Naglowek dla wszystkich stron
                $headerText = "Instrukcja obsługi aplikacji PIESP Patrol"
                
                foreach ($section in $doc.Sections) {
                    $header = $section.Headers.Item(1)  # wdHeaderFooterPrimary
                    $header.Range.Text = $headerText
                    $header.Range.Font.Size = 10
                    $header.Range.ParagraphFormat.Alignment = 1  # wdAlignParagraphCenter
                }
                
                $doc.Save()
                $doc.Close()
                $word.Quit()
                
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()
                
                Write-Host "Dodano naglowki" -ForegroundColor Green
            }
        } catch {
            Write-Host "OSTRZEZENIE: Nie udalo sie zmodyfikowac obrazow: $_" -ForegroundColor Yellow
            Write-Host "Dokument zostal utworzony, ale obrazy moga wymagac recznej modyfikacji." -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "Sukces! Plik gotowy: $outputFile" -ForegroundColor Green
        Write-Host ""
        Write-Host "Otwieranie pliku..." -ForegroundColor Cyan
        Start-Process $outputFile
    } else {
        Write-Host "BLAD: Plik nie zostal utworzony" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "BLAD podczas konwersji: $_" -ForegroundColor Red
    exit 1
}
