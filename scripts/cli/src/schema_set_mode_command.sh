subject="${args[--subject]}"
mode="${args[--mode]}"

ret=$(get_sr_url_and_security)

sr_url=$(echo "$ret" | cut -d "@" -f 1)
sr_security=$(echo "$ret" | cut -d "@" -f 2)

log "🔏 Set mode for subject ${subject} to $mode"
curl_output=$(curl $sr_security -s -X PUT -H "Content-Type: application/vnd.schemaregistry.v1+json" --data "{\"mode\": \"$mode\"}" "${sr_url}/mode/${subject}" | jq .)
ret=$?
if [ $ret -eq 0 ]
then
    if echo "$curl_output" | jq '. | has("error_code")' 2> /dev/null | grep -q true 
    then
        error_code=$(echo "$curl_output" | jq -r .error_code)
        message=$(echo "$curl_output" | jq -r .message)
        logerror "Command failed with error code $error_code"
        logerror "$message"
        exit 1
    else
        mode=$(echo "$curl_output" | jq -r .mode)
        echo "$mode"
    fi
else
    logerror "❌ curl request failed with error code $ret!"
    exit 1
fi