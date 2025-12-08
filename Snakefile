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



rule download_and_unzip_assemblies:
    output:
        dataset_package="{source}_assembly.zip",
        report="{source}_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
    params:
        taxon_id=TAXON_ID,
        unzip=unzip,
        output_dir="{source}_assembly",
    shell:
        """
        datasets download genome taxon {params.taxon_id} --assembly-source {wildcards.source} --dehydrated --filename {output.dataset_package}
        {params.unzip} {output.dataset_package} -d {params.output_dir}
        """

rule rehydrate_assemblies:
    input:
        report="{source}_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
    output:
        marker="{source}_assembly/.rehydration_complete",
    params:
        assembly_dir="{source}_assembly",
    shell:
        """
        datasets rehydrate --directory {params.assembly_dir} && touch {output.marker}
        """

rule get_assembly_groups:
    input:
        script="scripts/group_segments.py",
        report_genbank="genbank_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
        report_refseq="refseq_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
        rehydration_genbank="genbank_assembly/.rehydration_complete",
        rehydration_refseq="refseq_assembly/.rehydration_complete",
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