# winforge — guia do iniciante

[EN](GUIDE.md) | PT-BR

<!--
  Assuma que o leitor não sabe nada. Explique cada termo e aviso em linguagem
  simples. Isto não é referência de comandos (isso é a wiki) nem lista de
  recursos (isso é o README). O GUIDE.md deve permanecer estruturalmente idêntico.
-->

## O que é isto?

Quando você instala o Windows do zero, normalmente passa uma tarde baixando
programas um a um, mudando configurações e desligando coisas. O winforge faz isso
por você: você roda um comando e ele instala um conjunto de programas e aplica um
conjunto de ajustes.

Ele é organizado em **grupos** para você escolher o que quer — por exemplo `base`
(programas do dia a dia, como navegador e player de mídia) ou `shell` (um terminal
melhor). Você nunca precisa rodar tudo.

O ponto importante: o winforge só muda seu sistema quando você manda, ele pode
mostrar o que *faria* sem fazer, e tem um "desfazer" para a parte arriscada. Você
não precisa saber PowerShell para usar.

## Termos-chave

- **PowerShell** — o programa que roda o winforge. O Windows vem com uma versão
  antiga; o winforge precisa da versão 7 (download grátis).
- **Administrador (admin)** — permissão para mudar configurações do sistema.
  Alguns passos (instalar fontes, mudar serviços) precisam dela; o Windows mostra
  um popup pedindo permissão.
- **Grupo** — um pacote nomeado de trabalho. `base`, `dev`, `gaming`, `system`
  instalam programas; `optimize`, `customize`, `shell` mudam configurações;
  `restore` desfaz as mudanças do optimize. Você escolhe um com `-Group`, ou roda
  todos.
- **winget / Chocolatey** — duas "lojas de apps" para a linha de comando. O
  winforge tenta o winget primeiro; se falhar, tenta o Chocolatey; em último caso,
  um link de download direto.
- **Idempotente** — um jeito chique de dizer "seguro rodar de novo". O winforge
  verifica se um programa já está instalado e o pula, então rodar duas vezes não
  causa dano.
- **Registro (Registry)** — o grande banco de configurações do Windows. Muitos
  ajustes são só valores gravados aqui.
- **Serviço** — um programa que o Windows roda em segundo plano. Alguns podem ser
  desligados para poupar recursos; alguns precisam ficar ligados (o winforge não
  mexe mais nesses).
- **Perfil (Profile)** — o quão agressivo o grupo `optimize` é. `safe` (o padrão)
  só faz mudanças reversíveis e de baixo risco. `desktop` adiciona ajustes de
  energia; `gaming` adiciona rede e ajustes mais pesados. Eles se acumulam: gaming
  inclui desktop, que inclui safe.
- **`-WhatIf`** — um botão de "prévia". Adicione-o e o winforge lista o que
  *faria* sem mudar nada.
- **restore** — o desfazer. `-Group restore` devolve os serviços e configurações
  que o grupo `optimize` mudou aos padrões do Windows.
- **VSS / Restauração do Sistema, StorSvc, SmartScreen** — partes do Windows que
  versões antigas do winforge desabilitavam e quebravam (rollback, a Microsoft
  Store e uma checagem de segurança). O winforge não desabilita mais; o `restore`
  pode religá-las se um run antigo as deixou desligadas.

## Lendo a saída

O winforge imprime uma linha com horário para cada passo, com um símbolo que diz
o que aconteceu:

- `[i]` informação — um passo começando ou uma nota.
- `[+]` sucesso — o passo funcionou.
- `[!]` aviso — algo menor deu errado; o winforge continuou.
- `[x]` erro — um passo falhou (o winforge registra e segue para o próximo).
- `[~]` pulado — nada a fazer (ex.: o programa já estava instalado).

Linhas emolduradas em `=====` são cabeçalhos de grupo, marcando qual grupo está
rodando.

## Perguntas comuns

- **Preciso rodar tudo?** Não. Use `-Group <nome>` para rodar só um grupo.
- **É seguro?** O padrão é seguro por design: nunca desabilita a Restauração do
  Sistema, o serviço da Microsoft Store nem o SmartScreen. As mudanças mais
  pesadas são opt-in.
- **Como vejo o que ele vai fazer antes?** Adicione `-WhatIf` — ele prevê tudo e
  não muda nada.
- **Como desfaço?** Rode `.\setup.ps1 -Group restore` (prévia antes com
  `-WhatIf`). Veja [RESTORE.md](RESTORE.md).
- **Nada foi instalado — por quê?** O winforge pula programas que você já tem e
  precisa do `winget`. Se o `winget` estiver faltando, instale o "Instalador de
  Aplicativo" pela Microsoft Store.
- **A Microsoft Store ou a Game Bar quebrou depois de um run antigo.** Um winforge
  antigo desabilitou coisas que não devia. O `-Group restore` conserta isso; veja
  o [FAQ da wiki](https://github.com/gsjonio/winforge/wiki).
- **Onde estão os detalhes?** Referência de comandos e solução de problemas ficam
  na [wiki](https://github.com/gsjonio/winforge/wiki); detalhes por ajuste estão em
  [docs/OPTIMIZE.md](OPTIMIZE.md) e [docs/SERVICES.md](SERVICES.md).
