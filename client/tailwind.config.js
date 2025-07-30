export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          light: "#E0F2FE",  // azzurro molto chiaro
          DEFAULT: "#3B82F6", // blu principale
          dark: "#1E40AF",   // blu scuro
        },
        accent: {
          light: "#D1FAE5",  // verde acqua chiaro
          DEFAULT: "#10B981", // verde principale
          dark: "#065F46",   // verde scuro
        },
        neutral: {
          light: "#F9FAFB",
          DEFAULT: "#6B7280",
          dark: "#111827",
        },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
      },
      boxShadow: {
        soft: "0 4px 10px rgba(0, 0, 0, 0.05)",
        strong: "0 6px 15px rgba(0, 0, 0, 0.1)",
      },
    },
  },
  plugins: [],
};