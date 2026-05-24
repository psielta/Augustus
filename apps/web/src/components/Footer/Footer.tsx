import {
  BrFooter,
  BrFooterCategory,
  BrFooterItem,
  BrFooterLegal,
  BrFooterLogo,
  BrFooterSocial,
} from "@govbr-ds/webcomponents-react";
import React from "react";

interface FooterItem {
  text: string;
  href: string;
}

interface FooterCategory {
  label: string;
  items: FooterItem[];
}

interface SocialLink {
  icon: string;
  description: string;
  href: string;
}

interface PartnerLogo {
  src: string;
  description: string;
}

interface FooterProps {
  theme?: "light" | "dark";
  mainLogo?: { url: string; description: string };
  categories?: FooterCategory[];
  socialLinks?: SocialLink[];
  partnerLogos?: PartnerLogo[];
  licenseText?: string;
}

const ANO_ATUAL = new Date().getFullYear();

// Footer com `theme="dark"` por padrao para criar contraste visual com
// o conteudo (sempre em superficie clara). Isso NAO e dark mode global:
// e so a faixa inferior que ganha fundo escuro, padrao comum em layouts
// admin (Bootstrap docs, GitHub etc.). Light mode do produto continua
// valendo para todo o resto.
const Footer: React.FC<FooterProps> = ({
  theme = "dark",
  mainLogo = {
    url: "/brand/augustus-symbol.svg",
    description: "Augustus - Controlador de finanças pessoais",
  },
  categories = [],
  socialLinks = [],
  partnerLogos = [],
  licenseText = `© ${ANO_ATUAL} Augustus - Controlador de finanças pessoais.`,
}) => {
  return (
    <div className="d-flex flex-wrap justify-content-evenly mt-5">
      <BrFooter theme={theme}>
        <BrFooterLogo
          slot="logo"
          src={mainLogo.url}
          description={mainLogo.description}
        ></BrFooterLogo>

        {categories.map((category, cIdx) => (
          <BrFooterCategory label={category.label} key={cIdx}>
            {category.items.map((item, iIdx) => (
              <BrFooterItem href={item.href} key={iIdx}>
                {item.text}
              </BrFooterItem>
            ))}
          </BrFooterCategory>
        ))}

        {socialLinks.map((social, sIdx) => (
          <BrFooterSocial
            slot="social-network"
            href={social.href}
            icon={social.icon}
            description={social.description}
            key={sIdx}
          ></BrFooterSocial>
        ))}

        {partnerLogos.map((logoObj, pIdx) => (
          <BrFooterLogo
            slot="partner-logo"
            is-partner
            src={logoObj.src}
            description={logoObj.description}
            key={pIdx}
          ></BrFooterLogo>
        ))}

        <BrFooterLegal slot="legal">{licenseText}</BrFooterLegal>
      </BrFooter>
    </div>
  );
};

export default Footer;
