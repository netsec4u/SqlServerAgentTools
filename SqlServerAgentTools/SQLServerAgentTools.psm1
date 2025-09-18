Set-StrictMode -Version Latest

<#
Comment Based Help
	Add-SmoSqlAgentJobStep - Add examples

#>

#Region Enumerations
#EndRegion

#Region Classes
class ValidatePathIsValid : System.Management.Automation.ValidateArgumentsAttribute {
	[void]Validate([object]$Path, [System.Management.Automation.EngineIntrinsics]$EngineIntrinsics) {
		if([string]::IsNullOrWhiteSpace($Path)) {
			throw [System.ArgumentNullException]::New()
		}

		if ($Path -is [System.IO.DirectoryInfo]) {
			if (-not $(Test-Path -LiteralPath $Path.Parent -PathType Container)) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[System.ArgumentException]::New("Cannot find path '$Path.Directory' because it does not exist."),
					'1',
					[System.Management.Automation.ErrorCategory]::InvalidArgument,
					$Path
				)
			} elseif (-not $(Test-Path -LiteralPath $Path -PathType Container -IsValid)) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[System.ArgumentException]::New("The path '$Path.Name' is not valid."),
					'1',
					[System.Management.Automation.ErrorCategory]::InvalidArgument,
					$Path
				)
			}
		}

		if ($Path -is [System.IO.FileInfo]) {
			if (-not $(Test-Path -LiteralPath $_.Directory -PathType Container)) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[System.ArgumentException]::New("Cannot find path '$Path.Directory' because it does not exist."),
					'1',
					[System.Management.Automation.ErrorCategory]::InvalidArgument,
					$Path
				)
			} elseif (-not $(Test-Path -LiteralPath $_ -PathType Leaf -IsValid)) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[System.ArgumentException]::New("The path '$Path.Name' is not valid."),
					'1',
					[System.Management.Automation.ErrorCategory]::InvalidArgument,
					$Path
				)
			}
		}
	}
}
#EndRegion

#Region Type Definitions
$TypeDefinition = @'
using System;

namespace SqlServerAgent
{
	public class AgentSubsystem
	{
		public int SubSystemID;
		public string SubSystem;
		public string Description;
		public int MaxWorkerThreads;
	}

	public class ErrorLogRecord
	{
		public DateTime LogDate;
		public int ErrorLevel;
		public string Text;
	}

	public class JobHistory
	{
		public int InstanceID;
		public int SqlMessageID;
		public string Message;
		public int StepID;
		public string StepName;
		public int SqlSeverity;
		public Guid JobID;
		public string JobName;
		public int? RunStatus;

		public string RunStatusDescription
		{
			get
			{
				switch (RunStatus)
				{
					case 0:
						return "Failed";
					case 1:
						return "Succeeded";
					case 2:
						return "Retry";
					case 3:
						return "Canceled";
					case 4:
						return "In Progress";
					default:
						if (RunStatus == null)
						{
							return null;
						}
						else
						{
							throw new SqlServerAgent.UnknownRunStatus("Unknown SQL Agent run status.");
						}
				}
			}
		}

		public DateTime RunDate;
		public TimeSpan RunDuration;
		public string OperatorEmailed;
		public string OperatorNetsent;
		public string OperatorPaged;
		public int RetriesAttempted;
		public string Server;
	}

	public class MsxEncryptChannelOption
	{
		public string JobServer;
		public int? ChannelOption;

		public string Description
		{
			get
			{
				switch (ChannelOption)
				{
					case 0:
						return "No Encryption";
					case 1:
						return "TLS Encryption Trust Server Certificate";
					case 2:
						return "TLS Encryption";
					default:
						if (ChannelOption == null)
						{
							return null;
						}
						else
						{
							throw new SqlServerAgent.InvalidMsxEncryptChannelOption("Unknown Msx Encrypt Channel Option.");
						}
				}
			}
		}

		public MsxEncryptChannelOption(string JobServer, int ChannelOption)
		{
			this.JobServer = JobServer;
			this.ChannelOption = ChannelOption;
		}
	}

	[Serializable]
	public class InvalidMsxEncryptChannelOption : Exception
	{
		public InvalidMsxEncryptChannelOption() : base() { }
		public InvalidMsxEncryptChannelOption(string message) : base(message) { }
		public InvalidMsxEncryptChannelOption(string message, Exception inner) : base(message, inner) { }
	}

	[Serializable]
	public class UnknownRunStatus : Exception
	{
		public UnknownRunStatus() : base() { }
		public UnknownRunStatus(string message) : base(message) { }
		public UnknownRunStatus(string message, Exception inner) : base(message, inner) { }
	}
}
'@

Add-Type -TypeDefinition $TypeDefinition

Remove-Variable -Name @('TypeDefinition')
#EndRegion


