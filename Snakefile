TAXON_ID = config["taxon_id"]

if os.uname().sysname == "Darwin":
    # Don't use conda-forge unzip on macOS
    # Due to https://github.com/conda-forge/unzip-feedstock/issues/16
    unzip = "/usr/bin/unzip"
else:
    unzip = "unzip"


rule all:
    input:
        f"results/{TAXON_ID}-groups.json"



rule fetch_refseq_assemblies:
    output:
        dataset_package="refseq_assembly.zip",
        report="refseq_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
    params:
        taxon_id=TAXON_ID,
        unzip=unzip,
    shell:
        """
        datasets download genome taxon {params.taxon_id} --assembly-source refseq --dehydrated  --filename refseq_assembly.zip
        {params.unzip} refseq_assembly.zip -d refseq_assembly
        datasets rehydrate --directory refseq_assembly
        """

rule fetch_genbank_assemblies:
    output:
        dataset_package="genbank_assembly.zip",
        report="genbank_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
    params:
        taxon_id=TAXON_ID,
        unzip=unzip,
    shell:
        """
        datasets download genome taxon {params.taxon_id} --assembly-source genbank --dehydrated  --filename genbank_assembly.zip
        {params.unzip} genbank_assembly.zip -d genbank_assembly
        datasets rehydrate --directory genbank_assembly
        """

rule get_assembly_groups:
    input:
        script="scripts/group_segments.py",
        report_genbank="genbank_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
        report_refseq="refseq_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
        ignore_list="error_sequences.txt",
    output:
        groups_json="results/{TAXON_ID}-groups.json",
    params:
        genbank_dir="genbank_assembly/ncbi_dataset/data",
        refseq_dir="refseq_assembly/ncbi_dataset/data",
    shell:
        """
        python {input.script} \
        --dataset-dir {params.genbank_dir} \
        --dataset-dir {params.refseq_dir} \
        --output-file {output.groups_json} \
        --ignore-list {input.ignore_list}
        """