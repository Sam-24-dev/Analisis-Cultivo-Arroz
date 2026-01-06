-- RICE CROP ANALYTICS SYSTEM
DROP DATABASE IF EXISTS Rice_Crop_DB;
CREATE DATABASE Rice_Crop_DB;
USE Rice_Crop_DB;

-- Drop users if they exist
DROP USER IF EXISTS 'crop_manager'@'localhost';
DROP USER IF EXISTS 'supervisor'@'localhost';
DROP USER IF EXISTS 'worker'@'localhost';
DROP USER IF EXISTS 'analyst'@'localhost';

CREATE TABLE employees (
    id CHAR(10) PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    phone CHAR(10) NOT NULL,
    email VARCHAR(50) UNIQUE,
    contract_date DATE NOT NULL,
    daily_salary DECIMAL(8,2) DEFAULT 15.00 CHECK (daily_salary > 0),
    specialty ENUM('General', 'Planting', 'Irrigation', 'Harvest', 'Application', 'Supervisor') DEFAULT 'General',
    status ENUM('Active', 'Inactive', 'Vacation') DEFAULT 'Active',
    manager_id CHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(id) ON DELETE SET NULL,
    CONSTRAINT chk_email CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE areas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    hectares DECIMAL(6,2) NOT NULL CHECK (hectares > 0),
    soil_type ENUM('Clay', 'Loam', 'Silt', 'Sandy') DEFAULT 'Clay',
    status ENUM('Available', 'In_Use', 'Resting', 'Maintenance') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area_id INT NOT NULL,
    name VARCHAR(30) NOT NULL,
    square_meters INT NOT NULL CHECK (square_meters > 0),
    coord_x DECIMAL(10,6),
    coord_y DECIMAL(10,6),
    active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_area FOREIGN KEY (area_id) REFERENCES areas(id) ON DELETE CASCADE,
    CONSTRAINT uk_location_area UNIQUE (area_id, name)
);

CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    area_id INT NOT NULL,
    location_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NULL,
    type ENUM('planting', 'application', 'irrigation', 'harvest') NOT NULL,
    status ENUM('Pending', 'In_Progress', 'Completed', 'Cancelled') DEFAULT 'Pending',
    description TEXT,
    estimated_cost DECIMAL(10,2) DEFAULT 0.00 CHECK (estimated_cost >= 0),
    real_cost DECIMAL(10,2) DEFAULT 0.00 CHECK (real_cost >= 0),
    priority ENUM('Low', 'Medium', 'High', 'Urgent') DEFAULT 'Medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_task_area FOREIGN KEY (area_id) REFERENCES areas(id) ON DELETE CASCADE,
    CONSTRAINT fk_task_location FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE,
    CONSTRAINT chk_dates CHECK (end_time IS NULL OR end_time >= start_time)
);

