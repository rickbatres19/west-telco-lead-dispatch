-- Migration 02: Partner Reports System
-- Fecha: 18 Mar 2026
-- Descripción: Tablas para gestión de reportes mensuales a partners

CREATE TABLE IF NOT EXISTS public.partners (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  contact_name text,
  contact_email text NOT NULL,
  products text[],
  territories text[],
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.partner_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id uuid REFERENCES public.partners(id),
  partner_name text NOT NULL,
  partner_email text NOT NULL,
  period_label text NOT NULL,
  status text NOT NULL DEFAULT 'draft',
  total_leads integer DEFAULT 0,
  notes text,
  generated_at timestamptz,
  sent_at timestamptz,
  created_by text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.partner_report_leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id uuid REFERENCES public.partner_reports(id) ON DELETE CASCADE,
  target_id bigint REFERENCES public.builtwith_company_targets(id),
  company_name text,
  country text,
  territory text,
  product text,
  priority_score integer,
  contact_name text,
  contact_email text,
  offering_rationale text,
  included boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_partner_report_leads_report_id ON public.partner_report_leads(report_id);
CREATE INDEX IF NOT EXISTS idx_partner_reports_partner_id ON public.partner_reports(partner_id);
CREATE INDEX IF NOT EXISTS idx_partner_reports_status ON public.partner_reports(status);
