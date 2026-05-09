---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: https://github.com/netsec4u/SqlServerAgentTools/blob/main/docs/Get-SmoSqlAgentOperator.md
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 05/08/2026
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

### Example 1

```powershell
Get-SmoSqlAgentOperator -ServerInstance MyServer
```

Lists agent operators.

### Example 2

```powershell
Get-SmoSqlAgentOperator -SmoServerObject $SmoServerObject
```

Lists agent operators using Smo server object.

### Example 3

```powershell
Get-SmoSqlAgentOperator -SmoServerObject $SmoServerObject -OperatorName MyOperator
```

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

The name of the SQL Server instance to connect to.

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

An existing SMO Server object representing the SQL Server instance.

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

