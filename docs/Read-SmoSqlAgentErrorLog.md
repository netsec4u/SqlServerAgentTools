---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: https://github.com/netsec4u/SqlServerAgentTools/blob/main/docs/Read-SmoSqlAgentErrorLog.md
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 05/08/2026
PlatyPS schema version: 2024-05-01
title: Read-SmoSqlAgentErrorLog
---

# Read-SmoSqlAgentErrorLog

## SYNOPSIS

Reads a SQL Agent error log.

## SYNTAX

### ServerInstance (Default)

```
Read-SmoSqlAgentErrorLog
  -ServerInstance <string>
  [-LogNumber <int>]
  [<CommonParameters>]
```

### SmoServer

```
Read-SmoSqlAgentErrorLog
  -SmoServerObject <Server>
  [-LogNumber <int>]
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Reads a SQL Agent error log.

## EXAMPLES

### Example 1

```powershell
Read-SmoSqlAgentErrorLog -ServerInstance MyServer
```

Returns agent error log.

### Example 2

```powershell
Read-SmoSqlAgentErrorLog -SmoServerObject $SmoServerObject
```

Returns agent error log using specified Smo connection.

## PARAMETERS

### -LogNumber

Specifies agent log number.

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

### SqlServerAgent.ErrorLogRecord



## NOTES




## RELATED LINKS

