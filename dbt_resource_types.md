# dbt Resource Types

Vollständige Übersicht aller dbt Resource Types — verwendbar in `--select`, `--exclude`, Selektoren und Schema-YAMLs.

## Verwendung in Selektoren

```bash
dbt run   --select resource_type:model
dbt build --select resource_type:snapshot
dbt test  --select resource_type:test
```

---

## Übersicht

| Resource Type    | Beschreibung                                                                 | Definiert in              |
|------------------|------------------------------------------------------------------------------|---------------------------|
| `model`          | SQL- oder Python-Transformationsmodell                                       | `models/*.sql`            |
| `source`         | Rohdaten-Tabelle aus einem externen System                                   | `source.yml`              |
| `seed`           | Statische CSV-Datei, die in die Datenbank geladen wird                       | `seeds/*.csv`             |
| `snapshot`       | Slowly Changing Dimensions (SCD Type 2) — erfasst historische Zustände      | `snapshots/*.sql`         |
| `test`           | Datenqualitätstest (generisch oder singulär)                                 | `schema.yml` / `tests/*.sql` |
| `unit_test`      | Unit-Test für ein einzelnes Modell mit definierten Eingaben und Erwartungen  | `schema.yml`              |
| `analysis`       | Ad-hoc SQL-Abfrage (wird kompiliert, aber nicht materialisiert)              | `analyses/*.sql`          |
| `exposure`       | Downstream-Nutzung eines Modells (Dashboard, Report, ML-Modell etc.)        | `exposures.yml`           |
| `metric`         | Wiederverwendbare Business-Metrik (Legacy MetricFlow)                        | `metrics.yml`             |
| `semantic_model` | Semantisches Modell für MetricFlow (dbt Semantic Layer)                      | `semantic_models.yml`     |
| `saved_query`    | Vordefinierte MetricFlow-Abfrage für den Semantic Layer                      | `saved_queries.yml`       |
| `macro`          | Wiederverwendbares Jinja-Makro                                               | `macros/*.sql`            |
| `group`          | Gruppierung von Modellen für Access-Kontrolle                                | `groups.yml`              |

---

## Tests — Untertypen

| Typ               | Beschreibung                                                        |
|-------------------|---------------------------------------------------------------------|
| Generischer Test  | Definiert in `schema.yml` unter `tests:` einer Spalte/eines Modells |
| Singulärer Test   | Eigene SQL-Datei in `tests/` — gibt Zeilen zurück wenn Fehler       |

---

## Flags in `dbt_project.yml`

Resource-Type-spezifische Konfigurationen können im `flags`-Block gesetzt werden:

```yaml
flags:
  send_anonymous_usage_stats: false
  fail-fast: true
```

---

## Selector-Syntax Cheatsheet

### Logische Operatoren

| Logik   | Syntax        | Beschreibung                                        |
|---------|---------------|-----------------------------------------------------|
| **UND** | Komma `,`     | Modell muss **alle** Bedingungen erfüllen           |
| **ODER** | Leerzeichen  | Modell muss **eine** der Bedingungen erfüllen (Union)|
| **NICHT** | `--exclude` | Modelle ausschließen                                |

```bash
# UND — nur Modelle die BEIDE Tags haben
dbt run --select tag:daily,tag:core

# ODER — Modelle die einen der beiden Tags haben
dbt run --select tag:daily tag:core

# Kombination UND + NICHT
dbt run --select tag:daily,resource_type:model --exclude tag:staging
```

### Weitere Selektoren

```bash
# Nach Resource Type
dbt build --select resource_type:model
dbt build --select resource_type:snapshot

# Kombination mit anderen Selektoren
dbt run --select tag:daily,resource_type:model
dbt test --select resource_type:test,tag:core

# Upstream / Downstream
dbt run --select +exposure:contract_overview_report   # upstream
dbt run --select model+                               # downstream

# Ausschließen
dbt build --exclude resource_type:snapshot
```

---

## Wichtige dbt-Konzepte

---

### Node

