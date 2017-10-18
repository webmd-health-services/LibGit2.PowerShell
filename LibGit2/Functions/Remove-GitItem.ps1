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

function Remove-GitItem
{
    <#
.SYNOPSIS


.DESCRIPTION
Long description

.EXAMPLE
An example

.NOTES
General notes
#>

    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]
        # The paths to the files/directories to add to the next commit.
        $Path,

        [string]
        # The path to the repository where the files should be added. The default is the current directory as returned by Get-Location.
        $RepoRoot = (Get-Location).ProviderPath
    )
    Set-StrictMode -Version 'Latest'
    $repo = Find-GitRepository -Path $RepoRoot -Verify

    if( -not ((Test-Path -Path 'variable:repo') -and $repo) )
    {
        return
    }

    foreach( $pathItem in $Path )
    {
        if( -not [IO.Path]::IsPathRooted($pathItem) )
        {
            $pathItem = Join-Path -Path $repo.Info.WorkingDirectory -ChildPath $pathItem
        }
        $repo.Remove($pathItem, $true, $null)
    }
}