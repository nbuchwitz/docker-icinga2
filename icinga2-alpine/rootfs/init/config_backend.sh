
set +e
set +u

if [[ ! -z "${CONFIG_BACKEND_SERVER}" ]]
then
  if [[ -z "${CONFIG_BACKEND}" ]]
  then
    log_warn "no 'CONFIG_BACKEND' defined"
    return
  fi

  log_info "use '${CONFIG_BACKEND}' as configuration backend"

  if [[ "${CONFIG_BACKEND}" = "consul" ]]
  then
    . /init/config_backend/consul.sh
  elif [[ "${CONFIG_BACKEND}" = "etcd" ]]
  then
    . /init/config_backend/etcd.sh
  fi
fi

set -e
set -u

save_config() {

#  set_var  "root_user" "${MYSQL_SYSTEM_USER}"
#  set_var  "root_password" "${MYSQL_ROOT_PASS}"
#  set_var  "url" ${HOSTNAME}

#  register_node
  set_var  'icinga/version' ${ICINGA2_VERSION}
  set_var  'icinga/cert-service/ba/user'      ${CERT_SERVICE_BA_USER}
  set_var  'icinga/cert-service/ba/password'  ${CERT_SERVICE_BA_PASSWORD}
  set_var  'icinga/cert-service/api/user'     ${CERT_SERVICE_API_USER}
  set_var  'icinga/cert-service/api/password' ${CERT_SERVICE_API_PASSWORD}
  set_var  'icinga/database/ido/user'         'icinga2'
  set_var  'icinga/database/ido/password'     ${IDO_PASSWORD}
  set_var  'icinga/database/ido/schema'       ${IDO_DATABASE_NAME}
  set_var  'icinga/api/users/'                ''

}
#
# save_config() {
#
#   set_var  "type" "${ICINGA2_TYPE}"
#   set_var  "version" "${ICINGA2_VERSION}"
#   set_var  "url" ${HOSTNAME}
# }
