#!/bin/bash

# adding this switch because $GIT_DIR doesn't seem to be getting set in git 2.18
if [ "${GIT_DIR}" == "" ]; then
    # rely on relative path assuming the cwd is the project root
    PROJ_ROOT=""
else
    PROJ_ROOT="${GIT_DIR}/../"
fi


# shamelessly stolen from https://stackoverflow.com/questions/16840184/how-can-i-automatically-be-warned-if-a-specific-file-changes
# listing all these out is gross, fix it if you have a better way
REQS_CHANGED=$(git diff HEAD@{1} --stat -- ${PROJ_ROOT}requirements.txt | wc -l)
REQS_VARIANT_CHANGED=$(git diff HEAD@{1} --stat -- ${PROJ_ROOT}requirements-variant.txt | wc -l)
TEST_REQS_CHANGED=$(git diff HEAD@{1} --stat -- ${PROJ_ROOT}test-requirements.txt | wc -l)
TEST_REQS_VARIANT_CHANGED=$(git diff HEAD@{1} --stat -- ${PROJ_ROOT}test-requirements-variant.txt | wc -l)
MIGRATION_CHANGED=$(git diff HEAD@{1} --stat -- ${PROJ_ROOT}src/learning/app/migrations/ | wc -l)
ENV_CHANGELOG_CHANGED=$(git diff HEAD@{1} --stat -- ${PROJ_ROOT}ENV_CHANGELOG.md | wc -l)
CELERY_CONFIG_CHANGED=$(git diff HEAD@{1} --stat -- ${PROJ_ROOT}src/learning/settings/settings_celery.py | wc -l)
COMPOSE_OVERRIDES_CHANGED=$(git diff HEAD@{1} --stat -- ${PROJ_ROOT}ci/docker-compose.override.yml.tpl | wc -l)

RED=$'\e[31m'
RESET=$'\e[0m'

echo "HELLO_WORLD"
if [ $REQS_CHANGED -gt 0 ] || [ $TEST_REQS_CHANGED -gt 0 ]; then
    echo "${RED}requirements changed, to update run:"
    echo "$ make pip-install ${RESET}"
fi

if [ $MIGRATION_CHANGED -gt 0 ]; then
    echo "${RED}Changes detected in django migrations, to update run:"
    echo "$ make migrate-mysql ${RESET}"
fi

if [ $REQS_VARIANT_CHANGED -gt 0 ] || [ $TEST_REQS_VARIANT_CHANGED -gt 0 ]; then
    echo "${RED}variant requirements changed, if you are working with variant builds run (in your app variant venv):"
    echo "$ make VARIANT=1 pip-install ${RESET}"
fi

if [ $ENV_CHANGELOG_CHANGED -gt 0 ]; then
    echo "${RED}Change detected in ENV_CHANGELOG.md."
    echo "Read it. ${RESET}"
fi

if [ $CELERY_CONFIG_CHANGED -gt 0 ]; then
    echo "${RED}Changes detected in settings_celery.py, to verify a Celery migration is required, run:"
    echo "$ make migrate-celery"
    echo "To execute the migration, run:"
    echo "$ make migrate-celery-execute ${RESET}"
fi

if [ $COMPOSE_OVERRIDES_CHANGED -gt 0 ]; then
    echo "${RED}Changes detected in docker-compose.overrides.yml.tpl. To refresh your local overrides run:"
    echo "$ cp ci/docker-compose.override.yml.tpl docker-compose.override.yml"
    echo "Open docker-compose.override.yml in your editor of choice and apply any additional customizations, then run:"
    echo "$ make down up ${RESET}"
fi