Ein **Node** ist jedes einzelne Objekt im dbt DAG — jedes Modell, jeder Test, jede Quelle, jeder Seed usw. ist ein Node. Nodes haben eine eindeutige `unique_id` und sind in `manifest.json` dokumentiert.

```
unique_id-Format:
  model.<project>.<name>         → model.dbt_eth.stg_transactions
  test.<project>.<name>          → test.dbt_eth.not_null_stg_transactions_id
  source.<project>.<src>.<table> → source.dbt_eth.raw.transactions
  seed.<project>.<name>          → seed.dbt_eth.country_codes
```

**Node-Selektion über unique_id:**
```bash
dbt run --select model.dbt_eth.stg_transactions
```

---

### Tag

**Tags** sind frei definierbare Labels, die an Modelle, Spalten oder Tests gehängt werden. Sie ermöglichen eine flexible Gruppierung unabhängig von Ordnerstruktur.

**Definition in `schema.yml`:**
```yaml
models:
  - name: stg_transactions
    config:
      tags: ["daily", "core", "finance"]
    columns:
      - name: amount
        tests:
          - not_null:
              config:
                tags: ["critical"]
```

**Definition in `dbt_project.yml` (für ganze Ordner):**
```yaml
models:
  dbt_eth:
    staging:
      +tags: ["staging"]
    marts:
      finance:
        +tags: ["finance", "daily"]
```

**Selektion:**
```bash
dbt run --select tag:daily
dbt run --select tag:finance,tag:daily   # beide Tags müssen gesetzt sein
dbt test --select tag:critical
```

---

### Selector (YAML-Selektor)

**Selektoren** sind wiederverwendbare, benannte Selektionsregeln, die in `selectors.yml` definiert werden. Statt komplexe `--select`-Argumente zu wiederholen, referenziert man den Namen.

**`selectors.yml`:**
```yaml
selectors:
  - name: daily_finance_models
    description: "Alle täglich laufenden Finance-Modelle"
    definition:
      union:
        - method: tag
          value: daily
        - method: tag
          value: finance

  - name: nightly_full_build
    description: "Alles außer Snapshots"
    definition:
      difference:
        - method: fqn
          value: "*"
        - method: resource_type
          value: snapshot

  - name: changed_models_and_tests
    description: "Nur veränderte Modelle + ihre Tests"
    definition:
      intersection:
        - method: state
          value: modified+
        - method: resource_type
          value: test
```

**Verwendung:**
```bash
dbt run --selector daily_finance_models
dbt build --selector nightly_full_build
```

---

### ref()

`ref()` ist die zentrale Jinja-Funktion in dbt. Sie erstellt eine Abhängigkeit zwischen Modellen und löst automatisch den richtigen Schema-/Datenbank-Pfad auf.

```sql
-- models/marts/fct_orders.sql
SELECT
    o.order_id,
    o.amount,
    c.name AS customer_name
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_customers') }} c ON o.customer_id = c.customer_id
```

**Versionierte refs (dbt v1.5+):**
```sql
-- Referenz auf eine bestimmte Modellversion
SELECT * FROM {{ ref('stg_orders', version=2) }}
```

---

### source()

`source()` referenziert Rohdaten-Tabellen, die **nicht** von dbt erstellt wurden. Dadurch werden sie in den DAG eingebunden und können auf Freshness geprüft werden.

**Definition in `sources.yml`:**
```yaml
sources:
  - name: raw
    database: raw_db
    schema: public
    tables:
      - name: transactions
        loaded_at_field: _loaded_at
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}
```

**Verwendung im Modell:**
```sql
-- models/staging/stg_transactions.sql
SELECT * FROM {{ source('raw', 'transactions') }}
```

**Freshness prüfen:**
```bash
dbt source freshness
dbt source freshness --select source:raw.transactions
```

---

### Materialization

**Materialization** bestimmt, wie dbt ein Modell in der Datenbank speichert.

| Typ           | Beschreibung                                                  | Wann verwenden                        |
|---------------|---------------------------------------------------------------|---------------------------------------|
| `view`        | Erstellt eine View — keine Datenspeicherung                   | Staging, leichte Transformationen     |
| `table`       | Erstellt eine vollständige Tabelle bei jedem Run              | Kleine bis mittlere Datensätze        |
| `incremental` | Fügt nur neue/geänderte Daten hinzu                           | Große Tabellen, Append-only-Logs      |
| `ephemeral`   | Kein DB-Objekt — wird als CTE in abhängige Modelle eingebettet| Zwischenschritte ohne eigene Tabelle  |

