# Identidade visual

Assets oficiais do Augustus - Controlador de finanças pessoais.

## Arquivos canônicos

- `augustus-logo.svg`: logo completa, com símbolo, wordmark e subtítulo.
- `augustus-symbol.svg`: variante compacta do símbolo, indicada para favicon, launcher icon, splash ou avatar de app.

Os arquivos canônicos têm fundo branco incorporado. Não tratar a logo como asset transparente.

## Uso na documentação

O `README.md` da raiz deve usar o arquivo canônico:

```md
<p align="center">
  <img src="docs/assets/brand/augustus-logo.svg" alt="Augustus - Controlador de finanças pessoais" width="360">
</p>
```

## Uso futuro no web

Quando a identidade for aplicada no React, copie ou sincronize os arquivos para:

```txt
apps/web/src/assets/brand/augustus-logo.svg
apps/web/src/assets/brand/augustus-symbol.svg
```

Use o SVG completo em telas institucionais, cabeçalhos ou páginas de entrada. Use o símbolo para favicon ou pontos compactos de navegação.

## Uso futuro no mobile

Quando a identidade for aplicada no Flutter, copie ou sincronize os arquivos para:

```txt
apps/mobile/assets/images/brand/augustus-logo.svg
apps/mobile/assets/images/brand/augustus-symbol.svg
```

Depois registre a pasta no `apps/mobile/pubspec.yaml`, caso ela ainda não esteja incluída:

```yaml
flutter:
  assets:
    - assets/images/brand/
```

Para launcher icon, prefira gerar uma arte quadrada a partir de `augustus-symbol.svg`, sem o texto da marca.

## Regras de uso

- Não distorcer proporção.
- A logo oficial tem fundo branco; usar preferencialmente sobre superfícies claras.
- Não remover o fundo branco sem criar e documentar uma variante específica.
- Não recriar a logo em cada aplicação; a fonte canônica fica nesta pasta.
- Se houver uma versão original em PNG ou SVG entregue pelo designer, salvar aqui como `augustus-logo-original.*` e atualizar esta documentação.
