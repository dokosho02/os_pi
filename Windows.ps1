
# ls

function getFileName{
    Get-ChildItem -Name
}
Remove-Item alias:ls
Set-Alias ls getFileName

# git 
function gitAddCommit($message) {
    git add .
    git commit -m $message
}

function gitPull() {
    git pull
}

function gitPullPush($message) {
    git pull
    git push
}

function gitStatus($message) {
    git status
}

Set-Alias gpl gitPull
Set-Alias glh gitPullPush
Set-Alias gac gitAddCommit
Set-Alias gst gitStatus
Set-Alias py python
Set-Alias pt poetry

# show variable by name

# show file extension

function ShowFileExtensions()
{
    # http://superuser.com/questions/666891/script-to-set-hide-file-extensions
    Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . HideFileExt "0"
    Pop-Location
    Stop-Process -processName: Explorer -force # This will restart the Explorer service to make this work.
}
 
ShowFileExtensions

# exit cl programs
# `ctrl` + `break`

