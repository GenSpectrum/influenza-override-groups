# influenza-override-groups
This directory creates a JSON that contains the mapping of Influenza A and Influenza B genbank assemblies to segment accessions.

It can be used to create a mapping for any taxon by replacing the taxon-id and running:

```
micromamba create -f environment.yaml
micromamba activate grouping
snakemake --config taxon_id=197911
```

This repo builds on the work in https://github.com/anna-parker/influenza-a-groupings.
