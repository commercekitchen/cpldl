import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import Link from '@mui/material/Link';
import Typography from '@mui/material/Typography';

export default function PrivacyPolicy() {
  return (
    <Container maxWidth="md" sx={{ py: 6 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        DigitalLearn.org - Privacy Policy
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Effective date: June 1, 2026 | Replaces all prior versions
      </Typography>

      <Typography variant="body1">
        Your privacy is important to us. This Privacy Policy explains how DigitalLearn.org collects,
        uses, and protects personal information when you use this website. By using this site, you
        consent to the practices described in this policy.
      </Typography>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          1. Information We Collect
        </Typography>

        <Box sx={{ mt: 2 }}>
          <Typography variant="subtitle1" component="h3" fontWeight="bold" gutterBottom>
            1.1 Account Information
          </Typography>
          <Typography variant="body1">
            When you register on this site, we may ask for your name and email address. You may
            visit most areas of the site without registering.
          </Typography>
        </Box>

        <Box sx={{ mt: 2 }}>
          <Typography variant="subtitle1" component="h3" fontWeight="bold" gutterBottom>
            1.2 Usage Data and Analytics
          </Typography>
          <Typography variant="body1">
            This site uses Google Analytics to understand how visitors use the site. Google
            Analytics may collect data including pages visited, time spent on pages, general
            geographic region, browser type, and device type. Since the introduction of Google
            Analytics 4 (GA4), some of this data — such as IP-derived location and device
            identifiers — may constitute personal data under applicable privacy frameworks. We have
            configured Google Analytics with IP anonymization where supported. We do not use Google
            Analytics to collect your name, email address, or other directly identifying
            information. You may opt out of Google Analytics tracking at any time using the{' '}
            <Link
              href="https://tools.google.com/dlpage/gaoptout"
              target="_blank"
              rel="noopener noreferrer"
            >
              Google Analytics Opt-out Browser Add-on
            </Link>
            .
          </Typography>
        </Box>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          2. How We Use Your Information
        </Typography>
        <Typography variant="body1" sx={{ mb: 0.5 }}>
          We use the information we collect to:
        </Typography>
        <Box component="ul" sx={{ mt: 0.5 }}>
          <Typography component="li" variant="body1">
            Create and manage your account
          </Typography>
          <Typography component="li" variant="body1">
            Personalize your experience on the platform
          </Typography>
          <Typography component="li" variant="body1">
            Improve our website, content, and services based on usage patterns and feedback
          </Typography>
          <Typography component="li" variant="body1">
            Communicate with you about your account or changes to this platform
          </Typography>
          <Typography component="li" variant="body1">
            Comply with applicable legal obligations
          </Typography>
        </Box>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          3. Data Retention
        </Typography>
        <Typography variant="body1">
          We retain account information for as long as your account is active. If you close your
          account or request deletion, we will delete or anonymize your personal information within
          90 days, except where retention is required by law or legitimate business necessity (for
          example, records of transactions or legal disputes). Google Analytics data is retained for
          [X months/years — confirm in your GA4 settings] in accordance with Google&rsquo;s data
          retention settings.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          4. Information Sharing and Disclosure
        </Typography>
        <Typography variant="body1" sx={{ mb: 1 }}>
          We do not sell or trade your personally identifiable information. We may share your
          information in the following limited circumstances:
        </Typography>
        <Box component="ul" sx={{ mt: 0.5, mb: 1 }}>
          <Typography component="li" variant="body1">
            <strong>Service providers:</strong> Trusted third parties who assist in operating this
            website or conducting our business, subject to confidentiality obligations (e.g.,
            hosting providers, analytics services).
          </Typography>
          <Typography component="li" variant="body1">
            <strong>Legal compliance:</strong> When we believe disclosure is required by law, to
            enforce our policies, or to protect the rights, property, or safety of DigitalLearn.org
            or others.
          </Typography>
        </Box>
        <Typography variant="body1">
          Aggregate, non-personally identifiable information (such as overall usage statistics) may
          be shared with partners or reported publicly.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          5. Cookies and Tracking Technologies
        </Typography>
        <Typography variant="body1" sx={{ mb: 1 }}>
          This site uses cookies, which are small text files stored on your device. We use cookies
          for:
        </Typography>
        <Box component="ul" sx={{ mt: 0.5, mb: 1 }}>
          <Typography component="li" variant="body1">
            <strong>Authentication</strong> — keeping you logged in to your account
          </Typography>
          <Typography component="li" variant="body1">
            <strong>Analytics</strong> — understanding how the site is used (via Google Analytics)
          </Typography>
        </Box>
        <Typography variant="body1" sx={{ mb: 1 }}>
          By continuing to use this site, you consent to our use of cookies as described. You can
          configure your browser to refuse cookies, though some features of the site may not
          function correctly if you do so.
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Consider adding a cookie consent banner if you serve users in the EU, UK, or other
          jurisdictions with explicit consent requirements.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          6. Third-Party Links
        </Typography>
        <Typography variant="body1">
          This site may contain links to third-party websites. These sites have their own
          independent privacy policies, and we have no responsibility or liability for their content
          or practices. We encourage you to review the privacy policy of any third-party site you
          visit.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          7. Children&rsquo;s Privacy (COPPA)
        </Typography>
        <Typography variant="body1">
          This website, its products, and its services are directed to individuals who are at least
          13 years old. We do not knowingly collect personal information from children under 13. If
          you believe we have inadvertently collected such information, please contact us and we
          will delete it promptly.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          8. Your Rights and Choices
        </Typography>
        <Typography variant="body1" sx={{ mb: 0.5 }}>
          Depending on your location, you may have the right to:
        </Typography>
        <Box component="ul" sx={{ mt: 0.5, mb: 1 }}>
          <Typography component="li" variant="body1">
            Access the personal information we hold about you
          </Typography>
          <Typography component="li" variant="body1">
            Request correction of inaccurate or incomplete information
          </Typography>
          <Typography component="li" variant="body1">
            Request deletion of your personal information
          </Typography>
          <Typography component="li" variant="body1">
            Opt out of certain data processing activities
          </Typography>
        </Box>
        <Typography variant="body1">
          To exercise any of these rights, please contact us at [privacy contact email]. We will
          respond to verifiable requests within a reasonable timeframe.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          9. Security
        </Typography>
        <Typography variant="body1">
          We implement reasonable technical and organizational security measures to protect your
          personal information against unauthorized access, alteration, disclosure, or destruction.
          However, no method of internet transmission or electronic storage is 100% secure, and we
          cannot guarantee absolute security.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          10. Changes to This Policy
        </Typography>
        <Typography variant="body1">
          We may update this Privacy Policy from time to time. If we make material changes, we will
          notify registered users by email and post the updated policy on this page with a new
          effective date. Your continued use of the site after changes are posted constitutes your
          acceptance of the revised policy.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          11. Contact Us
        </Typography>
        <Typography variant="body1" sx={{ mb: 1 }}>
          If you have questions about this Privacy Policy or our data practices, please contact:
        </Typography>
        <Typography variant="body1">
          DigitalLearn.org
          <br />
          [Mailing Address]
          <br />
          [Email address]
        </Typography>
      </Box>
    </Container>
  );
}
