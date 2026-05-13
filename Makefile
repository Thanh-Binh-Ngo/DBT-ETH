.PHONY: run build test seed snapshot compile clean

STATE_DIR = state
TARGET_DIR = target
MANIFEST = manifest.json

run:
	dbt run $(ARGS)
	cp $(TARGET_DIR)/$(MANIFEST) $(STATE_DIR)/$(MANIFEST)

build:
	dbt build $(ARGS)
	cp $(TARGET_DIR)/$(MANIFEST) $(STATE_DIR)/$(MANIFEST)

test:
	dbt test $(ARGS)

seed:
	dbt seed $(ARGS)
	cp $(TARGET_DIR)/$(MANIFEST) $(STATE_DIR)/$(MANIFEST)

snapshot:
	dbt snapshot $(ARGS)
	cp $(TARGET_DIR)/$(MANIFEST) $(STATE_DIR)/$(MANIFEST)

compile:
	dbt compile $(ARGS)

clean:
	dbt clean