CREATE TABLE assignments (
    employee_id CHAR(10),
    task_id INT,
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    hours_worked DECIMAL(5,2) DEFAULT 0.00 CHECK (hours_worked >= 0),
    role ENUM('Supervisor', 'Worker', 'Assistant') DEFAULT 'Worker',
    notes TEXT,
    active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (employee_id, task_id),
    CONSTRAINT fk_assign_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_task FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE TABLE planting (
    task_id INT PRIMARY KEY,
    grain_type VARCHAR(30) NOT NULL DEFAULT 'Rice',
    variety VARCHAR(30) NOT NULL,
    seed_kg DECIMAL(8,2) NOT NULL CHECK (seed_kg > 0),
    sowing_density INT DEFAULT 150 CHECK (sowing_density > 0),
    method ENUM('Manual', 'Mechanized', 'Semi-mechanized') DEFAULT 'Manual',
    depth_cm DECIMAL(3,1) DEFAULT 2.5 CHECK (depth_cm > 0),
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_planting_task FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE TABLE application (
    task_id INT PRIMARY KEY,
    product VARCHAR(50) NOT NULL,
    type ENUM('Fertilizer', 'Pesticide', 'Herbicide', 'Fungicide') NOT NULL,
    concentration VARCHAR(20),
    liters DECIMAL(8,2) NOT NULL CHECK (liters > 0),
    cost_per_liter DECIMAL(6,2) DEFAULT 0.00 CHECK (cost_per_liter >= 0),
    application_time TIME NOT NULL,
    weather_condition ENUM('Sunny', 'Cloudy', 'Partly_Cloudy', 'Light_Rain') DEFAULT 'Sunny',
    equipment VARCHAR(50) DEFAULT 'Manual Pump',
    temp_celsius DECIMAL(4,1),
    humidity INT CHECK (humidity BETWEEN 0 AND 100),
    CONSTRAINT fk_app_task FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE TABLE irrigation (
    task_id INT PRIMARY KEY,
    water_liters INT NOT NULL CHECK (water_liters > 0),
    gas_tanks INT DEFAULT 1 CHECK (gas_tanks > 0),
    fuel_cost DECIMAL(8,2) DEFAULT 0.00 CHECK (fuel_cost >= 0),
    pump_pressure DECIMAL(4,1) DEFAULT 2.5 CHECK (pump_pressure > 0),
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    initial_water_level DECIMAL(4,1) DEFAULT 0.0,
    final_water_level DECIMAL(4,1),
    method ENUM('Flooding', 'Sprinkler', 'Drip', 'Intermittent') DEFAULT 'Flooding',
    CONSTRAINT fk_irrigation_task FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE TABLE harvests (
    task_id INT PRIMARY KEY,
    units_harvested DECIMAL(10,2) NOT NULL CHECK (units_harvested > 0), -- torvadas
    kg_equivalent DECIMAL(12,2) GENERATED ALWAYS AS (units_harvested * 181.4) STORED,
    machinery_count INT DEFAULT 1 CHECK (machinery_count > 0),
    machinery_cost DECIMAL(10,2) DEFAULT 0.00 CHECK (machinery_cost >= 0),
    humidity_pct DECIMAL(4,2) DEFAULT 14.00 CHECK (humidity_pct BETWEEN 10 AND 25),
    quality ENUM('First', 'Second', 'Third', 'Industrial') DEFAULT 'First',
    unit_price DECIMAL(8,2) DEFAULT 0.00 CHECK (unit_price >= 0),
    yield_per_hectare DECIMAL(8,2) DEFAULT 0.00,
    loss_kg DECIMAL(8,2) DEFAULT 0.00 CHECK (loss_kg >= 0),
    CONSTRAINT fk_harvest_task FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL,
    user VARCHAR(100) NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    record_id VARCHAR(50),
    old_values JSON,
    new_values JSON,
    details TEXT,
    INDEX idx_audit_time (timestamp),
    INDEX idx_audit_table (table_name)
);

-- Insert Initial Data (Translated)

INSERT INTO areas (name, hectares, soil_type, status) VALUES
('North Field', 5.5, 'Clay', 'In_Use'),
('South Field', 4.2, 'Loam', 'In_Use'),
('East Field', 3.8, 'Silt', 'Available'),
('West Field', 4.0, 'Sandy', 'Maintenance');

INSERT INTO locations (area_id, name, square_meters, coord_x, coord_y) VALUES
(1, 'Lot A1', 5000, -2.185400, -79.886600),
(1, 'Lot A2', 4500, -2.186000, -79.887000),
(1, 'Lot A3', 4000, -2.186500, -79.887500),
(2, 'Lot B1', 4200, -2.187000, -79.888000),
(2, 'Lot B2', 3800, -2.187500, -79.888500),
(3, 'Lot C1', 3800, -2.188000, -79.889000),
(4, 'Lot D1', 4000, -2.188500, -79.889500);

-- Employees
INSERT INTO employees (id, name, phone, email, contract_date, daily_salary, specialty, status, manager_id) VALUES
('0930492392', 'Kevin Mejía', '0991234567', 'kevin@rice.com', '2023-01-15', 35.00, 'Supervisor', 'Active', NULL);

INSERT INTO employees (id, name, phone, email, contract_date, daily_salary, specialty, status, manager_id) VALUES
('0925738347', 'Bob Martínez', '0991234568', 'bob@rice.com', '2023-02-01', 18.00, 'Planting', 'Active', '0930492392'),
('0946195734', 'Charlie López', '0991234569', 'charlie@rice.com', '2023-02-15', 20.00, 'Application', 'Active', '0930492392'),
('0285038323', 'David García', '0991234570', 'david@rice.com', '2023-03-01', 17.00, 'Irrigation', 'Active', '0930492392'),
('0782415632', 'Eve Rodríguez', '0991234571', 'eve@rice.com', '2023-03-15', 22.00, 'Harvest', 'Active', '0930492392'),
('0923456789', 'Ana Torres', '0991234572', 'ana@rice.com', '2023-04-01', 19.00, 'General', 'Active', '0930492392');

-- Tasks
INSERT INTO tasks (area_id, location_id, start_time, end_time, type, status, description, estimated_cost, real_cost, priority) VALUES
(1, 1, '2024-01-15 07:00:00', '2024-01-15 15:00:00', 'planting', 'Completed', 'Sowing INIAP-14 variety', 150.00, 145.50, 'High'),
(1, 2, '2024-01-16 08:00:00', '2024-01-16 16:00:00', 'planting', 'Completed', 'Sowing IR64 variety', 160.00, 158.00, 'High'),
(1, 1, '2024-02-01 06:00:00', '2024-02-01 10:00:00', 'application', 'Completed', 'Fertilizer 20-10-10 Application', 80.00, 75.00, 'Medium'),
(2, 4, '2024-02-15 05:30:00', '2024-02-15 11:30:00', 'irrigation', 'Completed', 'Maintenance Irrigation', 45.00, 42.00, 'High'),
(2, 5, '2024-05-01 06:00:00', '2024-05-03 18:00:00', 'harvest', 'Completed', 'Harvest Season 2024-1', 300.00, 285.00, 'Urgent'),
(3, 6, '2024-06-01 07:00:00', NULL, 'planting', 'Pending', 'Scheduled Sowing East Field', 140.00, 0.00, 'Medium');

-- Assignments
INSERT INTO assignments (employee_id, task_id, assigned_at, hours_worked, role, notes) VALUES
('0925738347', 1, '2024-01-15 06:30:00', 8.0, 'Worker', 'Excellent work sowing'),
('0930492392', 1, '2024-01-15 06:30:00', 8.0, 'Supervisor', 'Quality Control'),
('0925738347', 2, '2024-01-16 07:30:00', 8.0, 'Worker', 'Sowing completed on schedule'),
('0946195734', 3, '2024-02-01 05:45:00', 4.0, 'Worker', 'Precise fertilizer application'),
('0285038323', 4, '2024-02-15 05:00:00', 6.0, 'Worker', 'Irrigation completed smoothly'),
('0782415632', 5, '2024-05-01 05:30:00', 36.0, 'Worker', 'Successful harvest, good yield'),
('0930492392', 5, '2024-05-01 05:30:00', 36.0, 'Supervisor', 'Harvest supervision');

-- Specific Activities
INSERT INTO planting (task_id, grain_type, variety, seed_kg, sowing_density, method, depth_cm) VALUES
(1, 'Rice', 'INIAP-14', 125.5, 150, 'Manual', 2.5),
(2, 'Rice', 'IR64', 135.0, 160, 'Manual', 2.0);

INSERT INTO application (task_id, product, type, concentration, liters, cost_per_liter, application_time, weather_condition, equipment, temp_celsius, humidity) VALUES
(3, 'Urea + Complete', 'Fertilizer', '20-10-10', 45.5, 1.65, '07:30:00', 'Sunny', 'Motor Pump', 28.5, 65);

INSERT INTO irrigation (task_id, water_liters, gas_tanks, fuel_cost, pump_pressure, duration_minutes, initial_water_level, final_water_level, method) VALUES
(4, 15000, 2, 12.50, 2.8, 180, 0.5, 2.5, 'Flooding');

INSERT INTO harvests (task_id, units_harvested, machinery_count, machinery_cost, humidity_pct, quality, unit_price, loss_kg) VALUES
(5, 28.5, 3, 180.00, 14.2, 'First', 32.50, 45.20);