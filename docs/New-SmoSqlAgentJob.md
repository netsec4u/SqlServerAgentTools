---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# New-SmoSqlAgentJob

## SYNOPSIS
Creates a new job.

## SYNTAX

### ServerInstance (Default)
```
New-SmoSqlAgentJob
	-ServerInstance <String>
	-JobName <String>
	[-OwnerLoginName <String>]
	[-Category <String>]
	[-Description <String>]
	[-IsEnabled <Boolean>]
	[-EventLogLevel <CompletionAction>]
	[-DeleteLevel <CompletionAction>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### EmailOperator_ServerInstance
```
New-SmoSqlAgentJob
	-ServerInstance <String>
	-JobName <String>
	[-OwnerLoginName <String>]
	[-Category <String>]
	[-Description <String>]
	[-IsEnabled <Boolean>]
	-OperatorToEmail <String>
	-EmailLevel <CompletionAction>
	[-EventLogLevel <CompletionAction>]
	[-DeleteLevel <CompletionAction>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### EmailOperator_SmoServer
```
New-SmoSqlAgentJob
	-SmoServerObject <Server>
	-JobName <String>
	[-OwnerLoginName <String>]
	[-Category <String>]
	[-Description <String>]
	[-IsEnabled <Boolean>]
	-OperatorToEmail <String>
	-EmailLevel <CompletionAction>
	[-EventLogLevel <CompletionAction>]
	[-DeleteLevel <CompletionAction>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
New-SmoSqlAgentJob
	-SmoServerObject <Server>
	-JobName <String>
	[-OwnerLoginName <String>]
	[-Category <String>]
	[-Description <String>]
	[-IsEnabled <Boolean>]
	[-EventLogLevel <CompletionAction>]
	[-DeleteLevel <CompletionAction>]
	[-WhatIf]
	[-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a new job to be executed by SQL Agent service.

## EXAMPLES

### EXAMPLE 1
```powershell
New-SmoSqlAgentJob -ServerInstance MyServer -JobName MyJob -OwnerLoginName sa -OperatorToEmail MyOperator -EmailLevel OnFailure
```

Creates agent job MyJob.

### EXAMPLE 2
```powershell
New-SmoSqlAgentJob -SmoServerObject $SmoServerObject -JobName MyJob -OwnerLoginName sa -OperatorToEmail MyOperator -EmailLevel OnFailure
```

Creates agent job MyJob using Smo server object.

## PARAMETERS

### -Category
The category for the job.

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

### -DeleteLevel
A value that indicates when to delete the job.

```yaml
Type: CompletionAction
Parameter Sets: (All)
Aliases:
Accepted values: Never, OnSuccess, OnFailure, Always

Required: False
Position: Named
Default value: Never
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
The description of the job.

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

### -EmailLevel
A value that indicates when to send an e-mail upon the completion of this job.

```yaml
Type: CompletionAction
Parameter Sets: EmailOperator_ServerInstance, EmailOperator_SmoServer
Aliases:
Accepted values: Never, OnSuccess, OnFailure, Always

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventLogLevel
A value indicating when to place an entry in the Microsoft Windows application log for this job.

```yaml
Type: CompletionAction
Parameter Sets: (All)
Aliases:
Accepted values: Never, OnSuccess, OnFailure, Always

Required: False
Position: Named
Default value: OnFailure
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsEnabled
Indicates the status of the added job.

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
Specifies the name of the job.

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

### -OperatorToEmail
A value that indicates when to send an e-mail upon the completion of this job.

```yaml
Type: String
Parameter Sets: EmailOperator_ServerInstance, EmailOperator_SmoServer
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OwnerLoginName
The name of the login that owns the job.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Sa
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServerInstance
SQL Server host name and instance name.

```yaml
Type: String
Parameter Sets: ServerInstance, EmailOperator_ServerInstance
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
Parameter Sets: EmailOperator_SmoServer, SmoServer
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

### Microsoft.SqlServer.Management.Smo.Agent.Job

## NOTES

## RELATED LINKS
