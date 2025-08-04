$GroupEmailID = "your-group@yourdomain.com"
$CSVFile = "C:\Path\To\your-list.txt"

Connect-ExchangeOnline -ShowBanner:$False

$GroupMembers = Get-UnifiedGroupLinks -Identity $GroupEmailID -LinkType Members |
    Select-Object -ExpandProperty PrimarySmtpAddress

Import-CSV $CSVFile -Header "UPN" | ForEach-Object {
    $Email = $_.UPN.Trim().ToLower()

    if ($GroupMembers -contains $Email) {
        Write-Host -ForegroundColor Yellow "User is already a member: $Email"
    } else {
        try {
            Add-UnifiedGroupLinks -Identity $GroupEmailID -LinkType Members -Links $Email -ErrorAction Stop
            Write-Host -ForegroundColor Green "Added user to group: $Email"
        } catch {
            Write-Host -ForegroundColor Red "Error adding ${Email}: $($_.Exception.Message)"
        }
    }
}

Disconnect-ExchangeOnline -Confirm:$false