import os
import requests

def create_empty_branch(project_key, branch_name):
    if not branch_exists(project_key, branch_name):
        dummy_source_dir = "dummy"
        # Run scanner - token should be in env variable $SONAR_TOKEN
        # URL in $SONAR_HOST_URL
        os.command("sonar-scanner -Dsonar.sources={} -Dsonar.branch.name={}".format(dummy_source_dir, branch_name))

def branch_exists(project_key, branch_name):
    params