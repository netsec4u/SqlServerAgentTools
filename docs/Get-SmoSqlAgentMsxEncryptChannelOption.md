---
document type: cmdlet
external help file: SqlServerAgentTools-Help.xml
HelpUri: ''
Locale: en-US
Module Name: SqlServerAgentTools
ms.date: 07/29/2025
PlatyPS schema version: 2024-05-01
title: Get-SmoSqlAgentMsxEncryptChannelOption
---

# Get-SmoSqlAgentMsxEncryptChannelOption

## SYNOPSIS

Gets a SQL Agent Job MSX encrypt channel options.

## SYNTAX

### ServerInstance (Default)

```
Get-SmoSqlAgentMsxEncryptChannelOption
  -ServerInstance <string>
  [<CommonParameters>]
```

### SmoServer

```
Get-SmoSqlAgentMsxEncryptChannelOption
  -SmoServerObject <Server>
  [<CommonParameters>]
```

## ALIASES

This cmdlet has the following aliases:
  None

## DESCRIPTION

Gets a SQL Agent Job MSX encrypt channel options.

## EXAMPLES

### Example 1

```powershell
Get-SmoSqlAgentMsxEncryptChannelOption -ServerInstance MyServer
```

Gets SQL agent encrypt channel option from MyServer.

### Example 2

```powershell
Get-SmoSqlAgentMsxEncryptChannelOption -SmoServerObject $SmoServerObject
```

Gets SQL agent encrypt channel option using specified SMO connection for job MyJob.

## PARAMETERS

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

### SqlServerAgent.MsxEncryptChannelOption



## NOTES




## RELATED LINKS

None.

