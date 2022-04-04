#!/bin/bash
. /scripts/params-shell.sh

## HELP
if [[ ${PARAM['help']} ]];then
    tabs 2 30
    echo -e "NAME: \n\t gitlab variable management \n"
    echo -e "USAGE: \n\t gitlab-var-mng [command options]\n"
    echo -e "OPTIONS:
\t --api-version=<value> \t gitlab api version (default: 4)
\t --group-id=<value> \t gitlab group id [\$GROUP_ID]
\t --help \t show help (default: false)
\t --input=<value> \t input file name [\$INPUT]
\t --output=<value> \t output file name [\$OUTPUT]
\t --project-id=<value> \t gitlab project id [\$PROJECT_ID]
\t --remove-all \t Remove all variables
\t --token=<value> \t gitlab token [\$TOKEN]
\t --url=<value> \t gitlab url (with http:// or https://) [\$URL]
"
    echo -e "\nAUTHOR: \n\t Written by Romain LEON romain.leon@gmail.fr \n"
    exit 0
else
    . /scripts/params-shell.sh --token=${TOKEN} --url=${URL} --project-id=${PROJECT_ID} --group-id=${GROUP_ID} --output=${OUTPUT} --input=${INPUT} --api-version=${API_VERSION}  "$@" mandatory=token,url type_int=project-id,group-id
fi

## DEFAULT OUTPUT VALUE
if [[ -z ${PARAM['output']} ]];then
    PARAM['output']="export_var_${PARAM['project-id']}.yml"
else
    PARAM['export']=1
fi

## DEFAULT API VERSION
if [[ -z ${PARAM['api-version']} ]];then
    PARAM['api-version']=4
fi

## PROJECT OR GROUP
if [[ -z ${PARAM['project-id']} ]];then
    if [[ ${PARAM['group-id']} ]];then
        ID=${PARAM['group-id']}
        TYPE="groups"
    else
        echo -e "Missing parameter : project-id or group-id"
        exit 1
    fi
else
    ID=${PARAM['project-id']}
    TYPE="projects"
fi

## CHECK IF GROUP OR PROJECT EXIST
check=$(curl -s --header "PRIVATE-TOKEN: ${PARAM['token']}" ${PARAM['url']}/api/v${PARAM['api-version']}/${TYPE}/${ID})
message=$(jq -n "${check}" |jq --raw-output .message )
if [[ ${message} != "null" ]];then
    echo ${message}
    exit 1
fi

## EXPORT
if [[ ${PARAM['export']} || ${PARAM['remove-all']} ]];then
    echo -e "export : ${PARAM['output']}"
    > tmp_${PARAM['output']}

    X_TOTAL_PAGE=$(curl -s --header "PRIVATE-TOKEN: ${PARAM['token']}" --head ${PARAM['url']}/api/v${PARAM['api-version']}/${TYPE}/${ID}/variables | awk -v FS=": " 'BEGIN{RS="\r\n";} /^x-total-pages/{print $2}')

    for p in $(seq $X_TOTAL_PAGE)
    do
        curl -s --header "PRIVATE-TOKEN: ${PARAM['token']}" ${PARAM['url']}/api/v${PARAM['api-version']}/${TYPE}/${ID}/variables?page=${p} | yq eval -P >> tmp_${PARAM['output']}
    done

    cat tmp_${PARAM['output']} | yq 'sort_by(.environment_scope)' > ${PARAM['output']}
    rm tmp_${PARAM['output']}
fi

## REMOVE ALL VARIABLES
if [[ ${PARAM['remove-all']} ]];then
    echo -e "remove all : \n"
    TMP_JSON=/tmp/var_${ID}_rm.json
    cat ${PARAM['output']} | yq eval -o=json > ${TMP_JSON}

    jq -c '.[]' ${TMP_JSON} | while read i; do
        echo -e "\n------------------------------------------------------------------------------"
        key=$(jq -n "${i}" |jq --raw-output .key )
        env=$(jq -n "${i}" |jq --raw-output .environment_scope )
        delete_var=$(curl -s --request DELETE "${PARAM['url']}/api/v${PARAM['api-version']}/${TYPE}/${ID}/variables/${key}?filter%5Benvironment_scope%5D=${env}" \
        --header "PRIVATE-TOKEN: ${PARAM['token']}" \
        --header "Content-Type: application/json" --data-raw "${i}")
        echo "Remove variable ${key} - environment ${env} "
        echo ${delete_var}
    done

    rm -f ${TMP_JSON}
fi

## IMPORT
if [[ ${PARAM['input']} ]];then
    echo -e "import : ${PARAM['input']} \n"
    VAR_ALREADY_EXIST_STR="has already been taken"
    TMP_JSON="/tmp/var_${ID}.json"
    cat ${PARAM['input']} | yq eval -o=json > ${TMP_JSON}

    jq -c '.[]' ${TMP_JSON} | while read i; do
        post_var=$(curl -s --request POST ${PARAM['url']}/api/v${PARAM['api-version']}/${TYPE}/${ID}/variables \
        --header "PRIVATE-TOKEN: ${PARAM['token']}" \
        --header "Content-Type: application/json" --data-raw "${i}")
        echo -e "\n------------------------------------------------------------------------------"
        key=$(jq -n "${i}" |jq --raw-output .key )
        env=$(jq -n "${i}" |jq --raw-output .environment_scope )
        if [[ $post_var == *"$VAR_ALREADY_EXIST_STR"* ]];
        then
            echo "Update variable ${key} - environment ${env} "
            put_var=$(curl -s --request PUT "${PARAM['url']}/api/v${PARAM['api-version']}/${TYPE}/${ID}/variables/${key}?filter%5Benvironment_scope%5D=${env}" \
            --header "PRIVATE-TOKEN: ${PARAM['token']}" \
            --header "Content-Type: application/json" --data-raw "${i}")
            echo ${put_var} | yq eval -P
        else
            echo "Add variable ${key} - environment ${env} "
            echo ${post_var} 
        fi
    done

    rm -f ${TMP_JSON}
fi