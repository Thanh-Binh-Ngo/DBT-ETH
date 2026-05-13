## dbt_eth

dbt-Projekt für Ethereum-Blockchain- und Finanzdaten (Yahoo Finance).

---

## Projektstruktur

```
models/
├── staging/    # Rohdaten aus Quellsystemen (views)
├── core/       # Angereicherte und transformierte Modelle (tables)
└── mart/       # Finale Modelle für BI-Tools und Dashboards (views)
```

---

## Ausführung mit Make

Alle dbt-Befehle werden über das `Makefile` ausgeführt. Nach jedem Run wird
`target/manifest.json` automatisch nach `state/manifest.json` kopiert — die
Grundlage für Slim CI.

### Erster Run

```bash
make run
# oder
make build
```

### Ab dem zweiten Run — nur geänderte Modelle (Slim CI)

```bash
make run ARGS="--select state:modified+ --state state/"
make build ARGS="--select state:modified+ --state state/"
```

dbt vergleicht den aktuellen Stand mit dem letzten gespeicherten `state/manifest.json`
und führt nur Modelle aus, die sich geändert haben — inklusive ihrer Downstream-Abhängigkeiten (`+`).

### Mit zusätzlichen Selektoren

```bash
make run ARGS="--select tag:finance"
make run ARGS="--select state:modified+ --state state/ --fail-fast"
make test ARGS="--select tag:core"
```

---

## Slim CI — Ablauf

```
1. make run/build
       ↓
2. dbt führt Modelle aus
       ↓
3. target/manifest.json → state/manifest.json (automatisch)
       ↓
4. Nächster Run: --select state:modified+ --state state/
       ↓
5. Nur geänderte Modelle + Downstream werden neu gebaut
```

---

## Verfügbare Make-Targets

| Befehl            | Beschreibung                                      |
|-------------------|---------------------------------------------------|
| `make run`        | `dbt run` + manifest nach state/ kopieren         |
| `make build`      | `dbt build` + manifest nach state/ kopieren       |
| `make test`       | `dbt test`                                        |
| `make seed`       | `dbt seed` + manifest nach state/ kopieren        |
| `make snapshot`   | `dbt snapshot` + manifest nach state/ kopieren    |
| `make compile`    | `dbt compile`                                     |
| `make clean`      | `dbt clean`                                       |

---

## Ressourcen

- [dbt Dokumentation](https://docs.getdbt.com/docs/introduction)
- [dbt Community Slack](https://community.getdbt.com/)
- [dbt Blog](https://blog.getdbt.com/)
