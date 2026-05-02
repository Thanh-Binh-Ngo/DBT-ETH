{% docs __overview__ %}

# Ethereum Analytics — dbt Projekt

Willkommen in der Dokumentation des **Ethereum Analytics** dbt-Projekts.

Dieses Projekt transformiert rohe Ethereum-Blockchain-Daten in analysierbare Modelle
für Dashboards und Berichte.

## Datenquellen

Die Rohdaten stammen aus drei Ethereum-Tabellen:

| Quelle | Beschreibung |
|---|---|
| `CONTRACTS` | Alle deployed Smart Contracts auf der Ethereum-Blockchain |
| `TOKEN_TRANSFERS` | Alle Token-Transfers ausgelöst durch Smart Contracts |
| `TRANSACTIONS` | Alle Transaktionen auf der Ethereum-Blockchain |

## Modell-Schichten

```
Quellen (src_eth)
    │
    ▼
Staging         → Rohe Selektion und Bereinigung der Quelldaten
    │
    ▼
Core            → Angereicherte Entitäten mit Joins und Aggregationen
    │
    ▼
Mart            → Fertige Tabellen für BI-Tools und Dashboards
```

## Mart-Modelle (Endprodukte)

- **mart_token_activity** — Tägliche Token-Transfer-Aktivität pro Contract
- **mart_contract_overview** — Vollständige Contract-Übersicht mit Deployment- und Aktivitätsdaten

## Kontakt

**Owner:** Binh Ngo
**E-Mail:** ngo.datasolutions@gmail.com

{% enddocs %}
