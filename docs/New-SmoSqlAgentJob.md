---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: New-SmoSqlAgentJob
---

# New-SmoSqlAgentJob

## SYNOPSIS

Creates a new job.

## SYNTAX

### ServerInstance (Default)

```
New-SmoSqlAgentJob
  -ServerInstance <string>
  -JobName <string>
  [-OwnerLoginName <string>]
  [-Category <string>]
  [-Description <string>]
  [-IsEnabled <bool>]
  [-EventLogLevel <CompletionAction>]
  [-DeleteLevel <CompletionAction>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

### EmailOperator_ServerInstance

```
New-SmoSqlAgentJob
  -ServerInstance <string>
  -JobName <string>
  -OperatorToEmail <string>
  -EmailLevel <CompletionAction>
  [-OwnerLoginName <string>]
  [-Category <string>]
  [-Description <string>]
  [-IsEnabled <bool>]
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
  -JobName <string>
  -OperatorToEmail <string>
  -EmailLevel <CompletionAction>
  [-OwnerLoginName <string>]
  [-Category <string>]
  [-Description <string>]
  [-IsEnabled <bool>]
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
  -JobName <string>
  [-OwnerLoginName <string>]
  [-Category <string>]
  [-Description <string>]
  [-IsEnabled <bool>]
  [-EventLogLevel <CompletionAction>]
  [-DeleteLevel <CompletionAction>]
  [-WhatIf]
  [-Confirm]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Creates a new job to be executed by SQL Agent service.

## EXAMPLES

### EXAMPLE 1

New-SmoSqlAgentJob -ServerInstance MyServer -JobName MyJob -OwnerLoginName sa -OperatorToEmail MyOperator -EmailLevel OnFailure

Creates agent job MyJob.

### EXAMPLE 2

New-SmoSqlAgentJob -SmoServerObject $SmoServerObject -JobName MyJob -OwnerLoginName sa -OperatorToEmail MyOperator -EmailLevel OnFailure

Creates agent job MyJob using Smo server object.

## PARAMETERS

### -Category

The category for the job.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -DeleteLevel

A value that indicates when to delete the job.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.CompletionAction
DefaultValue: Never
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Description

The description of the job.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -EmailLevel

A value that indicates when to send an e-mail upon the completion of this job.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.CompletionAction
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: EmailOperator_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: EmailOperator_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -EventLogLevel

A value indicating when to place an entry in the Microsoft Windows application log for this job.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.CompletionAction
DefaultValue: OnFailure
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -IsEnabled

Indicates the status of the added job.

```yaml
Type: System.Boolean
DefaultValue: True
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -JobName

Specifies the name of the job.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OperatorToEmail

A value that indicates when to send an e-mail upon the completion of this job.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: EmailOperator_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: EmailOperator_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -OwnerLoginName

The name of the login that owns the job.

```yaml
Type: System.String
DefaultValue: Sa
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ServerInstance

SQL Server host name and instance name.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases:
- SqlServer
ParameterSets:
- Name: EmailOperator_ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: ServerInstance
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SmoServerObject

SQL Server Management Object.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Server
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: EmailOperator_SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
- Name: SmoServer
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.SqlServer.Management.Smo.Agent.Job



## NOTES




## RELATED LINKS

None.

