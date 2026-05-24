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

const Footer: React.FC<FooterProps> = ({
  theme = "dark",
  mainLogo = {
    url: "/img-template-negative.png",
    description: "Logo do Site",
  },
  categories = [
    {
      label: "Categoria 1",
      items: [
        { text: "Qui esse", href: "javascript:void(0)" },
        {
          text: "Adipisicing culpa et ad consequat",
          href: "javascript:void(0)",
        },
        {
          text: "Adipisicing culpa et ad consequat",
          href: "javascript:void(0)",
        },
        { text: "Deserunt", href: "javascript:void(0)" },
      ],
    },
    {
      label: "Categoria 2",
      items: [
        {
          text: "Adipisicing culpa et ad consequat",
          href: "javascript:void(0)",
        },
        { text: "Est ex deserunt", href: "javascript:void(0)" },
        { text: "Duis incididunt consectetur", href: "javascript:void(0)" },
      ],
    },
    {
      label: "Categoria 3",
      items: [
        {
          text: "Adipisicing culpa et ad consequat",
          href: "javascript:void(0)",
        },
        { text: "Qui esse", href: "javascript:void(0)" },
      ],
    },
    {
      label: "Categoria 4",
      items: [
        { text: "Deserunt", href: "javascript:void(0)" },
        { text: "Ad deserunt nostrud", href: "javascript:void(0)" },
        { text: "Est ex deserunt", href: "javascript:void(0)" },
      ],
    },
    {
      label: "Categoria 5",
      items: [
        { text: "Duis incididunt consectetur", href: "javascript:void(0)" },
        { text: "Qui esse", href: "javascript:void(0)" },
        {
          text: "Ex qui laborum consectetur aute commodo",
          href: "javascript:void(0)",
        },
        { text: "Est ex deserunt", href: "javascript:void(0)" },
      ],
    },
    {
      label: "Categoria 6",
      items: [
        {
          text: "Ex qui laborum consectetur aute commodo",
          href: "javascript:void(0)",
        },
        { text: "Duis incididunt consectetur", href: "javascript:void(0)" },
        { text: "Deserunt", href: "javascript:void(0)" },
      ],
    },
  ],
  socialLinks = [
    { icon: "facebook-f", description: "Facebook", href: "javascript:void(0)" },
    { icon: "twitter", description: "Twitter", href: "javascript:void(0)" },
    {
      icon: "linkedin-in",
      description: "Linkedin",
      href: "javascript:void(0)",
    },
    { icon: "whatsapp", description: "Whatsapp", href: "javascript:void(0)" },
  ],
  partnerLogos = [
    {
      src: "/img-template-negative.png",
      description: "Imagem",
    },
    {
      src: "/img-template-negative.png",
      description: "Imagem",
    },
  ],
  licenseText = "Texto destinado a exibição das informações relacionadas à <strong>licença de uso.</strong>",
}) => {
  return (
    <div className="d-flex flex-wrap justify-content-evenly mt-5">
      <BrFooter theme={theme}>
        {/* Slot de logo principal */}
        <BrFooterLogo
          slot="logo"
          src={mainLogo.url}
          description={mainLogo.description}
        ></BrFooterLogo>

        {/* Slots de categorias */}
        {categories.map((category, cIdx) => (
          <BrFooterCategory label={category.label} key={cIdx}>
            {category.items.map((item, iIdx) => (
              <BrFooterItem href={item.href} key={iIdx}>
                {item.text}
              </BrFooterItem>
            ))}
          </BrFooterCategory>
        ))}

        {/* Slot de redes sociais */}
        {socialLinks.map((social, sIdx) => (
          <BrFooterSocial
            slot="social-network"
            href={social.href}
            icon={social.icon}
            description={social.description}
            key={sIdx}
          ></BrFooterSocial>
        ))}

        {/* Slot de logos de parceiros */}
        {partnerLogos.map((logoObj, pIdx) => (
          <BrFooterLogo
            slot="partner-logo"
            is-partner
            src={logoObj.src}
            description={logoObj.description}
            key={pIdx}
          ></BrFooterLogo>
        ))}

        {/* Slot de conteúdo legal */}
        <BrFooterLegal slot="legal">
          <div dangerouslySetInnerHTML={{ __html: licenseText }} />
        </BrFooterLegal>
      </BrFooter>
    </div>
  );
};

export default Footer;
