---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: Get-SmoSqlAgentCategory
---

# Get-SmoSqlAgentCategory

## SYNOPSIS

Gets the specified category.

## SYNTAX

### ServerInstance (Default)

```
Get-SmoSqlAgentCategory
  -ServerInstance <string>
  -Class <string>
  [-CategoryName <string>]
  [<CommonParameters>]
```

### SmoServer

```
Get-SmoSqlAgentCategory
  -SmoServerObject <Server>
  -Class <string>
  [-CategoryName <string>]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Gets the specified category of jobs, alerts, or operators from the current server.

## EXAMPLES

### EXAMPLE 1

Get-SmoSqlAgentCategory -ServerInstance MyServer -Class Alert -CategoryName MyCategory

Gets agent category MyCategory in class Alert.

### EXAMPLE 2

Get-SmoSqlAgentCategory -SmoServerObject $SmoServerObject -Class Alert -CategoryName MyCategory

Gets agent category MyCategory in class Alert using Smo server object.

## PARAMETERS

### -CategoryName

The name of the category to be removed.

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

### -Class

The class of the category.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Microsoft.SqlServer.Management.Smo.Agent.AlertCategory



### Microsoft.SqlServer.Management.Smo.Agent.JobCategory



### Microsoft.SqlServer.Management.Smo.Agent.OperatorCategory



## NOTES




## RELATED LINKS

None.

