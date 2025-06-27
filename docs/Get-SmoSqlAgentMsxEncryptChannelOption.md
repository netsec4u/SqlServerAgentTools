---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Get-SmoSqlAgentMsxEncryptChannelOption

## SYNOPSIS
Gets a SQL Agent Job MSX encrypt channel options.

## SYNTAX

### ServerInstance (Default)
```
Get-SmoSqlAgentMsxEncryptChannelOption
	-ServerInstance <String>
	[<CommonParameters>]
```

### SmoServer
```
Get-SmoSqlAgentMsxEncryptChannelOption
	-SmoServerObject <Server>
	[<CommonParameters>]
```

## DESCRIPTION
Gets a SQL Agent Job MSX encrypt channel options.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-SmoSqlAgentMsxEncryptChannelOption -ServerInstance MyServer
```

Gets SQL agent encrypt channel option from MyServer.

### EXAMPLE 2
```powershell
Get-SmoSqlAgentMsxEncryptChannelOption -SmoServerObject $SmoServerObject
```

Gets SQL agent encrypt channel option using specified SMO connection for job MyJob.

## PARAMETERS

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### SqlServerAgent.MsxEncryptChannelOption

## NOTES

## RELATED LINKS
