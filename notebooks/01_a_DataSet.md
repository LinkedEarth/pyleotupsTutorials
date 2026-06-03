# Data, Dataset, Data Repository, Database

The tutorials will make use of concepts surrounding what most researchers refer to as "data" that we seek to clarify. 

**Data** is the most elemental — raw, unprocessed observations, measurements, or facts. A column of Mg/Ca values or temperature reconstruction. Data has meaning only in context; on its own it's just values.

**Metadata** is data about data, the contextual information that makes raw data interpretable, discoverable, and reusable. It answers questions like: who collected this? when and where? using what instrument or method? in what units? with what uncertainty? Metadata is what transforms a column of numbers into something scientifically meaningful. It exists at multiple levels: a single variable (units, precision), a dataset (title, authors, geographic coverage, publication), or a repository (submission standards, controlled vocabularies). Without metadata, data is effectively opaque.

**Dataset** is a structured, bounded collection of data that belongs together by virtue of a shared purpose, provenance, or methodology. It implies some coherence: a defined set of variables, a time range, a geographic scope, a documented collection process. A dataset is something you can cite, version, and describe with metadata. The boundary between "data" and "dataset" is blurry at the small end, but a dataset carries implicit claims about completeness and curation.

**Compilation** is a collection of datasets that belong together by virtue of shared purpose, provenance or methodology. For instance, the [`Temp12k` study](https://doi.org/10.1038/s41597-020-0530-7) is a collection.  

**Data Repository** is an infrastructure for storing, discovering, and accessing datasets — it's a place, not a thing you analyze directly. PANGAEA, Neotoma, NOAA Paleoclimate, and Zenodo are repositories. A repository holds many datasets and compilations contributed by many people; its job is preservation, discoverability, and access. Repositories have submission policies, accession numbers or DOIs, and curation workflows. They also typically enforce or encourage metadata standards, which is what makes cross-dataset discovery possible.

**Database** is a technical system for storing and querying structured data, managed by a database management system. The emphasis is on the management layer: schemas, indexing, query languages (SQL, SPARQL, etc.), transactions, access control. A database can back a repository (PANGAEA's search interface sits on top of databases), but a database is defined by its queryability and data model, not its curatorial mission. You can have a private internal database that isn't a repository at all.

Data is a measurement, metadata is the label on the measurement, a dataset is a labeled box of measurements, a repository is a library that holds many labeled boxes with a catalog, and a database is the filing and retrieval system the library uses internally.

Because repositories have different missions, they may have different metadata requirements, making interoperability difficult. PyleoTUPS helps create a uniform interface to work with the two largest repositories of paleoclimate datasets: [NOAA NCEI for Paleoclimatology](https://www.ncei.noaa.gov/products/paleoclimatology) and [PANGAEA](https://www.pangaea.de). 