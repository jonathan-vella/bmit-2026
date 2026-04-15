import { useState } from "react";
import { useCart } from "../context/CartContext";

interface OrderFormProps {
  onSubmit: (details: { name: string; phone: string; address: string }) => void;
  onBack: () => void;
}

export default function OrderForm({ onSubmit, onBack }: OrderFormProps) {
  const { items, totalPrice } = useCart();
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [address, setAddress] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({ name, phone, address });
  };

  return (
    <div className="order-form-container">
      <button className="back-btn" onClick={onBack}>
        ← Lura (Back)
      </button>
      <h2>
        📋 Fejn inwasslulek?{" "}
        <span className="subtitle">Where do we deliver?</span>
      </h2>

      <div className="order-summary-mini">
        <h3>Your Order</h3>
        {items.map((item) => (
          <div key={item.id} className="order-summary-item">
            <span>
              {item.quantity}× {item.name}
            </span>
            <span>€{(item.price * item.quantity).toFixed(2)}</span>
          </div>
        ))}
        <div className="order-summary-total">
          <strong>Total:</strong>
          <strong>€{totalPrice.toFixed(2)}</strong>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="order-form">
        <div className="form-group">
          <label htmlFor="name">Ismek (Your Name)</label>
          <input
            id="name"
            type="text"
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Mario Vella"
          />
        </div>
        <div className="form-group">
          <label htmlFor="phone">Numru tat-Telefon (Phone)</label>
          <input
            id="phone"
            type="tel"
            required
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="+356 9999 0000"
          />
        </div>
        <div className="form-group">
          <label htmlFor="address">Indirizz (Address)</label>
          <textarea
            id="address"
            required
            value={address}
            onChange={(e) => setAddress(e.target.value)}
            placeholder="Triq il-Kbira, Ħal Qormi"
            rows={3}
          />
        </div>

        <div className="payment-reminder">
          💶 <strong>Cash on delivery only.</strong> Like your nanna taught you.
          <br />
          <small>
            No cards, no crypto, no IOUs, no "I'll Revolut you later."
          </small>
        </div>

        <button type="submit" className="submit-order-btn">
          Ibgħat l-Ordni! 🛵
        </button>
      </form>
    </div>
  );
}
