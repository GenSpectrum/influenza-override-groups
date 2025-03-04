# influenza-override-groups
This repo builds on the work in https://github.com/anna-parker/influenza-a-groupings.

```
micromamba create -f environment.yaml
micromamba activate grouping
snakemake --config taxon_id=197911
```