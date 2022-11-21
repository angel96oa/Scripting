#!/bin/bash

# $1 es el archivo yaml del despliegue, $2 la cantidad de replicas que queremos, $3 es el numero primo a calcular
echo "despliegue: $1"
echo "cantidad de pods: $2"
echo "numero primo: $3"
echo "valor de sleep: $4"

# Hacemos una copia del ejecutable inicial para no modificarlo
cp $1 copia.yaml
# Sustituimos la x en los lugares clave para que podamos tener varios despliegues distintos
for ((i = 0 ; i < $2 ; i++)); do
	# Cogemos el la hora a la que se empieza a ejecutar el pod
	echo $(date +%T) >> fecha
	sed -i 's/:/-/g' fecha
	tiempo=$(cat fecha)
	rm fecha

	# Adecuamos el fichero a desplegar
        sed -i 's/q/'$3'/g' copia.yaml
	sed -i 's/tiempo/'$tiempo'/g' copia.yaml
        sed -i 's/sleep/'$4'/g' copia.yaml

	# Ejecutamos el despliegue
	kubectl apply -f copia.yaml
        sed -i 's/'$3'/q/g' copia.yaml
	sed -i 's/'$tiempo'/tiempo/g' copia.yaml
        sed -i 's/'$4'/sleep/g' copia.yaml
	sleep $4
done

rm copia.yaml
