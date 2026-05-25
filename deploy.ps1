$g = "C:\Program Files\Git\cmd\git.exe"
Set-Location "c:\Users\mingf\OneDrive\Desktop\Antigravity\3번 과제(투입횟수)\deploy"
& $g add .
& $g commit -m "대시보드 업데이트 $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
& $g push origin main
Write-Host "`n✅ 배포 완료! https://mingfei0908-wq.github.io/production-dashboard/"
