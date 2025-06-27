---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Get-SmoSqlAgentJobServer

## SYNOPSIS
Get SQL Agent Server.

## SYNTAX

### ServerInstance (Default)
```
Get-SmoSqlAgentJobServer
	-ServerInstance <String>
	[<CommonParameters>]
```

### SmoServer
```
Get-SmoSqlAgentJobServer
	-SmoServerObject <Server>
	[<CommonParameters>]
```

## DESCRIPTION
The Get-SmoSqlAgentJobServer function gets a SQL Agent Job Server object.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-SmoSqlAgentJobServer -ServerInstance MyServer
```

Gets agent job server.

### EXAMPLE 2
```powershell
Get-SmoSqlAgentJobServer -SmoServerObject $SmoServerObject
```

Gets agent job server using Smo server object.

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

### Microsoft.SqlServer.Management.Smo.Agent.JobServer

## NOTES

## RELATED LINKS
