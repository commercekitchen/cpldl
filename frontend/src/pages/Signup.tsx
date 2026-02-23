import { type FormEvent, useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { apiFetch } from '../app/api/apiFetch';
import { useAuth } from '../auth/useAuth';

export default function Signup() {
  const { refresh } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const from =
    typeof location.state === 'object' &&
    location.state !== null &&
    'from' in location.state &&
    typeof (location.state as { from?: { pathname?: string } }).from?.pathname === 'string'
      ? (location.state as { from: { pathname: string } }).from.pathname
      : '/app';

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      // Adjust to match your Rails signup endpoint.
      await apiFetch('/api/v1/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      }).then(async (r) => {
        if (!r.ok) {
          const body = await r.json().catch(() => null);
          throw new Error(body?.error || body?.message || `Signup failed: ${r.status}`);
        }
      });

      // If signup also logs the user in (cookie set), refresh auth state.
      await refresh();
      navigate(from, { replace: true });
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Signup failed';
      setError(message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div style={{ maxWidth: 480, margin: '48px auto', padding: 24 }}>
      <h1>Create account</h1>

      {error && <div style={{ marginBottom: 12 }}>{error}</div>}

      <form onSubmit={onSubmit} style={{ display: 'grid', gap: 12 }}>
        <label>
          Email
          <input value={email} onChange={(e) => setEmail(e.target.value)} autoComplete="email" />
        </label>

        <label>
          Password
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            autoComplete="new-password"
          />
        </label>

        <button disabled={submitting} type="submit">
          {submitting ? 'Creating…' : 'Create account'}
        </button>
      </form>

      <p style={{ marginTop: 16 }}>
        Already have an account? <Link to="/login">Log in</Link>
      </p>
    </div>
  );
}
