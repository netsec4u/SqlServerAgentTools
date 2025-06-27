---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
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

## DESCRIPTION
Add step to job.

## EXAMPLES

### EXAMPLE 1
```powershell
Add-SmoSqlAgentJobStep -ServerInstance MyServer -JobName MyJob -JobStepName MyJobStep -AgentSubSystem TransactSql
```

Adds job step MyJobStep to agent job MyJob.

### EXAMPLE 2
```powershell
Add-SmoSqlAgentJobStep -SmoServerObject $SmoServerObject -JobName MyJob -JobStepName MyJobStep
```

Adds job step MyJobStep to agent job MyJob using Smo server object.

## PARAMETERS

### -AgentSubSystem
The subsystem used by the SQL Server Agent service to execute command.

```yaml
Type: AgentSubSystem
Parameter Sets: (All)
Aliases:
Accepted values: TransactSql, ActiveScripting, CmdExec, Snapshot, LogReader, Distribution, Merge, QueueReader, AnalysisQuery, AnalysisCommand, Ssis, PowerShell

Required: False
Position: Named
Default value: TransactSql
Accept pipeline input: False
Accept wildcard characters: False
```

### -Command
The commands to be executed by SQLServerAgent service through subsystem.

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

### -CommandExecutionSuccessCode
The value returned by a CmdExec subsystem command to indicate that command executed successfully. Dynamic parameter optional when AgentSubSystem is CmdExec.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatabaseName
The name of the database in which to execute a Transact-SQL step. Dynamic parameter is required when AgentSubSystem is AnalysisQuery or TransactSql.

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

### -DatabaseUserName
Specifies the name of the user account to use when executing a Transact-SQL step. Dynamic parameter required when AgentSubSystem is TransactSql.

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

### -JobName
The name of the job to which to add the step.

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

### -JobStepFlags
Is an option that controls behavior.

```yaml
Type: JobStepFlags
Parameter Sets: (All)
Aliases:
Accepted values: None, AppendToLogFile, AppendToJobHistory, LogToTableWithOverwrite, AppendToTableLog, AppendAllCmdExecOutputToJobHistory, ProvideStopProcessEvent

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JobStepName
Specifies name of job step.

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

### -OnFailureAction
The action to perform if the step fails.

```yaml
Type: StepCompletionAction
Parameter Sets: (All)
Aliases:
Accepted values: QuitWithSuccess, QuitWithFailure, GoToNextStep, GoToStep

Required: False
Position: Named
Default value: QuitWithFailure
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnFailStep
The ID of the step in this job to execute if the step fails.  Dynamic parameter required when OnFailureAction is GoToStep.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnSuccessAction
The action to perform if the step succeeds.

```yaml
Type: StepCompletionAction
Parameter Sets: (All)
Aliases:
Accepted values: QuitWithSuccess, QuitWithFailure, GoToNextStep, GoToStep

Required: False
Position: Named
Default value: QuitWithSuccess
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnSuccessStep
The ID of the step in this job to execute if the step succeeds.  Dynamic parameter required when OnSuccessAction is GoToStep.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputFileName
The name of the file in which the output of this step is saved.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyName
The name of the proxy that the job step runs as.  Dynamic parameter required when when AgentSubSystem is CmdExec, PowerShell, or Ssis.

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

### -RetryAttempts
The number of retry attempts to use if this step fails.

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

### -RetryInterval
The amount of time in minutes between retry attempts.

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

### -Server
The Analysis Server.  Dynamic parameter required when agent subsystem is AnalysisCommand or AnalysisQuery.

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

### -ServerInstance
SQL Server host name and instance name.

```yaml
Type: String
Parameter Sets: ServerInstance
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
Parameter Sets: SmoServer
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

### Microsoft.SqlServer.Management.Smo.Agent.JobStep

## NOTES

## RELATED LINKS
