# PyleoTUPS Functionalities: A Unified Interface to Paleoclimate Data

## Overview

PyleoTUPS presents a **unified Python interface** to two fundamentally different paleoclimate data repositories: **NOAA NCEI Paleoclimate** and **PANGAEA**. Although these repositories organize data differently, use different search interfaces, and provide data in different formats, PyleoTUPS lets you work with both using the **same Python methods and parameters**.

This document explains what PyleoTUPS does for you and how to use it, regardless of which repository you're accessing.

For detailed information about NOAA and PANGAEA themselves, see `DataProviders.md`.

---

## Why a Unified Interface?

### The Problem
- **NOAA** has a hierarchical structure with rich metadata but complex legacy file formats
- **PANGAEA** has clean standardized tables but a simpler, flatter organization
- **Researchers** want to access both but don't want to learn two completely different APIs

### The Solution
PyleoTUPS wraps both backends with a single Python API:
- Same method names work for both (`search_studies()`, `get_data()`, etc.)
- Same parameter names for common searches (`search_text`, `min_lat`, `max_lat`, etc.)
- Consistent output format (pandas DataFrames with predictable columns)
- Automatic handling of provider differences (you don't need to worry about them)

### What This Means for You
Write your Python code in one style. It works with NOAA, PANGAEA, or both.

---

## The Unified Interface: Visual Overview

```
┌────────────────────────────────────────────────────────────────┐
│              YOUR PYTHON CODE (Same for Both)                  │
│                                                                │
│  dataset = pt.NOAADataset()                                    │
│  # OR                                                          │
│  dataset = pt.PangaeaDataset()                                 │
│                                                                │
│  # SAME METHODS & PARAMETERS FOR BOTH                          │
│  results = dataset.search_studies(                             │
│      search_text="tree rings",          ← Works for both       │
│      min_lat=30, max_lat=40,            ← Works for both       │
│      investigators="Smith, J",          ← Works for both       │
│      limit=50                           ← Works for both       │
│  )                                                             │
└────────────────────────┬───────────────────────────────────────┘
                         │
         ┌───────────────┴────────────────┐
         ▼                                ▼
    ╔─────────────╗              ╔──────────────╗
    ║  NOAA API   ║              ║ PANGAEA API  ║
    ║ (Converted  ║              ║ (Converted   ║
    ║ internally) ║              ║ internally)  ║
    ╚─────────────╝              ╚──────────────╝
         │                                │
         └───────────────┬────────────────┘
                         ▼
        ╔──────────────────────────────────╗
        │   SAME OUTPUT (pandas DataFrame) │
        │  ├─ Identical column names       │
        │  ├─ Predictable structure        │
        │  └─ Ready for analysis           │
        ╚──────────────────────────────────╝
```

---

## The Six Core Methods (Work Identically for Both)

All of these methods work the same way whether you're using `NOAADataset` or `PangaeaDataset`:

### 1. search_studies()

**What it does**: Search and filter studies based on your criteria

**Common parameters** (work for both providers):
- `search_text` – Free-text search (e.g., "δ18O", "paleoclimate reconstructions")
- `min_lat`, `max_lat`, `min_lon`, `max_lon` – Geographic bounding box (degrees)
- `investigators` – Author/researcher names
- `variable_name` – Measured variable (e.g., "ring width", "oxygen isotope")
- `limit` – Maximum number of results (default: 100)
- `skip` – Offset for pagination

**Returns**: DataFrame with study overview
- Columns: `study_id`, `title`, `authors`, `year`, `location`, `data_type`, `summary`

**Example**:
```python
ds = pt.NOAADataset()  # Same code works for pt.PangaeaDataset()
results = ds.search_studies(
    search_text="tree rings",
    min_lat=30,
    max_lat=40,
    limit=20
)
print(results.head())  # Identical format from either provider
```

---

### 2. get_summary()

**What it does**: Get a comprehensive summary of all studies you've found

**Parameters**: None

**Returns**: DataFrame with all registered studies
- Columns: `study_id`, `title`, `authors`, `year`, `location`, `data_type`, `geographic_bounds`, `summary_info`

**Use case**: Review all studies from your search before downloading data

**Example**:
```python
ds.search_studies(search_text="paleoclimate")
summary = ds.get_summary()
# See all studies found
```

---

### 3. get_publications()

**What it does**: Get publication and citation information for all studies

**Parameters**: None

**Returns**: DataFrame with bibliographic information
- Columns: `study_id`, `citation`, `doi`, `journal`, `year`, `authors`

**Use case**: Properly cite the datasets you download in your research papers

**Example**:
```python
publications = ds.get_publications()
# Get ready-to-use citations for your bibliography
print(publications[['citation', 'doi']])
```

---

### 4. get_funding()

**What it does**: Get funding source information for all studies

**Parameters**: None

**Returns**: DataFrame with funding details
- Columns: `study_id`, `funding_agency`, `grant_number`, `award_title`

**Use case**: Understand who funded the research, acknowledge funding sources

**Example**:
```python
funding = ds.get_funding()
# Shows which agencies (NSF, NOAA, etc.) supported each study
```

---

### 5. get_geo()

**What it does**: Get geographic and site-level information for all studies

**Parameters**: None

**Returns**: DataFrame with location details
- Columns: `site_id`, `latitude`, `longitude`, `elevation`, `site_name`, `location_details`

**Use case**: Understand where measurements were taken, plan field visits, visualize study locations

**Example**:
```python
locations = ds.get_geo()
# All sites with coordinates—ready for mapping
print(locations[['site_name', 'latitude', 'longitude']])
```

---

### 6. get_data(identifier)

**What it does**: Extract the actual measurement data from a study

**Parameters**:
- `identifier` – Study ID or DOI (string)

**Returns**: DataFrame with measurements + metadata
- **Columns**: Time axis (age, depth, or year), measured values (δ18O, ring width, etc.), uncertainty
- **Attributes**: Units, variable descriptions, measurement methods, data source, study metadata

**Use case**: Get the actual numbers to analyze in your research

**Example**:
```python
# Get data from a specific study
data = ds.get_data("<Some ID>")

# Access measurements
print(data)
# Output: age, value, uncertainty columns

# Access metadata attached to the data
print(data.attrs)
# Output: variables, StudyId, etc.
```

---

## Provider-Specific Features (Optional Extensions)

For most uses, the common parameters above are sufficient. However, each provider has additional filters available if you need them.

### NOAA-Specific Search Parameters

Available when using `NOAADataset.search_studies()`:

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `noaa_id` | Direct lookup by NOAA Study ID | `noaa_id=13156` |
| `data_type_id` | Filter by archive type | `data_type_id=18` (tree rings), `4` (corals), `1` (boreholes) |
| `locations` | Hierarchical geographic filter | `locations="Africa>Kenya"` |
| `species` | Tree species filter (4-letter codes) | `species="PIAM"` (Pinus aristata) |
| `cv_materials` | Material type filter | Follow NOAA PaST thesaurus |
| `cv_seasonalities` | Seasonal information | Follow NOAA PaST thesaurus |
| `earliest_year`, `latest_year` | Time window | `earliest_year=-8000, latest_year=-1000` (BP/CE) |
| `min_elevation`, `max_elevation` | Elevation range in meters | `min_elevation=0, max_elevation=3000` |
| `reconstruction` | Climate reconstructions only | `reconstruction=True` |

**When to use**: When `search_text` and location filters aren't specific enough

**Example**:
```python
noaa_ds = pt.NOAADataset()
# Advanced search: tree ring data from high elevations in the Alps
results = noaa_ds.search_studies(
    data_type_id=18,           # Tree rings
    locations="Europe>Alps",   # Hierarchical location
    min_elevation=1500,        # High elevation
    limit=50
)
```

---

### PANGAEA-Specific Search Parameters

Available when using `PangaeaDataset.search_studies()`:

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `topic` | Filter by research topic | `topic="Paleontology"`, `"Cryosphere"`, `"Oceans"`, `"Atmosphere"` |

**When to use**: To filter by broad research categories

**Example**:
```python
pangaea_ds = pt.PangaeaDataset()
# Find all paleontology-related datasets
results = pangaea_ds.search_studies(
    topic="Paleontology",
    search_text="holocene",
    limit=50
)
```

---

## Side-by-Side Comparison

```
SHARED (Both Providers)              PROVIDER-SPECIFIC
═══════════════════════════════════  ════════════════════════════════

Methods:                             NOAA-Only Filters:
├─ search_studies()                  ├─ data_type_id (archive type)
├─ get_summary()                     ├─ species (tree codes)
├─ get_publications()                ├─ elevation range
├─ get_funding()                     ├─ time window (CE/BP)
├─ get_geo()                         ├─ hierarchical locations
└─ get_data()                        └─ controlled vocabulary

Common Parameters:                   PANGAEA-Only:
├─ search_text                       └─ topic (Paleontology, etc.)
├─ min_lat, max_lat
├─ min_lon, max_lon
├─ investigators
├─ variable_name
├─ limit
└─ skip

Same Output Format:                  Internal Differences (You Don't See):
├─ columns identical                 ├─ NOAA: Various file formats
├─ column names consistent           ├─ PANGAEA: Standardized format
└─ data types predictable            └─ Speed (NOAA slower for first download)
```

---

## What Information You Get

### From search_studies() or get_summary()

```
Columns you receive:
├── study_id              : Unique identifier
├── title                 : Study title
├── authors               : Research team members
├── year                  : Publication year
├── data_type             : Type of paleoclimate data
├── geographic_bounds     : Region covered (lat/lon)
└── summary_info          : Brief description
```

### From get_publications()

```
Columns you receive:
├── study_id              : Which study?
├── citation              : Full bibliographic reference
├── doi                   : Digital Object Identifier
├── journal               : Journal name
└── year                  : Published year
```

### From get_funding()

```
Columns you receive:
├── study_id              : Which study?
├── funding_agency        : Organization (NSF, NOAA, etc.)
├── grant_number          : Award ID
└── award_title           : Project name
```

### From get_geo()

```
Columns you receive:
├── site_id               : Unique site identifier
├── latitude              : Degrees North
├── longitude             : Degrees East
├── elevation             : Meters above sea level
├── site_name             : Location name
└── location_details      : Additional geographic info
```

### From get_data(identifier)

```
A Pandas Dataframe with optional columns like:
├── age / depth / year    : Time axis (format varies by data type)
├── value                 : The actual measurement (δ18O, ring width, etc.)
└── uncertainty           : Measurement error / precision

```

---

## Practical Differences You Might Notice

| Aspect | NOAA | PANGAEA | What to Expect |
|--------|------|---------|-----------------|
| **Search options** | Many detailed filters | Simpler filters | NOAA for precise queries, PANGAEA for broad searches |
| **Data extraction** | Slower (parses legacy formats) | Faster (clean format) | NOAA first download takes longer |
| **Metadata detail** | Site-level (sites within studies) | Dataset-level | NOAA tells you exactly where each point was measured |
| **Data consistency** | Varies (legacy formats) | Standardized (FAIR) | PANGAEA easier to combine across studies |
| **Search breadth** | Fewer results (curated) | More results (interdisciplinary) | May need more filtering for PANGAEA |

---

## Quick Reference: What to Use

| Your Goal | Use This Method | Works With |
|-----------|-----------------|-----------|
| Find relevant studies | `search_studies()` + common parameters | Both NOAA & PANGAEA |
| Review all results | `get_summary()` | Both |
| Cite your datasets | `get_publications()` | Both |
| Acknowledge funders | `get_funding()` | Both |
| Map study locations | `get_geo()` | Both |
| Get actual measurements | `get_data(study_id)` | Both |
| Need NOAA-specific filters | Add `data_type_id`, `species`, `elevation`, etc. | NOAA only |
| Filter PANGAEA by topic | Add `topic` parameter | PANGAEA only |

---

## Key Takeaway

**Majority of your work uses the common methods.** Only use provider-specific parameters when you need fine-grained control.

The unified interface means:
- ✓ Learn PyleoTUPS once, use it everywhere
- ✓ Switch between NOAA and PANGAEA with one line of code
- ✓ Get consistent output regardless of provider
- ✓ Focus on your paleoclimate research, not API differences

---

## Next Steps

- See **DataProviders.md** for details on NOAA and PANGAEA repositories
- See **Tutorials** for step-by-step workflows and code examples
- See **API Reference** for complete parameter documentation
