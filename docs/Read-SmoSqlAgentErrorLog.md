---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Read-SmoSqlAgentErrorLog

## SYNOPSIS
Reads a SQL Agent error log.

## SYNTAX

### ServerInstance (Default)
```
Read-SmoSqlAgentErrorLog
	-ServerInstance <String>
	[-LogNumber <Int32>]
	[<CommonParameters>]
```

### SmoServer
```
Read-SmoSqlAgentErrorLog
	-SmoServerObject <Server>
	[-LogNumber <Int32>]
	[<CommonParameters>]
```

## DESCRIPTION
Reads a SQL Agent error log.

## EXAMPLES

### EXAMPLE 1
```powershell
Read-SmoSqlAgentErrorLog -ServerInstance MyServer
```

Returns agent error log.

### EXAMPLE 2
```powershell
Read-SmoSqlAgentErrorLog -SmoServerObject $SmoServerObject
```

Returns agent error log using specified Smo connection.

## PARAMETERS

### -LogNumber
Specifies agent log number.

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

### SqlServerAgent.ErrorLogRecord

## NOTES

## RELATED LINKS
