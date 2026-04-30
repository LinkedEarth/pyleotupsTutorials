# Understanding Data Providers: NOAA & PANGAEA

## Overview

PyleoTUPS integrates with two major paleoclimate data repositories to provide researchers with unified access to paleoclimate datasets. Understanding how these repositories work is essential for effectively using PyleoTUPS.

### Data Provider:

In PyleoTUPS, a "Data Provider" is a backend paleoclimate repository that:
- Hosts paleoclimate datasets (tree rings, ice cores, marine records, etc.)
- Provides search/query capabilities via an API or web interface
- Stores metadata (location, authors, time periods, variables measured)

PyleoTUPS works with:
a. NOAA
b. Pangaea

PyleoTUPS acts as a bridge between you and these repositories, handling API calls, data parsing, and format conversion so you don't have to.

---

## NOAA NCEI Paleoclimate Database

### What is NOAA?

The **National Oceanic and Atmospheric Administration (NOAA)** maintains the **NCEI Paleoclimate Global Monitoring Program**, one of the world's largest collections of paleoclimate data. 

### NOAA Data Organization

NOAA datasets are organized hierarchically:

![\[noaa_ER_diagram.png\]](../noaa_ER_diagram.png)

**Key Concepts:**
- **Study**: A research publication or dataset. Each study has a unique NOAA Study ID (e.g., `13156`)
- **Site**: A specific geographic location where measurements were taken
- **Data Table**: The actual data, often embedded in text files with varying file extensions and formats

**Entity Relations:**
In NOAA, data is organized in a hierarchical, one-to-many structure:

- A Study (a publication or dataset) can contain multiple Sites
- Each Site can contain multiple Paleo Data records
- Each Paleo Data entry can include multiple Data Files (e.g., CSV, TXT)
- Each Data File may correspond to one or more Data Tables [Generally, NOAA Template files have one table, however, old files contain multiple tables] 

### NOAA API Endpoints

PyleoTUPS uses the **NOAA NCEI Paleo Study Search API**:

```
Base URL: https://www.ncei.noaa.gov/access/paleo-search/api/study/search.json
```

