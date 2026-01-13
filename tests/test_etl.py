"""
Unit tests for ETL pipeline.
Run with: python -m pytest tests/ -v
"""

import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from etl.extract_transform import (
    translate,
    parse_number,
    load_csv,
    extract_data,
    transform_employees,
    transform_financial
)


class TestTranslate:
    def test_translate_known_value(self):
        mapping = {'Enero': 'January', 'Febrero': 'February'}
        assert translate('Enero', mapping) == 'January'
    
    def test_translate_unknown_value(self):
        mapping = {'Enero': 'January'}
        assert translate('Unknown', mapping) == 'Unknown'
    
    def test_translate_none(self):
        mapping = {'Enero': 'January'}
        assert translate(None, mapping) is None


class TestParseNumber:
    def test_parse_valid_integer(self):
        assert parse_number('42') == 42
    
    def test_parse_valid_float(self):
        assert parse_number('3.14') == 3.14
    
    def test_parse_empty_string(self):
        assert parse_number('') == 0
    
    def test_parse_none(self):
        assert parse_number(None) == 0
    
    def test_parse_invalid(self):
        assert parse_number('invalid') == 0
    
    def test_parse_with_default(self):
        assert parse_number('', default=-1) == -1


class TestLoadCSV:
    def test_load_existing_file(self):
        raw_dir = Path(__file__).parent.parent / "data" / "raw"
        if (raw_dir / "employee_productivity.csv").exists():
            data = load_csv("employee_productivity.csv")
            assert isinstance(data, list)
            assert len(data) > 0


class TestExtractData:
    def test_extract_returns_dict(self):
        raw_data = extract_data()
        assert isinstance(raw_data, dict)
    
    def test_extract_has_required_keys(self):
        raw_data = extract_data()
        expected_keys = ['employees', 'financial', 'areas', 'trends', 'recommendations']
        for key in expected_keys:
            assert key in raw_data


class TestTransformEmployees:
    def test_transform_employees_structure(self):
        raw_data = extract_data()
        employees = transform_employees(raw_data)
        assert isinstance(employees, list)
        if len(employees) > 0:
            emp = employees[0]
            assert 'name' in emp
            assert 'tasks_completed' in emp
            assert 'success_rate' in emp


class TestTransformFinancial:
    def test_transform_financial_structure(self):
        raw_data = extract_data()
        financial = transform_financial(raw_data)
        assert isinstance(financial, list)
        if len(financial) > 0:
            item = financial[0]
            assert 'activity_type' in item
            assert 'total_investment' in item


if __name__ == "__main__":
    import pytest
    pytest.main([__file__, "-v"])
