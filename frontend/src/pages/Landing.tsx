import { Link } from "react-router-dom";
import { useAuth } from "../auth/useAuth";

export default function Landing() {
  const { status, user } = useAuth();

  return (
    <div style={{ maxWidth: 720, margin: "48px auto", padding: 24 }}>
      <h1>Welcome</h1>
      <p>This is the marketing/landing page. Sign in to continue.</p>

      {status === "authenticated" ? (
        <>
          <p>Signed in as <strong>{user?.email}</strong></p>
          <Link to="/app">Go to dashboard</Link>
        </>
      ) : (
        <div style={{ display: "flex", gap: 12 }}>
          <Link to="/login">Log in</Link>
          <Link to="/signup">Create account</Link>
        </div>
      )}
    </div>
  );
}
