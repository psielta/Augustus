import React from "react";
import { useAuth } from "../hooks/useAuth";

const Home: React.FC = () => {
  const { isAutenticado, usuario } = useAuth();

  return (
    <section>
      <h1>Augustus</h1>
      <p>
        Bem-vindo ao Augustus, seu controlador de finanças pessoais.
        {isAutenticado && usuario && ` Olá, ${usuario.nome}.`}
      </p>
      <p>
        O dashboard financeiro será incluído em breve. Por enquanto, esta tela
        serve como ponto de entrada da aplicação.
      </p>
    </section>
  );
};

export default Home;
