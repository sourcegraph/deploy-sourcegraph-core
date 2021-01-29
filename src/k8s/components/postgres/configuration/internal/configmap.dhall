let configmap =
      { namespace : Optional Text, data : { `postgresql.conf` : Text } }

in  configmap
