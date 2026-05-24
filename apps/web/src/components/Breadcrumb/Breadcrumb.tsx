import React from "react";

import { BrBreadcrumb } from "@govbr-ds/webcomponents-react";

interface Link {
  label: string;
  url: string;
  home?: boolean;
  active?: boolean;
}

interface BreadcrumbProps {
  links?: Link[];
}

const Breadcrumb: React.FC<BreadcrumbProps> = ({
  links = [
    {
      label: "Augustus",
      url: "/",
      active: true,
    },
  ],
}) => {
  if (links.length <= 1) return null;

  return (
    <BrBreadcrumb
      crumbs={links.map((link) => ({
        label: link.label,
        target: "_self",
        url: link.url,
        active: link.active,
      }))}
      homeUrl="/"
    />
  );
};

export default Breadcrumb;
