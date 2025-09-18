---
document type: cmdlet
external help file: SQLServerAgentTools-help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
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

### EXAMPLE 1

Read-SmoSqlAgentErrorLog -ServerInstance MyServer

Returns agent error log.

### EXAMPLE 2

Read-SmoSqlAgentErrorLog -SmoServerObject $SmoServerObject

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

### SqlServerAgent.ErrorLogRecord



## NOTES




## RELATED LINKS

None.

