-- ============================================================
-- SQL PARA INSERTAR CONTACTOS EN target_contacts
-- Fecha: 2026-03-24
-- Generado por: Lead Generation Expert
--
-- INSTRUCCIONES:
-- 1. Ve a Supabase Dashboard → SQL Editor
-- 2. Pega este SQL y ejecuta
-- 3. Verifica en "Leads Calificados" que aparecen los nuevos contactos
-- ============================================================

-- ============================================================
-- 1. NUEVOS CONTACTOS (empresas sin contactos previos)
-- ============================================================

-- Arcos Dorados (ID: 1786) - Magdalena Gonzalez Victorica (CTO)
INSERT INTO target_contacts (
    target_id, full_name, email, phone, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    1786,
    'Magdalena Gonzalez Victorica',
    NULL,
    NULL,
    'Chief Innovation & Technology Officer (CITO)',
    'c_suite',
    'Technology',
    'https://linkedin.com/in/magdalena-gonzalez-victorica-9b618717',
    true,
    'manual_linkedin',
    95,
    ARRAY['Zoom'],
    NOW(),
    'arcosdorados.com'
);

-- Contacto alternativo: Rodolfo Spacek (IT Sr Lead LATAM)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    1786,
    'Rodolfo Spacek',
    'IT Sr Lead LATAM',
    'director',
    'Technology',
    'https://linkedin.com/in/rodolfo-spacek-4a038326',
    false,
    'manual_linkedin',
    85,
    ARRAY['Zoom'],
    NOW(),
    'arcosdorados.com'
);

-- Cyrela Brazil Realty (ID: 6616) - Thenório Queiroz
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    6616,
    'Thenório Queiroz',
    'Coordenador de Tecnologia da Informação (IT Coordinator)',
    'manager',
    'Technology',
    'https://linkedin.com/in/thenorio-queiroz-b2326417',
    true,
    'manual_linkedin',
    75,
    ARRAY['Zoom'],
    NOW(),
    'cyrela.com.br'
);

-- Contacto alternativo: Marcelo Edgar Martinelli (Gerente TI)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    6616,
    'Marcelo Edgar Martinelli',
    'Gerente de TI',
    'manager',
    'Technology',
    false,
    'manual_linkedin',
    70,
    ARRAY['Zoom'],
    NOW(),
    'cyrela.com.br'
);

-- Federal University of Rio Grande (ID: 10276) - Silvia Botelho
INSERT INTO target_contacts (
    target_id, full_name, email, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    10276,
    'Silvia Silva da Costa Botelho',
    'proiti.proreitora@furg.br',
    'Pró-Reitora de Inovação e TI',
    'director',
    'Technology',
    true,
    'manual_linkedin',
    80,
    ARRAY['Zoom'],
    NOW(),
    'furg.br'
);

-- Contacto alternativo: Diogo Paludo de Oliveira (Diretor CGTI)
INSERT INTO target_contacts (
    target_id, full_name, email, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    10276,
    'Diogo Paludo de Oliveira',
    'cgti@furg.br',
    'Diretor do Centro de Gestão de TI',
    'director',
    'Technology',
    false,
    'manual_linkedin',
    75,
    ARRAY['Zoom'],
    NOW(),
    'furg.br'
);

-- Porto Seguro (ID: 20234) - Marcos Sirelli (CIO)
INSERT INTO target_contacts (
    target_id, full_name, phone, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    20234,
    'Marcos Sirelli',
    '+55 (11) 4114-2009',
    'Chief Information Officer (CIO) / CTIO',
    'c_suite',
    'Technology',
    'https://linkedin.com/in/marcos-sirelli-0474a03',
    true,
    'manual_linkedin',
    95,
    ARRAY['Zoom'],
    NOW(),
    'portoseguro.com.br'
);

-- Contacto alternativo: Daniel Cassiano (CTIO)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    20234,
    'Daniel Cassiano',
    'Chief Technology & Innovation Officer (CTIO)',
    'c_suite',
    'Technology',
    false,
    'manual_linkedin',
    90,
    ARRAY['Zoom'],
    NOW(),
    'portoseguro.com.br'
);

-- RUMO (ID: 22095) - Diego José Guidelli
INSERT INTO target_contacts (
    target_id, full_name, phone, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    22095,
    'Diego José Guidelli',
    '+55 (41) 2104-6600',
    'Gerente Executivo de Tecnologia Ferroviária e Operações de TI',
    'director',
    'Technology',
    'https://theorg.com/org/rumo/org-chart/diego-jose-guidelli',
    true,
    'manual_linkedin',
    85,
    ARRAY['Zoom'],
    NOW(),
    'rumolog.com'
);

-- Universidade Federal do Pará (ID: 26305) - Marco Aurélio
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    26305,
    'Marco Aurélio',
    'Diretor de TI',
    'director',
    'Technology',
    'https://linkedin.com/in/macapela',
    true,
    'manual_linkedin',
    80,
    ARRAY['Zoom'],
    NOW(),
    'ufpa.br'
);

-- ============================================================
-- 2. CONTACTOS ADICIONALES (empresas que ya tienen contactos)
-- ============================================================

-- ALFA (ID: 1044) - Agregar contacto alternativo (IT)
-- NOTA: El contacto existente (Eduardo Escalante) es CFO, agregamos contacto IT
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    1044,
    'Iván De La Peña',
    'Subdirector de Desarrollo de Tecnología',
    'director',
    'Technology',
    false,  -- false porque ya existe otro contacto primario
    'manual_linkedin',
    85,
    ARRAY['Zoom'],
    NOW(),
    'alfa.com.mx'
);

