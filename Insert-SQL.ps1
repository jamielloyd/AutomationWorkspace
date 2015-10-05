workflow Insert-SQL
{
	param
	(
		[String] $To,
		[object] $WebhookData
	)
	
	$EmailMarker = $WebhookData.RequestBody.IndexOf('EmailServer:')
	$Email = $WebhookData.RequestBody.Substring($EmailMarker + 12)
	$Feedback = $WebhookData.RequestBody.Substring(0, $EmailMarker)

    Write-Output "Full email submitted: "
    Write-Output $Email
    Write-Output "Full feedback submitted: "
    Write-Output $Feedback
    Write-Output ""

    ### BEGIN INSERT DATA INTO SQL ###

	$userName = Get-AutomationVariable -Name 'SqlFeedbackDbUserName'
	$password =	Get-AutomationVariable -Name 'SqlFeedbackDbPassword'
    $SqlConnectionString = "Server=tcp:automation-ise-addon.database.windows.net,1433;Database=automation-ise-addon;User ID=${userName};Password=${password};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    $tableName = "FeedbackFormSubmissions"
    try {
        inlinescript {
            Write-Output "Connecting to SQL DB..."
            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
            $sqlConnection.ConnectionString = $using:SqlConnectionString
            try {
                $sqlConnection.Open()
            } catch {
                Throw $error
            }
            if ($sqlConnection.State.value__ -eq 0) {
                Throw "Could not connect to the SQL DB. Connection wasn't opened"
            }
            Write-Output "Connected to DB"
            Write-Output "Begin inserting data into DB table ${using:tableName}..."
            $sqlCommand = $sqlConnection.CreateCommand()
            $emailTruncated = $using:Email
            $feedbackTruncated = $using:Feedback
            if ($emailTruncated.Length > 255) {
                $emailTruncated = $emailTruncated.Substring(0, 255)
            }
            if ($feedbackTruncated.Length > 2000) {
                $feedbackTruncated = $feedbackTruncated.Substring(0, 2000)
            }
            $sqlCommand.CommandText = "INSERT INTO ${using:tableName} (Email, Text) VALUES ('${emailTruncated}', '${feedbackTruncated}');"
            try {
                $result = $sqlCommand.ExecuteNonQuery()
            } catch {
                Write-Output "Closing SQL connection..."
                $sqlConnection.Close()
                Throw $error
            }
            Write-Output "Done inserting data."
            Write-Output "Closing SQL connection..."
            $sqlConnection.Close()
        }
    }
    catch {
        $errorMessage = "Database connection/insertion failed, job execution will be suspended.`nException:`n$_"
        $bodyMsg = "Oh no!`nRunbook: Receive-ISEFeedback`nAutomation Account: ISEAutomation`nSubscription: eamonoreillyhotmail.onmicrosoft.com`n`n$errorMessage"
        Send-AutomationEmail -To "alstab@microsoft.com" -Subject "Failed to insert ISE feedback into SQL :(" -Body $bodyMsg
        Throw $_
    }
    
    ### END INSERT DATA INTO SQL ###

    Write-Output "Done."
}