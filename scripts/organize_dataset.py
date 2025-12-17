#!/usr/bin/env python3
"""
Script to organize nuScenes dataset into the correct structure for CVT.
Uses symbolic links to avoid copying large files.
"""

import os
import json
from pathlib import Path
from tqdm import tqdm
import shutil

# Paths
NUSCENES_SOURCE = Path("/mnt/f16be684-4842-4b90-acc9-6565e6bd9d83/automni/dataset/nuscenes")
NUSCENES_TARGET = Path("/home/bevlog-1/Documents/bevlog/cross/cross_view_transformers/datasets/nuscenes")

def create_directory_structure():
    """Create the base directory structure."""
    print("📁 Creating directory structure...")
    
    dirs = [
        NUSCENES_TARGET,
        NUSCENES_TARGET / "samples",
        NUSCENES_TARGET / "sweeps",
        NUSCENES_TARGET / "maps" / "basemap",
        NUSCENES_TARGET / "maps" / "expansion",
    ]
    
    for dir_path in tqdm(dirs, desc="Creating directories"):
        dir_path.mkdir(parents=True, exist_ok=True)
    
    print("✅ Directory structure created\n")

def link_metadata():
    """Link or copy metadata files."""
    print("📋 Linking metadata (v1.0-trainval)...")
    
    source_meta = NUSCENES_SOURCE / "v1.0-trainval_meta" / "v1.0-trainval"
    target_meta = NUSCENES_TARGET / "v1.0-trainval"
    
    if target_meta.exists() and target_meta.is_symlink():
        target_meta.unlink()
    elif target_meta.exists():
        shutil.rmtree(target_meta)
    
    if source_meta.exists():
        os.symlink(source_meta, target_meta)
        print(f"✅ Linked: {source_meta} -> {target_meta}\n")
    else:
        print(f"⚠️  Warning: {source_meta} not found\n")

def link_maps():
    """Link map files."""
    print("🗺️  Linking maps...")
    
    source_maps = NUSCENES_SOURCE / "v1.0-trainval_meta" / "maps"
    
    if not source_maps.exists():
        print(f"⚠️  Warning: {source_maps} not found\n")
        return
    
    # Link basemap
    basemap_files = list(source_maps.glob("basemap/*.png"))
    for map_file in tqdm(basemap_files, desc="Linking basemap files"):
        target = NUSCENES_TARGET / "maps" / "basemap" / map_file.name
        if target.exists():
            target.unlink()
        os.symlink(map_file, target)
    
    # Link expansion
    expansion_files = list(source_maps.glob("expansion/*.png"))
    for map_file in tqdm(expansion_files, desc="Linking expansion files"):
        target = NUSCENES_TARGET / "maps" / "expansion" / map_file.name
        if target.exists():
            target.unlink()
        os.symlink(map_file, target)
    
    print(f"✅ Linked {len(basemap_files)} basemap files and {len(expansion_files)} expansion files\n")

