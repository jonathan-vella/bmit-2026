export interface MenuItem {
  id: string;
  name: string;
  desc: string;
  price: number;
  image: string;
}

export interface MenuCategory {
  id: string;
  name: string;
  subtitle: string;
  items: MenuItem[];
}

export const menuData: MenuCategory[] = [
  {
    id: "pastizzi",
    name: "Pastizzi",
    subtitle: "Savoury Pastries",
    items: [
      {
        id: "ricotta",
        name: "Pastizz tal-Irkotta",
        desc: "Flaky diamond of ricotta goodness. The reason you woke up today.",
        price: 0.5,
        image: "/images/pastizzi-ricotta.jpg",
      },
      {
        id: "pea",
        name: "Pastizz tal-Piżelli",
        desc: "Mushy peas in pastry. Don't knock it till you've tried it.",
        price: 0.5,
        image: "/images/pastizzi-pea.jpg",
      },
    ],
  },
  {
    id: "birra",
    name: "Birra",
    subtitle: "Beer 🍺",
    items: [
      {
        id: "cisk-lager",
        name: "Cisk Lager 330ml",
        desc: "Malta's finest. Pairs with everything. Especially more Cisk.",
        price: 2.5,
        image: "/images/cisk-lager.jpg",
      },
      {
        id: "cisk-excel",
        name: "Cisk Excel 330ml",
        desc: "Low carb. For when you want beer but also want to pretend you're healthy.",
        price: 2.75,
        image: "/images/cisk-excel.jpg",
      },
      {
        id: "cisk-chill",
        name: "Cisk Chill 330ml",
        desc: "Lemon-flavoured. Because sometimes you need to feel fancy.",
        price: 2.75,
        image: "/images/cisk-chill.jpg",
      },
    ],
  },
  {
    id: "xorb",
    name: "Xorb",
    subtitle: "Drinks 🥤",
    items: [
      {
        id: "kinnie",
        name: "Kinnie Original 330ml",
        desc: "Bitter orange herbal soda. An acquired taste that every Maltese person acquired at birth.",
        price: 1.5,
        image: "/images/kinnie.jpg",
      },
      {
        id: "kinnie-zest",
        name: "Kinnie Zest 330ml",
        desc: "Diet Kinnie. Same acquired taste, fewer calories, same judgement from your nanna.",
        price: 1.5,
        image: "/images/kinnie-zest.jpg",
      },
    ],
  },
  {
    id: "ikla-ohra",
    name: "Ikla Oħra",
    subtitle: "More Food 🍽️",
    items: [
      {
        id: "timpana",
        name: "Timpana",
        desc: "Baked pasta pie. Basically a carb bomb wrapped in pastry. You're welcome.",
        price: 5.0,
        image: "/images/timpana.jpg",
      },
      {
        id: "ftira",
        name: "Ftira Għawdxija",
        desc: "Gozitan flatbread loaded with tomatoes, olives, and opinions.",
        price: 4.5,
        image: "/images/ftira.jpg",
      },
      {
        id: "hobz-biz-zejt",
        name: "Ħobż biż-Żejt",
        desc: "Tomato bread with oil, capers & olives. The Maltese bruschetta that came first.",
        price: 3.5,
        image: "/images/hobz-biz-zejt.jpg",
      },
      {
        id: "imqaret",
        name: "Imqaret",
        desc: "Deep-fried date pastry. Your dentist hates this one weird trick.",
        price: 1.0,
        image: "/images/imqaret.jpg",
      },
    ],
  },
];
