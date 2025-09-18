---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: Get-SmoSqlAgentOperator
---

# Get-SmoSqlAgentOperator

## SYNOPSIS

Gets a SQL Agent Job Operator object for each operator that is present in the target instance of SQL Agent.

## SYNTAX

### ServerInstance (Default)

```
Get-SmoSqlAgentOperator
  -ServerInstance <string>
  [-OperatorName <string>]
  [<CommonParameters>]
```

### SmoServer

```
Get-SmoSqlAgentOperator
  -SmoServerObject <Server>
  [-OperatorName <string>]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

The Get-SmoSqlAgentOperator function gets a SQL Agent Job object for each operator that is present in the target instance of SQL Agent.
If the name of the operator is provided, the function gets only this specific operator object.

## EXAMPLES

### EXAMPLE 1

Get-SmoSqlAgentOperator -ServerInstance MyServer

Lists agent operators.

### EXAMPLE 2

Get-SmoSqlAgentOperator -SmoServerObject $SmoServerObject

Lists agent operators using Smo server object.

### EXAMPLE 3

Get-SmoSqlAgentOperator -SmoServerObject $SmoServerObject -OperatorName MyOperator

Lists agent operator MyOperator using Smo server object.

## PARAMETERS

### -OperatorName

The operator name to retrieve.

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

### Microsoft.SqlServer.Management.Smo.Agent.Operator



## NOTES




## RELATED LINKS

None.

