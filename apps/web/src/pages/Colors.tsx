import { BrIcon, BrInput, BrMessage } from "@govbr-ds/webcomponents-react";
import React, { useMemo, useState } from "react";
import styles from "./Colors.module.css";

import { colors } from "../data/cores";

const Colors: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [clickedCard, setClickedCard] = useState<string | null>(null);
  const [mensagemVisivel, setMensagemVisivel] = useState(false);
  const [mensagemTexto, setMensagemTexto] = useState("");

  const filteredColors = useMemo(() => {
    const term = searchTerm.toLowerCase();
    return colors.filter(
      (color) =>
        !term ||
        color.nome.toLowerCase().includes(term) ||
        color.hex.toLowerCase().includes(term) ||
        (color.token?.toLowerCase().includes(term) ?? false)
    );
  }, [searchTerm]);

  function handleCardClick(color: {
    nome: string;
    hex: string;
    token?: string;
  }) {
    setClickedCard(color.nome);
    const texto = `Nome: ${color.nome}\nHexadecimal: ${color.hex}\nToken: ${
      color.token ?? "N/A"
    }`;
    navigator.clipboard
      .writeText(texto)
      .then(() => {
        setMensagemTexto(`Cor copiada com sucesso!\n${texto}`);
        setMensagemVisivel(true);
      })
      .catch(() => {
        setMensagemTexto("Erro ao copiar a cor. Por favor, tente novamente.");
        setMensagemVisivel(true);
      });
    setTimeout(() => setClickedCard(null), 500);
  }

  return (
    <>
      <h1>Cores do Design System</h1>
      <p className={styles.subtitle}>
        Explore nossa paleta de cores e copie os valores facilmente
      </p>

      <div className={styles.controlsContainer}>
        <div className={styles.searchWrapper}>
          <div className={styles.searchInputContainer}>
            <BrInput
              type="text"
              value={searchTerm}
              id="inputButtonRight"
              placeholder="Buscar por nome, hex ou token..."
              onValueChange={(e: CustomEvent<string>) =>
                setSearchTerm(e.detail)
              }
            >
              <BrIcon slot="action" iconName="fa-solid:search" height="16" />
            </BrInput>

            {!searchTerm && (
              <p>Total de cores na paleta: {filteredColors.length}</p>
            )}
            {searchTerm && filteredColors.length > 0 && (
              <p>
                Total de cores encontradas na busca: {filteredColors.length}
              </p>
            )}
          </div>
        </div>
      </div>

      {mensagemVisivel && (
        <BrMessage
          state="info"
          message={mensagemTexto}
          isInline
          isClosable
          showIcon
          // ariaLabel="info: Cor copiada com sucesso"
          onClick={() => setMensagemVisivel(false)}
        />
      )}
      {searchTerm && filteredColors.length === 0 && (
        <BrMessage
          state="warning"
          message={`Nenhuma cor encontrada para a busca: "${searchTerm}"`}
          isInline
          showIcon
          // ariaLabel={`aviso: sem resultados`}
        />
      )}

      <div className={styles.colorsGrid} role="grid">
        {filteredColors.map((color) => (
          <div
            key={color.nome}
            className={`${styles.colorCard} ${
              clickedCard === color.nome ? styles.cardClicked : ""
            }`}
            style={{ backgroundColor: color.hex }}
            role="gridcell"
            tabIndex={0}
            onClick={() => handleCardClick(color)}
            onKeyPress={(e) => e.key === "Enter" && handleCardClick(color)}
            aria-label={`Cor ${color.nome}. Pressione Enter para copiar`}
          >
            <div
              className={styles.colorPreview}
              style={{ backgroundColor: color.hex }}
            />
            <div className={styles.colorInfo}>
              <h3>{color.nome}</h3>
              <p className="hex-value">{color.hex}</p>
              <p className="token-value">{color.token}</p>
              <span className={styles.copyHint}>Clique para copiar</span>
            </div>
          </div>
        ))}
      </div>
    </>
  );
};

export default Colors;
