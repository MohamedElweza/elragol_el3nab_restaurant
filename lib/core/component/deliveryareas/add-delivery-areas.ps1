# PowerShell Script to Add Delivery Areas
# No dependencies required - uses built-in Invoke-RestMethod

Write-Host "🏪 Delivery Areas Manager (PowerShell Version)" -ForegroundColor Blue
Write-Host "============================================================" -ForegroundColor Blue

# Configuration
$API_URL = "https://c8ee04b37e9b.ngrok-free.app/api/v1/admin/deliveryAreas"
$TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OTAxNDg4OGU4M2UxMzg2MDExOTc4ZTUiLCJpYXQiOjE3NjE2OTI3NTR9.YaozXiuzOlCUP3TV1dguGcdcyb21HF3qks7bWZRIgxg"
$APIKEY = "ca36503d5358b81d9c3d0242738362f0"

Write-Host "📡 API Endpoint: $API_URL" -ForegroundColor Blue
Write-Host "🔑 Using API Key: $($APIKEY.Substring(0,8))..." -ForegroundColor Blue
Write-Host ""

# Headers for API requests
$headers = @{
    'Content-Type' = 'application/json'
    'Authorization' = "Bearer $TOKEN"
    'X-API-Key' = $APIKEY
    'ngrok-skip-browser-warning' = 'true'
}

# Delivery areas data
$deliveryAreas = @(
    @{ name = "سمنود"; deliveryFee = 20 },
    @{ name = "جراح"; deliveryFee = 40 },
    @{ name = "الناصريه"; deliveryFee = 35 },
    @{ name = "ابوصير"; deliveryFee = 50 },
    @{ name = "بنا ابو صير"; deliveryFee = 75 },
    @{ name = "ميت حبيب"; deliveryFee = 85 },
    @{ name = "ميت بدر"; deliveryFee = 95 },
    @{ name = "العجزيه"; deliveryFee = 120 },
    @{ name = "المحله"; deliveryFee = 75 },
    @{ name = "ابو علي"; deliveryFee = 50 },
    @{ name = "الراهبين"; deliveryFee = 40 },
    @{ name = "منيا"; deliveryFee = 25 },
    @{ name = "اجا"; deliveryFee = 55 },
    @{ name = "الديرس"; deliveryFee = 55 },
    @{ name = "نوسه البحر"; deliveryFee = 90 },
    @{ name = "نوسه الغيط"; deliveryFee = 90 },
    @{ name = "كفر التعابنيه"; deliveryFee = 40 },
    @{ name = "محله خلف"; deliveryFee = 40 },
    @{ name = "الناوية"; deliveryFee = 50 },
    @{ name = "عساس"; deliveryFee = 60 },
    @{ name = "بهبيت"; deliveryFee = 75 },
    @{ name = "طليمه"; deliveryFee = 75 },
    @{ name = "كفر حسان"; deliveryFee = 70 },
    @{ name = "كفر العرب"; deliveryFee = 130 },
    @{ name = "الجمزتين"; deliveryFee = 25 },
    @{ name = "منيا سمنود"; deliveryFee = 25 },
    @{ name = "سنبخت"; deliveryFee = 55 }
)

# Counters
$successCount = 0
$failedCount = 0
$skippedCount = 0
$totalAreas = $deliveryAreas.Count

Write-Host "🚀 Starting to add $totalAreas delivery areas..." -ForegroundColor Blue
Write-Host "============================================================" -ForegroundColor Blue

# Function to add delivery area
function Add-DeliveryArea {
    param($area, $index)
    
    Write-Host "`n[$index/$totalAreas] Adding: $($area.name) (Fee: $($area.deliveryFee) SAR)" -ForegroundColor White
    
    $body = @{
        name = $area.name
        deliveryFee = $area.deliveryFee
        estimatedTime = 30
    } | ConvertTo-Json -Depth 3
    
    try {
        $result = Invoke-RestMethod -Uri $API_URL -Method Post -Headers $headers -Body $body -ContentType "application/json"
        Write-Host "   ✅ Success: $($area.name) added" -ForegroundColor Green
        return "success"
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMessage = $_.Exception.Message
        
        # Check if it's a duplicate (409 Conflict)
        if ($statusCode -eq 409 -or $errorMessage -like "*already exists*") {
            Write-Host "   ⚠️  Skipped: $($area.name) (already exists)" -ForegroundColor Yellow
            return "skipped"
        }
        else {
            Write-Host "   ❌ Failed: $($area.name)" -ForegroundColor Red
            Write-Host "   Error: $errorMessage" -ForegroundColor Red
            if ($statusCode) {
                Write-Host "   Status Code: $statusCode" -ForegroundColor Red
            }
            return "failed"
        }
    }
}

# Add all delivery areas
for ($i = 0; $i -lt $deliveryAreas.Count; $i++) {
    $area = $deliveryAreas[$i]
    $result = Add-DeliveryArea -area $area -index ($i + 1)
    
    switch ($result) {
        "success" { $successCount++ }
        "failed" { $failedCount++ }
        "skipped" { $skippedCount++ }
    }
    
    # Add delay between requests
    if ($i -lt ($deliveryAreas.Count - 1)) {
        Start-Sleep -Seconds 1
    }
}

# Show summary
Write-Host "`n============================================================" -ForegroundColor Blue
Write-Host "📊 ADDITION SUMMARY" -ForegroundColor Blue
Write-Host "============================================================" -ForegroundColor Blue
Write-Host "✅ Successfully added: $successCount" -ForegroundColor Green
Write-Host "⚠️  Skipped (already exist): $skippedCount" -ForegroundColor Yellow
Write-Host "❌ Failed: $failedCount" -ForegroundColor Red

# Verify by fetching all areas
Write-Host "`n============================================================" -ForegroundColor Blue
Write-Host "🔍 Verifying all delivery areas..." -ForegroundColor Blue
Write-Host "============================================================" -ForegroundColor Blue

try {
    $allAreas = Invoke-RestMethod -Uri $API_URL -Method Get -Headers $headers
    $areas = $allAreas.data.deliveryAreas
    
    Write-Host "📦 Total areas in database: $($areas.Count)" -ForegroundColor Green
    Write-Host "`n📋 All delivery areas in database:" -ForegroundColor Blue
    Write-Host "────────────────────────────────────────────────────────" -ForegroundColor Blue
    
    # Sort by delivery fee and display
    $sortedAreas = $areas | Sort-Object deliveryFee
    foreach ($area in $sortedAreas) {
        $status = if ($area.isActive) { "Active" } else { "Inactive" }
        Write-Host "   $($area.name.PadRight(25)) $($area.deliveryFee) SAR ($status)" -ForegroundColor White
    }
    
    Write-Host "`nTotal: $($areas.Count) delivery areas" -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to fetch delivery areas: $($_.Exception.Message)" -ForegroundColor Red
}

# Final status
Write-Host "`n============================================================" -ForegroundColor Blue
if ($failedCount -eq 0) {
    Write-Host "✅ SUCCESS: Process completed!" -ForegroundColor Green
}
else {
    Write-Host "⚠️  WARNING: Some areas failed to add. Check the errors above." -ForegroundColor Yellow
}
Write-Host "============================================================" -ForegroundColor Blue

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")