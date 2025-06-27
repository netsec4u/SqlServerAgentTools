---
external help file: SQLServerAgentTools-help.xml
Module Name: SQLServerAgentTools
online version:
schema: 2.0.0
---

# Set-SmoSqlAgentMsxEncryptChannelOption

## SYNOPSIS
Sets MSX encrypt channel option.

## SYNTAX

### ServerInstance (Default)
```
Set-SmoSqlAgentMsxEncryptChannelOption
	-ServerInstance <String>
	-MsxEncryptChannelOption <Int32>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

### SmoServer
```
Set-SmoSqlAgentMsxEncryptChannelOption
	-SmoServerObject <Server>
	-MsxEncryptChannelOption <Int32>
	[-WhatIf]
	[-Confirm]
	[<CommonParameters>]
```

## DESCRIPTION
Sets MSX encrypt channel option.

## EXAMPLES

### EXAMPLE 1
```powershell
Set-SmoSqlAgentMsxEncryptChannelOption -ServerInstance MyServer -SubSystem PowerShell -MsxEncryptChannelOption 2
```

Sets MsxEncryptChannelOption to 2.

### EXAMPLE 2
```powershell
Set-SmoSqlAgentMsxEncryptChannelOption -SmoServerObject $SmoServerObject -SubSystem PowerShell -MsxEncryptChannelOption 2
```

Sets MsxEncryptChannelOption to 2 using the specified Smo server object.

## PARAMETERS

### -MsxEncryptChannelOption
Specifies MsxEncryptChannelOption value.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
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

### SqlServerAgent.MsxEncryptChannelOption

## NOTES

## RELATED LINKS
