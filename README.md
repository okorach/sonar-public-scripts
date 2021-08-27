# sonar-scripts
## cobertura2sonar.sh

Converts a Cobertura coverage report in SonarQube generic format

Use `cobertura2sonar.sh -h` to get details on the options

## download-build-wrapper.sh

Downloads the latest version of the SonarCFamily build wrapper
inn a local directory

Use `download-build-wrapper.sh -h` to get details on the options

## replay-the-past.sh

Rebuilds the entire history of a project by reanalysing old tags/commits

Use `replay-the-past.sh -h` to get details on the options

## set-ref-branch.sh

Applies to a branch a given other reference branch for new code
If the branch does not exist yet, the branch is created before being set a reference branch

Example:

`set-ref-branch.sh <projectKey> <newBranch> <referenceBranch>`
