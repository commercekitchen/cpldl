import { useState, useEffect } from 'react';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import Button from '@mui/material/Button';
import Alert from '@mui/material/Alert';
import CircularProgress from '@mui/material/CircularProgress';
import Divider from '@mui/material/Divider';
import Link from '@mui/material/Link';
import DownloadIcon from '@mui/icons-material/Download';
import OpenInNewIcon from '@mui/icons-material/OpenInNew';
import { useTranslation } from 'react-i18next';
import { apiFetch } from '../../app/api/apiFetch';

interface Report {
  key: string;
  title: string;
}

interface AnalyticsLink {
  title: string;
  url: string;
}

function defaultStartDate(): string {
  const d = new Date();
  d.setMonth(d.getMonth() - 1);
  d.setDate(1);
  return d.toISOString().slice(0, 10);
}

function defaultEndDate(): string {
  const d = new Date();
  d.setDate(0); // last day of previous month
  return d.toISOString().slice(0, 10);
}

export default function AdminReports() {
  const { t } = useTranslation();

  const [reports, setReports] = useState<Report[]>([]);
  const [analyticsLinks, setAnalyticsLinks] = useState<AnalyticsLink[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [selectedReport, setSelectedReport] = useState('');
  const [startDate, setStartDate] = useState(defaultStartDate);
  const [endDate, setEndDate] = useState(defaultEndDate);
  const [dateError, setDateError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    apiFetch('/api/v1/admin/reports')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load reports');
        return res.json() as Promise<{ reports: Report[]; analyticsLinks: AnalyticsLink[] }>;
      })
      .then((data) => {
        if (cancelled) return;
        setReports(data.reports);
        setAnalyticsLinks(data.analyticsLinks ?? []);
        if (data.reports.length > 0) setSelectedReport(data.reports[0].key);
      })
      .catch(() => {
        if (!cancelled) setError(t('admin.reportsPage.loadError'));
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => { cancelled = true; };
  }, [t]);

  function handleDownload() {
    if (startDate > endDate) {
      setDateError(t('admin.reportsPage.dateRangeError'));
      return;
    }
    setDateError(null);

    const params = new URLSearchParams({
      report: selectedReport,
      start_date: startDate,
      end_date: endDate,
    });
    window.location.href = `/admin/report_export.csv?${params.toString()}`;
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        {t('admin.reportsPage.title')}
      </Typography>

      {loading && <CircularProgress />}

      {error && <Alert severity="error">{error}</Alert>}

      {!loading && !error && (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3, maxWidth: 480 }}>
          <FormControl fullWidth>
            <InputLabel id="report-type-label">{t('admin.reportsPage.reportType')}</InputLabel>
            <Select
              labelId="report-type-label"
              value={selectedReport}
              label={t('admin.reportsPage.reportType')}
              onChange={(e) => setSelectedReport(e.target.value)}
            >
              {reports.map((r) => (
                <MenuItem key={r.key} value={r.key}>
                  {r.title}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <Box sx={{ display: 'flex', gap: 2 }}>
            <TextField
              label={t('admin.reportsPage.startDate')}
              type="date"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              slotProps={{ inputLabel: { shrink: true } }}
              fullWidth
            />
            <TextField
              label={t('admin.reportsPage.endDate')}
              type="date"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              slotProps={{ inputLabel: { shrink: true } }}
              fullWidth
            />
          </Box>

          {dateError && <Alert severity="error">{dateError}</Alert>}

          <Button
            variant="contained"
            startIcon={<DownloadIcon />}
            onClick={handleDownload}
            disabled={!selectedReport}
          >
            {t('admin.reportsPage.download')}
          </Button>

          {analyticsLinks.length > 0 && (
            <>
              <Divider />
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Typography variant="subtitle1" fontWeight={600}>
                  {t('admin.reportsPage.analyticsTitle')}
                </Typography>
                {analyticsLinks.map((link) => (
                  <Link
                    key={link.url}
                    href={link.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    sx={{ display: 'inline-flex', alignItems: 'center', gap: 0.5 }}
                  >
                    {link.title}
                    <OpenInNewIcon fontSize="inherit" />
                  </Link>
                ))}
              </Box>
            </>
          )}
        </Box>
      )}
    </Box>
  );
}
