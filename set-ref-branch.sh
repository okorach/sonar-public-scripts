
project_key=$1
new_branch=$2
ref_branch=$3

branch_exists() {
    branch_name=$1
    project_key=$2
    curl -s -X GET -u $SONAR_TOKEN: "$SONAR_HOST_URL/api/project_branches/list?project=$project_key" | \
        python -m json.tool | grep '"name": ' | cut -d ':' -f 2 | cut -d '"' -f 2|grep -E "^${branch_name}$" >/dev/null
    return $?
}

create_branch() {
    branch_name=$1
    project_key=$2

    if branch_exists $project_key $branch_name; then
        echo "Branch $branch_name already exists"
        return 0
    fi

    echo "Creating branch through a dummy scan, please wait..."
    dummy_sources="dummy$$"
    mkdir -p $dummy_sources
    # Create the new branch empty thru a dummy scan:
    # Analysing a dummy (empty) sources directory is faster
    # than excluding all the code (ie sonar.exclusions=**/*)
    sonar-scanner -Dsonar.projectKey=$project_key -Dsonar.branch.name=$branch_name -Dsonar.sources=$dummy_sources >/dev/null
    rm -rf $dummy_sources

    echo "Waiting for branch to exist in SonarQube..."
    total_wait=0
    current_wait=5
    # branch creation may take time depending on you platform load (bg task queue)
    # loop until branch exists
    while ! branch_exists $project_key $branch_name; do
        sleep $current_wait
        let total_wait=$total_wait+$current_wait
        if [ $total_wait -ge 300 ]; then
            # Abort after a given timeout (5 minutes here)
            echo "Branch creation too long, aborting..."
            return 1
        fi
        let current_wait=$current_wait*2
    done
    echo "Branch created"
    return 0
}

set_ref_branch() {
    project_key=$1
    branch_name=$2
    ref_branch=$3

    curl -X POST -u $SONAR_TOKEN: "$SONAR_HOST_URL/api/new_code_periods/set?project=$project_key&type=REFERENCE_BRANCH&branch=$branch_name&value=$ref_branch"
    echo "Reference branch $ref_branch set for branch $branch_name"
}

create_branch $project_key $new_branch
if [ $? -eq 0 ]; then
    set_ref_branch $project_key $new_branch $ref_branch
fi