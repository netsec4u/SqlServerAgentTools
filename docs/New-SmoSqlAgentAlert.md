---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# New-SmoSqlAgentAlert

## SYNOPSIS
Creates a agent alert.

## SYNTAX

### SqlServerEventMessageID_ServerInstance (Default)
```
New-SmoSqlAgentAlert
	-ServerInstance <String>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	[-DatabaseName <string>]
	[-MessageID <Int32>]
	[-EventDescriptionKeyword <String>]
	[-PerformanceObject <String>]
	[-PerformanceCounter <String>]
	[-PerformanceCounterInstance <String>]
	[-ComparisonOperator <String>]
	[-PerformanceValue <Decimal>]
	[-WmiEventNamespace <String>]
	[-WmiEventQuery <String>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerEventSeverity_ServerInstance
```
New-SmoSqlAgentAlert
	-ServerInstance <String>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	[-DatabaseName <String>]
	[-Severity <Int32>]
	[-EventDescriptionKeyword <String>]
	[-PerformanceObject <String>]
	[-PerformanceCounter <String>]
	[-PerformanceCounterInstance <String>]
	[-ComparisonOperator <String>]
	[-PerformanceValue <Decimal>]
	[-WmiEventNamespace <String>]
	[-WmiEventQuery <String>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerEventMessageID_SmoServer
```
New-SmoSqlAgentAlert
	-SmoServerObject <Server>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	[-DatabaseName <String>]
	[-MessageID <Int32>]
	[-EventDescriptionKeyword <String>]
	[-PerformanceObject <String>]
	[-PerformanceCounter <String>]
	[-PerformanceCounterInstance <String>]
	[-ComparisonOperator <String>]
	[-PerformanceValue <Decimal>]
	[-WmiEventNamespace <String>]
	[-WmiEventQuery <String>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SqlServerEventSeverity_SmoServer
```
New-SmoSqlAgentAlert
	-SmoServerObject <Server>
	-AlertName <String>
	[-IsEnabled <Boolean>]
	-AlertType <AlertType>
	[-DatabaseName <String>]
	[-Severity <Int32>]
	[-EventDescriptionKeyword <String>]
	[-PerformanceObject <String>]
	[-PerformanceCounter <String>]
	[-PerformanceCounterInstance <String>]
	[-ComparisonOperator <String>]
	[-PerformanceValue <Decimal>]
	[-WmiEventNamespace <String>]
	[-WmiEventQuery <String>]
	[-JobName <String>]
	[-IncludeEventDescription <NotifyMethods>]
	[-NotificationMessage <String>]
	[-DelayBetweenResponses <Int32>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Creates a agent alert.

## EXAMPLES

### EXAMPLE 1
```powershell
New-SmoSqlAgentAlert -ServerInstance . -AlertName MyAlert -AlertType SqlServerEvent -MessageID 823
```

Creates agent alert for events with message ID 823.

### EXAMPLE 2
```powershell
New-SmoSqlAgentAlert -SmoServerObject $SmoServerObject -AlertName MyAlert -AlertType SqlServerEvent -MessageID 823
```

Creates agent alert for events with message ID 823 using Smo server object.

### EXAMPLE 3
```powershell
New-SmoSqlAgentAlert -ServerInstance . -AlertName TestServerEvent -AlertType SqlServerEvent -Severity 16
```

Creates agent alert for events with severity 16.

### EXAMPLE 4
```powershell
New-SqlAgentAlert -ServerInstance . -AlertName TestPerformanceCondition -AlertType SqlServerPerformanceCondition -PerformanceObject 'SQL Statistics' -PerformanceCounter 'SQL Compilations/sec' -PerformanceCounterInstance '' -ComparisonOperator '>' -PerformanceValue 3000
```

Creates alert on performance object.

### EXAMPLE 5
```powershell
New-SmoSqlAgentAlert -ServerInstance . -AlertName TestWmiEvent -AlertType WmiEvent -WmiEventNamespace '\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER' -WmiEventQuery 'SELECT * FROM DDL_DATABASE_EVENTS'
```

Creates alert on WMI results.

## PARAMETERS

### -AlertName
Specifies the name of alert.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertType
The type of alert condition.

```yaml
Type: AlertType
Parameter Sets: (All)
Aliases:
Accepted values: SqlServerEvent, SqlServerPerformanceCondition, NonSqlServerEvent, WmiEvent

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComparisonOperator
The comparison operator used to compare counter to a value.  Dynamic parameter required when AlertType is SqlServerPerformanceCondition.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatabaseName
The database in which the error must occur for the alert to fire.  Dynamic parameter available when AlertType is SqlServerEvent.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DelayBetweenResponses
The wait period, in seconds, between responses to the alert.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventDescriptionKeyword
The sequence of characters that the description of the SQL Server error must be like. Transact-SQL LIKE expression pattern-matching characters can be used.  Dynamic parameter available when AlertType is SqlServerEvent.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeEventDescription
Is whether the description of the SQL Server error should be included as part of the notification message.

```yaml
Type: NotifyMethods
Parameter Sets: (All)
Aliases:
Accepted values: None, NotifyEmail, Pager, NetSend, NotifyAll

Required: False
Position: Named
Default value: NotifyEmail
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsEnabled
Indicates the current status of the alert.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobName
The name of the job to be executed in response to this alert.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MessageID
The message error number that defines the alert.  Dynamic parameter available when AlertType is SqlServerEvent.

```yaml
Type: Int32
Parameter Sets: SqlServerEventMessageID_ServerInstance, SqlServerEventSeverity_SmoServer
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NotificationMessage
Is an optional additional message sent to the operator as part of the e-mail, net send, or pager notification.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerformanceCounter
The performance counter to monitor.  Dynamic parameter required when AlertType is SqlServerPerformanceCondition.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerformanceCounterInstance
The instance of the performance counter.  Dynamic parameter available when AlertType is SqlServerPerformanceCondition.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerformanceObject
The performance object of the counter. Dynamic parameter required when AlertType is SqlServerPerformanceCondition.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerformanceValue
The numeric threshold value of the counter.  Dynamic parameter required when AlertType is SqlServerPerformanceCondition.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerInstance
SQL Server host name and instance name.

```yaml
Type: String
Parameter Sets: SqlServerEventMessageID_ServerInstance, SqlServerEventSeverity_ServerInstance
Aliases: SqlServer

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Severity
The severity level (from 1 through 25) that defines the alert. Dynamic parameter available when AlertType is SqlServerEvent.

```yaml
Type: Int32
Parameter Sets: SqlServerEventMessageID_ServerInstance, SqlServerEventSeverity_SmoServer
Aliases: SqlServer

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SmoServerObject
SQL Server Management Object.

```yaml
Type: Server
Parameter Sets: SqlServerEventSeverity_SmoServer, SqlServerEventMessageID_SmoServer
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WmiEventNamespace
The WMI namespace to query for events.  Dynamic parameter required when AlertType is WmiEvent.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WmiEventQuery
The query that specifies the WMI event for the alert.  Dynamic parameter required when AlertType is WmiEvent.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.SqlServer.Management.Smo.Agent.Alert

## NOTES

## RELATED LINKS
