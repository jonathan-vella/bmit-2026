import { useState } from "react";
import { CartProvider } from "./context/CartContext";
import { menuData } from "./data/menu";
import Header from "./components/Header";
import MenuSection from "./components/MenuSection";
import Cart from "./components/Cart";
import OrderForm from "./components/OrderForm";
import OrderConfirmation from "./components/OrderConfirmation";
import Footer from "./components/Footer";

type View = "menu" | "checkout" | "confirmation";

function AppContent() {
  const [view, setView] = useState<View>("menu");
  const [cartOpen, setCartOpen] = useState(false);
  const [customerName, setCustomerName] = useState("");

  const handleCheckout = () => {
    setCartOpen(false);
    setView("checkout");
  };

  const handleOrderSubmit = (details: { name: string }) => {
    setCustomerName(details.name);
    setView("confirmation");
  };

  const handleNewOrder = () => {
    setCustomerName("");
    setView("menu");
  };

  if (view === "confirmation") {
    return (
      <>
        <Header onCartClick={() => {}} />
        <OrderConfirmation
          customerName={customerName}
          onNewOrder={handleNewOrder}
        />
        <Footer />
      </>
    );
  }

  if (view === "checkout") {
    return (
      <>
        <Header onCartClick={() => setCartOpen(true)} />
        <main className="main-content">
          <OrderForm
            onSubmit={handleOrderSubmit}
            onBack={() => setView("menu")}
          />
        </main>
        <Cart
          isOpen={cartOpen}
          onClose={() => setCartOpen(false)}
          onCheckout={handleCheckout}
        />
        <Footer />
      </>
    );
  }

  return (
    <>
      <Header onCartClick={() => setCartOpen(true)} />
      <main className="main-content">
        <div className="hero">
          <h2>X'trid tordna llum?</h2>
          <p>What would you like to order today?</p>
          <p className="hero-subtitle">
            Choose wisely. Or don't. We'll deliver either way.{" "}
            <em>Probably.</em>
          </p>
        </div>
        {menuData.map((category) => (
          <MenuSection key={category.id} category={category} />
        ))}
      </main>
      <Cart
        isOpen={cartOpen}
        onClose={() => setCartOpen(false)}
        onCheckout={handleCheckout}
      />
      <Footer />
    </>
  );
}

export default function App() {
  return (
    <CartProvider>
      <AppContent />
    </CartProvider>
  );
}
