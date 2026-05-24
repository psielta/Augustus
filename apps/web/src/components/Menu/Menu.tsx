import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";

// Interface para itens do menu
interface MenuItem {
  id: string;
  name: string;
  icon: string;
  url?: string;
  expanded?: boolean;
  children?: MenuItem[];
}

interface MenuProps {
  onClose: () => void;
}

const Menu: React.FC<MenuProps> = ({ onClose }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const [itemAtivo, setItemAtivo] = useState<string | null>(null);

  // Estado inicial dos itens do menu
  const [menuItems, setMenuItems] = useState<MenuItem[]>([
    {
      id: "home",
      name: "Início",
      icon: "fas fa-home",
      url: "/",
    },
    {
      id: "form",
      name: "Formulário",
      icon: "fas fa-check-circle",
      url: "/formulario",
    },
    {
      id: "cores",
      name: "Cores",
      icon: "fas fa-palette",
      url: "/cores",
    },
  ]);

  // Função para encontrar o item ativo baseado na URL atual
  const findActiveItemByUrl = (url: string): string | null => {
    // Procura primeiro nos itens principais
    for (const item of menuItems) {
      if (item.url === url) {
        return item.id;
      }
      // Se tiver filhos, procura neles também
      if (item.children) {
        for (const child of item.children) {
          if (child.url === url) {
            return child.id;
          }
          // Se tiver subfilhos, procura neles também
          if (child.children) {
            for (const sub of child.children) {
              if (sub.url === url) {
                return sub.id;
              }
            }
          }
        }
      }
    }
    return null;
  };

  // useEffect para detectar mudanças na URL e atualizar o item ativo
  useEffect(() => {
    const activeItemId = findActiveItemByUrl(location.pathname);
    setItemAtivo(activeItemId);
  }, [location.pathname, menuItems]);

  // Alternar a visibilidade da pasta
  const toggleFolder = (id: string) => {
    setMenuItems(
      menuItems.map((item) => ({
        ...item,
        expanded: item.id === id ? !item.expanded : false,
      }))
    );
  };

  // Navegar para a URL (o item ativo será definido automaticamente pelo useEffect)
  const navigateTo = (url: string) => {
    navigate(url);
    // So fecha o drawer em mobile (overlay) — em desktop a sidebar push
    // fica permanentemente aberta conforme a preferencia salva, e seria
    // anti-UX fecha-la a cada navegacao.
    try {
      if (window.matchMedia("(max-width: 768px)").matches) {
        onClose();
      }
    } catch {
      // sem matchMedia (raro): conservador, nao fecha
    }
  };

  // Lidar com eventos de teclado para acessibilidade
  const handleKeyDown = (
    e: React.KeyboardEvent<HTMLAnchorElement>,
    callback: () => void
  ) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      callback();
    }
  };

  return (
    <div
      className="br-menu push active"
      id="main-navigation"
      style={{ width: "250px" }}
      role="navigation"
      aria-label="Menu principal"
    >
      <div className="menu-container">
        <div className="menu-panel">
          <div className="menu-header" data-visible="false">
            <div className="menu-title">
              <img
                src="/brand/augustus-symbol.svg"
                alt="Augustus - Controlador de finanças pessoais"
              />
              <span>Augustus</span>
            </div>
            <div className="menu-close">
              <button
                className="br-button circle"
                type="button"
                aria-label="Fechar o menu lateral"
                onClick={onClose}
              >
                <i className="fas fa-times" aria-hidden="true"></i>
              </button>
            </div>
          </div>
          <div className="menu-body" role="tree">
            {/* Renderizando cada seção (pasta ou item simples) */}
            {menuItems.map((folder) => (
              <div
                key={folder.id}
                className={`menu-folder drop-menu ${
                  folder.expanded ? "active" : ""
                }`}
              >
                {/* Item sem submenu */}
                {!folder.children || folder.children.length === 0 ? (
                  <a
                    href="#"
                    className={`menu-item ${
                      itemAtivo === folder.id && !folder.expanded
                        ? "active"
                        : ""
                    }`}
                    role="treeitem"
                    tabIndex={0}
                    aria-level={1}
                    aria-current={itemAtivo === folder.id ? "true" : undefined}
                    onClick={(e) => {
                      e.preventDefault();
                      if (folder.url) navigateTo(folder.url);
                    }}
                    onKeyDown={(e) => {
                      handleKeyDown(e, () => {
                        if (folder.url) navigateTo(folder.url);
                      });
                    }}
                  >
                    <span className="icon">
                      <i className={folder.icon} aria-hidden="true"></i>
                    </span>
                    <span className="content">{folder.name}</span>
                  </a>
                ) : (
                  // Item com submenu (pasta)
                  <>
                    <a
                      href="#"
                      className={`menu-item ${
                        itemAtivo === folder.id && !folder.expanded
                          ? "active"
                          : ""
                      }`}
                      role="treeitem"
                      tabIndex={0}
                      aria-expanded={folder.expanded ? "true" : "false"}
                      aria-level={1}
                      onClick={(e) => {
                        e.preventDefault();
                        toggleFolder(folder.id);
                      }}
                      onKeyDown={(e) => {
                        handleKeyDown(e, () => toggleFolder(folder.id));
                      }}
                    >
                      <span className="icon">
                        <i className={folder.icon} aria-hidden="true"></i>
                      </span>
                      <span className="content">{folder.name}</span>
                      <span className="support">
                        <i
                          className="fas fa-chevron-down"
                          aria-hidden="true"
                        ></i>
                      </span>
                    </a>

                    <ul
                      className={`list-hide ${folder.expanded ? "show" : ""}`}
                      role="group"
                      aria-hidden={!folder.expanded}
                      style={{ display: folder.expanded ? "block" : "none" }}
                    >
                      {folder.children.map((child) => (
                        <li key={child.id}>
                          <a
                            href="#"
                            className={`menu-item ${
                              itemAtivo === child.id ? "active" : ""
                            }`}
                            role="treeitem"
                            tabIndex={0}
                            aria-level={2}
                            aria-current={
                              itemAtivo === child.id ? "true" : undefined
                            }
                            onClick={(e) => {
                              e.preventDefault();
                              if (child.url) navigateTo(child.url);
                            }}
                            onKeyDown={(e) => {
                              handleKeyDown(e, () => {
                                if (child.url) navigateTo(child.url);
                              });
                            }}
                          >
                            <span className="icon">
                              <i className={child.icon} aria-hidden="true"></i>
                            </span>
                            <span className="content">{child.name}</span>
                          </a>

                          {/* Subitens (terceiro nível) */}
                          {child.children && (
                            <ul role="group">
                              {child.children.map((sub) => (
                                <li key={sub.id}>
                                  <a
                                    href="#"
                                    className={`menu-item ${
                                      itemAtivo === sub.id ? "active" : ""
                                    }`}
                                    role="treeitem"
                                    tabIndex={0}
                                    aria-level={3}
                                    aria-current={
                                      itemAtivo === sub.id ? "true" : undefined
                                    }
                                    onClick={(e) => {
                                      e.preventDefault();
                                      if (sub.url) navigateTo(sub.url);
                                    }}
                                    onKeyDown={(e) => {
                                      handleKeyDown(e, () => {
                                        if (sub.url) navigateTo(sub.url);
                                      });
                                    }}
                                  >
                                    <span className="icon">
                                      <i
                                        className={sub.icon}
                                        aria-hidden="true"
                                      ></i>
                                    </span>
                                    <span className="content">{sub.name}</span>
                                  </a>
                                </li>
                              ))}
                            </ul>
                          )}
                        </li>
                      ))}
                    </ul>
                  </>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Menu;
