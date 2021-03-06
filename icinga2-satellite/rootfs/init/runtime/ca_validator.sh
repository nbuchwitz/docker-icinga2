#!/bin/bash

# periodic check of the (satellite) CA file
# **this use the API from the icinga-cert-service!**
#
# when the CA file are not in  sync, we restart the container to
# getting a new certificate
#
# BE CAREFUL WITH THIS 'FEATURE'!
# IT'S JUST A FIX FOR A FAULTY USE.
#

. /init/output.sh
. /init/environment.sh

. /init/cert/certificate_handler.sh

log_info "start the ca validator for '${HOSTNAME}'"

while true
do
  # check the creation date of our certificate request against the
  # connected endpoints
  # (take a look in the test.sh line 112:125)
  #
  sign_file="${ICINGA2_LIB_DIRECTORY}/backup/sign_${HOSTNAME}.json"

  if [[ -f ${sign_file} ]]
  then
    ICINGA2_API_PORT=${ICINGA2_API_PORT:-5665}
    warn=300  #  5 minuten
    crit=600  # 10 minuten

#    log_debug "icinga2 api user: '${CERT_SERVICE_API_USER}'"
#    log_debug "icinga2 api pass: '${CERT_SERVICE_API_PASSWORD}'"
#    log_debug "icinga2 master  : '${ICINGA2_MASTER}'"
#    log_debug "icinga2 api port: '${ICINGA2_API_PORT}'"

    message=$(jq --raw-output .message ${sign_file} 2> /dev/null)
    master_name=$(jq --raw-output .master_name ${sign_file} 2> /dev/null)
    master_ip=$(jq --raw-output .master_ip ${sign_file} 2> /dev/null)
    date=$(jq --raw-output .date ${sign_file} 2> /dev/null)
    timestamp=$(jq --raw-output .timestamp ${sign_file} 2> /dev/null)

    # timestamp must be in UTC!
    current_timestamp=$(date +%s)
    diff=$(expr ${current_timestamp} - ${timestamp})
    diff_full=$(printf '%dh:%dm:%ds\n' $((${diff}/3600)) $((${diff}%3600/60)) $((${diff}%60)))

#    log_info "${message}"
#    log_debug "  - ${date}"
#    log_debug "  - ${master_name}"
#    log_debug "  - ${master_ip}"
#    log_debug "  - ${timestamp}"
#    log_debug "  - ${current_timestamp}"
#    log_debug "diff: ${diff} seconds  (${diff_full})"
#    log_debug "old: $(date -d @${timestamp})  (${date})"
#    log_debug "new: $(date -d @${current_timestamp})"

    code=$(curl \
      --silent \
      --user ${CERT_SERVICE_API_USER}:${CERT_SERVICE_API_PASSWORD} \
      --header 'Accept: application/json' \
      --insecure \
      https://${ICINGA2_MASTER}:${ICINGA2_API_PORT}/v1/status/ApiListener)

    if [[ $? -eq 0 ]]
    then
      connected=$(echo "${code}" | jq --raw-output '.results[].status.api.conn_endpoints | join(",")' | grep -c ${HOSTNAME})

      if [[ ${connected} -eq 1 ]]
      then
        log_info "We are connected to our Master since ${diff_full} \m/"
      elif [[ ${connected} -eq 0 ]]
      then

        num_endpoints=$(echo "${code}" | jq --raw-output ".results[].status.api.num_endpoints")
        num_conn_endpoints=$(echo "${code}" | jq --raw-output ".results[].status.api.num_conn_endpoints")
        num_not_conn_endpoints=$(echo "${code}" | jq --raw-output ".results[].status.api.num_not_conn_endpoints")
        conn_endpoints=$(echo "${code}" | jq --raw-output '.results[].status.api.conn_endpoints | join(",")')
        not_conn_endpoints=$(echo "${code}" | jq --raw-output '.results[].status.api.not_conn_endpoints | join(",")')

#        log_debug "endpoints summary:"
#        log_debug "totaly: '${num_endpoints}' / connected: '${num_conn_endpoints}' / not connected: '${num_not_conn_endpoints}'"
#        log_debug "i'm connected: ${connected}"
#        log_debug ""
#        log_debug "connected endpoints: "
#        log_debug "${conn_endpoints}"
#        log_debug ""
#        log_debug "not connected endpoints: "
#        log_debug "${not_conn_endpoints}"
#        log_debug ""

        if [[ ${diff} -gt ${warn} ]] && [[ ${diff} -lt ${crit} ]]
        then
          log_warn "Our certificate request is already ${diff_full} old"
          log_warn "and we're not connected to the master yet."
          log_warn "This may be a major problem"
          log_warn "If this problem persists, the satellite will be reset and restarted."

        elif [[ ${diff} -gt ${crit} ]]
        then
          log_error "Our certificate request is already ${diff_full} old"
          log_error "and we're not connected to the master yet."
          log_error "That's a problem"
          log_error "This satellite will be reset and restarted"

set -x
          icinga_pid=$(ps ax | grep icinga2 | grep daemon | grep -v grep | awk '{print $1}')

          [[ $(echo -e "${icinga_pid}" | wc -w) -gt 0 ]] && log_debug "kill ya"

        fi
      else
        # DAS GEHT?
        :
      fi
    fi
  else
    log_error "i can't find the sign file '${sign_file}'"
    log_error "That's a problem"
    log_error "This satellite will be reset and restarted"

set -x
    icinga_pid=$(ps ax | grep icinga2 | grep daemon | grep -v grep | awk '{print $1}')
    [[ -z "${icinga2_pid}" ]] || killall icinga2 > /dev/null 2> /dev/null

    exit 1
  fi

  . /init/wait_for/cert_service.sh
  validate_local_ca

  if [[ ! -f ${ICINGA2_CERT_DIRECTORY}/${HOSTNAME}.key ]]
  then
    log_error "The validation of our CA was not successful."
    log_error "That's a problem"
    log_error "This satellite will be reset and restarted"

set -x
    icinga_pid=$(ps ax | grep icinga2 | grep daemon | grep -v grep | awk '{print $1}')
    [[ -z "${icinga2_pid}" ]] || killall icinga2 > /dev/null 2> /dev/null

    exit 1
  fi

  sleep 5m
done