def link_samples_and_sweeps():
    """Link all samples and sweeps from blob directories."""
    print("📸 Linking samples and sweeps from all blobs...")
    
    # Find all blob directories
    blob_dirs = sorted([d for d in NUSCENES_SOURCE.iterdir() 
                       if d.is_dir() and 'trainval' in d.name and 'blob' in d.name])
    
    print(f"Found {len(blob_dirs)} blob directories\n")
    
    # Count total files first
    print("🔢 Counting total files to link...")
    total_sample_files = 0
    total_sweep_files = 0
    
    sample_files_list = []
    sweep_files_list = []
    
    for blob_dir in tqdm(blob_dirs, desc="Scanning blobs"):
        samples_dir = blob_dir / "samples"
        if samples_dir.exists():
            for sensor_dir in samples_dir.iterdir():
                if sensor_dir.is_dir():
                    for sample_file in sensor_dir.iterdir():
                        sample_files_list.append((sample_file, sensor_dir.name))
                        total_sample_files += 1
        
        sweeps_dir = blob_dir / "sweeps"
        if sweeps_dir.exists():
            for sensor_dir in sweeps_dir.iterdir():
                if sensor_dir.is_dir():
                    for sweep_file in sensor_dir.iterdir():
                        sweep_files_list.append((sweep_file, sensor_dir.name))
                        total_sweep_files += 1
    
    print(f"Found {total_sample_files} sample files and {total_sweep_files} sweep files\n")
    
    # Link samples
    print("Linking samples...")
    for sample_file, sensor_name in tqdm(sample_files_list, desc="Linking sample files", total=total_sample_files):
        target_sensor_dir = NUSCENES_TARGET / "samples" / sensor_name
        target_sensor_dir.mkdir(exist_ok=True)
        
        target_file = target_sensor_dir / sample_file.name
        if not target_file.exists():
            os.symlink(sample_file, target_file)
    
    # Link sweeps
    print("\nLinking sweeps...")
    for sweep_file, sensor_name in tqdm(sweep_files_list, desc="Linking sweep files", total=total_sweep_files):
        target_sensor_dir = NUSCENES_TARGET / "sweeps" / sensor_name
        target_sensor_dir.mkdir(exist_ok=True)
        
        target_file = target_sensor_dir / sweep_file.name
        if not target_file.exists():
            os.symlink(sweep_file, target_file)
    
    print(f"✅ Linked {total_sample_files} sample files and {total_sweep_files} sweep files\n")

def verify_structure():
    """Verify the final structure."""
    print("🔍 Verifying structure...\n")
    
    checks = [
        (NUSCENES_TARGET / "v1.0-trainval", "Metadata directory"),
        (NUSCENES_TARGET / "samples", "Samples directory"),
        (NUSCENES_TARGET / "sweeps", "Sweeps directory"),
        (NUSCENES_TARGET / "maps" / "basemap", "Maps basemap directory"),
        (NUSCENES_TARGET / "maps" / "expansion", "Maps expansion directory"),
    ]
    
    all_good = True
    for path, description in checks:
        if path.exists():
            if path.is_dir():
                count = len(list(path.iterdir())) if path.is_dir() else 0
                print(f"✅ {description}: {count} items")
            else:
                print(f"✅ {description}: exists")
        else:
            print(f"❌ {description}: NOT FOUND")
            all_good = False
    
    # Count samples subdirectories
    if (NUSCENES_TARGET / "samples").exists():
        sensor_dirs = [d for d in (NUSCENES_TARGET / "samples").iterdir() if d.is_dir()]
        print(f"   └─ Sensor types in samples: {len(sensor_dirs)}")
        for sensor_dir in sensor_dirs:
            file_count = len(list(sensor_dir.iterdir()))
            print(f"      └─ {sensor_dir.name}: {file_count} files")
    
    # Count sweeps subdirectories
    if (NUSCENES_TARGET / "sweeps").exists():
        sensor_dirs = [d for d in (NUSCENES_TARGET / "sweeps").iterdir() if d.is_dir()]
        print(f"   └─ Sensor types in sweeps: {len(sensor_dirs)}")
        for sensor_dir in sensor_dirs:
            file_count = len(list(sensor_dir.iterdir()))
            print(f"      └─ {sensor_dir.name}: {file_count} files")
    
    print()
    if all_good:
        print("✅ Dataset structure is correct!")
    else:
        print("⚠️  Some issues found in dataset structure")
    
    return all_good

def main():
    print("=" * 60)
    print("nuScenes Dataset Organization Script")
    print("=" * 60)
    print()
    
    # Check if source exists
    if not NUSCENES_SOURCE.exists():
        print(f"❌ Error: Source directory not found: {NUSCENES_SOURCE}")
        return
    
    print(f"Source: {NUSCENES_SOURCE}")
    print(f"Target: {NUSCENES_TARGET}")
    print()
    
    # Execute steps
    try:
        create_directory_structure()
        link_metadata()
        link_maps()
        link_samples_and_sweeps()
        verify_structure()
        
        print("\n" + "=" * 60)
        print("✅ Dataset organization complete!")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n❌ Error occurred: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
