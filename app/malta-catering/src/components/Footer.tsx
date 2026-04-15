export default function Footer() {
  return (
    <footer className="footer">
      <div className="footer-inner">
        <p className="footer-tagline">
          Powered by pastizzi and stubbornness since 2026.
        </p>
        <p className="footer-warning">
          ⚠️ Side effects may include: spontaneous Maltese pride, carb comas,
          and saying "mela" in every sentence.
        </p>
        <div className="footer-links">
          <span>📍 Malta, EU</span>
          <span>•</span>
          <span>📞 +356 2099 FOOD</span>
          <span>•</span>
          <span>🕐 Mon-Sun: When we feel like it</span>
        </div>
        <p className="footer-attribution">
          Images sourced from Wikimedia Commons and the internet. This is a demo
          application.
        </p>
        <p className="footer-copy">
          © {new Date().getFullYear()} Il-Pastizzeria ta' Mario. All rights
          reserved. Especially the pastizzi.
        </p>
      </div>
    </footer>
  );
}
