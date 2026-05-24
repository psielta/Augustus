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

const Menu: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [itemAtivo, setItemAtivo] = useState<string | null>(null);

  // Estado inicial dos itens do menu
  const [menuItems, setMenuItems] = useState<MenuItem[]>([
    {
      id: "home",
      name: "Home",
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
    >
      <div className="menu-container">
        <div className="menu-panel">
          <div className="menu-header" data-visible="false">
            <div className="menu-title">
              <img
                src="data:image/png;base64,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"
                alt="Imagem ilustrativa"
              />
              <span>Identificação do site ou Sistema</span>
            </div>
            <div className="menu-close">
              <button
                className="br-button circle"
                type="button"
                aria-label="Fechar o menu"
                data-dismiss="menu"
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