function Add-SmoSqlAgentAlertOperator {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false)]
		[ValidateLength(1, 128)]
		[string]$AlertName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string[]]$OperatorName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$Alert = $JobServer.Alerts[$AlertName]

			if ($null -eq $Alert) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent alert not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$AlertName
				)
			}

			foreach ($Operator in $OperatorName) {
				if ($Operator -NotIn $JobServer.Operators.Name) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('Agent operator not found.'),
						'1',
						[System.Management.Automation.ErrorCategory]::ObjectNotFound,
						$Operator
					)
				}
			}

			$AlertOperators = $Alert.EnumNotifications([Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail).OperatorName

			foreach ($Operator in $OperatorName) {
				if ($Operator -in $AlertOperators) {
					$PSCmdlet.WriteError(
						[System.Management.Automation.ErrorRecord]::New(
							[Exception]::New('Agent alert operator exists.'),
							'1',
							[System.Management.Automation.ErrorCategory]::ResourceExists,
							$Operator
						)
					)
				} else {
					if ($PSCmdlet.ShouldProcess($Operator, "Add SQL Agent alert operator")) {
						$Alert.AddNotification($Operator, [Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail)
					}
				}
			}

			if ($PSCmdlet.ShouldProcess($AlertName, "Alter SQL Agent alert")) {
				$Alert.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Add-SmoSqlAgentJobSchedule {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ScheduleName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$AgentJob = $JobServer.Jobs[$JobName]

			if ($null -eq $AgentJob) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent job not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$JobName
				)
			}

			$Schedule = $JobServer.sharedSchedules[$ScheduleName]

			if ($null -eq $Schedule) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent schedule not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$ScheduleName
				)
			}

			if ($AgentJob.JobSchedules.Count -gt 0) {
				if ($ScheduleName -in $AgentJob.JobSchedules.Name) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('Agent schedule exists.'),
						'1',
						[System.Management.Automation.ErrorCategory]::ResourceExists,
						$ScheduleName
					)
				}
			}

			if ($PSCmdlet.ShouldProcess($ScheduleName, "Add SQL Agent job schedule")) {
				$AgentJob.AddSharedSchedule($Schedule.ID)

				$AgentJob.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Add-SmoSqlAgentJobStep {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.JobStep])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobStepName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.AgentSubSystem]$AgentSubSystem = 'TransactSql',

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[string]$Command,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.StepCompletionAction]$OnSuccessAction = 'QuitWithSuccess',

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateRange('Positive')]
		[int]$RetryAttempts = 0,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateRange('Positive')]
		[int]$RetryInterval = 0,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.StepCompletionAction]$OnFailureAction = 'QuitWithFailure',

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidatePathIsValid()]
		[System.IO.FileInfo]$OutputFileName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.JobStepFlags]$JobStepFlags
	)

	DynamicParam {
		$RuntimeDefinedParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

		if ($PSBoundParameters['AgentSubSystem'] -in @('CmdExec', 'PowerShell', 'Ssis')) {
			#Region ProxyName
			$ParameterName = 'ProxyName'

			$ProxyNameParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$ProxyNameParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($ProxyNameParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateLengthAttribute]::New(1, 128)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['AgentSubSystem'] -in @('AnalysisCommand', 'AnalysisQuery')) {
			#Region Server
			$ParameterName = 'Server'

			$ServerParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$ServerParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($ServerParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateLengthAttribute]::New(1, 128)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['AgentSubSystem'] -eq 'CmdExec') {
			#Region CommandExecutionSuccessCode
			$ParameterName = 'CommandExecutionSuccessCode'

			$CommandExecutionSuccessCodeParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$CommandExecutionSuccessCodeParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($CommandExecutionSuccessCodeParameterAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

			$RuntimeDefinedParameter.Value = 0

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['AgentSubSystem'] -in @('AnalysisQuery', 'TransactSql')) {
			#Region DatabaseName
			$ParameterName = 'DatabaseName'

			$DatabaseNameParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$DatabaseNameParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($DatabaseNameParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateLengthAttribute]::New(1, 128)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['OnSuccessAction'] -eq 'GoToStep') {
			#Region OnSuccessStep
			$ParameterName = 'OnSuccessStep'

			$OnSuccessStepParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$OnSuccessStepParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($OnSuccessStepParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New([System.Management.Automation.ValidateRangeKind]::Positive)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['OnFailureAction'] -eq 'GoToStep') {
			#Region OnFailStep
			$ParameterName = 'OnFailStep'

			$OnFailStepParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$OnFailStepParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($OnFailStepParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New([System.Management.Automation.ValidateRangeKind]::Positive)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['AgentSubSystem'] -eq 'TransactSql') {
			#Region DatabaseUserName
			$ParameterName = 'DatabaseUserName'

			$DatabaseUserNameParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$DatabaseUserNameParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($DatabaseUserNameParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateLengthAttribute]::New(1, 128)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		$RuntimeDefinedParameterDictionary
	}

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			if ($PSBoundParameters.ContainsKey("CommandExecutionSuccessCode")) {
				$CommandExecutionSuccessCode = $PSBoundParameters['CommandExecutionSuccessCode']
			}

			if ($PSBoundParameters.ContainsKey("DatabaseName")) {
				$DatabaseName = $PSBoundParameters['DatabaseName']
			}

			if ($PSBoundParameters.ContainsKey("DatabaseUserName")) {
				$DatabaseUserName = $PSBoundParameters['DatabaseUserName']
			}

			if ($PSBoundParameters.ContainsKey("OnFailStep")) {
				$OnFailStep = $PSBoundParameters['OnFailStep']
			}

			if ($PSBoundParameters.ContainsKey("OnSuccessStep")) {
				$OnSuccessStep = $PSBoundParameters['OnSuccessStep']
			}

			if ($PSBoundParameters.ContainsKey("ProxyName")) {
				$ProxyName = $PSBoundParameters['ProxyName']
			}

			if ($PSBoundParameters.ContainsKey("Server")) {
				$Server = $PSBoundParameters['Server']
			}
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$AgentJob = $JobServer.Jobs[$JobName]

			if ($null -eq $AgentJob) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent job not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$JobName
				)
			}

			$JobStep = [Microsoft.SqlServer.Management.Smo.Agent.JobStep]::New($AgentJob, $JobStepName)

			#Region General
			$JobStep.Subsystem = $AgentSubSystem

			if ($PSBoundParameters.ContainsKey("ProxyName")) {
				$JobStep.ProxyName = $ProxyName
			}

			if ($PSBoundParameters.ContainsKey("Server")) {
				$JobStep.Server = $Server
			}

			if ($PSBoundParameters.ContainsKey("DatabaseName")) {
				$JobStep.DatabaseName = $DatabaseName
			}

			if ($PSBoundParameters.ContainsKey("CommandExecutionSuccessCode")) {
				$JobStep.CommandExecutionSuccessCode = $CommandExecutionSuccessCode
			}

			$JobStep.Command = $Command
			#EndRegion

			#Region Advanced
			$JobStep.OnSuccessAction = $OnSuccessAction

			if ($PSBoundParameters.ContainsKey("OnSuccessStep")) {
				$JobStep.OnSuccessStep = $OnSuccessStep
			}

			$JobStep.RetryAttempts = $RetryAttempts
			$JobStep.RetryInterval = $RetryInterval

			$JobStep.OnFailAction = $OnFailureAction

			if ($PSBoundParameters.ContainsKey("OnFailStep")) {
				$JobStep.OnFailStep = $OnFailStep
			}

			if ($PSBoundParameters.ContainsKey("OutputFileName")) {
				$JobStep.OutputFileName = $OutputFileName
			}

			if ($PSBoundParameters.ContainsKey("JobStepFlags")) {
				$JobStep.JobStepFlags = $JobStepFlags
			}

			if ($PSBoundParameters.ContainsKey("DatabaseUserName")) {
				$JobStep.DatabaseUserName = $DatabaseUserName
			}
			#EndRegion

			if ($PSCmdlet.ShouldProcess($JobName, "Add SQL Agent job step")) {
				$JobStep.Create()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Add-SmoSqlAgentProxyPrincipal {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ProxyAccountName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string[]]$PrincipalName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$ProxyAccount = $JobServer.ProxyAccounts[$ProxyAccountName]

			if ($null -eq $ProxyAccount) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent proxy account not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$ProxyAccountName
				)
			}

			foreach ($Principal in $PrincipalName) {
				if ($Principal -NotIn $SmoServerObject.Logins.Name) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('Principal not found.'),
						'1',
						[System.Management.Automation.ErrorCategory]::ObjectNotFound,
						$PrincipalName
					)
				}
			}

			foreach ($Principal in $PrincipalName) {
				if ($PSCmdlet.ShouldProcess($Principal, "Add SQL Agent proxy principal")) {
					$ProxyAccount.AddLogin($Principal)
				}
			}

			if ($PSCmdlet.ShouldProcess($ProxyAccountName, "Alter SQL Agent proxy account")) {
				$ProxyAccount.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Add-SmoSqlAgentProxySubSystem {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ProxyAccountName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.AgentSubSystem]$SubSystemName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$ProxyAccount = $JobServer.ProxyAccounts[$ProxyAccountName]

			if ($null -eq $ProxyAccount) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent proxy account not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$ProxyAccountName
				)
			}

			if ($PSCmdlet.ShouldProcess($SubSystemName, "Add SQL Agent proxy subsystem")) {
				$ProxyAccount.AddSubSystem($SubSystemName)

				$ProxyAccount.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentAlert {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.Alert])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$AlertName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey("AlertName")) {
				$Alerts = $JobServer.Alerts[$AlertName]
			} else {
				$Alerts = $JobServer.Alerts
			}

			$Alerts
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentCategory {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType(
		[Microsoft.SqlServer.Management.Smo.Agent.AlertCategory],
		[Microsoft.SqlServer.Management.Smo.Agent.JobCategory],
		[Microsoft.SqlServer.Management.Smo.Agent.OperatorCategory]
	)]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateSet('Alert', 'Job', 'Operator')]
		[string]$Class,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$CategoryName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			switch ($Class) {
				'Alert' {
					if ($PSBoundParameters.ContainsKey("CategoryName")) {
						$Category = $JobServer.AlertCategories[$CategoryName]
					} else {
						$Category = $JobServer.AlertCategories
					}
				}
				'Job' {
					if ($PSBoundParameters.ContainsKey("CategoryName")) {
						$Category = $JobServer.JobCategories[$CategoryName]
					} else {
						$Category = $JobServer.JobCategories
					}
				}
				'Operator' {
					if ($PSBoundParameters.ContainsKey("CategoryName")) {
						$Category = $JobServer.OperatorCategories[$CategoryName]
					} else {
						$Category = $JobServer.OperatorCategories
					}
				}
			}

			$Category
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.Job])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey("JobName")) {
				$Jobs = $JobServer.Jobs[$JobName]
			} else {
				$Jobs = $JobServer.Jobs
			}

			$Jobs
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentJobServer {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.JobServer])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$JobServer = $SmoServerObject.JobServer

			$JobServer
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentMsxEncryptChannelOption {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([SqlServerAgent.MsxEncryptChannelOption])]

	param (
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}

		$AgentPathFormatString = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\{0}\SQLServerAgent'

		$ScriptBlock_GetMsxEncryptChannelOptions = {
			Param([string]$AgentPath)
			Get-ItemProperty -Path $AgentPath -Name MsxEncryptChannelOptions
		}
	}

	process {
		try {
			$CommandParameters = @{
				'ScriptBlock' = $ScriptBlock_GetMsxEncryptChannelOptions
				'ArgumentList' = [string]::Format($AgentPathFormatString, $SmoServerObject.ServiceInstanceId)
			}

			if ([System.Net.Dns]::GetHostName() -ne $SmoServerObject.NetName) {
				$CommandParameters.Add('ComputerName', $SmoServerObject.NetName)
			}

			$Results = Invoke-Command @CommandParameters

			[SqlServerAgent.MsxEncryptChannelOption]::New($JobServer.Name, $Results.MsxEncryptChannelOptions)
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentOperator {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.Operator])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$OperatorName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey("OperatorName")) {
				$Operators = $JobServer.Operators[$OperatorName]
			} else {
				$Operators = $JobServer.Operators
			}

			$Operators
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentProxyAccount {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.ProxyAccount])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ProxyAccountName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey("ProxyAccountName")) {
				$ProxyAccounts = $JobServer.ProxyAccounts[$ProxyAccountName]
			} else {
				$ProxyAccounts = $JobServer.ProxyAccounts
			}

			$ProxyAccounts
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentSchedule {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.JobSchedule])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ScheduleName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey("ScheduleName")) {
				$SharedSchedules = $JobServer.SharedSchedules[$ScheduleName]
			} else {
				$SharedSchedules = $JobServer.SharedSchedules
			}

			$SharedSchedules
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Get-SmoSqlAgentSubSystem {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([SqlServerAgent.AgentSubsystem])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.AgentSubSystem]$AgentSubSystem
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$DatabaseObject = $SmoServerObject.Databases['master']
		}
		catch {
			throw $_
		}

		$Query_AgentSubsystems = 'SELECT s.subsystem_id AS SubSystemID
			,	s.subsystem	SubSystem
			,	m.text AS Description
			,	s.max_worker_threads AS MaxWorkerThreads
			FROM msdb.dbo.syssubsystems s
			INNER JOIN sys.messages m ON s.description_id = m.message_id
			WHERE m.language_id = 1033;'
	}

	process {
		try {
			$DataSet = $DatabaseObject.ExecuteWithResults($Query_AgentSubsystems)

			if ($PSBoundParameters.ContainsKey("AgentSubSystem")) {
				$Rows = $DataSet.Tables.Select("subsystem = '$AgentSubSystem'")
			} else {
				$Rows = $DataSet.Tables.Select()
			}

			foreach ($Row in $Rows) {
				$SqlAgentSubSystem = [SqlServerAgent.AgentSubsystem]::New()

				foreach ($ColumnName in $Row.Table.Columns.ColumnName) {
					$SqlAgentSubSystem.$ColumnName = $Row.$ColumnName
				}

				$SqlAgentSubSystem
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function New-SmoSqlAgentAlert {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'SqlServerEventMessageID_ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.Alert])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventMessageID_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventSeverity_ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventMessageID_SmoServer'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventSeverity_SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$AlertName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[bool]$IsEnabled = $true,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.AlertType]$AlertType,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]$IncludeEventDescription = [Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateNotNullOrEmpty()]
		[string]$NotificationMessage,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateRange('Positive')]
		[int]$DelayBetweenResponses = 0
	)

	DynamicParam {
		$RuntimeDefinedParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

		switch ($AlertType) {
			'NonSqlServerEvent' {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Alert type not supported.'),
					'1',
					[System.Management.Automation.ErrorCategory]::InvalidOperation,
					$AlertType
				)
			}

			'SqlServerEvent' {
				#Region DatabaseName
				$ParameterName = 'DatabaseName'

				$DatabaseNameParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
				$AttributeCollection.Add($DatabaseNameParameterAttribute)

				$ValidateLengthAttribute = [System.Management.Automation.ValidateLengthAttribute]::New(1, 128)
				$AttributeCollection.Add($ValidateLengthAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region MessageID
				$ParameterName = 'MessageID'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$MessageIDParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$MessageIDParameterAttribute.Mandatory = $true
				$MessageIDParameterAttribute.ParameterSetName = 'SqlServerEventMessageID_ServerInstance'

				$AttributeCollection.Add($MessageIDParameterAttribute)

				$MessageIDParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$MessageIDParameterAttribute.Mandatory = $true
				$MessageIDParameterAttribute.ParameterSetName = 'SqlServerEventMessageID_SmoServer'

				$AttributeCollection.Add($MessageIDParameterAttribute)

				$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New(1, 65535)
				$AttributeCollection.Add($ValidateRangeAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region Severity
				$ParameterName = 'Severity'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$SeverityParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$SeverityParameterAttribute.Mandatory = $true
				$SeverityParameterAttribute.ParameterSetName = 'SqlServerEventSeverity_ServerInstance'

				$AttributeCollection.Add($SeverityParameterAttribute)

				$SeverityParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$SeverityParameterAttribute.Mandatory = $true
				$SeverityParameterAttribute.ParameterSetName = 'SqlServerEventSeverity_SmoServer'

				$AttributeCollection.Add($SeverityParameterAttribute)

				$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New(1, 25)
				$AttributeCollection.Add($ValidateRangeAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region EventDescriptionKeyword
				$ParameterName = 'EventDescriptionKeyword'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$EventDescriptionKeywordParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

				$AttributeCollection.Add($EventDescriptionKeywordParameterAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion
			}

			'SqlServerPerformanceCondition' {
				#Region PerformanceObject
				$ParameterName = 'PerformanceObject'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$PerformanceObjectParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$PerformanceObjectParameterAttribute.Mandatory = $true

				$AttributeCollection.Add($PerformanceObjectParameterAttribute)

				$ValidateNotNullOrEmptyAttribute = [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::New()
				$AttributeCollection.Add($ValidateNotNullOrEmptyAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region PerformanceCounter
				$ParameterName = 'PerformanceCounter'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$PerformanceCounterParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$PerformanceCounterParameterAttribute.Mandatory = $true

				$AttributeCollection.Add($PerformanceCounterParameterAttribute)

				$ValidateNotNullOrEmptyAttribute = [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::New()
				$AttributeCollection.Add($ValidateNotNullOrEmptyAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region PerformanceCounterInstance
				$ParameterName = 'PerformanceCounterInstance'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$PerformanceCounterParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

				$AttributeCollection.Add($PerformanceCounterParameterAttribute)

				$ValidateNotNullAttribute = [System.Management.Automation.ValidateNotNullAttribute]::New()
				$AttributeCollection.Add($ValidateNotNullAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)
				$RuntimeDefinedParameter.Value = ''

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region ComparisonOperator
				$ParameterName = 'ComparisonOperator'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$ComparisonOperatorParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$ComparisonOperatorParameterAttribute.Mandatory = $true

				$AttributeCollection.Add($ComparisonOperatorParameterAttribute)

				$ValidateSetAttribute = [System.Management.Automation.ValidateSetAttribute]::New('>', '<', '=')
				$AttributeCollection.Add($ValidateSetAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region PerformanceValue
				$ParameterName = 'PerformanceValue'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$PerformanceValueParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$PerformanceValueParameterAttribute.Mandatory = $true

				$AttributeCollection.Add($PerformanceValueParameterAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [decimal], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion
			}

			'WmiEvent' {
				#Region WmiEventNamespace
				$ParameterName = 'WmiEventNamespace'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$WmiEventNamespaceParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$WmiEventNamespaceParameterAttribute.Mandatory = $true

				$AttributeCollection.Add($WmiEventNamespaceParameterAttribute)

				$ValidateNotNullOrEmptyAttribute = [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::New()
				$AttributeCollection.Add($ValidateNotNullOrEmptyAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region WmiEventQuery
				$ParameterName = 'WmiEventQuery'

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

				$WmiEventQueryParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
				$WmiEventQueryParameterAttribute.Mandatory = $true

				$AttributeCollection.Add($WmiEventQueryParameterAttribute)

				$ValidateNotNullOrEmptyAttribute = [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::New()
				$AttributeCollection.Add($ValidateNotNullOrEmptyAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [string], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion
			}

			Default {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Unknown AlertType.'),
					'1',
					[System.Management.Automation.ErrorCategory]::InvalidOperation,
					$AlertType
				)
			}
		}

		$RuntimeDefinedParameterDictionary
	}

	begin {
		try {
			switch ($AlertType) {
				'SqlServerEvent' {
					if ($PSBoundParameters.ContainsKey("DatabaseName")) {
						$DatabaseName = $PSBoundParameters['DatabaseName']
					}

					if ($PSBoundParameters.ContainsKey("MessageID")) {
						$MessageID = $PSBoundParameters['MessageID']
					}

					if ($PSBoundParameters.ContainsKey("Severity")) {
						$Severity = $PSBoundParameters['Severity']
					}

					if ($PSBoundParameters.ContainsKey("EventDescriptionKeyword")) {
						$EventDescriptionKeyword = $PSBoundParameters['EventDescriptionKeyword']
					}
				}

				'SqlServerPerformanceCondition' {
					$PerformanceObject = $PSBoundParameters['PerformanceObject']
					$PerformanceCounter = $PSBoundParameters['PerformanceCounter']
					$PerformanceCounterInstance = $PSBoundParameters['PerformanceCounterInstance']
					$ComparisonOperator = $PSBoundParameters['ComparisonOperator']
					$PerformanceValue = $PSBoundParameters['PerformanceValue']
				}

				'WmiEvent' {
					$WmiEventNamespace = $PSBoundParameters['WmiEventNamespace']
					$WmiEventQuery = $PSBoundParameters['WmiEventQuery']
				}
			}

			if ($PSCmdlet.ParameterSetName -in @('SqlServerEventMessageID_ServerInstance', 'SqlServerEventSeverity_ServerInstance')) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$AgentAlert = [Microsoft.SqlServer.Management.Smo.Agent.Alert]::New($JobServer, $AlertName)

			$AgentAlert.IsEnabled = $IsEnabled

			switch ($AlertType) {
				'SqlServerEvent' {
					if ($PSBoundParameters.ContainsKey("DatabaseName")) {
						$AgentAlert.DatabaseName = $DatabaseName
					}

					if ($PSBoundParameters.ContainsKey("MessageID")) {
						$AgentAlert.MessageID = $MessageID
					}

					if ($PSBoundParameters.ContainsKey("Severity")) {
						$AgentAlert.Severity = $Severity
					}

					if ($PSBoundParameters.ContainsKey("EventDescriptionKeyword")) {
						$AgentAlert.EventDescriptionKeyword = $EventDescriptionKeyword
					}
				}

				'SqlServerPerformanceCondition' {
					$PerformanceCondition = [string]::Format('{0}|{1}|{2}|{3}|{4}', $PerformanceObject, $PerformanceCounter, $PerformanceCounterInstance, $ComparisonOperator, $PerformanceValue)

					$AgentAlert.PerformanceCondition = $PerformanceCondition
				}

				'WmiEvent' {
					$AgentAlert.WmiEventNamespace = $WmiEventNamespace
					$AgentAlert.WmiEventQuery = $WmiEventQuery
				}
			}

			if ($PSBoundParameters.ContainsKey("JobName")) {
				$AgentAlert.JobName = $JobName
			}

			$AgentAlert.IncludeEventDescription = $IncludeEventDescription

			if ($PSBoundParameters.ContainsKey("NotificationMessage")) {
				$AgentAlert.NotificationMessage = $NotificationMessage
			}

			$AgentAlert.DelayBetweenResponses = $DelayBetweenResponses

			if ($PSCmdlet.ShouldProcess($AlertName, "Create SQL Agent alert")) {
				$AgentAlert.Create()

				$AgentAlert
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function New-SmoSqlAgentCategory {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType(
		[Microsoft.SqlServer.Management.Smo.Agent.AlertCategory],
		[Microsoft.SqlServer.Management.Smo.Agent.JobCategory],
		[Microsoft.SqlServer.Management.Smo.Agent.OperatorCategory]
	)]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateSet('Alert', 'Job', 'Operator')]
		[string]$Class,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$CategoryName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			switch ($Class) {
				'Alert' {
					$Category = [Microsoft.SqlServer.Management.Smo.Agent.AlertCategory]::New($JobServer, $CategoryName)
				}
				'Job' {
					$Category = [Microsoft.SqlServer.Management.Smo.Agent.JobCategory]::New($JobServer, $CategoryName)
				}
				'Operator' {
					$Category = [Microsoft.SqlServer.Management.Smo.Agent.OperatorCategory]::New($JobServer, $CategoryName)
				}
			}

			if ($PSCmdlet.ShouldProcess($CategoryName, "Create SQL Agent category")) {
				$Category.Create()

				$Category
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function New-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.Job])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'EmailOperator_ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'EmailOperator_SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$OwnerLoginName = 'sa',

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$Category,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[string]$Description,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[bool]$IsEnabled = $true,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'EmailOperator_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'EmailOperator_SmoServer'
		)]
		[string]$OperatorToEmail,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'EmailOperator_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'EmailOperator_SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]$EmailLevel,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]$EventLogLevel = [Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::OnFailure,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]$DeleteLevel = [Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::Never
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -in @('ServerInstance', 'EmailOperator_ServerInstance')) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$AgentJob = [Microsoft.SqlServer.Management.SMO.Agent.Job]::New($JobServer, $JobName)

			$AgentJob.OwnerLoginName = $OwnerLoginName

			if ($PSBoundParameters.ContainsKey("Description")) {
				$AgentJob.Category = $Category
			}

			if ($PSBoundParameters.ContainsKey("Description")) {
				$AgentJob.Description = $Description
			}

			$AgentJob.IsEnabled = $IsEnabled

			if ($PSCmdlet.ParameterSetName -in @('EmailOperator_ServerInstance', 'EmailOperator_SmoServer')) {
				$AgentJob.OperatorToEmail = $OperatorToEmail
				$AgentJob.EmailLevel = $EmailLevel
			}

			$AgentJob.EventLogLevel = $EventLogLevel
			$AgentJob.DeleteLevel = $DeleteLevel

			if ($PSCmdlet.ShouldProcess($JobName, "Create SQL Agent job")) {
				$AgentJob.Create()

				$AgentJob.ApplyToTargetServer('(local)')

				$AgentJob.Alter()

				$AgentJob
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function New-SmoSqlAgentOperator {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.Operator])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$OperatorName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[bool]$IsEnabled = $true,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$OperatorEmailAddress
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$Operator = [Microsoft.SqlServer.Management.Smo.Agent.Operator]::New($JobServer, $OperatorName)

			$Operator.IsEnabled = $IsEnabled
			$Operator.EmailAddress = $OperatorEmailAddress

			if ($PSCmdlet.ShouldProcess($OperatorName, "Create SQL Agent operator")) {
				$Operator.Create()

				$Operator
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function New-SmoSqlAgentProxyAccount {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.ProxyAccount])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ProxyAccountName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$CredentialName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 512)]
		[string]$Description,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.AgentSubsystem[]]$AgentSubSystem
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$ProxyAccount = [Microsoft.SqlServer.Management.Smo.Agent.ProxyAccount]::New($JobServer, $ProxyAccountName, $CredentialName, $true, $Description)

			if ($PSCmdlet.ShouldProcess($ProxyAccountName, "Create SQL Agent proxy account")) {
				$ProxyAccount.Create()

				$ProxyAccount.AddSubSystem($AgentSubSystem)

				$ProxyAccount
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function New-SmoSqlAgentSchedule {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.JobSchedule])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance_FrequencySubDay'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer_FrequencySubDay'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ScheduleName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[bool]$IsEnabled = $true,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.SMO.Agent.FrequencyTypes]$FrequencyType
	)

	DynamicParam {
		$RuntimeDefinedParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

		if ($PSBoundParameters['FrequencyType'] -in @('Daily', 'Monthly', 'MonthlyRelative', 'Weekly')) {
			#Region FrequencyInterval
			$ParameterName = 'FrequencyInterval'

			$FrequencyIntervalParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$FrequencyIntervalParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($FrequencyIntervalParameterAttribute)

			switch ($PSBoundParameters['FrequencyType']) {
				'Daily' {
					$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New([System.Management.Automation.ValidateRangeKind]::Positive)
				}
				'Monthly' {
					$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New(1, 31)
				}
				'MonthlyRelative' {
					$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New(1, 10)
				}
				'Weekly' {
					$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New(1, 127)
				}
				Default {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('Unknown FrequencyType.'),
						'1',
						[System.Management.Automation.ErrorCategory]::InvalidOperation,
						$PSBoundParameters['FrequencyType']
					)
				}
			}

			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion

			#Region FrequencySubDayType
			$ParameterName = 'FrequencySubDayType'

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

			$FrequencySubDayTypeParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$FrequencySubDayTypeParameterAttribute.Mandatory = $true
			$FrequencySubDayTypeParameterAttribute.ParameterSetName = 'ServerInstance_FrequencySubDay'

			$AttributeCollection.Add($FrequencySubDayTypeParameterAttribute)

			$FrequencySubDayTypeParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$FrequencySubDayTypeParameterAttribute.Mandatory = $true
			$FrequencySubDayTypeParameterAttribute.ParameterSetName = 'SmoServer_FrequencySubDay'

			$AttributeCollection.Add($FrequencySubDayTypeParameterAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [Microsoft.SqlServer.Management.SMO.Agent.FrequencySubDayTypes], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion

			#Region FrequencySubDayInterval
			$ParameterName = 'FrequencySubDayInterval'

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

			$FrequencySubDayIntervalParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$FrequencySubDayIntervalParameterAttribute.ParameterSetName = 'ServerInstance_FrequencySubDay'

			$AttributeCollection.Add($FrequencySubDayIntervalParameterAttribute)

			$FrequencySubDayIntervalParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$FrequencySubDayIntervalParameterAttribute.ParameterSetName = 'SmoServer_FrequencySubDay'

			$AttributeCollection.Add($FrequencySubDayIntervalParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New([System.Management.Automation.ValidateRangeKind]::Positive)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion

			#Region ActiveEndTimeOfDay
			$ParameterName = 'ActiveEndTimeOfDay'

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()

			$ActiveEndTimeOfDayParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$ActiveEndTimeOfDayParameterAttribute.ParameterSetName = 'ServerInstance_FrequencySubDay'

			$AttributeCollection.Add($ActiveEndTimeOfDayParameterAttribute)

			$ActiveEndTimeOfDayParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$ActiveEndTimeOfDayParameterAttribute.ParameterSetName = 'SmoServer_FrequencySubDay'

			$AttributeCollection.Add($ActiveEndTimeOfDayParameterAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [TimeSpan], $AttributeCollection)

			$RuntimeDefinedParameter.Value = [System.TimeSpan]::New(23, 59, 59)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['FrequencyType'] -in @('Daily', 'Monthly', 'MonthlyRelative', 'Onetime', 'Weekly')) {
			#Region ActiveStartTimeOfDay
			$ParameterName = 'ActiveStartTimeOfDay'

			$ActiveStartTimeOfDayParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($ActiveStartTimeOfDayParameterAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [TimeSpan], $AttributeCollection)

			$RuntimeDefinedParameter.Value = [System.TimeSpan]::New(0, 0, 0)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion

			#Region ActiveStartDate
			$ParameterName = 'ActiveStartDate'

			$ActiveStartDateParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($ActiveStartDateParameterAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [DateTime], $AttributeCollection)

			$RuntimeDefinedParameter.Value = Get-Date

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion

			#Region ActiveEndDate
			$ParameterName = 'ActiveEndDate'

			$ActiveEndDateParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($ActiveEndDateParameterAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [DateTime], $AttributeCollection)

			$RuntimeDefinedParameter.Value = '9999-12-31 00:00:00'

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['FrequencyType'] -in @('Monthly', 'MonthlyRelative', 'Weekly')) {
			#Region FrequencyRecurrenceFactor
			$ParameterName = 'FrequencyRecurrenceFactor'

			$FrequencyRecurrenceFactorParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$FrequencyRecurrenceFactorParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($FrequencyRecurrenceFactorParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New([System.Management.Automation.ValidateRangeKind]::Positive)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		if ($PSBoundParameters['FrequencyType'] -in @('MonthlyRelative')) {
			#Region FrequencyRelativeIntervals
			$ParameterName = 'FrequencyRelativeIntervals'

			$FrequencyRelativeIntervalsParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()
			$FrequencyRelativeIntervalsParameterAttribute.Mandatory = $true

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($FrequencyRelativeIntervalsParameterAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [Microsoft.SqlServer.Management.Smo.Agent.FrequencyRelativeIntervals], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion
		}

		$RuntimeDefinedParameterDictionary
	}

	begin {
		try {
			if ($PSBoundParameters.ContainsKey("ActiveEndDate")) {
				$ActiveEndDate = $PSBoundParameters['ActiveEndDate']
			}

			if ($PSBoundParameters.ContainsKey("ActiveEndTimeOfDay")) {
				$ActiveEndTimeOfDay = $PSBoundParameters['ActiveEndTimeOfDay']
			}

			if ($PSBoundParameters.ContainsKey("ActiveStartDate")) {
				$ActiveStartDate = $PSBoundParameters['ActiveStartDate']
			}

			if ($PSBoundParameters.ContainsKey("ActiveStartTimeOfDay")) {
				$ActiveStartTimeOfDay = $PSBoundParameters['ActiveStartTimeOfDay']
			}

			if ($PSBoundParameters.ContainsKey("FrequencyInterval")) {
				$FrequencyInterval = $PSBoundParameters['FrequencyInterval']
			}

			if ($PSBoundParameters.ContainsKey("FrequencyRecurrenceFactor")) {
				$FrequencyRecurrenceFactor = $PSBoundParameters['FrequencyRecurrenceFactor']
			}

			if ($PSBoundParameters.ContainsKey("FrequencyRelativeIntervals")) {
				$FrequencyRelativeIntervals = $PSBoundParameters['FrequencyRelativeIntervals']
			}

			if ($PSBoundParameters.ContainsKey("FrequencySubDayInterval")) {
				$FrequencySubDayInterval = $PSBoundParameters['FrequencySubDayInterval']
			}

			if ($PSBoundParameters.ContainsKey("FrequencySubDayType")) {
				$FrequencySubDayType = $PSBoundParameters['FrequencySubDayType']

				if ($FrequencySubDayType -eq 'Once') {
					if ($PSBoundParameters.ContainsKey("FrequencySubDayInterval")) {
						throw [System.Management.Automation.ErrorRecord]::New(
							[Exception]::New('FrequencySubDayInterval is not valid when FrequencySubDayType is Once.'),
							'1',
							[System.Management.Automation.ErrorCategory]::InvalidOperation,
							$FrequencySubDayInterval
						)
					}

					if ($PSBoundParameters.ContainsKey("ActiveEndTimeOfDay")) {
						throw [System.Management.Automation.ErrorRecord]::New(
							[Exception]::New('ActiveEndTimeOfDay is not valid when FrequencySubDayType is Once.'),
							'1',
							[System.Management.Automation.ErrorCategory]::InvalidOperation,
							$ActiveEndTimeOfDay
						)
					}
				}
			}

			if ($PSBoundParameters.ContainsKey("ActiveStartDate") -and $PSBoundParameters.ContainsKey("ActiveEndDate")) {
				if ($ActiveStartDate -ge $ActiveEndDate) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('ActiveStartDate must be less than ActiveEndDate.'),
						'1',
						[System.Management.Automation.ErrorCategory]::InvalidArgument,
						$ActiveStartDate
					)
				}
			}

			if ($PSBoundParameters.ContainsKey("ActiveStartTimeOfDay") -and $PSBoundParameters.ContainsKey("ActiveEndTimeOfDay")) {
				if ($ActiveStartTimeOfDay -ge $ActiveEndTimeOfDay) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('ActiveStartTimeOfDay must be less than ActiveEndTimeOfDay.'),
						'1',
						[System.Management.Automation.ErrorCategory]::InvalidArgument,
						$ActiveStartTimeOfDay
					)
				}
			}

			if ($PSCmdlet.ParameterSetName -in @('ServerInstance', 'ServerInstance_FrequencySubDay')) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$JobSchedule = [Microsoft.SqlServer.Management.SMO.Agent.JobSchedule]::New($JobServer, $ScheduleName)

			$JobSchedule.IsEnabled = $IsEnabled
			$JobSchedule.FrequencyTypes = $FrequencyType

			#Region Frequency
			if ($PSBoundParameters.ContainsKey("FrequencyRelativeIntervals")) {
				$JobSchedule.FrequencyRelativeIntervals = $FrequencyRelativeIntervals
			}

			if ($PSBoundParameters.ContainsKey("FrequencyInterval")) {
				$JobSchedule.FrequencyInterval = $FrequencyInterval
			}

			if ($PSBoundParameters.ContainsKey("FrequencyRecurrenceFactor")) {
				$JobSchedule.FrequencyRecurrenceFactor = $FrequencyRecurrenceFactor
			}
			#EndRegion

			#Region Daily Frequency
			if ($PSBoundParameters.ContainsKey("FrequencySubDayType")) {
				$JobSchedule.FrequencySubDayTypes = $FrequencySubDayType
			}

			if ($PSBoundParameters.ContainsKey("ActiveStartTimeOfDay")) {
				$JobSchedule.ActiveStartTimeOfDay = $ActiveStartTimeOfDay
			}

			if ($PSBoundParameters.ContainsKey("ActiveEndTimeOfDay")) {
				$JobSchedule.ActiveEndTimeOfDay = $ActiveEndTimeOfDay
			}

			if ($PSBoundParameters.ContainsKey("FrequencySubDayInterval")) {
				$JobSchedule.FrequencySubDayInterval = $FrequencySubDayInterval
			}
			#EndRegion

			#Region Duration
			if ($PSBoundParameters.ContainsKey("ActiveStartDate")) {
				$JobSchedule.ActiveStartDate = $ActiveStartDate
			}

			if ($PSBoundParameters.ContainsKey("ActiveEndDate")) {
				$JobSchedule.ActiveEndDate = $ActiveEndDate
			}
			#EndRegion

			if ($PSCmdlet.ShouldProcess($ScheduleName, "Create SQL Agent schedule")) {
				$JobSchedule.Create()

				$JobSchedule
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Read-SmoSqlAgentErrorLog {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([SqlServerAgent.ErrorLogRecord])]

	param (
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[int]$LogNumber = 0
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance -StatementTimeout 0
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		$DataView = [System.Data.DataView]::New($JobServer.ReadErrorLog($LogNumber))
		$DataView.Sort = 'LogDate DESC'

		$ColumnNames = $DataView.Table.Columns.ColumnName

		foreach ($Row in $DataView) {
			$ErrorLogRecord = [SqlServerAgent.ErrorLogRecord]::New()

			foreach ($ColumnName in $ColumnNames) {
				$ErrorLogRecord.$ColumnName = $Row.$ColumnName
			}

			$ErrorLogRecord
		}
	}

	end {
	}
}

function Read-SmoSqlAgentJobHistory {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $false,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([SqlServerAgent.JobHistory])]

	param (
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.CompletionResult[]]$CompletionResult,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[int]$MessageID,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[int]$Severity,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[System.DateTime]$StartRunDate,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[System.DateTime]$EndRunDate
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance -StatementTimeout 0
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		$JobHistoryFilter = [Microsoft.SqlServer.Management.Smo.Agent.JobHistoryFilter]::New()

		$JobHistoryFilter.JobName = $JobName

		if ($PSBoundParameters.ContainsKey("CompletionResult")) {
			$JobHistoryFilter.OutcomeTypes = $CompletionResult
		}

		if ($PSBoundParameters.ContainsKey("MessageID")) {
			$JobHistoryFilter.SqlMessageID = $MessageID
		}

		if ($PSBoundParameters.ContainsKey("Severity")) {
			$JobHistoryFilter.SqlSeverity = $Severity
		}

		if ($PSBoundParameters.ContainsKey("StartRunDate")) {
			$JobHistoryFilter.StartRunDate = $StartRunDate
		}

		if ($PSBoundParameters.ContainsKey("EndRunDate")) {
			$JobHistoryFilter.EndRunDate = $EndRunDate
		}

		$DataView = [System.Data.DataView]::New($JobServer.EnumJobHistory($JobHistoryFilter))
		$DataView.Sort = 'InstanceID DESC'

		$ColumnNames = $DataView.Table.Columns.ColumnName

		foreach ($Row in $DataView) {
			$JobHistory = [SqlServerAgent.JobHistory]::New()

			switch ($ColumnNames) {
				'RunDuration' {
					$Duration = $Row.$_

					$JobHistory.$_ = [System.TimeSpan]::New(
						$(($Duration - ($Duration % 1000000)) / 1000000),
						$(($Duration - ($Duration % 10000)) % 1000000 / 10000),
						$(($Duration - ($Duration % 100)) % 10000 / 100),
						$($Duration % 100)
					)
				}
				Default {
					$JobHistory.$_ = $Row.$_
				}
			}

			$JobHistory
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentAlert {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$AlertName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($AlertName, "Remove SQL Agent alert")) {
				$AgentAlert = $JobServer.Alerts[$AlertName]

				$AgentAlert.Drop()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentAlertOperator {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$AlertName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string[]]$OperatorName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$Alert = $JobServer.Alerts[$AlertName]

			if ($null -eq $Alert) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent alert not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$Alert
				)
			}

			foreach ($Operator in $OperatorName) {
				if ($PSCmdlet.ShouldProcess($Operator, "Remove SQL Agent alert operator")) {
					$Alert.RemoveNotification($Operator)
				}
			}

			if ($PSCmdlet.ShouldProcess($AlertName, "Alter SQL Agent alert")) {
				$Alert.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentCategory {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateSet('Alert', 'Job', 'Operator')]
		[string]$Class,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$CategoryName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			switch ($Class) {
				'Alert' {
					$Category = $JobServer.AlertCategories[$CategoryName]
				}
				'Job' {
					$Category = $JobServer.JobCategories[$CategoryName]
				}
				'Operator' {
					$Category = $JobServer.OperatorCategories[$CategoryName]
				}
			}

			if ($PSCmdlet.ShouldProcess($CategoryName, "Remove SQL Agent category")) {
				$Category.Drop()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -in @('ServerInstance', 'EmailOperator_ServerInstance')) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($JobName, "Remove SQL Agent job")) {
				$AgentJob = $JobServer.Jobs[$JobName]

				$AgentJob.Drop()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentJobSchedule {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ScheduleName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$AgentJob = $JobServer.Jobs[$JobName]
			$Schedule = $JobServer.sharedSchedules[$ScheduleName]
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($ScheduleName, "Remove SQL Agent job schedule")) {
				$AgentJob.RemoveSharedSchedule($Schedule.ID)

				$AgentJob.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentJobStep {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobStepName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$AgentJob = $JobServer.Jobs[$JobName]
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($JobStepName, "Remove SQL Agent job step")) {
				$JobStep = $JobServer.Jobs[$AgentJob].JobSteps[$JobStepName]

				$JobStep.Drop()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentOperator {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$OperatorName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($OperatorName, "Remove SQL Agent operator")) {
				$Operator = $JobServer.Operators[$OperatorName]

				$Operator.Drop()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentProxyAccount {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ProxyAccountName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($ProxyAccountName, "Remove SQL Agent proxy account")) {
				$ProxyAccount = $JobServer.ProxyAccounts[$ProxyAccountName]

				$ProxyAccount.Drop()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentProxyPrincipal {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ProxyAccountName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string[]]$PrincipalName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$ProxyAccount = $JobServer.ProxyAccounts[$ProxyAccountName]
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			foreach ($Principal in $PrincipalName) {
				if ($PSCmdlet.ShouldProcess($Principal, "Remove SQL Agent proxy principal")) {
					$ProxyAccount.RemoveLogin($Principal)
				}
			}

			if ($PSCmdlet.ShouldProcess($ProxyAccountName, "Alter SQL Agent proxy account")) {
				$ProxyAccount.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentProxySubSystem {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ProxyAccountName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.AgentSubSystem]$SubSystemName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$ProxyAccount = $JobServer.ProxyAccounts[$ProxyAccountName]
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($SubSystemName, "Remove SQL Agent proxy subsystem")) {
				$ProxyAccount.RemoveSubSystem($SubSystemName)

				$ProxyAccount.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentSchedule {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$ScheduleName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($ScheduleName, "Remove SQL Agent schedule")) {
				$JobSchedule = $JobServer.SharedSchedules[$ScheduleName]

				$JobSchedule.Drop()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Set-SmoSqlAgentJobOperator {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([Microsoft.SqlServer.Management.Smo.Agent.Operator])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string[]]$OperatorName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.SMO.Agent.CompletionAction]$EmailLevel = 'OnFailure'
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$AgentJob = $JobServer.Jobs[$JobName]
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$Operator = $JobServer.Operators[$OperatorName]

			if ($PSCmdlet.ShouldProcess($Operator.name, "Set SQL Agent operator")) {
				$AgentJob.OperatorToEmail = $Operator.name
				$AgentJob.EmailLevel = $EmailLevel

				$AgentJob.Alter()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Set-SmoSqlAgentMsxEncryptChannelOption {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([SqlServerAgent.MsxEncryptChannelOption])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateSet(0, 1, 2)]
		[int]$MsxEncryptChannelOption
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$DatabaseObject = $SmoServerObject.Databases['master']
		}
		catch {
			throw $_
		}

		$AgentPathFormatString = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\{0}\SQLServerAgent'

		$Query_AgentServiceName = 'SELECT servicename AS ServiceName
			FROM sys.dm_server_services
			WHERE servicename LIKE N''SQL Server Agent%'';'

		$ScriptBlock_SetMsxEncryptChannelOptions = {
			Param([string]$AgentPath, [int]$Value)
			Set-ItemProperty -Path $AgentPath -Name MsxEncryptChannelOptions -Value $Value
		}

		$ScriptBlock_RestartService = {
			Param([string]$DisplayName)
			Restart-Service -DisplayName $DisplayName
		}
	}

	process {
		try {
			$CommandParameters = @{
				'ScriptBlock' = $ScriptBlock_SetMsxEncryptChannelOptions
				'ArgumentList' = @(
					[string]::Format($AgentPathFormatString, $SmoServerObject.ServiceInstanceId)
					$MsxEncryptChannelOption
				)
			}

			if ($PSCmdlet.ShouldProcess($SmoServerObject.Name, "Set MsxSecureChannelOption")) {
				Invoke-Command @CommandParameters
			}

			#Region Restart Agent Service
			$ResultSet = $DatabaseObject.ExecuteWithResults($Query_AgentServiceName)

			$CommandParameters = @{
				'ScriptBlock' = $ScriptBlock_RestartService
				'ArgumentList' = $ResultSet.Tables.Rows.ServiceName
			}

			if ([System.Net.Dns]::GetHostName() -ne $SmoServerObject.NetName) {
				$CommandParameters.Add('ComputerName', $SmoServerObject.NetName)
			}

			if ($PSCmdlet.ShouldProcess('SQL Server Agent', "Restart job server")) {
				for ($i = 0; $i -lt 20; $i++) {
					if (($JobServer.Jobs.where({$_.JobType -eq 'Local'}).CurrentRunStatus -ne 'Idle').Count -eq 0) {
						Invoke-Command @CommandParameters

						break
					} else {
						if ($i -eq 19) {
							throw [System.Management.Automation.ErrorRecord]::New(
								[Exception]::New('Unable to restart SQL Server Agent due to running jobs.'),
								'1',
								[System.Management.Automation.ErrorCategory]::OperationTimeout,
								$SmoServer.JobServer.Name
							)
						}

						Start-Sleep -Seconds 15
					}
				}
			}
			#EndRegion

			Get-SmoSqlAgentMsxEncryptChannelOption -SmoServer $SmoServerObject
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Set-SmoSqlAgentSubSystem {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([SqlServerAgent.MsxEncryptChannelOption])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[Microsoft.SqlServer.Management.Smo.Agent.AgentSubSystem]$AgentSubSystem,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[int]$MaxWorkerThreads
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$DatabaseObject = $SmoServerObject.Databases['master']
		}
		catch {
			throw $_
		}

		$Query_AgentServiceName = 'SELECT servicename AS ServiceName
			FROM sys.dm_server_services
			WHERE servicename LIKE N''SQL Server Agent%'';'

		$Query_SetMaxWorkerThreads = 'UPDATE [msdb].[dbo].[syssubsystems]
			SET max_worker_threads = {0}
			WHERE subsystem = ''{1}'';'

		$ScriptBlock_RestartService = {
			Param([string]$DisplayName)
			Restart-Service -DisplayName $DisplayName
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($AgentSubSystem, "Set max worker threads")) {
				$DatabaseObject.ExecuteNonQuery([string]::Format($Query_SetMaxWorkerThreads, $MaxWorkerThreads, $AgentSubSystem))
			}

			#Region Restart Agent Service
			$ResultSet = $DatabaseObject.ExecuteWithResults($Query_AgentServiceName)

			$CommandParameters = @{
				'ScriptBlock' = $ScriptBlock_RestartService
				'ArgumentList' = $ResultSet.Tables.Rows.ServiceName
			}

			if ([System.Net.Dns]::GetHostName() -ne $SmoServerObject.NetName) {
				$CommandParameters.Add('ComputerName', $SmoServerObject.NetName)
			}

			if ($PSCmdlet.ShouldProcess('SQL Server Agent', "Restart job server")) {
				for ($i = 0; $i -lt 20; $i++) {
					if (($JobServer.Jobs.where({$_.JobType -eq 'Local'}).CurrentRunStatus -ne 'Idle').Count -eq 0) {
						Invoke-Command @CommandParameters

						break
					} else {
						if ($i -eq 19) {
							throw [System.Management.Automation.ErrorRecord]::New(
								[Exception]::New('Unable to restart SQL Server Agent due to running jobs.'),
								'1',
								[System.Management.Automation.ErrorCategory]::OperationTimeout,
								$SmoServerObject.JobServer.Name
							)
						}

						Start-Sleep -Seconds 15
					}
				}
			}
			#EndRegion

			Get-SmoSqlAgentSubSystem -SmoServerObject $SmoServerObject -SubSystem $AgentSubSystem
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Start-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Low',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobStepName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$AgentJob = $JobServer.Jobs[$JobName]

			if ($null -eq $AgentJob) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent job not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$JobName
				)
			}

			if ($PSBoundParameters.ContainsKey("JobStepName")) {
				if ($AgentJob.JobSteps.Name -NotContains $JobStepName) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('Agent job step not found.'),
						'1',
						[System.Management.Automation.ErrorCategory]::ObjectNotFound,
						$JobStepName
					)
				}
			}

			if ($PSCmdlet.ShouldProcess($JobName, "Start job")) {
				if ($PSBoundParameters.ContainsKey("JobStepName")) {
					$AgentJob.Start($JobStepName)
				} else {
					$AgentJob.Start()
				}
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}

function Stop-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SQLServerAgentTools-help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'High',
		DefaultParameterSetName = 'ServerInstance'
	)]

	[OutputType([System.Void])]

	PARAM(
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'ServerInstance'
		)]
		[ValidateLength(1, 128)]
		[Alias('SqlServer')]
		[string]$ServerInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SmoServer'
		)]
		[Microsoft.SqlServer.Management.Smo.Server]$SmoServerObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false
		)]
		[ValidateLength(1, 128)]
		[string]$JobName
	)

	begin {
		try {
			if ($PSCmdlet.ParameterSetName -eq 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			throw $_
		}
	}

	process {
		try {
			$AgentJob = $JobServer.Jobs[$JobName]

			if ($null -eq $AgentJob) {
				throw [System.Management.Automation.ErrorRecord]::New(
					[Exception]::New('Agent job not found.'),
					'1',
					[System.Management.Automation.ErrorCategory]::ObjectNotFound,
					$JobName
				)
			}

			if ($PSCmdlet.ShouldProcess($JobName, "Stop job")) {
				$AgentJob.Stop()
			}
		}
		catch {
			throw $_
		}
	}

	end {
	}
}
