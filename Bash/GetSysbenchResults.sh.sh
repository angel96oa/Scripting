#!/bin/bash

# Guardar resultados en un archivo
kubectl get pods | tee salida.txt

# Miro los que estan completos y los añado
awk '$3=="Completed" {print $1}' salida.txt >> salida1.txt
rm salida.txt

# Cuento los que hay
tambucle=$(cat salida1.txt | wc -l)

# Genero un bucle con tantas iteraciones como lineas tenga salida1.txt,
# cojo la primera linea que es el nombre de pod, compruebo su log y guardo
# el resultado en un archivo. Borro esa primera linea y vuelvo al
# principio del bucle otra vez
for (( c=0; c<tambucle; c++ )); do
        variable=$(head -1 salida1.txt) # Cogemos la primera linea del archivo que contiene los pods que han sido completados
        echo $variable >> resultado.txt
        kubectl logs $variable >> resultado.txt # guardamos la salida en el archivo resultado.txt
        kubectl describe pod $variable >> variable.txt
	kubectl delete pod $variable
        awk '$1=="Node:" {print}' variable.txt >> resultado.txt # Guardamos en que nodo estaba el pod actual
        rm variable.txt
        tail -n +2 salida1.txt >> salidaAux.txt # borramos la primera linea
        rm salida1.txt
        cat salidaAux.txt >> salida1.txt
        rm salidaAux.txt
        echo "-----" >> resultado.txt
done

# Buscamos las lineas que indican el nodo, el nombre del pod y su tiempo
grep -i -E "Node:|sysbench-|total time:" resultado.txt >> resultados1.txt
awk '{if($1 ~ /s[sysbench-]/){print $1;}if($1=="total"){print $3;}if($1=="Node:"){print $2;}}' resultados1.txt >> resultados.txt
rm resultado.txt resultados1.txt salida1.txt

#Arreglamos el archivo para obtener un archivo csv
sed -e 's/s$//' resultados.txt >> resultados1.txt #Quitamos la s de los tiempo

echo "Nombre;Tiempo;Nodo" >> resultados.csv

tam=$(cat resultados1.txt | wc -l)

while [ $tam -gt 0 ]
do
        parte1=$(sed -n '1p' resultados1.txt)
        parte2=$(sed -n '2p' resultados1.txt)
        parte3=$(sed -n '3p' resultados1.txt)
        parte="${parte1};${parte2};${parte3}"
        echo $parte >> resultados.csv

        for i in 1 2 3
        do
                sed -i -e "1d" resultados1.txt
        done

        tam=$(cat resultados1.txt | wc -l)

done

echo " " >> resultados.csv

rm resultados1.txt resultados.txt
