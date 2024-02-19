#   About: Script to ping a list of servers and log faults to Kibana/Logstash via http endpoint.
#  Author: Qulle
#    Date: 2024-02-15
# Version: 1.0.0

$env = @{
    test = "https://001.localhost:1234";
    prod = "https://002.localhost:1234";
};

$endpoint = $env.test;
$headers = @{
    "Accept" = "application/json";
    "Content-Type" = "application/json";
};

$hostnames = @(
    "SERVER001",
    "SERVER002",
    "SERVER003",
    "COMPUTER001",
    "COMPUTER002"
);

foreach($hostname in $hostnames) {
    if(-not(
        Test-Connection $hostname -Count 1 -ErrorAction SilentlyContinue
    )) {
        $timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssK:fff").ToString();
        $message = [ordered]@{
            info = "Host not responding to PING";
            pingedHostname = $hostname;
            reportedBy = $env:computername;
        } | ConvertTo-Json -Compress;

        $body = @{
            fields = @{
                site = "company";
                team = "maintenance";
                application = "ping-monitor";
            };
            log = @{
                level = "Error";
            };
            origin = "ping-monitor.ps1";
            method = "script";
            message = $message;
            timestamp = $timestamp;
        } | ConvertTo-Json;

        Invoke-WebRequest -Uri $endpoint -Method POST -Body $body -Headers $headers | Out-Null;
    }
}
