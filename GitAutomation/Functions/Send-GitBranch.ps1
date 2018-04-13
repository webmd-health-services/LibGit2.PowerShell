# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Send-GitBranch
{
    <#
    .SYNOPSIS
    Pushes the current branch to a remote repository, merging in changes from the remote branch, if necessary.

    .DESCRIPTION
    The `Send-GitBranch` function sends the changes in the current branch to a remote repository. If there are any new changes for that branch on the remote repository, they are pulled in and merged with the local branch using the `Sync-GitBranch` function.

    Use the `MergeStrategy` argument to control how new changes are merged into your branch. The default is to use the `merge.ff` Git setting, which is to fast-forward when possible, merge otherwise.

    The `Retry` parameter controls how many pull/merge/push attempts to make. The default is "5".

    This command implements the `git push` function.

    .LINK
    Sync-GitBranch

    .LINK
    Send-GitCommit

    .EXAMPLE
    Send-GitBranch

    Demonstrates how to push changes to a remote repository.
    #>
    [CmdletBinding()]
    param(
        [string]
        $RepoRoot = (Get-Location).ProviderPath,

        [ValidateSet('FastForward','Merge')]
        [string]
        # What to do when merging remote changes into your local branch. By default, will use your configured `merge.ff` configuration options. Set to `Merge` to always create a merge commit. Use `FastForward` to only allow fast-forward "merges" (i.e. move the remote branch to point to your local branch head if there are no new changes on the remote branch). When automating, the safest option is `Merge`. If you choose `FastForward` and the remote branch has new changes on it, this function will fail.
        $MergeStrategy,

        [int]
        # The number of times to retry the push. Default is 5.
        $Retry = 5
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $mergeStrategyParam = @{ }
    if( $MergeStrategy )
    {
        $mergeStrategyParam['MergeStrategy'] = $MergeStrategy
    }
    
    $tryNum = 0
    do
    {
        $syncResult = Sync-GitBranch -RepoRoot $RepoRoot @mergeStrategyParam
        if( -not $syncResult )
        {
            return
        }

        $syncResult

        if( $syncResult.Status -eq [LibGit2Sharp.MergeStatus]::Conflicts )
        {
            Write-Error -Message ('There are merge conflicts pulling remote changes into local branch.')
            return
        }

        $pushResult = Send-GitCommit -RepoRoot $RepoRoot
        $pushResult
    }
    while( $tryNum++ -lt $Retry -and $pushResult -ne [Git.Automation.PushResult]::Ok )
}
