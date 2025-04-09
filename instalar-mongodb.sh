#!/bin/bash
#Actividad 2 Sebastian Veloza
set -e

logger "Inicio de instalación y configuración de MongoDB"

USO="Uso: install.sh -f <config_file>
Ejemplo:
install.sh -f config.ini
Opciones:
-f archivo de configuración (obligatorio)
-a muestra esta ayuda
"

function ayuda() {
    echo "${USO}"
    if [[ ${1} ]]; then
        echo "${1}"
    fi
    exit 1
}

# Procesar argumentos
while getopts ":f:a" OPCION; do
    case ${OPCION} in
    f) CONFIG_FILE=${OPTARG} ;;
    a) ayuda ;;
    :) ayuda "Falta el argumento para -$OPTARG" ;;
    \?) ayuda "Opción no válida: $OPTARG" ;;
    esac
done

if [[ -z ${CONFIG_FILE} ]]; then
    ayuda "Debe especificar un archivo de configuración con -f"
fi

# Leer archivo de configuración
if [[ ! -f ${CONFIG_FILE} ]]; then
    echo "Error: El archivo ${CONFIG_FILE} no existe."
    exit 1
fi

source <(awk -F= '{print $1"=\""$2"\""}' ${CONFIG_FILE})

if [[ -z ${user} || -z ${password} ]]; then
    echo "Error: El archivo de configuración debe incluir 'user' y 'password'."
    exit 1
fi

if [[ -z ${port} ]]; then
    port=27017
fi

logger "Configuración cargada: usuario=${user}, puerto=${port}"

# Preparar repositorio de MongoDB
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 4B7C549A058F8B6B
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | tee /etc/apt/sources.list.d/mongodb.list

if [[ -z "$(mongo --version 2>/dev/null | grep '4.2.1')" ]]; then
    apt-get -y update
    apt-get install -y \
        mongodb-org=4.2.1 \
        mongodb-org-server=4.2.1 \
        mongodb-org-shell=4.2.1 \
        mongodb-org-mongos=4.2.1 \
        mongodb-org-tools=4.2.1
fi

# Crear directorios
mkdir -p /datos/{bd,log}
chown mongodb:mongodb /datos/{bd,log}

# Configurar MongoDB
cat <<MONGOD_CONF > /etc/mongod.conf
systemLog:
   destination: file
   path: /datos/log/mongod.log
   logAppend: true
storage:
   dbPath: /datos/bd
   engine: wiredTiger
   journal:
      enabled: true
net:
   port: ${port}
security:
   authorization: enabled
MONGOD_CONF

# Reiniciar servicio
systemctl enable mongod
systemctl restart mongod

# Comprobar estado del servicio
for i in {1..10}; do
    if systemctl is-active --quiet mongod; then
        logger "MongoDB arrancó correctamente."
        break
    fi
    sleep 1
done

if ! systemctl is-active --quiet mongod; then
    echo "Error: MongoDB no arrancó correctamente."
    exit 1
fi

# Crear usuario en MongoDB
mongo admin <<CREACION_DE_USUARIO
db.createUser({
    user: "${user}",
    pwd: "${password}",
    roles: [
        { role: "root", db: "admin" },
        { role: "restore", db: "admin" }
    ]
})
CREACION_DE_USUARIO

logger "Usuario ${user} creado con éxito."