**Konfiguration:**
```sql
-- models/marts/fct_events.sql
{{ config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='sync_all_columns'
) }}

SELECT *
FROM {{ ref('stg_events') }}
{% if is_incremental() %}
  WHERE event_date > (SELECT MAX(event_date) FROM {{ this }})
{% endif %}
```

**Global in `dbt_project.yml`:**
```yaml
models:
  dbt_eth:
    staging:
      +materialized: view
    marts:
      +materialized: table
```

---

### DAG (Directed Acyclic Graph)

Der **DAG** ist der gerichtete azyklische Abhängigkeitsgraph aller Nodes. dbt baut ihn automatisch aus `ref()`- und `source()`-Aufrufen. Er definiert die Ausführungsreihenfolge.

```
sources.raw.transactions
    └── stg_transactions        (staging)
            └── int_daily_volume  (intermediate)
                    └── fct_revenue   (mart)
                            └── exposure: Revenue Dashboard
```

**DAG-Traversal-Operatoren:**
```bash
dbt run --select +fct_revenue        # fct_revenue + alle Upstream-Nodes
dbt run --select fct_revenue+        # fct_revenue + alle Downstream-Nodes
dbt run --select 1+fct_revenue       # fct_revenue + 1 Upstream-Ebene
dbt run --select +fct_revenue+       # alles: upstream + node + downstream
```

---

### Config

**Config** sind Konfigurationsoptionen, die auf Modell-, Ordner- oder Projektebene gesetzt werden. Niedrigere Ebenen überschreiben höhere.

**Im Modell (höchste Priorität):**
```sql
{{ config(
    materialized='table',
    schema='finance',
    tags=['daily'],
    meta={'owner': 'finance-team'},
    pre_hook="GRANT SELECT ON {{ this }} TO ROLE reporter",
    post_hook="ANALYZE {{ this }}"
) }}
```

**In `schema.yml`:**
```yaml
models:
  - name: fct_revenue
    config:
      materialized: table
      tags: ["finance", "daily"]
      meta:
        owner: "finance-team"
```

**In `dbt_project.yml` (niedrigste Priorität):**
```yaml
models:
  dbt_eth:
    +materialized: view
    marts:
      +materialized: table
      +schema: marts
```

---

### Access (Sichtbarkeit)

**Access** steuert, welche Modelle von anderen Projekten oder Teams referenziert werden dürfen (dbt v1.5+).

| Level       | Bedeutung                                                   |
|-------------|-------------------------------------------------------------|
| `private`   | Nur innerhalb derselben Gruppe nutzbar                      |
| `protected` | Nur innerhalb desselben Projekts nutzbar (Default)          |
| `public`    | Kann von anderen dbt-Projekten via `ref()` genutzt werden   |

```yaml
models:
  - name: fct_revenue
    access: public

  - name: int_daily_volume
    access: private
    group: finance
```

---

### Group

**Groups** fassen Modelle zusammen und ermöglichen Access-Kontrolle. Jede Gruppe hat einen Owner.

**Definition in `groups.yml`:**
```yaml
groups:
  - name: finance
    owner:
      name: Finance Team
      email: finance@company.com
```

**Zuweisung:**
```yaml
models:
  - name: fct_revenue
    group: finance
    access: public

  - name: int_cost_center
    group: finance
    access: private
```

---

### Macro

**Macros** sind wiederverwendbare Jinja-Funktionen in `macros/*.sql`. Sie vermeiden Code-Duplikation.

**`macros/cents_to_dollars.sql`:**
```sql
{% macro cents_to_dollars(column_name) %}
    ({{ column_name }} / 100.0)::NUMERIC(18, 2)
{% endmacro %}
```

**Verwendung:**
```sql
SELECT
    order_id,
    {{ cents_to_dollars('amount_cents') }} AS amount_dollars
FROM {{ ref('stg_orders') }}
```

