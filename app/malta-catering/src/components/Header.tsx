import { useCart } from "../context/CartContext";

export default function Header({ onCartClick }: { onCartClick: () => void }) {
  const { totalItems } = useCart();

  return (
    <header className="header">
      <div className="header-inner">
        <div className="header-brand">
          <h1>🇲🇹 Il-Pastizzeria ta' Mario</h1>
          <p className="header-tagline">Because calling us is too mainstream</p>
        </div>
        <button
          className="cart-button"
          onClick={onCartClick}
          aria-label="Open cart"
        >
          🛒
          {totalItems > 0 && <span className="cart-badge">{totalItems}</span>}
        </button>
      </div>
      <div className="payment-banner">
        💶 Cash on delivery. Like your nanna taught you.
      </div>
    </header>
  );
}
