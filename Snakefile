TAXON_ID = config["taxon_id"]

if os.uname().sysname == "Darwin":
    # Don't use conda-forge unzip on macOS
    # Due to https://github.com/conda-forge/unzip-feedstock/issues/16
    unzip = "/usr/bin/unzip"
else:
    unzip = "unzip"


rule all:
    input:
        "results/groups.json"



rule fetch_ncbi_dataset_package:
    output:
        dataset_package="results/genbank_assembly.zip",
        report="results/ncbi_dataset/data/assembly_data_report.jsonl",
    params:
        taxon_id=TAXON_ID
        unzip=unzip,
    shell:
        """
        datasets download genome taxon {params.taxon_id} --assembly-source refseq --dehydrated  --filename genbank_assembly.zip
        {params.unzip} genbank_assembly.zip -d genbank_assembly
        datasets rehydrate --directory genbank_assembly
        """

rule get_assembly_groups:
    input:
        script="scripts/group_segments.py",
        report="results/ncbi_dataset/data/assembly_data_report.jsonl",
        ignore_list="error_sequences.txt",
    output:
        groups_json="results/groups.json",
    params:
        dataset_dir="results/genbank_assembly/ncbi_dataset/data",
    shell:
        """
        python {input.script} \
        --dataset-dir {params.dataset_dir} \
        --output-file {output.groups_json} \
        --ignore-list {input.ignore_list}
        """