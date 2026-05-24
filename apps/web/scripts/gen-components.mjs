#!/usr/bin/env node
import { promises as fs } from "fs";
import path from "path";
import { fileURLToPath } from "url";
import chalk from "chalk";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Lista de componentes a gerar
const COMPONENTS = [
  "Checkgroup",
  "Collapse",
  "Divider",
  "Dropdown",
  "Formulario",
  "Icon",
  "Input",
  "Item",
  "List",
  "Loading",
  "Message",
  "Radio",
  "Select",
  "Switch",
  "Tag",
  "TextArea",
  "Upload",
];

// Caminho do template
const TEMPLATE_DIR = path.resolve(__dirname, "../src/pages/components/Avatar");
const OUT_DIR_BASE = path.resolve(__dirname, "../src/pages/components");

/**
 * Converte PascalCase em kebab-case
 */
function toKebab(str) {
  return str.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase();
}

async function loadTemplate(filename) {
  const filePath = path.join(TEMPLATE_DIR, filename);
  try {
    return await fs.readFile(filePath, "utf8");
  } catch (err) {
    console.error(chalk.red(`Falha ao ler template ${filename}:`), err.message);
    process.exit(1);
  }
}

async function generateComponent(name, tsxTpl, cssTpl) {
  const dir = path.join(OUT_DIR_BASE, name);
  await fs.mkdir(dir, { recursive: true });

  const pascal = name;
  const kebab = toKebab(name);

  // TSX: trocar Avatar/ avatar pelos nomes correspondentes
  const tsx = tsxTpl.replaceAll("Avatar", pascal).replaceAll("avatar", kebab);

  // CSS: trocar .avatar e Avatar
  const css = cssTpl
    .replaceAll(".avatar", `.${kebab}`)
    .replaceAll("Avatar", pascal);

  await Promise.all([
    fs.writeFile(path.join(dir, `${pascal}.tsx`), tsx, "utf8"),
    fs.writeFile(path.join(dir, `${pascal}.css`), css, "utf8"),
  ]);

  console.log(chalk.green(`✓ Componente ${pascal} gerado em ${dir}`));
}

async function main() {
  console.log(chalk.blue("Gerando componentes a partir do template Avatar..."));

  const [tsxTpl, cssTpl] = await Promise.all([
    loadTemplate("Avatar.tsx"),
    loadTemplate("Avatar.css"),
  ]);

  for (const name of COMPONENTS) {
    await generateComponent(name, tsxTpl, cssTpl);
  }

  console.log(chalk.blue("Todos os componentes foram gerados com sucesso!"));
}

main().catch((err) => {
  console.error(chalk.red("Erro inesperado:"), err);
  process.exit(1);
});
