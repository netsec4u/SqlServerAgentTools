Set-StrictMode -Version Latest

#Region Enumerations
#EndRegion

#Region Classes
class TransformPath : System.Management.Automation.ArgumentTransformationAttribute {
	[object]Transform([System.Management.Automation.EngineIntrinsics]$EngineIntrinsics, [object]$InputData) {
		if ([System.IO.Path]::IsPathRooted($InputData)) {
			return $InputData
		} else {
			return [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PWD.Path, $InputData))
		}

		throw [System.InvalidOperationException]::New('Unexpected error.')
	}
}

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
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			$Notifications = $Alert.EnumNotifications([Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail)

			if ($Notifications.Rows.Count -gt 0) {
				$AlertOperators = $Notifications.OperatorName
			} else {
				$AlertOperators = @()
			}

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
					if ($PSCmdlet.ShouldProcess($Operator, 'Add SQL Agent alert operator')) {
						$Alert.AddNotification($Operator, [Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]::NotifyEmail)
					}
				}
			}

			if ($PSCmdlet.ShouldProcess($AlertName, 'Alter SQL Agent alert')) {
				$Alert.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Add-SmoSqlAgentJobSchedule {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSCmdlet.ShouldProcess($ScheduleName, 'Add SQL Agent job schedule')) {
				$AgentJob.AddSharedSchedule($Schedule.ID)

				$AgentJob.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Add-SmoSqlAgentJobStep {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		[System.IO.FileInfo][TransformPath()]$OutputFileName,

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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			if ($PSBoundParameters.ContainsKey('CommandExecutionSuccessCode')) {
				$CommandExecutionSuccessCode = $PSBoundParameters['CommandExecutionSuccessCode']
			}

			if ($PSBoundParameters.ContainsKey('DatabaseName')) {
				$DatabaseName = $PSBoundParameters['DatabaseName']
			}

			if ($PSBoundParameters.ContainsKey('DatabaseUserName')) {
				$DatabaseUserName = $PSBoundParameters['DatabaseUserName']
			}

			if ($PSBoundParameters.ContainsKey('OnFailStep')) {
				$OnFailStep = $PSBoundParameters['OnFailStep']
			}

			if ($PSBoundParameters.ContainsKey('OnSuccessStep')) {
				$OnSuccessStep = $PSBoundParameters['OnSuccessStep']
			}

			if ($PSBoundParameters.ContainsKey('ProxyName')) {
				$ProxyName = $PSBoundParameters['ProxyName']
			}

			if ($PSBoundParameters.ContainsKey('Server')) {
				$Server = $PSBoundParameters['Server']
			}
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSBoundParameters.ContainsKey('ProxyName')) {
				$JobStep.ProxyName = $ProxyName
			}

			if ($PSBoundParameters.ContainsKey('Server')) {
				$JobStep.Server = $Server
			}

			if ($PSBoundParameters.ContainsKey('DatabaseName')) {
				$JobStep.DatabaseName = $DatabaseName
			}

			if ($PSBoundParameters.ContainsKey('CommandExecutionSuccessCode')) {
				$JobStep.CommandExecutionSuccessCode = $CommandExecutionSuccessCode
			}

			$JobStep.Command = $Command
			#EndRegion

			#Region Advanced
			$JobStep.OnSuccessAction = $OnSuccessAction

			if ($PSBoundParameters.ContainsKey('OnSuccessStep')) {
				$JobStep.OnSuccessStep = $OnSuccessStep
			}

			$JobStep.RetryAttempts = $RetryAttempts
			$JobStep.RetryInterval = $RetryInterval

			$JobStep.OnFailAction = $OnFailureAction

			if ($PSBoundParameters.ContainsKey('OnFailStep')) {
				$JobStep.OnFailStep = $OnFailStep
			}

			if ($PSBoundParameters.ContainsKey('OutputFileName')) {
				$JobStep.OutputFileName = $OutputFileName
			}

			if ($PSBoundParameters.ContainsKey('JobStepFlags')) {
				$JobStep.JobStepFlags = $JobStepFlags
			}

			if ($PSBoundParameters.ContainsKey('DatabaseUserName')) {
				$JobStep.DatabaseUserName = $DatabaseUserName
			}
			#EndRegion

			if ($PSCmdlet.ShouldProcess($JobName, 'Add SQL Agent job step')) {
				$JobStep.Create()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Add-SmoSqlAgentProxyPrincipal {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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
				if ($PSCmdlet.ShouldProcess($Principal, 'Add SQL Agent proxy principal')) {
					$ProxyAccount.AddLogin($Principal)
				}
			}

			if ($PSCmdlet.ShouldProcess($ProxyAccountName, 'Alter SQL Agent proxy account')) {
				$ProxyAccount.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Add-SmoSqlAgentProxySubSystem {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSCmdlet.ShouldProcess($SubSystemName, 'Add SQL Agent proxy subsystem')) {
				$ProxyAccount.AddSubSystem($SubSystemName)

				$ProxyAccount.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentAlert {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey('AlertName')) {
				$Alerts = $JobServer.Alerts[$AlertName]
			} else {
				$Alerts = $JobServer.Alerts
			}

			$Alerts
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentCategory {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			switch ($Class) {
				'Alert' {
					if ($PSBoundParameters.ContainsKey('CategoryName')) {
						$Category = $JobServer.AlertCategories[$CategoryName]
					} else {
						$Category = $JobServer.AlertCategories
					}
				}
				'Job' {
					if ($PSBoundParameters.ContainsKey('CategoryName')) {
						$Category = $JobServer.JobCategories[$CategoryName]
					} else {
						$Category = $JobServer.JobCategories
					}
				}
				'Operator' {
					if ($PSBoundParameters.ContainsKey('CategoryName')) {
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
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey('JobName')) {
				$Jobs = $JobServer.Jobs[$JobName]
			} else {
				$Jobs = $JobServer.Jobs
			}

			$Jobs
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentJobServer {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentMsxEncryptChannelOption {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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
				$CommandParameters.Add('ComputerName', $SmoServerObject.Information.FullyQualifiedNetName)
			}

			$Results = Invoke-Command @CommandParameters

			[SqlServerAgent.MsxEncryptChannelOption]::New($JobServer.Name, $Results.MsxEncryptChannelOptions)
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentOperator {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey('OperatorName')) {
				$Operators = $JobServer.Operators[$OperatorName]
			} else {
				$Operators = $JobServer.Operators
			}

			$Operators
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentProxyAccount {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey('ProxyAccountName')) {
				$ProxyAccounts = $JobServer.ProxyAccounts[$ProxyAccountName]
			} else {
				$ProxyAccounts = $JobServer.ProxyAccounts
			}

			$ProxyAccounts
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentSchedule {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSBoundParameters.ContainsKey('ScheduleName')) {
				$SharedSchedules = $JobServer.SharedSchedules[$ScheduleName]
			} else {
				$SharedSchedules = $JobServer.SharedSchedules
			}

			$SharedSchedules
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Get-SmoSqlAgentSubSystem {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$DatabaseObject = $SmoServerObject.Databases['master']
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSBoundParameters.ContainsKey('AgentSubSystem')) {
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
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function New-SmoSqlAgentAlert {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
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
					[System.Management.Automation.ErrorCategory]::NotImplemented,
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

				$MessageIDParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
				$AttributeCollection.Add($MessageIDParameterAttribute)

				$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New(1, 65535)
				$AttributeCollection.Add($ValidateRangeAttribute)

				$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

				$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
				#EndRegion

				#Region Severity
				$ParameterName = 'Severity'

				$SeverityParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

				$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
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
		$ServerInstanceParameterSets = @('SqlServerEventMessageID_ServerInstance', 'SqlServerEventSeverity_ServerInstance')

		try {
			switch ($AlertType) {
				'SqlServerEvent' {
					if (-not $PSBoundParameters.ContainsKey('Severity') -and -not $PSBoundParameters.ContainsKey('MessageID')) {
						throw [System.Management.Automation.ErrorRecord]::New(
							[System.ArgumentException]::New('Required parameter missing.  SqlServerEvent requires Severity or MessageID.'),
							'1',
							[System.Management.Automation.ErrorCategory]::InvalidOperation,
							$AlertType
						)
					}

					if ($PSBoundParameters.ContainsKey('Severity') -and $PSBoundParameters.ContainsKey('MessageID')) {
						throw [System.Management.Automation.ErrorRecord]::New(
							[System.ArgumentException]::New('The parameters Severity and MessageID are mutually exclusive and cannot be used together.'),
							'1',
							[System.Management.Automation.ErrorCategory]::InvalidOperation,
							$AlertType
						)
					}

					if ($PSBoundParameters.ContainsKey('DatabaseName')) {
						$DatabaseName = $PSBoundParameters['DatabaseName']
					}

					if ($PSBoundParameters.ContainsKey('MessageID')) {
						$MessageID = $PSBoundParameters['MessageID']
					}

					if ($PSBoundParameters.ContainsKey('Severity')) {
						$Severity = $PSBoundParameters['Severity']
					}

					if ($PSBoundParameters.ContainsKey('EventDescriptionKeyword')) {
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

			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			$AgentAlert = [Microsoft.SqlServer.Management.Smo.Agent.Alert]::New($JobServer, $AlertName)

			$AgentAlert.IsEnabled = $IsEnabled

			switch ($AlertType) {
				'SqlServerEvent' {
					if ($PSBoundParameters.ContainsKey('DatabaseName')) {
						$AgentAlert.DatabaseName = $DatabaseName
					}

					if ($PSBoundParameters.ContainsKey('MessageID')) {
						$AgentAlert.MessageID = $MessageID
					}

					if ($PSBoundParameters.ContainsKey('Severity')) {
						$AgentAlert.Severity = $Severity
					}

					if ($PSBoundParameters.ContainsKey('EventDescriptionKeyword')) {
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

			if ($PSBoundParameters.ContainsKey('JobName')) {
				$Job = Get-SmoSqlAgentJob -SmoServerObject $SmoServerObject -JobName $JobName

				if ($Job -isnot [Microsoft.SqlServer.Management.Smo.Agent.Job]) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('Job not found.'),
						'1',
						[System.Management.Automation.ErrorCategory]::ObjectNotFound,
						$JobName
					)
				}

				$AgentAlert.JobID = $Job.JobID
			}

			$AgentAlert.IncludeEventDescription = $IncludeEventDescription

			if ($PSBoundParameters.ContainsKey('NotificationMessage')) {
				$AgentAlert.NotificationMessage = $NotificationMessage
			}

			$AgentAlert.DelayBetweenResponses = $DelayBetweenResponses

			if ($PSCmdlet.ShouldProcess($AlertName, 'Create SQL Agent alert')) {
				$AgentAlert.Create()

				$AgentAlert
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function New-SmoSqlAgentCategory {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in 'ServerInstance') {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSCmdlet.ShouldProcess($CategoryName, 'Create SQL Agent category')) {
				$Category.Create()

				$Category
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function New-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance', 'EmailOperator_ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			$AgentJob = [Microsoft.SqlServer.Management.SMO.Agent.Job]::New($JobServer, $JobName)

			$AgentJob.OwnerLoginName = $OwnerLoginName

			if ($PSBoundParameters.ContainsKey('Description')) {
				$AgentJob.Category = $Category
			}

			if ($PSBoundParameters.ContainsKey('Description')) {
				$AgentJob.Description = $Description
			}

			$AgentJob.IsEnabled = $IsEnabled

			if ($PSCmdlet.ParameterSetName -in @('EmailOperator_ServerInstance', 'EmailOperator_SmoServer')) {
				$AgentJob.OperatorToEmail = $OperatorToEmail
				$AgentJob.EmailLevel = $EmailLevel
			}

			$AgentJob.EventLogLevel = $EventLogLevel
			$AgentJob.DeleteLevel = $DeleteLevel

			if ($PSCmdlet.ShouldProcess($JobName, 'Create SQL Agent job')) {
				$AgentJob.Create()

				$AgentJob.ApplyToTargetServer('(local)')

				$AgentJob.Alter()

				$AgentJob
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function New-SmoSqlAgentOperator {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			$Operator = [Microsoft.SqlServer.Management.Smo.Agent.Operator]::New($JobServer, $OperatorName)

			$Operator.Enabled = $IsEnabled
			$Operator.EmailAddress = $OperatorEmailAddress

			if ($PSCmdlet.ShouldProcess($OperatorName, 'Create SQL Agent operator')) {
				$Operator.Create()

				$Operator
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function New-SmoSqlAgentProxyAccount {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			$ProxyAccount = [Microsoft.SqlServer.Management.Smo.Agent.ProxyAccount]::New($JobServer, $ProxyAccountName, $CredentialName, $true, $Description)

			if ($PSCmdlet.ShouldProcess($ProxyAccountName, 'Create SQL Agent proxy account')) {
				$ProxyAccount.Create()

				$ProxyAccount.AddSubSystem($AgentSubSystem)

				$ProxyAccount
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function New-SmoSqlAgentSchedule {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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

			$FrequencySubDayTypeParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($FrequencySubDayTypeParameterAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [Microsoft.SqlServer.Management.SMO.Agent.FrequencySubDayTypes], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion

			#Region FrequencySubDayInterval
			$ParameterName = 'FrequencySubDayInterval'

			$FrequencySubDayIntervalParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
			$AttributeCollection.Add($FrequencySubDayIntervalParameterAttribute)

			$ValidateRangeAttribute = [System.Management.Automation.ValidateRangeAttribute]::New([System.Management.Automation.ValidateRangeKind]::Positive)
			$AttributeCollection.Add($ValidateRangeAttribute)

			$RuntimeDefinedParameter = [System.Management.Automation.RuntimeDefinedParameter]::New($ParameterName, [int], $AttributeCollection)

			$RuntimeDefinedParameterDictionary.Add($ParameterName, $RuntimeDefinedParameter)
			#EndRegion

			#Region ActiveEndTimeOfDay
			$ParameterName = 'ActiveEndTimeOfDay'

			$ActiveEndTimeOfDayParameterAttribute = [System.Management.Automation.ParameterAttribute]::New()

			$AttributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::New()
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
		$ServerInstanceParameterSets = @('ServerInstance', 'ServerInstance_FrequencySubDay')

		try {
			if ($PSBoundParameters['FrequencyType'] -in @('Daily', 'Monthly', 'MonthlyRelative', 'Weekly')) {
				if (-not $PSBoundParameters.ContainsKey('FrequencySubDayType') -and ($PSBoundParameters.ContainsKey('FrequencySubDayInterval') -or $PSBoundParameters.ContainsKey('ActiveEndTimeOfDay'))) {
						throw [System.Management.Automation.ErrorRecord]::New(
							[System.ArgumentException]::New('FrequencySubDayInterval or ActiveEndTimeOfDay not valid without FrequencySubDayType.'),
							'1',
							[System.Management.Automation.ErrorCategory]::InvalidOperation,
							$PSBoundParameters['FrequencyType']
						)
				}
			}

			if ($PSBoundParameters.ContainsKey('ActiveEndDate')) {
				$ActiveEndDate = $PSBoundParameters['ActiveEndDate']
			}

			if ($PSBoundParameters.ContainsKey('ActiveEndTimeOfDay')) {
				$ActiveEndTimeOfDay = $PSBoundParameters['ActiveEndTimeOfDay']
			}

			if ($PSBoundParameters.ContainsKey('ActiveStartDate')) {
				$ActiveStartDate = $PSBoundParameters['ActiveStartDate']
			}

			if ($PSBoundParameters.ContainsKey('ActiveStartTimeOfDay')) {
				$ActiveStartTimeOfDay = $PSBoundParameters['ActiveStartTimeOfDay']
			}

			if ($PSBoundParameters.ContainsKey('FrequencyInterval')) {
				$FrequencyInterval = $PSBoundParameters['FrequencyInterval']
			}

			if ($PSBoundParameters.ContainsKey('FrequencyRecurrenceFactor')) {
				$FrequencyRecurrenceFactor = $PSBoundParameters['FrequencyRecurrenceFactor']
			}

			if ($PSBoundParameters.ContainsKey('FrequencyRelativeIntervals')) {
				$FrequencyRelativeIntervals = $PSBoundParameters['FrequencyRelativeIntervals']
			}

			if ($PSBoundParameters.ContainsKey('FrequencySubDayInterval')) {
				$FrequencySubDayInterval = $PSBoundParameters['FrequencySubDayInterval']
			}

			if ($PSBoundParameters.ContainsKey('FrequencySubDayType')) {
				$FrequencySubDayType = $PSBoundParameters['FrequencySubDayType']

				if ($FrequencySubDayType -eq 'Once') {
					if ($PSBoundParameters.ContainsKey('FrequencySubDayInterval')) {
						throw [System.Management.Automation.ErrorRecord]::New(
							[Exception]::New('FrequencySubDayInterval is not valid when FrequencySubDayType is Once.'),
							'1',
							[System.Management.Automation.ErrorCategory]::InvalidOperation,
							$FrequencySubDayInterval
						)
					}

					if ($PSBoundParameters.ContainsKey('ActiveEndTimeOfDay')) {
						throw [System.Management.Automation.ErrorRecord]::New(
							[Exception]::New('ActiveEndTimeOfDay is not valid when FrequencySubDayType is Once.'),
							'1',
							[System.Management.Automation.ErrorCategory]::InvalidOperation,
							$ActiveEndTimeOfDay
						)
					}
				}
			}

			if ($PSBoundParameters.ContainsKey('ActiveStartDate') -and $PSBoundParameters.ContainsKey('ActiveEndDate')) {
				if ($ActiveStartDate -ge $ActiveEndDate) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('ActiveStartDate must be less than ActiveEndDate.'),
						'1',
						[System.Management.Automation.ErrorCategory]::InvalidArgument,
						$ActiveStartDate
					)
				}
			}

			if ($PSBoundParameters.ContainsKey('ActiveStartTimeOfDay') -and $PSBoundParameters.ContainsKey('ActiveEndTimeOfDay')) {
				if ($ActiveStartTimeOfDay -ge $ActiveEndTimeOfDay) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('ActiveStartTimeOfDay must be less than ActiveEndTimeOfDay.'),
						'1',
						[System.Management.Automation.ErrorCategory]::InvalidArgument,
						$ActiveStartTimeOfDay
					)
				}
			}

			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			$JobSchedule = [Microsoft.SqlServer.Management.SMO.Agent.JobSchedule]::New($JobServer, $ScheduleName)

			$JobSchedule.IsEnabled = $IsEnabled
			$JobSchedule.FrequencyTypes = $FrequencyType

			#Region Frequency
			if ($PSBoundParameters.ContainsKey('FrequencyRelativeIntervals')) {
				$JobSchedule.FrequencyRelativeIntervals = $FrequencyRelativeIntervals
			}

			if ($PSBoundParameters.ContainsKey('FrequencyInterval')) {
				$JobSchedule.FrequencyInterval = $FrequencyInterval
			}

			if ($PSBoundParameters.ContainsKey('FrequencyRecurrenceFactor')) {
				$JobSchedule.FrequencyRecurrenceFactor = $FrequencyRecurrenceFactor
			}
			#EndRegion

			#Region Daily Frequency
			if ($PSBoundParameters.ContainsKey('FrequencySubDayType')) {
				$JobSchedule.FrequencySubDayTypes = $FrequencySubDayType
			}

			if ($PSBoundParameters.ContainsKey('ActiveStartTimeOfDay')) {
				$JobSchedule.ActiveStartTimeOfDay = $ActiveStartTimeOfDay
			}

			if ($PSBoundParameters.ContainsKey('ActiveEndTimeOfDay')) {
				$JobSchedule.ActiveEndTimeOfDay = $ActiveEndTimeOfDay
			}

			if ($PSBoundParameters.ContainsKey('FrequencySubDayInterval')) {
				$JobSchedule.FrequencySubDayInterval = $FrequencySubDayInterval
			}
			#EndRegion

			#Region Duration
			if ($PSBoundParameters.ContainsKey('ActiveStartDate')) {
				$JobSchedule.ActiveStartDate = $ActiveStartDate
			}

			if ($PSBoundParameters.ContainsKey('ActiveEndDate')) {
				$JobSchedule.ActiveEndDate = $ActiveEndDate
			}
			#EndRegion

			if ($PSCmdlet.ShouldProcess($ScheduleName, 'Create SQL Agent schedule')) {
				$JobSchedule.Create()

				$JobSchedule
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Read-SmoSqlAgentErrorLog {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance -StatementTimeout 0
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
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
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Read-SmoSqlAgentJobHistory {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance -StatementTimeout 0
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			$JobHistoryFilter = [Microsoft.SqlServer.Management.Smo.Agent.JobHistoryFilter]::New()

			$JobHistoryFilter.JobName = $JobName

			if ($PSBoundParameters.ContainsKey('CompletionResult')) {
				$JobHistoryFilter.OutcomeTypes = $CompletionResult
			}

			if ($PSBoundParameters.ContainsKey('MessageID')) {
				$JobHistoryFilter.SqlMessageID = $MessageID
			}

			if ($PSBoundParameters.ContainsKey('Severity')) {
				$JobHistoryFilter.SqlSeverity = $Severity
			}

			if ($PSBoundParameters.ContainsKey('StartRunDate')) {
				$JobHistoryFilter.StartRunDate = $StartRunDate
			}

			if ($PSBoundParameters.ContainsKey('EndRunDate')) {
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
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentAlert {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		[string]$AlertName
	)

	begin {
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($AlertName, 'Remove SQL Agent alert')) {
				$AgentAlert = $JobServer.Alerts[$AlertName]

				$AgentAlert.Drop()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentAlertOperator {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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
				if ($PSCmdlet.ShouldProcess($Operator, 'Remove SQL Agent alert operator')) {
					$Alert.RemoveNotification($Operator)
				}
			}

			if ($PSCmdlet.ShouldProcess($AlertName, 'Alter SQL Agent alert')) {
				$Alert.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentCategory {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSCmdlet.ShouldProcess($CategoryName, 'Remove SQL Agent category')) {
				$Category.Drop()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance', 'EmailOperator_ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($JobName, 'Remove SQL Agent job')) {
				$AgentJob = $JobServer.Jobs[$JobName]

				$AgentJob.Drop()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentJobSchedule {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$AgentJob = $JobServer.Jobs[$JobName]
			$Schedule = $JobServer.sharedSchedules[$ScheduleName]
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($ScheduleName, 'Remove SQL Agent job schedule')) {
				$AgentJob.RemoveSharedSchedule($Schedule.ID)

				$AgentJob.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentJobStep {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$AgentJob = $JobServer.Jobs[$JobName]
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($JobStepName, 'Remove SQL Agent job step')) {
				$JobStep = $JobServer.Jobs[$AgentJob].JobSteps[$JobStepName]

				$JobStep.Drop()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentOperator {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		[string]$OperatorName
	)

	begin {
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($OperatorName, 'Remove SQL Agent operator')) {
				$Operator = $JobServer.Operators[$OperatorName]

				$Operator.Drop()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentProxyAccount {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		[string]$ProxyAccountName
	)

	begin {
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($ProxyAccountName, 'Remove SQL Agent proxy account')) {
				$ProxyAccount = $JobServer.ProxyAccounts[$ProxyAccountName]

				$ProxyAccount.Drop()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentProxyPrincipal {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$ProxyAccount = $JobServer.ProxyAccounts[$ProxyAccountName]
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			foreach ($Principal in $PrincipalName) {
				if ($PSCmdlet.ShouldProcess($Principal, 'Remove SQL Agent proxy principal')) {
					$ProxyAccount.RemoveLogin($Principal)
				}
			}

			if ($PSCmdlet.ShouldProcess($ProxyAccountName, 'Alter SQL Agent proxy account')) {
				$ProxyAccount.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentProxySubSystem {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$ProxyAccount = $JobServer.ProxyAccounts[$ProxyAccountName]
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($SubSystemName, 'Remove SQL Agent proxy subsystem')) {
				$ProxyAccount.RemoveSubSystem($SubSystemName)

				$ProxyAccount.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Remove-SmoSqlAgentSchedule {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		[string]$ScheduleName
	)

	begin {
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			if ($PSCmdlet.ShouldProcess($ScheduleName, 'Remove SQL Agent schedule')) {
				$JobSchedule = $JobServer.SharedSchedules[$ScheduleName]

				$JobSchedule.Drop()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Set-SmoSqlAgentAlert {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
	#>

	[System.Diagnostics.DebuggerStepThrough()]

	[CmdletBinding(
		PositionalBinding = $false,
		SupportsShouldProcess = $true,
		ConfirmImpact = 'Medium',
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
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'WmiEvent_ServerInstance'
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
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_SmoServer'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'WmiEvent_SmoServer'
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
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventMessageID_ServerInstance'
		)]
		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventSeverity_ServerInstance'
		)]
		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventMessageID_SmoServer'
		)]
		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventSeverity_SmoServer'
		)]
		$DatabaseName,

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
			ParameterSetName = 'SqlServerEventMessageID_SmoServer'
		)]
		$MessageID,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventSeverity_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventSeverity_SmoServer'
		)]
		$Severity,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventMessageID_ServerInstance'
		)]
		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventSeverity_ServerInstance'
		)]
		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventMessageID_SmoServer'
		)]
		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerEventSeverity_SmoServer'
		)]
		$EventDescriptionKeyword,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_SmoServer'
		)]
		$PerformanceObject,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_SmoServer'
		)]
		$PerformanceCounter,

		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_ServerInstance'
		)]
		[Parameter(
			Mandatory = $false,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_SmoServer'
		)]
		$PerformanceCounterInstance,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_SmoServer'
		)]
		$ComparisonOperator,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'SqlServerPerformanceCondition_SmoServer'
		)]
		$PerformanceValue,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'WmiEvent_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'WmiEvent_SmoServer'
		)]
		$WmiEventNamespace,

		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'WmiEvent_ServerInstance'
		)]
		[Parameter(
			Mandatory = $true,
			ValueFromPipeline = $false,
			ValueFromPipelineByPropertyName = $false,
			ParameterSetName = 'WmiEvent_SmoServer'
		)]
		$WmiEventQuery,

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
		[Microsoft.SqlServer.Management.Smo.Agent.NotifyMethods]$IncludeEventDescription,

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
		[int]$DelayBetweenResponses
	)

	begin {
		try {
			$ServerInstanceParameterSets = @('SqlServerEventMessageID_ServerInstance', 'SqlServerEventSeverity_ServerInstance', 'SqlServerPerformanceCondition_ServerInstance', 'WmiEvent_ServerInstance')

			if ($PSBoundParameters.ContainsKey('DatabaseName')) {
				$DatabaseName = $PSBoundParameters['DatabaseName']
			}

			if ($PSBoundParameters.ContainsKey('MessageID')) {
				$MessageID = $PSBoundParameters['MessageID']
			}

			if ($PSBoundParameters.ContainsKey('Severity')) {
				$Severity = $PSBoundParameters['Severity']
			}

			if ($PSBoundParameters.ContainsKey('EventDescriptionKeyword')) {
				$EventDescriptionKeyword = $PSBoundParameters['EventDescriptionKeyword']
			}

			if ($PSBoundParameters.ContainsKey('PerformanceObject')) {
				$PerformanceObject = $PSBoundParameters['PerformanceObject']
			}

			if ($PSBoundParameters.ContainsKey('PerformanceCounter')) {
				$PerformanceCounter = $PSBoundParameters['PerformanceCounter']
			}

			if ($PSBoundParameters.ContainsKey('PerformanceCounterInstance')) {
				$PerformanceCounterInstance = $PSBoundParameters['PerformanceCounterInstance']
			}

			if ($PSBoundParameters.ContainsKey('ComparisonOperator')) {
				$ComparisonOperator = $PSBoundParameters['ComparisonOperator']
			}

			if ($PSBoundParameters.ContainsKey('PerformanceValue')) {
				$PerformanceValue = $PSBoundParameters['PerformanceValue']
			}

			if ($PSBoundParameters.ContainsKey('WmiEventNamespace')) {
				$WmiEventNamespace = $PSBoundParameters['WmiEventNamespace']
			}

			if ($PSBoundParameters.ContainsKey('WmiEventQuery')) {
				$WmiEventQuery = $PSBoundParameters['WmiEventQuery']
			}

			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			$AgentAlert = Get-SmoSqlAgentAlert -SmoServerObject $SmoServerObject -AlertName $AlertName

			if ($PSBoundParameters.ContainsKey('IsEnabled')) {
				$AgentAlert.IsEnabled = $IsEnabled
			}

			#Region SqlServerEvent
			if ($PSBoundParameters.ContainsKey('DatabaseName')) {
				$AgentAlert.DatabaseName = $DatabaseName
			}

			if ($PSBoundParameters.ContainsKey('MessageID')) {
				$AgentAlert.MessageID = $MessageID
			}

			if ($PSBoundParameters.ContainsKey('Severity')) {
				$AgentAlert.Severity = $Severity
			}

			if ($PSBoundParameters.ContainsKey('EventDescriptionKeyword')) {
				$AgentAlert.EventDescriptionKeyword = $EventDescriptionKeyword
			}
			#EndRegion

			#Region SqlServerPerformanceCondition
			if ($PSCmdlet.ParameterSetName -in @('SqlServerPerformanceCondition_ServerInstance', 'SqlServerPerformanceCondition_SmoServer')) {
				$PerformanceCondition = [string]::Format('{0}|{1}|{2}|{3}|{4}', $PerformanceObject, $PerformanceCounter, $PerformanceCounterInstance, $ComparisonOperator, $PerformanceValue)

				$AgentAlert.PerformanceCondition = $PerformanceCondition
			}
			#EndRegion

			#Region WmiEvent
			if ($PSBoundParameters.ContainsKey('WmiEventNamespace')) {
				$AgentAlert.WmiEventNamespace = $WmiEventNamespace
			}

			if ($PSBoundParameters.ContainsKey('WmiEventQuery')) {
				$AgentAlert.WmiEventQuery = $WmiEventQuery
			}
			#EndRegion

			if ($PSBoundParameters.ContainsKey('JobName')) {
				$Job = Get-SmoSqlAgentJob -SmoServerObject $SmoServerObject -JobName $JobName

				if ($Job -isnot [Microsoft.SqlServer.Management.Smo.Agent.Job]) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('Job not found.'),
						'1',
						[System.Management.Automation.ErrorCategory]::ObjectNotFound,
						$JobName
					)
				}

				$AgentAlert.JobID = $Job.JobID
			}

			if ($PSBoundParameters.ContainsKey('IncludeEventDescription')) {
				$AgentAlert.IncludeEventDescription = $IncludeEventDescription
			}

			if ($PSBoundParameters.ContainsKey('NotificationMessage')) {
				$AgentAlert.NotificationMessage = $NotificationMessage
			}

			if ($PSBoundParameters.ContainsKey('DelayBetweenResponses')) {
				$AgentAlert.DelayBetweenResponses = $DelayBetweenResponses
			}

			if ($PSCmdlet.ShouldProcess($AlertName, 'Create SQL Agent alert')) {
				$AgentAlert.Create()

				$AgentAlert
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Set-SmoSqlAgentJobOperator {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$AgentJob = $JobServer.Jobs[$JobName]
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

			throw $_
		}
	}

	process {
		try {
			$Operator = $JobServer.Operators[$OperatorName]

			if ($PSCmdlet.ShouldProcess($Operator.name, 'Set SQL Agent operator')) {
				$AgentJob.OperatorToEmail = $Operator.name
				$AgentJob.EmailLevel = $EmailLevel

				$AgentJob.Alter()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Set-SmoSqlAgentMsxEncryptChannelOption {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$DatabaseObject = $SmoServerObject.Databases['master']
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSCmdlet.ShouldProcess($SmoServerObject.Name, 'Set MsxSecureChannelOption')) {
				Invoke-Command @CommandParameters
			}

			#Region Restart Agent Service
			$ResultSet = $DatabaseObject.ExecuteWithResults($Query_AgentServiceName)

			$CommandParameters = @{
				'ScriptBlock' = $ScriptBlock_RestartService
				'ArgumentList' = $ResultSet.Tables.Rows.ServiceName
			}

			if ([System.Net.Dns]::GetHostName() -ne $SmoServerObject.NetName) {
				$CommandParameters.Add('ComputerName', $SmoServerObject.Information.FullyQualifiedNetName)
			}

			if ($PSCmdlet.ShouldProcess('SQL Server Agent', 'Restart job server')) {
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

			Get-SmoSqlAgentMsxEncryptChannelOption -SmoServer $SmoServerObject
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Set-SmoSqlAgentSubSystem {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer

			$DatabaseObject = $SmoServerObject.Databases['master']
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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
			if ($PSCmdlet.ShouldProcess($AgentSubSystem, 'Set max worker threads')) {
				$DatabaseObject.ExecuteNonQuery([string]::Format($Query_SetMaxWorkerThreads, $MaxWorkerThreads, $AgentSubSystem))
			}

			#Region Restart Agent Service
			$ResultSet = $DatabaseObject.ExecuteWithResults($Query_AgentServiceName)

			$CommandParameters = @{
				'ScriptBlock' = $ScriptBlock_RestartService
				'ArgumentList' = $ResultSet.Tables.Rows.ServiceName
			}

			if ([System.Net.Dns]::GetHostName() -ne $SmoServerObject.NetName) {
				$CommandParameters.Add('ComputerName', $SmoServerObject.Information.FullyQualifiedNetName)
			}

			if ($PSCmdlet.ShouldProcess('SQL Server Agent', 'Restart job server')) {
				for ($i = 0; $i -lt 20; $i++) {
					if (($JobServer.Jobs.where({$_.JobType -eq 'Local' -and $_.CurrentRunStatus -ne 'Idle'}).Count -eq 0)) {
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

			Get-SmoSqlAgentSubSystem -SmoServerObject $SmoServerObject -AgentSubSystem $AgentSubSystem
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Start-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSBoundParameters.ContainsKey('JobStepName')) {
				if ($AgentJob.JobSteps.Name -NotContains $JobStepName) {
					throw [System.Management.Automation.ErrorRecord]::New(
						[Exception]::New('Agent job step not found.'),
						'1',
						[System.Management.Automation.ErrorCategory]::ObjectNotFound,
						$JobStepName
					)
				}
			}

			if ($PSCmdlet.ShouldProcess($JobName, 'Start job')) {
				if ($PSBoundParameters.ContainsKey('JobStepName')) {
					$AgentJob.Start($JobStepName)
				} else {
					$AgentJob.Start()
				}
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

function Stop-SmoSqlAgentJob {
	<#
	.EXTERNALHELP
	SqlServerAgentTools-Help.xml
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
		$ServerInstanceParameterSets = @('ServerInstance')

		try {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				$SmoServerObject = Connect-SmoServer -ServerInstance $ServerInstance
			}

			$JobServer = $SmoServerObject.JobServer
		}
		catch {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				if (Test-Path -Path Variable:\SmoServerObject) {
					if ($SmoServerObject -is [Microsoft.SqlServer.Management.Smo.Server]) {
						Disconnect-SmoServer -SmoServerObject $SmoServerObject
					}
				}
			}

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

			if ($PSCmdlet.ShouldProcess($JobName, 'Stop job')) {
				$AgentJob.Stop()
			}
		}
		catch {
			throw $_
		}
		finally {
			if ($PSCmdlet.ParameterSetName -in $ServerInstanceParameterSets) {
				Disconnect-SmoServer -SmoServerObject $SmoServerObject
			}
		}
	}

	end {
	}
}

# SIG # Begin signature block
# MIInywYJKoZIhvcNAQcCoIInvDCCJ7gCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDR1RfEl+aDsB0Y
# FrJBc/Yjta/8wmxV3ckIhWcqkYiQWaCCINswggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwgga0MIIEnKADAgECAhANx6xXBf8hmS5AQyIMOkmGMA0GCSqG
# SIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMx
# GTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IFRy
# dXN0ZWQgUm9vdCBHNDAeFw0yNTA1MDcwMDAwMDBaFw0zODAxMTQyMzU5NTlaMGkx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UEAxM4
# RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBTSEEyNTYg
# MjAyNSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC0eDHTCphB
# cr48RsAcrHXbo0ZodLRRF51NrY0NlLWZloMsVO1DahGPNRcybEKq+RuwOnPhof6p
# vF4uGjwjqNjfEvUi6wuim5bap+0lgloM2zX4kftn5B1IpYzTqpyFQ/4Bt0mAxAHe
# HYNnQxqXmRinvuNgxVBdJkf77S2uPoCj7GH8BLuxBG5AvftBdsOECS1UkxBvMgEd
# gkFiDNYiOTx4OtiFcMSkqTtF2hfQz3zQSku2Ws3IfDReb6e3mmdglTcaarps0wjU
# jsZvkgFkriK9tUKJm/s80FiocSk1VYLZlDwFt+cVFBURJg6zMUjZa/zbCclF83bR
# VFLeGkuAhHiGPMvSGmhgaTzVyhYn4p0+8y9oHRaQT/aofEnS5xLrfxnGpTXiUOeS
# LsJygoLPp66bkDX1ZlAeSpQl92QOMeRxykvq6gbylsXQskBBBnGy3tW/AMOMCZIV
# NSaz7BX8VtYGqLt9MmeOreGPRdtBx3yGOP+rx3rKWDEJlIqLXvJWnY0v5ydPpOjL
# 6s36czwzsucuoKs7Yk/ehb//Wx+5kMqIMRvUBDx6z1ev+7psNOdgJMoiwOrUG2Zd
# SoQbU2rMkpLiQ6bGRinZbI4OLu9BMIFm1UUl9VnePs6BaaeEWvjJSjNm2qA+sdFU
# eEY0qVjPKOWug/G6X5uAiynM7Bu2ayBjUwIDAQABo4IBXTCCAVkwEgYDVR0TAQH/
# BAgwBgEB/wIBADAdBgNVHQ4EFgQU729TSunkBnx6yuKQVvYv1Ensy04wHwYDVR0j
# BBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0
# cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0
# cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNVHR8E
# PDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1sBwEw
# DQYJKoZIhvcNAQELBQADggIBABfO+xaAHP4HPRF2cTC9vgvItTSmf83Qh8WIGjB/
# T8ObXAZz8OjuhUxjaaFdleMM0lBryPTQM2qEJPe36zwbSI/mS83afsl3YTj+IQhQ
# E7jU/kXjjytJgnn0hvrV6hqWGd3rLAUt6vJy9lMDPjTLxLgXf9r5nWMQwr8Myb9r
# EVKChHyfpzee5kH0F8HABBgr0UdqirZ7bowe9Vj2AIMD8liyrukZ2iA/wdG2th9y
# 1IsA0QF8dTXqvcnTmpfeQh35k5zOCPmSNq1UH410ANVko43+Cdmu4y81hjajV/gx
# dEkMx1NKU4uHQcKfZxAvBAKqMVuqte69M9J6A47OvgRaPs+2ykgcGV00TYr2Lr3t
# y9qIijanrUR3anzEwlvzZiiyfTPjLbnFRsjsYg39OlV8cipDoq7+qNNjqFzeGxcy
# tL5TTLL4ZaoBdqbhOhZ3ZRDUphPvSRmMThi0vw9vODRzW6AxnJll38F0cuJG7uEB
# YTptMSbhdhGQDpOXgpIUsWTjd6xpR6oaQf/DJbg3s6KCLPAlZ66RzIg9sC+NJpud
# /v4+7RWsWCiKi9EOLLHfMR2ZyJ/+xhCx9yHbxtl5TPau1j/1MIDpMPx0LckTetiS
# uEtQvLsNz3Qbp7wGWqbIiOWCnb5WqxL3/BAPvIXKUjPSxyZsq8WhbaM2tszWkPZP
# ubdcMIIGuTCCBKGgAwIBAgIRAJmjgAomVTtlq9xuhKaz6jkwDQYJKoZIhvcNAQEM
# BQAwgYAxCzAJBgNVBAYTAlBMMSIwIAYDVQQKExlVbml6ZXRvIFRlY2hub2xvZ2ll
# cyBTLkEuMScwJQYDVQQLEx5DZXJ0dW0gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkx
# JDAiBgNVBAMTG0NlcnR1bSBUcnVzdGVkIE5ldHdvcmsgQ0EgMjAeFw0yMTA1MTkw
# NTMyMThaFw0zNjA1MTgwNTMyMThaMFYxCzAJBgNVBAYTAlBMMSEwHwYDVQQKExhB
# c3NlY28gRGF0YSBTeXN0ZW1zIFMuQS4xJDAiBgNVBAMTG0NlcnR1bSBDb2RlIFNp
# Z25pbmcgMjAyMSBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJ0j
# zwQwIzvBRiznM3M+Y116dbq+XE26vest+L7k5n5TeJkgH4Cyk74IL9uP61olRsxs
# U/WBAElTMNQI/HsE0uCJ3VPLO1UufnY0qDHG7yCnJOvoSNbIbMpT+Cci75scCx7U
# sKK1fcJo4TXetu4du2vEXa09Tx/bndCBfp47zJNsamzUyD7J1rcNxOw5g6FJg0Im
# Iv7nCeNn3B6gZG28WAwe0mDqLrvU49chyKIc7gvCjan3GH+2eP4mYJASflBTQ3HO
# s6JGdriSMVoD1lzBJobtYDF4L/GhlLEXWgrVQ9m0pW37KuwYqpY42grp/kSYE4BU
# QrbLgBMNKRvfhQPskDfZ/5GbTCyvlqPN+0OEDmYGKlVkOMenDO/xtMrMINRJS5SY
# +jWCi8PRHAVxO0xdx8m2bWL4/ZQ1dp0/JhUpHEpABMc3eKax8GI1F03mSJVV6o/n
# mmKqDE6TK34eTAgDiBuZJzeEPyR7rq30yOVw2DvetlmWssewAhX+cnSaaBKMEj9O
# 2GgYkPJ16Q5Da1APYO6n/6wpCm1qUOW6Ln1J6tVImDyAB5Xs3+JriasaiJ7P5KpX
# eiVV/HIsW3ej85A6cGaOEpQA2gotiUqZSkoQUjQ9+hPxDVb/Lqz0tMjp6RuLSKAR
# sVQgETwoNQZ8jCeKwSQHDkpwFndfCceZ/OfCUqjxAgMBAAGjggFVMIIBUTAPBgNV
# HRMBAf8EBTADAQH/MB0GA1UdDgQWBBTddF1MANt7n6B0yrFu9zzAMsBwzTAfBgNV
# HSMEGDAWgBS2oVQ5AsOgP46KvPrU+Bym0ToO/TAOBgNVHQ8BAf8EBAMCAQYwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwMAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL2NybC5j
# ZXJ0dW0ucGwvY3RuY2EyLmNybDBsBggrBgEFBQcBAQRgMF4wKAYIKwYBBQUHMAGG
# HGh0dHA6Ly9zdWJjYS5vY3NwLWNlcnR1bS5jb20wMgYIKwYBBQUHMAKGJmh0dHA6
# Ly9yZXBvc2l0b3J5LmNlcnR1bS5wbC9jdG5jYTIuY2VyMDkGA1UdIAQyMDAwLgYE
# VR0gADAmMCQGCCsGAQUFBwIBFhhodHRwOi8vd3d3LmNlcnR1bS5wbC9DUFMwDQYJ
# KoZIhvcNAQEMBQADggIBAHWIWA/lj1AomlOfEOxD/PQ7bcmahmJ9l0Q4SZC+j/v0
# 9CD2csX8Yl7pmJQETIMEcy0VErSZePdC/eAvSxhd7488x/Cat4ke+AUZZDtfCd8y
# HZgikGuS8mePCHyAiU2VSXgoQ1MrkMuqxg8S1FALDtHqnizYS1bIMOv8znyJjZQE
# Sp9RT+6NH024/IqTRsRwSLrYkbFq4VjNn/KV3Xd8dpmyQiirZdrONoPSlCRxCIi5
# 4vQcqKiFLpeBm5S0IoDtLoIe21kSw5tAnWPazS6sgN2oXvFpcVVpMcq0C4x/CLSN
# e0XckmmGsl9z4UUguAJtf+5gE8GVsEg/ge3jHGTYaZ/MyfujE8hOmKBAUkVa7NMx
# RSB1EdPFpNIpEn/pSHuSL+kWN/2xQBJaDFPr1AX0qLgkXmcEi6PFnaw5T17UdIIn
# A58rTu3mefNuzUtse4AgYmxEmJDodf8NbVcU6VdjWtz0e58WFZT7tST6EWQmx/Oo
# HPelE77lojq7lpsjhDCzhhp4kfsfszxf9g2hoCtltXhCX6NqsqwTT7xe8LgMkH4h
# Vy8L1h2pqGLT2aNCx7h/F95/QvsTeGGjY7dssMzq/rSshFQKLZ8lPb8hFTmiGDJN
# yHga5hZ59IGynk08mHhBFM/0MLeBzlAQq1utNjQprztZ5vv/NJy8ua9AGbwkMWkO
# MIIG4DCCBMigAwIBAgIQQ7s0QZ8qUnHOP66HyvajHjANBgkqhkiG9w0BAQsFADBW
# MQswCQYDVQQGEwJQTDEhMB8GA1UEChMYQXNzZWNvIERhdGEgU3lzdGVtcyBTLkEu
# MSQwIgYDVQQDExtDZXJ0dW0gQ29kZSBTaWduaW5nIDIwMjEgQ0EwHhcNMjYwOTEy
# MjEzNTQ3WhcNMjcwOTEyMjEzNTQ2WjCBhTELMAkGA1UEBhMCVVMxFzAVBgNVBAgM
# DlNvdXRoIENhcm9saW5hMREwDwYDVQQHDAhOZXdiZXJyeTEeMBwGA1UECgwVT3Bl
# biBTb3VyY2UgRGV2ZWxvcGVyMSowKAYDVQQDDCFPcGVuIFNvdXJjZSBEZXZlbG9w
# ZXIgUm9iZXJ0IEVkZXIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC6
# 72ybkWUB620cgb49nkhI4VvtWKABeSD8277f0Jww+/5fKUxoX2vC77QjmaSXU+I9
# LB2YTj8yCSTDVlxIwJoS7KgsIN9P2EC6ehJe9FRI0n2Rt33/VlRY8kuSh2XsIVGg
# i6Y3RooWVjVmYCAOXuV5zrqjGY1P72nrSIekxcGCTo1Y0nmRwsECCIYn7b3ZM065
# u9b3AtYf3oI4grblWhtY0kbuHNCSeDjpp+qExQgeIs6OpFACJSDASFiDnF8+L+bB
# V+UtUcFbvlu0WpQyblXw9vdN7BEIdqZ/1fxyhjHxqpSuOoTqoZcyDjilXtnMOfWp
# gfgdKPFRc6NHwrmxUyNLAYHOsqBC+bMxamurB1qCJ/16lFbW/YWJRrJsaeA2WaPw
# 8ulkUnZUoP9JgyVE1nwZbhZOgE3YwlVLmBBsAKsRiyJWBYqG1VdaMpfzLYJVNTc8
# 4F/90uC2BvIoafcFfNyc8dIpdd7Ni17JmYuD0+/u1gqUi3p+Qdlk/y+Vgsb1x+0z
# kaMA6CzjFA83szdzwRLFDDnaUOVngyRR8+JLnSNuEw9nNM3G5WWRGBDOkLbwq+NO
# H1gWWAaJJYOlTARrg7ea2JHLl66CBJaaledp2u8hBl1Y5yQTpIkVYx0VPt1Oa7Nq
# kOkXlNjmmlYsZm5pe3fSTBPx5YdUOeIl1sAWXGH/+QIDAQABo4IBeDCCAXQwDAYD
# VR0TAQH/BAIwADA9BgNVHR8ENjA0MDKgMKAuhixodHRwOi8vY2NzY2EyMDIxLmNy
# bC5jZXJ0dW0ucGwvY2NzY2EyMDIxLmNybDBzBggrBgEFBQcBAQRnMGUwLAYIKwYB
# BQUHMAGGIGh0dHA6Ly9jY3NjYTIwMjEub2NzcC1jZXJ0dW0uY29tMDUGCCsGAQUF
# BzAChilodHRwOi8vcmVwb3NpdG9yeS5jZXJ0dW0ucGwvY2NzY2EyMDIxLmNlcjAf
# BgNVHSMEGDAWgBTddF1MANt7n6B0yrFu9zzAMsBwzTAdBgNVHQ4EFgQUCdHvF5Qw
# xL78QY6vfJNPC89uTWEwSwYDVR0gBEQwQjAIBgZngQwBBAEwNgYLKoRoAYb2dwIF
# AQQwJzAlBggrBgEFBQcCARYZaHR0cHM6Ly93d3cuY2VydHVtLnBsL0NQUzATBgNV
# HSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBADGvhUwApFlOiMwxr4muEgH+EK8xGwyw7qZGQZYdHQZV7E6ev+4i0u2ywMbF
# H0XcYpaB4xubprYIGbltJhIXoIM+BmIB6mgzgAtKMJBIWMECnACZKPAWPJ5vp3Xu
# GLCg0gwQGZEKJInwEFLzplH3G5g8hTO8KSLmWLVWoWHTTA3WI4LgTf/XRs3QYqur
# bB1gWRWa+vx8J/4I6znbpnpRDxy/jCYh9qtv21Dk3BovIPnfaj50JOWJhWeongQ6
# Dgd4/FZhM/U1Fj/g1W7WDMal9q43MABwmrHPbxrIEK1V5vXwAhK1m9eSaZ8bqbeA
# SId0wOYzIyEziquoO5TCdf/lSi8nD4BIm2E+h738pLQXWvr6tYWyvqaUN0uk5f27
# NsXlVRYp8EUZPP83BJMaQJFgTsYPMeZejAndk3nuqPVGeCL6WW90M7eK5sPbTAmW
# WrSnYFx4pgnMR3X3s14074ytJ3o3ycKa0bxjhMcoCTfMDmV7jUUhATpW8iZ2/E4b
# +0s7DmbN37VsBngsj04vMyVxhcNLSwdFDTQEgkEwHccChlw0anfoZJ7Xui4x5RSr
# j3rOyyrf7mFYIpsbDYjVxBo5/JVJuu5h2+BRxY9MLoSMknm391tCI7aVC/XTl/zW
# rX1kJeCx0nYBnZnmjWCRrCXWOX5V8QaLAnK/R6durGeXnlo3MIIG7TCCBNWgAwIB
# AgIQCE/cM09+RU7bww+P+ZIYNTANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQGEwJV
# UzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRy
# dXN0ZWQgRzQgVGltZVN0YW1waW5nIFJTQTQwOTYgU0hBMjU2IDIwMjUgQ0ExMB4X
# DTI2MDgwNTAwMDAwMFoXDTM3MTEwNDIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAV
# BgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBTSEEyNTYg
# UlNBNDA5NiBUaW1lc3RhbXAgUmVzcG9uZGVyIDIwMjYgMTCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBALZ7pvLJ/s1K+NSbTGWz/TjGMPh8CQ6RucZCLv5a
# nHzWJjF/NWJrFIhy24fcpKXlgRiky4WAawDfU3YP0BMxt9l3Dm5oCG5Z69AqEN1k
# gHg2epx+l+lZBcmJCcN0ASURML5uFIS80sZsDwO3BSkUxDjLJhBI+qiZP3aixAC/
# qEGLjsBNlLol9VZ7pfGEXiMlneJIC5/YKuizVzNFKZZEeoy/0B8Zm+nzKBgSWG52
# lCO1w+nCg6XpCtklTJXeIg283hw7TmmsZXR+SMbjbrEOvZ3fP2VxIgeR28Y90ZSt
# d3F9VuA5RVynb/whITPAo9b75Zr4Ta6Mj3URm26QZYMn/FnbuTegcoRcFEZ9FOqM
# 5T6MTdtr/n74lIT/ug0eeOzmZ6QTFg33otX+bFRsIolvykE1jive4PuESaT8zzVe
# FWDAMDtozNgLctkGD1ZjkEyZtJrLl5ya0m5doH/ScpaZCZVl6pNUOCybMc/kxC6E
# AmSJY24L0yYKD1Nkddsnb/ItVKi/2nXpQNMu1PT5prW83vV8d67WowuUs0HdY4H8
# AMLGvdL/WHEj3ZnqMqAQQP9u3Ai9t+5eQ02GDwy0ODjdzi0xlp70W+ow63/0++YD
# EX1M0iwgUHwbrJvfpklkZQvw3+kv3vUPItdwroczk9icflf55W1zOEKAcJVAIXpc
# MCU9AgMBAAGjggGVMIIBkTAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQUyWOKMC7U
# SvtulPPm40B+9ezN4jAfBgNVHSMEGDAWgBTvb1NK6eQGfHrK4pBW9i/USezLTjAO
# BgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwgZUGCCsGAQUF
# BwEBBIGIMIGFMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# XQYIKwYBBQUHMAKGUWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dFRydXN0ZWRHNFRpbWVTdGFtcGluZ1JTQTQwOTZTSEEyNTYyMDI1Q0ExLmNydDBf
# BgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRUcnVzdGVkRzRUaW1lU3RhbXBpbmdSU0E0MDk2U0hBMjU2MjAyNUNBMS5jcmww
# IAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUA
# A4ICAQCNxTphHp1SCt+ZrAmAfn0oQLFr0mLywSLaDXQIENoyKqxrFbJblzCVP/pk
# XmwXOdrOpWygLzlT12os5ipDCy35RBCg2UMeApEtrfGhz45F4Wt4WGdNdIbRWt3Y
# TYJmpR+b7lr4d7Uwn+H600u4D7RnOGf8Wj4UNgAdZkfHhHv1mx9EVh71SJelcEN/
# oORSjXzdjfw1iZH9d8Nh/thn6hH23d+VsPAr6GAYyzSA02nXD1nYLI7Ijmiv+xLC
# iYC41DSFYL3GhTiy0PxpawPtGRyaBVGzq+UiTfM8pD7KVyF5aQyWP4KhVGUUTnmm
# /RlYJoW3TiXA/+t0YcT2oRVBm3JETjajHug2AL+v5jhtKVnd3D0rbHXEu27o+Q8p
# 4sEWPMqKDB+qbceb6T/6WcwTwXmQ9lOCLLYcsQeSWmvKqzpAec9etE14jOQAzLKW
# dE3w/TCaKtLRaRT7LCkRYVnhA2D73FLje1O5b3HR5eHs0NzU/+xX7NbEdcofy0W3
# Wdwd1XOqtlpg/JgwtKfZM5dqO94lbUveOiJBI+xZEbGRsMNbXmMREUTgu+Oca7Y7
# 3MPWcslIx2VhkSKSXjDbD6rgg39H5Mh7QfieAIjWagkJNt68Yfim6cjEzVSiLSeZ
# fdkr5dtFPTW6jATlWJdYeeDRGCyatf8R1hSjzSvdN8yWQPT9gzGCBkYwggZCAgEB
# MGowVjELMAkGA1UEBhMCUEwxITAfBgNVBAoTGEFzc2VjbyBEYXRhIFN5c3RlbXMg
# Uy5BLjEkMCIGA1UEAxMbQ2VydHVtIENvZGUgU2lnbmluZyAyMDIxIENBAhBDuzRB
# nypScc4/rofK9qMeMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIFBPgYeBs0Chge7W8/qz
# ENVfxBeLpcD270P3kfDDB8gaMA0GCSqGSIb3DQEBAQUABIICAKDyxmxE0RSaQZEf
# stpCRjKvCwgWXcCaGhHMxuBKpd7St/n7e5deynfL2UyXA3YFTO5cZW5pvUxp1sUw
# cSSmtF7O8I4ZznND7FA30rUvgAOKZ3JiHfUUBxPoLtZWCmcaDMLQfZuYd5By5Mxf
# bWhBEVhkQffMSja3J5k4GWXzFYJ4Vt8Q2IstLLeKxcB11tevLz1X7c+CmZVO1YHc
# bNZnSeV1Yy9KHjuxDSvhRb+bBoFFmbaPo935UCNxzelkwkB/0m+PIwaROaakB8ua
# kopoEe/mo7Zp0DKxH3Ftun37MXWQpM4ayCmfRL3lZ+P3Iq3AGIrcweZwipPAljz/
# oBCLwNOXGY3yZqse9HykGPMqz/YmBi5d5xzqoJFn3uRIChcOL+XkCL4A3VhA2asK
# S0FaFMlv7Zq2OJUE9dKg7kdizx+i5XyZnRpbFItCzrn//QAkHlGd0NeL5Lyppgyc
# qKTQ8fWr93UitLOyidSZkuvG++Zv4bIe/8ClhHO0bgnTcWtYl9qsgw3kFOF9Rnoj
# mtgdPfa6gT8fXxQLTXmc3VZye7rs9Hxzm5T7c2L5/Xc/5Ix8T0ngL9jswpgyXKcc
# bf1ZTNqn3Bkp1019KEfiojk9k0cAJ0GiV0hHCiEe0ssuS9vOadcN4HNC5mRWjfd7
# PoXME5oAGcU0+ZNvqILyUUdxJFAnoYIDJjCCAyIGCSqGSIb3DQEJBjGCAxMwggMP
# AgEBMH0waTELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMUEw
# PwYDVQQDEzhEaWdpQ2VydCBUcnVzdGVkIEc0IFRpbWVTdGFtcGluZyBSU0E0MDk2
# IFNIQTI1NiAyMDI1IENBMQIQCE/cM09+RU7bww+P+ZIYNTANBglghkgBZQMEAgEF
# AKBpMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI2
# MTAzMTE2MjcwNFowLwYJKoZIhvcNAQkEMSIEIEEC4JmtfGi2ljSmisyWM6x4wm45
# XWs95Oq0ZJlscR58MA0GCSqGSIb3DQEBAQUABIICAD2i8glNs5LLLapLq8ZRxwlh
# oE+xkC6jIwar0TjhsO7ODxTbfG/OyohLZi2DbxIyabuoUyvuLpUDc1q1hpghiPt0
# GwIJj92pVcvoXXiSJ7ta4kyxN8lkTZaTiTZf9slOMvv6L5SHiAcyCBV89HJd3J5/
# EBlCwlGSoWIHpBIGHE9NROksmRtNlm1iNd2J/GORpfXBdq2A665lxHLot/DGHdmH
# ZiPucaXYCj99WUQqKL2HOYHt6px/aQviA0dP2LUV1IWK7fcE6S2O4xMKFOaqiR1n
# mOEcij8FXa/AnZ+qt1TFwEk+hPHD4WuOkZq+CofWx8l0TpQjHb5EE/G8KJf6lmp+
# WbDUXlretCY9F2BTvKErYV2AkrDZdrK7rAVeH/QXXG7018dA02mwpEcz2jTYRGwU
# Di5ZQsGKTexsvEMFNJv0obR/MwmUU2Iy8fN4zC4ft2OOgjmouGgkMED9g/blaYik
# gRinM7oKOfvjyeUfZkxtleQtwDnwa/nu0ziRSVgWz1kY93VyhX9e6oBNA5MPA6wS
# DO2zPMrwqE0ArnyEgWOpfd3mnQ0IKl0SZmWSjfKGUxHT11RHVFjPoIquLmi9l8tF
# BfwUZubwaxp6gORf6Y6EaHOBAxWXnoJ818wK9xChifFrTh1JUezFt9N2CUE7eDxH
# YefpqkhGiDSCgBSqNYge
# SIG # End signature block