**Macro mit Default-Argument:**
```sql
{% macro limit_rows(n=100) %}
    {% if target.name == 'dev' %} LIMIT {{ n }} {% endif %}
{% endmacro %}

SELECT * FROM {{ ref('fct_revenue') }}
{{ limit_rows(500) }}
```

---

### Target & Profile

**Profile** speichern Verbindungsdaten (in `~/.dbt/profiles.yml`). **Target** ist die aktive Umgebung innerhalb eines Profils (z.B. `dev` vs. `prod`).

**`~/.dbt/profiles.yml`:**
```yaml
dbt_eth:
  target: dev
  outputs:
    dev:
      type: bigquery
      project: my-project-dev
      dataset: dbt_binh
      threads: 4

    prod:
      type: bigquery
      project: my-project-prod
      dataset: analytics
      threads: 16
```

**Target in Modellen nutzen:**
```sql
{% if target.name == 'prod' %}
    SELECT * FROM {{ ref('fct_revenue') }}
{% else %}
    SELECT * FROM {{ ref('fct_revenue') }} LIMIT 1000
{% endif %}
```

**CLI-Nutzung:**
```bash
dbt run --target prod
dbt run --target dev
```

---

### State

**State** ermöglicht es, nur Modelle auszuführen, die sich seit dem letzten Run geändert haben. Basis dafür ist `manifest.json` aus einem vorherigen Run.

```bash
# Nur veränderte Modelle
dbt run --select state:modified --state ./prod-manifest

# Veränderte Modelle + alle Downstream-Abhängigkeiten
dbt run --select state:modified+ --state ./prod-manifest

# Neue Modelle
dbt run --select state:new --state ./prod-manifest
```

**Typischer CI/CD-Workflow:**
```bash
# 1. Prod-Manifest herunterladen
dbt ls --target prod > /dev/null   # generiert manifest.json

# 2. Nur geänderte Modelle in CI bauen
dbt build --select state:modified+ --state ./prod-manifest
```

---

### Hooks

**Hooks** sind SQL-Befehle, die vor (`pre-hook`) oder nach (`post-hook`) einem Modell-Run ausgeführt werden.

```yaml
# In schema.yml
models:
  - name: fct_revenue
    config:
      pre_hook: "DELETE FROM {{ this }} WHERE is_test = TRUE"
      post_hook:
        - "GRANT SELECT ON {{ this }} TO ROLE reporter"
        - "ANALYZE {{ this }}"
```

```yaml
# Global in dbt_project.yml
models:
  +post-hook:
    - "GRANT SELECT ON {{ this }} TO ROLE bi_user"
```

---

### Exposures

**Exposures** dokumentieren, wie dbt-Daten genutzt werden (Dashboards, Reports, ML-Modelle). Sie erscheinen im DAG als Downstream-Nodes.

**`exposures.yml`:**
```yaml
exposures:
  - name: revenue_dashboard
    type: dashboard          # dashboard | notebook | analysis | ml | application
    maturity: high           # low | medium | high
    url: https://looker.company.com/dashboards/42
    description: "Tägliches Revenue-Dashboard für Finance"
    owner:
      name: Finance Team
      email: finance@company.com
    depends_on:
      - ref('fct_revenue')
      - ref('dim_customers')
```

**Selektion:**
```bash
dbt run --select +exposure:revenue_dashboard   # alle Upstream-Modelle des Dashboards
```

---

### Manifest (`manifest.json`)

Das **Manifest** ist das zentrale Artefakt, das dbt nach jedem Compile/Run erzeugt (`target/manifest.json`). Es enthält den vollständigen DAG mit allen Nodes, Konfigurationen und Abhängigkeiten.

```bash
# Manifest ohne Run erzeugen
dbt compile
dbt parse

# Typischer Inhalt
target/
  manifest.json      # vollständiger DAG (für state:modified genutzt)
  catalog.json       # Spalten-/Typ-Informationen aus der DB
  run_results.json   # Ergebnisse des letzten Runs
  sources.json       # Freshness-Ergebnisse
```
