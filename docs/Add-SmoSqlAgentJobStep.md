---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: Add-SmoSqlAgentJobStep
---

# Add-SmoSqlAgentJobStep

## SYNOPSIS

Add step to job.

## SYNTAX

### ServerInstance (Default)
```
Add-SmoSqlAgentJobStep
	-ServerInstance <String>
	-JobName <String>
	-JobStepName <String>
	[-AgentSubSystem <AgentSubSystem>]
	[-ProxyName <String>]
	[-Server <String>]
	[-DatabaseName <String>]
	[-CommandExecutionSuccessCode <Int32>]
	-Command <String>
	[-OnSuccessAction <StepCompletionAction>]
	[-OnSuccessStep <Int32>]
	[-RetryAttempts <Int32>]
	[-RetryInterval <Int32>]
	[-OnFailureAction <StepCompletionAction>]
	[-OnFailStep <Int32>]
	[-OutputFileName <FileInfo>]
	[-JobStepFlags <JobStepFlags>]
	[-DatabaseUserName <String>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Add-SmoSqlAgentJobStep
	-SmoServerObject <Server>
	-JobName <String>
	-JobStepName <String>
	[-AgentSubSystem <AgentSubSystem>]
	[-ProxyName <String>]
	[-Server <String>]
	[-DatabaseName <String>]
	[-CommandExecutionSuccessCode <Int32>]
	-Command <String>
	[-OnSuccessAction <StepCompletionAction>]
	[-OnSuccessStep <Int32>]
	[-RetryAttempts <Int32>]
	[-RetryInterval <Int32>]
	[-OnFailureAction <StepCompletionAction>]
	[-OnFailStep <Int32>]
	[-OutputFileName <FileInfo>]
	[-JobStepFlags <JobStepFlags>]
	[-DatabaseUserName <String>]
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Add step to job.

## EXAMPLES

### EXAMPLE 1

Add-SmoSqlAgentJobStep -ServerInstance MyServer -JobName MyJob -JobStepName MyJobStep -AgentSubSystem TransactSql

Adds job step MyJobStep to agent job MyJob.

### EXAMPLE 2

Add-SmoSqlAgentJobStep -SmoServerObject $SmoServerObject -JobName MyJob -JobStepName MyJobStep

Adds job step MyJobStep to agent job MyJob using Smo server object.

## PARAMETERS

### -AgentSubSystem

The subsystem used by the SQL Server Agent service to execute command.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.AgentSubSystem
DefaultValue: TransactSql
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

### -Command

The commands to be executed by SQLServerAgent service through subsystem.

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

### -CommandExecutionSuccessCode

The value returned by a CmdExec subsystem command to indicate that command executed successfully.
Dynamic parameter optional when AgentSubSystem is CmdExec.

```yaml
Type: System.Int32
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

### -DatabaseName

The name of the database in which to execute a Transact-SQL step.
Dynamic parameter is required when AgentSubSystem is AnalysisQuery or TransactSql.

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

### -DatabaseUserName

Specifies the name of the user account to use when executing a Transact-SQL step.
Dynamic parameter required when AgentSubSystem is TransactSql.

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

### -JobName

The name of the job to which to add the step.

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

### -JobStepFlags

Is an option that controls behavior.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.JobStepFlags
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

### -JobStepName

Specifies name of job step.

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

### -OnFailStep

The ID of the step in this job to execute if the step fails.
Dynamic parameter required when OnFailureAction is GoToStep.

```yaml
Type: System.Int32
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

### -OnFailureAction

The action to perform if the step fails.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.StepCompletionAction
DefaultValue: QuitWithFailure
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

### -OnSuccessAction

The action to perform if the step succeeds.

```yaml
Type: Microsoft.SqlServer.Management.Smo.Agent.StepCompletionAction
DefaultValue: QuitWithSuccess
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

### -OnSuccessStep

The ID of the step in this job to execute if the step succeeds.
Dynamic parameter required when OnSuccessAction is GoToStep.

```yaml
Type: System.Int32
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

### -OutputFileName

The name of the file in which the output of this step is saved.

```yaml
Type: System.IO.FileInfo
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

### -ProxyName

The name of the proxy that the job step runs as.
Dynamic parameter required when when AgentSubSystem is CmdExec, PowerShell, or Ssis.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ServerInstance
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -RetryAttempts

The number of retry attempts to use if this step fails.

```yaml
Type: System.Int32
DefaultValue: 0
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

### -RetryInterval

The amount of time in minutes between retry attempts.

```yaml
Type: System.Int32
DefaultValue: 0
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

### -Server

The Analysis Server.
Dynamic parameter required when agent subsystem is AnalysisCommand or AnalysisQuery.

```yaml
Type: System.String
DefaultValue: None
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ServerInstance
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

### Microsoft.SqlServer.Management.Smo.Agent.JobStep



## NOTES




## RELATED LINKS

None.