-- Klabin (ID: 14350) - Agregar CIO actual (Odercio Claro)
-- NOTA: Ya existe Mônica Pomposelli, agregamos al CIO actual
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    14350,
    'Odercio Reginaldo Claro',
    'CIO / Diretor de TI',
    'c_suite',
    'Technology',
    false,
    'manual_linkedin',
    95,
    ARRAY['Zoom'],
    NOW(),
    'klabin.com.br'
);

-- Contacto adicional: Luiz Carlos Martinez (AI Office)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    14350,
    'Luiz Carlos Martinez',
    'IT Governance, Architecture and AI Leader',
    'director',
    'Technology',
    'https://br.linkedin.com/in/lcmartinezjr',
    false,
    'manual_linkedin',
    80,
    ARRAY['Zoom'],
    NOW(),
    'klabin.com.br'
);

-- Suhai (ID: 24308) - Agregar VP TI (Alexandre Staffa)
-- NOTA: Ya existe Marcos Oliveira (CEO)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    24308,
    'Alexandre Staffa',
    'Vice-Presidente Financeiro e de TI',
    'vp',
    'Technology',
    'https://linkedin.com/in/alexandre-staffa-40438017',
    false,
    'manual_linkedin',
    90,
    ARRAY['Xcally'],
    NOW(),
    'suhaiseguradora.com'
);

-- Flash (ID: 9845) - Agregar CTO actual (Guilherme Lane)
-- NOTA: Ya existe Guilherme Roschke (CEO), agregamos CTO
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    9845,
    'Guilherme Lane',
    'Founder & CTO',
    'c_suite',
    'Technology',
    false,
    'manual_linkedin',
    95,
    ARRAY['Zoom'],
    NOW(),
    'flashapp.com.br'
);

-- Contacto adicional: Jose Augusto Aiex Alves (CISO)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    9845,
    'Jose Augusto Aiex Alves',
    'Chief Information Security Officer (CISO)',
    'c_suite',
    'Security',
    false,
    'manual_linkedin',
    85,
    ARRAY['Zoom'],
    NOW(),
    'flashapp.com.br'
);

-- IDS Comercial (ID: 12460) - Agregar CIO (Jorge Cuellar)
-- NOTA: Ya existe "Contacto Comercial IDS", agregamos CIO real
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    12460,
    'Jorge Alberto Lima Cuellar',
    'Chief Information and Initiatives Officer (CIO)',
    'c_suite',
    'Technology',
    'https://theorg.com/org/ids-comercial/org-chart/jorge-alberto-lima-cuellar',
    false,
    'manual_linkedin',
    95,
    ARRAY['Zoom'],
    NOW(),
    'ids.com.mx'
);

-- Contacto adicional: Jose Luis Neri Becerril (Director Desarrollo)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    12460,
    'Jose Luis Neri Becerril',
    'Director Desarrollo de Negocio MX y Centroamérica',
    'director',
    'Business Development',
    'https://linkedin.com/in/jose-luis-neri-becerril-35060410',
    false,
    'manual_linkedin',
    85,
    ARRAY['Zoom'],
    NOW(),
    'ids.com.mx'
);

-- Ibero-American University (ID: 12321) - Agregar CIO (Guillermo Espinosa)
-- NOTA: Ya existe "Dirección de Tecnologías", agregamos CIO específico
INSERT INTO target_contacts (
    target_id, full_name, email, job_title, seniority,
    department, linkedin_url, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    12321,
    'Guillermo Espinosa',
    'maribel.sanchez@ibero.mx',
    'CIO IBERO Puebla',
    'c_suite',
    'Technology',
    'https://linkedin.com/in/guillermo-espinosa-6aa4344a',
    false,
    'manual_linkedin',
    85,
    ARRAY['Zoom'],
    NOW(),
    'ibero.mx'
);

-- Contacto adicional CDMX: Maribel Sánchez
INSERT INTO target_contacts (
    target_id, full_name, email, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    12321,
    'Maribel Sánchez Sánchez',
    'maribel.sanchez@ibero.mx',
    'Coordinadora de Cómputo Académico CDMX',
    'manager',
    'Technology',
    false,
    'manual_linkedin',
    75,
    ARRAY['Zoom'],
    NOW(),
    'ibero.mx'
);

-- Hach Company (ID: 11621) - Agregar CTO Global (Russell Young)
-- NOTA: Ya existe Gary Dreher (VP Ops)
INSERT INTO target_contacts (
    target_id, full_name, phone, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    11621,
    'Russell Young',
    '+1-970-669-3050',
    'Global CTO',
    'c_suite',
    'Technology',
    false,
    'manual_linkedin',
    90,
    ARRAY['Zoom'],
    NOW(),
    'hach.com'
);

-- Contacto adicional México: Pamela Saavedra (GM México)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    11621,
    'Pamela Saavedra',
    'General Manager México',
    'director',
    'Management',
    false,
    'manual_linkedin',
    85,
    ARRAY['Zoom'],
    NOW(),
    'hach.com'
);

-- Contacto adicional IT MX: Raúl Carreón (IT Technician)
INSERT INTO target_contacts (
    target_id, full_name, job_title, seniority,
    department, is_primary, source, relevance_score,
    relevant_for_products, enriched_at, canonical_domain
) VALUES (
    11621,
    'Raúl Carreón',
    'IT Technician Monterrey',
    'manager',
    'Technology',
    false,
    'manual_linkedin',
    70,
    ARRAY['Zoom'],
    NOW(),
    'hach.com'
);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================

-- Verificar cuántos contactos nuevos se insertaron
SELECT 'Contactos insertados: ' || COUNT(*)::text as resultado
FROM target_contacts
WHERE source = 'manual_linkedin' AND enriched_at >= '2026-03-24'::date;
