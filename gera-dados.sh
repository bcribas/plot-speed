#!/bin/bash
#This file is part of plot-speed.
#
#Foobar is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 2 of the License.
#
#Foobar is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Foobar.  If not, see <http://www.gnu.org/licenses/>

exec > /dev/null

for dep in speedtest-cli gnuplot awk bash; do
  if ! which $dep &>/dev/null; then
    echo "Faltando: '$dep'" >&2
    exit 1
  fi
done

AGORA=$(date +%s)
MES=$(date +"%Y-%m")
DIA=$(date +"%d")
TEMP=$(mktemp)

#AGORA="$(date +"%m/%d/%y %H:%M:%S")"
declare -A mapaD
declare -A mapaU

ORDEMBR="$(printf "11245 Maravilha\n942 COPEL\n1201 RNP-SC\n3123 RNP-ES\n10559 Speedtest-SP")"
ORDEMGR="$(printf "1779 Miami-COMCAST\n10390 Speedtest-NY\n10392 Speedtest-LA")"
ORDEM="$(printf "$ORDEMBR\n$ORDEMGR")"
ORDEMFULLDATA="$(printf "$ORDEMBR\n$ORDEMGR\n1 BR\n2 GR")"
while read ID NOME; do
  echo "$NOME ::: $(date)"
  DOWN='-'
  UP='-'
  TRY=0
  while [[ "$DOWN" == "-" ]] || [[ "$UP" == "-" ]]; do
    speedtest-cli --server $ID |egrep '^(Download|Upload): '|
      awk '{print $(NF-1)}'| tr '\n' ' ' > $TEMP
    read DOWN UP < $TEMP
    if [[ "x$DOWN" == "x" ]]; then
      DOWN='-'
    fi
    if [[ "x$UP" == "x" ]]; then
      UP='-'
    fi
  done
  echo "$DOWN $UP"
  mkdir -p results/$NOME/$MES
  printf "$AGORA $DOWN $UP\n" >> results/$NOME/$MES/$DIA.data
  if grep -q "$NOME" <<< "$ORDEMBR"; then
    mkdir -p results/BR/$MES
    printf "$AGORA $DOWN $UP\n" >> results/BR/$MES/$DIA.data
  else
    mkdir -p results/GR/$MES
    printf "$AGORA $DOWN $UP\n" >> results/GR/$MES/$DIA.data
  fi
done <<< "$ORDEM"

mkdir -p pagina/{MD,MM}

if (( $(date +%k) == 0 )); then
  mkdir -p results/BR results/GR
  cd results && bash ../gera-medias
  cd ..
  while read ID NOME; do
    cat results/$NOME/*/*mdata > pagina/MD/$NOME-MD.data
    cat results/$NOME/*.mdata > pagina/MM/$NOME-MM.data
  done <<< "$ORDEMFULLDATA"
  cd pagina/MD && bash ../../plot-MD
  cd ../..
  cd pagina/MM && bash ../../plot-MM
  cd ../..
  cd pagina
  rsync -aHx --delete-during ./ trinium.naquadah.com.br:/home/html/ribas/plot/
  cd ..
fi

rm -f $TEMP
