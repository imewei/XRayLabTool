#!/usr/bin/env python3
"""
Convert NIST X-ray optical constants raw data to JSON and CSV formats.
"""

import json
import csv
import os
from pathlib import Path


def parse_nist_file(filepath):
    """Parse NIST raw data file and extract energy, f1, f2 values."""
    data = {
        'energy_keV': [],
        'f1': [],
        'f2': [],
        'metadata': {}
    }
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    # Extract metadata from comments
    material_name = ""
    density = None
    atomic_number = None
    
    for line in lines:
        line = line.strip()
        if line.startswith('#'):
            if 'Z =' in line:
                atomic_number = int(line.split('Z =')[1].strip())
            elif 'Density:' in line:
                density = float(line.split('Density:')[1].split('g/cm3')[0].strip())
            elif '(' in line and ')' in line:
                # Extract material name from first comment line
                if not material_name:
                    start = line.find('(')
                    end = line.find(')')
                    if start != -1 and end != -1:
                        material_name = line[start+1:end]
            continue
            
        if line and not line.startswith('#'):
            parts = line.split()
            if len(parts) >= 3:
                try:
                    energy = float(parts[0])
                    f1 = float(parts[1])
                    f2 = float(parts[2])
                    
                    data['energy_keV'].append(energy)
                    data['f1'].append(f1)
                    data['f2'].append(f2)
                except ValueError:
                    continue
    
    # Store metadata
    data['metadata'] = {
        'material': material_name,
        'source': 'NIST X-ray Form Factor, Attenuation and Scattering Tables',
        'atomic_number': atomic_number,
        'density_g_cm3': density,
        'description': f'X-ray optical constants for {material_name}',
        'columns': {
            'energy_keV': 'Photon energy in keV',
            'f1': 'Real part of atomic scattering factor',
            'f2': 'Imaginary part of atomic scattering factor'
        }
    }
    
    return data


def save_as_json(data, filepath):
    """Save data as JSON file."""
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)


def save_as_csv(data, filepath):
    """Save data as CSV file."""
    with open(filepath, 'w', newline='') as f:
        writer = csv.writer(f)
        
        # Write header
        writer.writerow(['energy_keV', 'f1', 'f2'])
        
        # Write data
        for i in range(len(data['energy_keV'])):
            writer.writerow([
                data['energy_keV'][i],
                data['f1'][i],
                data['f2'][i]
            ])


def main():
    """Convert all NIST raw files to JSON and CSV formats."""
    script_dir = Path(__file__).parent
    
    materials = ['Si', 'SiO2', 'H2O', 'Au']
    
    for material in materials:
        raw_file = script_dir / f"{material}_nist_raw.txt"
        json_file = script_dir / f"{material}_optical_constants.json"
        csv_file = script_dir / f"{material}_optical_constants.csv"
        
        if raw_file.exists():
            print(f"Processing {material}...")
            data = parse_nist_file(raw_file)
            
            # Save as JSON
            save_as_json(data, json_file)
            print(f"  Saved JSON: {json_file}")
            
            # Save as CSV
            save_as_csv(data, csv_file)
            print(f"  Saved CSV: {csv_file}")
        else:
            print(f"Warning: {raw_file} not found")


if __name__ == "__main__":
    main()
