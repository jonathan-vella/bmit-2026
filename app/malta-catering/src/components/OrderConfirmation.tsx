import { useCart } from "../context/CartContext";

interface OrderConfirmationProps {
  customerName: string;
  onNewOrder: () => void;
}

export default function OrderConfirmation({
  customerName,
  onNewOrder,
}: OrderConfirmationProps) {
  const { items, totalPrice, clearCart } = useCart();
  const orderNumber = `MT-${Date.now().toString(36).toUpperCase().slice(-6)}`;

  const handleNewOrder = () => {
    clearCart();
    onNewOrder();
  };

  return (
    <div className="confirmation-container">
      <div className="confirmation-card">
        <div className="confirmation-icon">✅</div>
        <h1>Grazzi ħafna, {customerName}!</h1>
        <p className="confirmation-subtitle">
          Your order is being prepared by our highly trained team.
          <br />
          <em>(It's just Mario.)</em>
        </p>

        <div className="confirmation-order-id">Order #{orderNumber}</div>

        <div className="confirmation-items">
          {items.map((item) => (
            <div key={item.id} className="confirmation-item">
              <span>
                {item.quantity}× {item.name}
              </span>
              <span>€{(item.price * item.quantity).toFixed(2)}</span>
            </div>
          ))}
          <div className="confirmation-total">
            <strong>Total (cash):</strong>
            <strong>€{totalPrice.toFixed(2)}</strong>
          </div>
        </div>

        <div className="confirmation-delivery">
          <p>
            🛵 <strong>Delivery estimate:</strong>
          </p>
          <p className="delivery-estimate">
            We'll get there. Probably. <em>Mela.</em>
          </p>
          <p className="delivery-subtext">
            Somewhere between 20 minutes and whenever Mario finishes his coffee.
          </p>
        </div>

        <div className="confirmation-footer-note">
          <p>
            🔔 If the pastizzi are cold, it's because you took too long to open
            the door.
          </p>
        </div>

        <button className="new-order-btn" onClick={handleNewOrder}>
          Ordna iktar! (Order more!) 🔄
        </button>
      </div>
    </div>
  );
}
