FROM mcr.microsoft.com/windows/servercore:ltsc2019

ENV chocolateyUseWindowsCompression false

RUN powershell -Command \
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature disable --name showDownloadProgress; \
    choco install -y mysql --version=8.0.17;

COPY stage/ /

RUN powershell -Command \
    sc.exe config MySQL binPath= "C:\tools\mysql\current\bin\mysqld --defaults-file=C:\tools\mysql\current\my.ini MySQL";

# monitor event log
# https://stackoverflow.com/a/55274110/1419658
ENTRYPOINT ["powershell"]
CMD Get-EventLog -LogName System -After (Get-Date).AddHours(-1) | Select -ExpandProperty Message;\
    $idx = (get-eventlog -LogName System -Newest 1).Index; \
    while ($true) \
    {; \
      start-sleep -Seconds 1; \
      $idx2  = (Get-EventLog -LogName System -newest 1).index; \
      get-eventlog -logname system -newest ($idx2 - $idx) |  sort index | Select -ExpandProperty Message; \
      $idx = $idx2; \
    }
