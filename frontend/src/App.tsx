import { RouterProvider } from 'react-router-dom';
import { OrganizationProvider } from './app/organization/OrganizationProvider';
import { createAppRouter } from './app/router/router';
import { AuthProvider } from './auth/AuthContext';
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from './app/queryClient';

function App() {
  const router = createAppRouter();

  return (
    <QueryClientProvider client={queryClient}>
      <OrganizationProvider>
        <AuthProvider>
          <RouterProvider router={router} />
        </AuthProvider>
      </OrganizationProvider>
    </QueryClientProvider>
  );
}

export default App;
