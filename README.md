# influenza-override-groups

This repository contains a mapping of Influenza A and Influenza B genbank assemblies to segment accessions,
as well as the code to update this mapping.

Mapping files:

* `results/197911-groups.json` (Influenza A)
* `results/11520-groups.json` (Influenza B)

The files are updated automatically every night through GitHub actions.

## Getting Started

After cloning this repository, install dependencies using [pixi](https://pixi.sh):

```sh
pixi install
```

## Generating these files

Use the pixi tasks to regenerate the grouping files:

```sh
# For Influenza A
pixi run regenerate-influenza-a

# For Influenza B
pixi run regenerate-influenza-b
```

## What the script is doing

1. Download the metadata information for the assemblies from genbank and refseq.
2. Hydrate the assemblies, which means that the actual sequence information is downloaded.
3. For each assembly parse the `fna` file to find the segment names, and store the final JSON file.

For Influenza A, step 1 takes about 3 minutes, step 2 can take around 1 hour, and step 3 should take only 30 seconds.

## `error_sequences.txt`

This file contains a line-by-line list of sequences that cause pipeline errors. Often, this happens when two sequences in the same assembly are assigned to the same segment. In that case, we but all sequences from the assembly on the list.

Typically we get notified about a pipeline error through Slack, and then put the sequences on the list that caused the error.

## GitHub Actions to regenerate the grouping files

This repository also contains a GitHub action per organism, to regenerate the grouping JSON files.
The actions are scheduled to run once every night, and if changes to the groupings are found, a PR is created to update the grouping file.

## How these files are used

[Loculus](https://loculus.org/) can use these files during ingest, to override groups.
You can specify these files in the [ingest configuration](https://loculus.org/reference/helm-chart-config/#ingest-type) using the `grouping_override` setting by pointing directly to the file URL:

```yaml
grouping_override: "https://GenSpectrum.github.io/influenza-override-groups/results/197911-groups.json"
```

## Acknowledgements

This repository builds on the work in https://github.com/anna-parker/influenza-a-groupings.
