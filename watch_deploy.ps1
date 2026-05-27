$folder = "c:\Users\mingf\OneDrive\Desktop\Antigravity\3번 과제(투입횟수)\deploy"
$gitPath = "C:\Program Files\Git\cmd\git.exe"

Write-Host "👀 파일 변경 감시 및 자동 배포 시스템 시작..."
Write-Host "대상 폴더: $folder"
Write-Host "이 폴더 내 파일이 수정되고 3초 동안 추가 변경이 없으면 자동으로 깃허브에 배포됩니다."
Write-Host "종료하려면 이 창에서 Ctrl+C를 누르세요.`n"

# 초기화
$global:pending = $false
$global:lastRun = [DateTime]::MinValue

$fsw = New-Object IO.FileSystemWatcher $folder, "*.*" -Property @{
    IncludeSubdirectories = $false
    NotifyFilter = [IO.NotifyFilters]::LastWrite
}

# 파일 변경 감지 핸들러
$action = {
    # 깃 설정 파일이나 자기 자신(.ps1)은 무시
    $fileName = $Event.SourceEventArgs.Name
    if ($fileName -like "*.git*" -or $fileName -like "*watch_deploy.ps1") {
        return
    }
    
    $global:pending = $true
    $global:lastRun = [DateTime]::Now
}

$eventSub = Register-ObjectEvent $fsw Changed -Action $action

try {
    while ($true) {
        Start-Sleep -Milliseconds 500
        # 변경사항이 대기 중이고, 마지막 변경 발생 후 3초가 지나면 배포
        if ($global:pending -and ([DateTime]::Now - $global:lastRun).TotalSeconds -ge 3) {
            $global:pending = $false
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 📝 변경사항 감지! 자동 배포 시작..."
            
            try {
                Set-Location $folder
                & $gitPath add .
                # 변경된 파일 이름 추출 시도
                & $gitPath commit -m "자동 배포: 대시보드 파일 변경 반영 ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
                & $gitPath push origin main
                Write-Host "✅ 깃허브 배포 완료! https://mingfei0908-wq.github.io/production-dashboard/`n"
            } catch {
                Write-Host "❌ 배포 오류 발생: $_" -ForegroundColor Red
            }
        }
    }
} finally {
    # 이벤트 해제 및 자원 정리
    Unregister-Event -SourceIdentifier $eventSub.Name
    $fsw.Dispose()
    Write-Host "`n👋 파일 감시가 종료되었습니다."
}
