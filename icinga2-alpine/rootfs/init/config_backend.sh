
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

save_config() {

  set_var  "type" "${ICINGA2_TYPE}"
  set_var  "version" "${ICINGA2_VERSION}"
  set_var  "url" ${HOSTNAME}
}
