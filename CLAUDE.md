# CLAUDE.md

## Busca: use o qmd PRIMEIRO (MCP)

Antes de qualquer busca por código ou conteúdo neste repositório — "onde está X",
grep, leitura exploratória de arquivos — **consulte primeiro o MCP do qmd**.
Este projeto está indexado na collection **`palWorld_friendFinder`** do qmd; usar a
busca indexada economiza tempo e tokens.

- Ferramenta: MCP `qmd` → `query` com `collections: ["palWorld_friendFinder"]`.
- Combine `lex` (palavra-chave exata) + `vec` (semântica) e sempre informe `intent`.
- Recupere arquivos com `get` / `multi_get` (caminhos relativos à collection).
- Só caia para grep/leitura direta de arquivos se o qmd não trouxer o necessário.

Exemplo:

```
query:
  searches=[{type:'lex', query:'install bat'},
            {type:'vec', query:'instalador e script lua do mod'}]
  collections=['palWorld_friendFinder']
  intent='passos do instalador e versão atualizada do mod'
```

## Sobre o projeto

Repositório irmão/variante do mod **FriendFinder** para Palworld (Lua/UE4SS):
instalador, README e versão atualizada do mod de marcadores de aliados na bússola.
Mesma finalidade do repo `friendFinder`.
