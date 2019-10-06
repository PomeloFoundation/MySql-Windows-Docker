FROM mcr.microsoft.com/windows/servercore:ltsc2019

ENV chocolateyUseWindowsCompression false

RUN powershell -Command \
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature disable --name showDownloadProgress

RUN choco install -y mysql --version=8.0.17

# run a windows service and monitor logs
# https://stackoverflow.com/a/55274110/1419658
ENTRYPOINT ["powershell"]
CMD Start-Service mysql; \
    Get-EventLog -LogName System -After (Get-Date).AddHours(-1) | Format-List ;\
    $idx = (get-eventlog -LogName System -Newest 1).Index; \
    while ($true) \
    {; \
      start-sleep -Seconds 1; \
      $idx2  = (Get-EventLog -LogName System -newest 1).index; \
      get-eventlog -logname system -newest ($idx2 - $idx) |  sort index | Format-List; \
      $idx = $idx2; \
    }
