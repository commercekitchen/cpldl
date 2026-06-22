import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import Link from '@mui/material/Link';
import Typography from '@mui/material/Typography';
import { usePageMetadata } from '../app/metadata/usePageMetadata';

export default function TermsOfUse() {
  usePageMetadata({ title: 'Terms of Use' });
  return (
    <Container maxWidth="md" sx={{ py: 6 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        DigitalLearn.org - Terms of Use
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
        Effective date: June 1, 2026 | Replaces all prior versions
      </Typography>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          1. Agreement to These Terms
        </Typography>
        <Typography variant="body1">
          By accessing or using this website, you agree to be bound by these Terms of Use and all
          applicable laws and regulations. If you do not agree with any of these terms, you are
          prohibited from using or accessing this site. These terms apply to all visitors, users,
          and others who access the platform.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          2. License Scope
        </Typography>
        <Typography variant="body1">
          This platform involves two distinct layers of intellectual property, each governed by a
          separate license:
        </Typography>

        <Box sx={{ mt: 2 }}>
          <Typography
            variant="subtitle1"
            component="h3"
            fontWeight="bold"
            gutterBottom
          ></Typography>
        </Box>

        <Box sx={{ mt: 2 }}>
          <Typography variant="subtitle1" component="h3" fontWeight="bold" gutterBottom>
            2.1 Platform Software — MIT License
          </Typography>
          <Typography variant="body1">
            The underlying platform software, including application code, user interface components,
            and APIs, is licensed under the{' '}
            <Link
              href="https://opensource.org/licenses/MIT"
              target="_blank"
              rel="noopener noreferrer"
            >
              MIT License
            </Link>
            . You are free to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the software, subject to the MIT License terms, including retention of the
            copyright notice. DigitalLearn.org trademarks and subsite configurations are not covered
            by the MIT License and remain proprietary.
          </Typography>
        </Box>

        <Box sx={{ mt: 2 }}>
          <Typography variant="subtitle1" component="h3" fontWeight="bold" gutterBottom>
            2.2 Course Content — CC BY-NC-SA 4.0
          </Typography>
          <Typography variant="body1" sx={{ mb: 1.5 }}>
            The course content, curricula, learning materials, and media made available through this
            platform are licensed under the{' '}
            <Link
              href="https://creativecommons.org/licenses/by-nc-sa/4.0/"
              target="_blank"
              rel="noopener noreferrer"
            >
              Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC
              BY-NC-SA 4.0)
            </Link>
            , unless an individual item specifies otherwise.
          </Typography>
          <Typography variant="body1" sx={{ mb: 0.5 }}>
            Under this license you are free to:
          </Typography>
          <Box component="ul" sx={{ mt: 0.5, mb: 1.5 }}>
            <Typography component="li" variant="body1">
              <strong>Share</strong> — copy and redistribute the material in any medium or format
            </Typography>
            <Typography component="li" variant="body1">
              <strong>Adapt</strong> — remix, transform, and build upon the material
            </Typography>
          </Box>
          <Typography variant="body1" sx={{ mb: 0.5 }}>
            Under the following conditions:
          </Typography>
          <Box component="ul" sx={{ mt: 0.5, mb: 1.5 }}>
            <Typography component="li" variant="body1">
              <strong>Attribution</strong> — You must give appropriate credit, provide a link to the
              license, and indicate if changes were made. You may do so in any reasonable manner,
              but not in any way that suggests DigitalLearn.org endorses you or your use.
            </Typography>
            <Typography component="li" variant="body1">
              <strong>NonCommercial</strong> — You may not use the material for commercial purposes.
            </Typography>
            <Typography component="li" variant="body1">
              <strong>ShareAlike</strong> — If you remix, transform, or build upon the material, you
              must distribute your contributions under the same CC BY-NC-SA 4.0 license as the
              original.
            </Typography>
          </Box>
          <Typography variant="body1" sx={{ mb: 1.5 }}>
            For the complete legal text of this license, see the{' '}
            <Link
              href="https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode"
              target="_blank"
              rel="noopener noreferrer"
            >
              CC BY-NC-SA 4.0 Legal Code
            </Link>
            .
          </Typography>
        </Box>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          3. Prohibited Uses
        </Typography>
        <Typography variant="body1" sx={{ mb: 0.5 }}>
          You may not use this site's content:
        </Typography>
        <Box component="ul" sx={{ mt: 0.5 }}>
          <Typography component="li" variant="body1">
            For any commercial purpose, or for any public display (commercial or non-commercial)
            that falls outside the permissions of the CC BY-NC-SA 4.0 license
          </Typography>
          <Typography component="li" variant="body1">
            To remove any copyright or other proprietary notations from the materials
          </Typography>
        </Box>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          4. Disclaimer of Warranties
        </Typography>
        <Typography variant="body1">
          The materials on DigitalLearn.org are provided &ldquo;as is.&rdquo; DigitalLearn.org makes
          no warranties, expressed or implied, and hereby disclaims all other warranties, including
          without limitation implied warranties of merchantability, fitness for a particular
          purpose, or non-infringement of intellectual property or other violation of rights.
          DigitalLearn.org does not warrant or make any representations concerning the accuracy,
          likely results, or reliability of the use of the materials on its website or on any sites
          linked to this site.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          5. Limitation of Liability
        </Typography>
        <Typography variant="body1">
          In no event shall DigitalLearn.org or its suppliers be liable for any damages (including,
          without limitation, damages for loss of data or profit, or due to business interruption)
          arising out of the use or inability to use the materials on DigitalLearn.org&rsquo;s
          website, even if DigitalLearn.org or an authorized representative has been notified orally
          or in writing of the possibility of such damage. Because some jurisdictions do not allow
          limitations on implied warranties or limitations of liability for consequential or
          incidental damages, these limitations may not apply to you.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          6. Accuracy and Revisions
        </Typography>
        <Typography variant="body1">
          The materials appearing on this website could include technical, typographical, or
          photographic errors. DigitalLearn.org does not warrant that any of the materials on its
          website are accurate, complete, or current. DigitalLearn.org may make changes to the
          materials at any time without notice, but does not commit to updating them.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          7. Third-Party Links
        </Typography>
        <Typography variant="body1">
          DigitalLearn.org has not reviewed all sites linked to from this website and is not
          responsible for the contents of any linked site. The inclusion of any link does not imply
          endorsement by DigitalLearn.org. Use of any linked website is at the user&rsquo;s own
          risk.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          8. Modifications to These Terms
        </Typography>
        <Typography variant="body1">
          DigitalLearn.org may revise these Terms of Use at any time. In the event of any such
          revision, we will post changes on this page and update the effective date. By using this
          website you are agreeing to be bound by the then-current version of these terms. We
          recommend checking this page periodically for changes.
        </Typography>
      </Box>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" component="h2" gutterBottom>
          9. Governing Law
        </Typography>
        <Typography variant="body1">
          Any claim relating to DigitalLearn.org&rsquo;s website shall be governed by the laws of
          the State of Illinois, without regard to its conflict of law provisions.
        </Typography>
      </Box>
    </Container>
  );
}
