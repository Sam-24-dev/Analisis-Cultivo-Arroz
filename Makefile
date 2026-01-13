# Rice Crop Analytics Platform
# Development automation commands

.PHONY: help install etl test serve clean

help:
	@echo "Available commands:"
	@echo "  make install  - Install Python dependencies"
	@echo "  make etl      - Run ETL pipeline"
	@echo "  make test     - Run unit tests"
	@echo "  make serve    - Start local development server"
	@echo "  make clean    - Remove generated files"

install:
	pip install -r requirements.txt

etl:
	python etl/extract_transform.py

test:
	python -m pytest tests/ -v

serve:
	cd web && python -m http.server 8000

clean:
	rm -rf __pycache__
	rm -rf etl/__pycache__
	rm -rf tests/__pycache__
	rm -rf .pytest_cache
