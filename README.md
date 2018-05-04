# README

*plot-speed* é uma ferramenta simples que escrevi para medir o desempenho
da internet de casa de perceber desempenho ruins em conteúdos de streaming,
como youtube e netflix.

Esta ferramenta não está otimizada, não está configurável. *plot_speed* é
distribuído como está e sem garantias.

## Dependências

- speedtest-cli
- gnuplot
- rsync
- bash
- awk

## Uso

Para utilizar entre no diretório do plot speed e execute o comando
```
bash gera-dados.sh
```

Exemplo para o seu crontab:
```
0 */2 * * * cd plot-speed && bash gera-dados.sh
```

## Em execução

As minhas coletas estão disponibilizadas no link
<http://www.naquadah.com.br/~ribas/plot/>