The API accepts a rich set of query parameters [\[View complete list here\]](https://www.ncei.noaa.gov/access/paleo-search/api):

| Category | Parameter | Example |
|----------|-----------|---------|
| **Identifiers** | `noaa_id`, `xml_id` | `noaa_id=13156` |
| **Text** | `search_text` | `search_text="younger dryas"` |
| **People** | `investigators` | `investigators="Smith, JS"` |
| **Location** | `locations`, `min_lat`, `max_lat`, `min_lon`, `max_lon` | `min_lat=30, max_lat=40` |
| **Data Type** | `data_type_id` | `4` (Corals), `18` (Tree Ring) |
| **Variables** | `variable_name` (cvWhats), `cv_materials`, `cv_seasonalities` | `variable_name="Radial growth"` |
| **Time** | `earliest_year`, `latest_year`, `time_format`, `time_method` | `earliest_year=-8000` |
| **Elevation** | `min_elevation`, `max_elevation` | `min_elevation=0, max_elevation=3000` |
| **Pagination** | `limit`, `skip` | `limit=50, skip=100` |

### How PyleoTUPS Uses NOAA

When you call `NOAADataset.search_studies(**kwargs)`:

1. **Query Building** → Translates Pythonic parameter names to NOAA API names
2. **API Request** → Makes HTTP GET request to the NOAA study search endpoint
3. **Response Parsing** → Receives JSON containing study metadata and file URLs
4. **Data Registration** → Stores studies internally and builds indexes for efficient file lookups
5. **Returns** → A DataFrame summarizing found studies

Each study returned includes file URLs pointing to text/CSV/Excel files hosted on NOAA servers.

### Example NOAA Workflow

```python
import pyleotups as pt

ds = pt.NOAADataset()

# Search by ID (direct lookup)
df = ds.search_studies(noaa_id=13156)

# Search by location
df = ds.search_studies(min_lat=30, max_lat=40, min_lon=-100, max_lon=-80, limit=20)

# Search by data type (e.g., Tree rings)
df = ds.search_studies(data_type_id=18, limit=50)

# Get data from a study
df_data = ds.get_data("some_datatable_id")
```

---

## PANGAEA Database

### What is PANGAEA?

**PANGAEA** is a sophisticated scientific data repository operated by the **Center for Marine Environmental Sciences (MARUM)**. It hosts interdisciplinary datasets, with a growing collection of paleoclimate studies.

### PANGAEA Data Organization

PANGAEA organizes datasets differently than NOAA:

```
Dataset (standalone publication)
├── Metadata
│   ├── Title and description
│   ├── Authors/Investigators
│   ├── Publication DOI
│   ├── Funding Information
│   └── Topics
├── Data Tables
│   ├── Columns (parameters with units and descriptions)
│   ├── Geographic locations (one or more, often one per row)
│   └── Rows (measurements or observations)
└── Related Datasets
    └── Child datasets or related publications
```

**Key Concepts:**
- **Dataset**: A standalone data publication with a unique DOI and PANGAEA ID (e.g., `830587`)
- **Parameter** (or Column): A measured variable (e.g., "δ18O", "Age")
- **Event**: A data point with geographic/temporal metadata
- **Citation**: Every dataset has a formal reference that aligns with publication standards

```NOTE:
Unlike NOAA, one Pangaea Dataset contains only one Data Table i.e. 1 csv/tsv type file.   
```
### PANGAEA Query Interface

PANGAEA uses a **faceted search model** with advanced query syntax:

```
Base URL: https://www.pangaea.de/advanced/search.php
```

Query parameters and operators [\[View complete list here\]](https://wiki.pangaea.de/wiki/PANGAEA_search#:~:text=Searches%20in%20specific%20fields):

| Feature | Syntax | Example |
|---------|--------|---------|
| **Full-text** | `q=<text>` | `q=stable isotopes` |
| **Author** | `author:<name>` | `author:"Khider, D"` |
| **Parameter** | `parameter:<name>` | `parameter:"δ18O"` |
| **Topic** | `topic=<topic>` | `topic="Paleontology"` |
| **Geographic** | Bounding box | `minlon=-100&maxlon=-80&minlat=30&maxlat=40` |
| **Operators** | AND, OR, NOT | `(isotopes OR δ18O) AND paleoclimate` |
| **Field Search** | property:value | Multiple field combinations |

**Logical Operators:**
- `AND` (default): Both conditions must be met
- `OR`: Either condition can be met
- `NOT`: Exclude results matching the term
- Parentheses `()`: Group terms for precedence

### How PyleoTUPS Uses PANGAEA

When you call `PangaeaDataset.search_studies(**kwargs)`:

1. **Query Building** → Translates Python parameters into PANGAEA query syntax
2. **Query Execution** → Makes requests to PANGAEA search API via `pangaeapy` library
3. **Result Processing** → Retrieves dataset metadata and constructs summary DataFrames
4. **ID Registration** → Stores dataset IDs and metadata for later data retrieval
5. **Returns** → A DataFrame summarizing found datasets

PyleoTUPS uses the **`pangaeapy`** library (an existing wrapper for PANGAEA API) under the hood to handle low-level API interactions.

### Example PANGAEA Workflow

```python
import pyleotups as pt

ds = pt.PangaeaDataset()

# Search by ID (direct lookup)
df = ds.search_studies(study_ids=830587)

# Search by text
df = ds.search_studies(search_text="stable isotopes", limit=20)

# Search by parameter
df = ds.search_studies(variable_name="δ18O", limit=20)

# Search with geographic bounds
df = ds.search_studies(min_lat=-10, max_lat=10, min_lon=120, max_lon=160)

# Get data from a dataset
df_data = ds.get_data(830587)
```

---

## Comparison: NOAA vs. PANGAEA

### Data Model

| Aspect | NOAA | PANGAEA |
|--------|------|---------|
| **Structure** | Hierarchical (Study → Site → PaleoData → DataTable) | Flat (Dataset with multiple parameters) |
| **Geography** | Multiple sites per study | One or more events/locations per dataset |
| **Primary Focus** | Paleoclimate proxy records | Interdisciplinary geoscience data |
| **File Formats** | Legacy text formats, NOAA Templated Text formats, CSV, Excel | Standardized table format (tab-delimited), net-cdf |
| **Metadata** | Rich hierarchical structure | Standardized metadata fields |

### Query Capabilities

| Feature | NOAA | PANGAEA |
|---------|------|---------|
| **ID-Based Search** | Yes (NOAA ID, XML ID) | Yes (DOI, numeric ID) |
| **Full-Text** | Yes (Oracle syntax) | Yes (faceted search) |
| **Variable Filter** | Via cvWhats (controlled vocab) | Via parameter name (text-based) |
| **Geographic** | Bounding box | Bounding box |
| **Time Range** | Explicit earliest/latest year | Implicit in data timestamps |
| **Data Type** | Filtered via dataTypeID | Filtered via topic |
| **Authors** | Supported | Supported |
| **Multi-value Logic** | AND/OR operators | AND/OR operators |

### Data Access

| Aspect | NOAA | PANGAEA |
|--------|------|---------|
| **Files** | Links to remote files (text, CSV, Excel) | Tables accessed via API or download |
| **Parsing** | Complex legacy formats → requires dedicated parser | Standardized format → no parsing needed |
| **File Handling** | PyleoTUPS downloads and parses | pangaeapy handles retrieval |
| **Metadata in Data** | Embedded within files | Separate dataset-level metadata |

---

## For PyleoTUPS Users
- **Unified API**: Search both repositories with consistent Python syntax
- **Flexible workflow**: Choose the repository that best fits your research needs
- **Data integration**: Make use of datasets from multiple sources with metadata intact
- **Proxy comparison**: Cross-validate findings using multiple independent datasets

---

## Summary

PyleoTUPS bridges NOAA and PANGAEA by:

1. **Normalizing search parameters** into repository-specific query formats
2. **Abstracting repository differences** so users think in terms of paleoclimate concepts, not backend APIs
3. **Parsing diverse file formats** (especially NOAA's legacy formats)
4. **Providing unified access** to both searches and data retrieval
5. **Preserving metadata** throughout the data pipeline

In the next section, we'll explore how PyleoTUPS' architecture enables this unified interface.