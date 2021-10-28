---
output: github_document
---

<!-- README.md is generated from README.Rmd. -->

# IFCB data formatting for EcoTaxa <img src="figures/IFCB_Rowan+EcoTaxa.JPG" align="right" height="185.5"/>

<!-- badges: start -->

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT) [![R 4.1.1](https://img.shields.io/badge/R-4.1.1-red.svg)](https://www.r-project.org/)

<!-- badges: end -->

This repository shows how to easily format IFCB data that are stored in a database, with or without manual annotation, into a format suitable to be imported in EcoTaxa.

This is especially useful to:

1.  Import in EcoTaxa images that were manually annotated with another tool such as ifcb-annotate (either for validation or to use as training set for non annotated images)
2.  Export non-annotated images to classify them in EcoTaxa

## EcoTaxa format

EcoTaxa imports and exports metadata of images with specific column names. The importation requires:

1.  a zip file of all the images you want to import
2.  a tsv file with the metadata associated (including the classification)

<p align="center">
  <img src="figures/D20190124T213523_IFCB120_00096.png" />
</p>

In the file each row corresponds to one image, the headers being standardized categories for EcoTaxa and the second row indicating the type of each column (float or text). The columns for the image above would look like that:

![](figures/example_categories.png)

Note that the actual EcoTaxa headers are longer and preceded by "object\_", "object_annotation" or "acq\_". They can be found in the example file *data/ecotaxa_example_1image.tsv*.

## IFCB format

The default data processing for the IFBC images extracts the blobs (.png) and the features (.csv) for each sample and stores the images in MATLAB .mat files. These data can be stored in a database in order to be readily and easily accessible. Every database is different so the sql queries will have to be adapted.

For reference, the database designed by Audrey Ciochetto for the Mouw lab look like that: the main tables needed for the export to EcoTaxa are the *raw_files* table with all the samples metadata which connects to the *roi table* with every image, the *class* table records all the classes used and their equivalence in other systems and the *manual_class* the manually annotated images with their annotation.

![](figures/mouwlab_database.JPG)

## Installation

You can either clone this repository or download the scrpts that are of interest for you.

```{bash}
git clone https://github.com/VirginieSonnet/IFCBdatabaseToEcotaxa.git
```

## Run

<u> Credit</u>: composite image created by Rowan Cirivello.
