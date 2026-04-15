import { useCart } from "../context/CartContext";

interface CartProps {
  isOpen: boolean;
  onClose: () => void;
  onCheckout: () => void;
}

export default function Cart({ isOpen, onClose, onCheckout }: CartProps) {
  const { items, updateQuantity, removeItem, totalPrice, totalItems } =
    useCart();

  const getSarcasticComment = () => {
    if (totalItems === 0)
      return "Your cart is emptier than Valletta at 2pm in August";
    if (totalItems >= 10) return "Kemm tridu?! Having a festa or what? 🎉";
    if (totalItems >= 5) return "Now we're talking. Your nanna would be proud.";
    return "Good start. But you can do better.";
  };

  return (
    <>
      <div
        className={`cart-overlay ${isOpen ? "open" : ""}`}
        onClick={onClose}
      />
      <div className={`cart-drawer ${isOpen ? "open" : ""}`}>
        <div className="cart-header">
          <h2>🛒 Il-Basket</h2>
          <button
            className="cart-close"
            onClick={onClose}
            aria-label="Close cart"
          >
            ✕
          </button>
        </div>

        <p className="cart-sarcasm">{getSarcasticComment()}</p>

        {items.length === 0 ? (
          <div className="cart-empty">
            <p>🦗 *cricket sounds*</p>
            <p>Add something, ħi. We don't judge.</p>
          </div>
        ) : (
          <>
            <div className="cart-items">
              {items.map((item) => (
                <div key={item.id} className="cart-item">
                  <div className="cart-item-info">
                    <span className="cart-item-name">{item.name}</span>
                    <span className="cart-item-price">
                      €{(item.price * item.quantity).toFixed(2)}
                    </span>
                  </div>
                  <div className="cart-item-controls">
                    <button
                      onClick={() => updateQuantity(item.id, item.quantity - 1)}
                      aria-label="Decrease"
                    >
                      −
                    </button>
                    <span className="cart-item-qty">{item.quantity}</span>
                    <button
                      onClick={() => updateQuantity(item.id, item.quantity + 1)}
                      aria-label="Increase"
                    >
                      +
                    </button>
                    <button
                      className="cart-item-remove"
                      onClick={() => removeItem(item.id)}
                      aria-label="Remove"
                    >
                      🗑️
                    </button>
                  </div>
                </div>
              ))}
            </div>

            <div className="cart-footer">
              <div className="cart-total">
                <span>The Damage:</span>
                <span className="cart-total-price">
                  €{totalPrice.toFixed(2)}
                </span>
              </div>
              <button className="checkout-btn" onClick={onCheckout}>
                Lest! 🚀
              </button>
              <p className="cart-delivery-note">
                We'll get there. Probably. <em>Mela.</em>
              </p>
            </div>
          </>
        )}
      </div>
    </>
  );
}
