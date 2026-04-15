import type { MenuItem } from "../data/menu";
import { useCart } from "../context/CartContext";

export default function MenuCard({ item }: { item: MenuItem }) {
  const { addItem } = useCart();

  return (
    <div className="menu-card">
      <div className="menu-card-image">
        <img
          src={item.image}
          alt={item.name}
          loading="lazy"
          onError={(e) => {
            (e.target as HTMLImageElement).src =
              `https://placehold.co/300x200/CF142B/white?text=${encodeURIComponent(item.name)}`;
          }}
        />
      </div>
      <div className="menu-card-body">
        <h3 className="menu-card-name">{item.name}</h3>
        <p className="menu-card-desc">{item.desc}</p>
        <div className="menu-card-footer">
          <span className="menu-card-price">€{item.price.toFixed(2)}</span>
          <button className="add-to-cart-btn" onClick={() => addItem(item)}>
            Iva, irrid! 🛒
          </button>
        </div>
      </div>
    </div>
  );
}
