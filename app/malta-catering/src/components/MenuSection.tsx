import type { MenuCategory } from "../data/menu";
import MenuCard from "./MenuCard";

export default function MenuSection({ category }: { category: MenuCategory }) {
  return (
    <section className="menu-section" id={category.id}>
      <div className="menu-section-header">
        <h2>{category.name}</h2>
        <span className="menu-section-subtitle">{category.subtitle}</span>
      </div>
      <div className="menu-grid">
        {category.items.map((item) => (
          <MenuCard key={item.id} item={item} />
        ))}
      </div>
    </section>
  );
}
