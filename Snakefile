TAXON_ID = config["taxon_id"]

if os.uname().sysname == "Darwin":
    # Don't use conda-forge unzip on macOS
    # Due to https://github.com/conda-forge/unzip-feedstock/issues/16
    unzip = "/usr/bin/unzip"
else:
    unzip = "unzip"

# Disable progress bars in CI environments
datasets_progress_flag = "--no-progressbar" if os.environ.get("CI") else ""


rule all:
    input:
        f"results/{TAXON_ID}-groups.json"



rule download_assemblies:
    """
    This rule simply downloads zip files of assemblies for a given organism. The assemblies are downloaded dehydrated,
    which means they don't actually contain any sequence data yet, only metadata and links for downloading the seq. data.
    This makes the download quite fast. The 'rehydration' is then done in another rule.
    """
    output:
        dataset_package="{source}_assembly.zip",
    params:
        taxon_id=TAXON_ID,
        progress_flag=datasets_progress_flag,
    shell:
        """
        datasets download genome taxon {params.taxon_id} \
            {params.progress_flag} \
            --assembly-source {wildcards.source} \
            --dehydrated \
            --filename {output.dataset_package}
        """

rule unzip_and_rehydrate_assemblies:
    """
    Unzips the downloaded, dehydrated assembly, and then rehydrates it. The rehydration can take quite a bit,
    but it can be restarted. Run this rule with --rerun-incomplete to let snakemake know that it can be safely restarted.
    """
    input:
        dataset_package="{source}_assembly.zip",
    output:
        report="{source}_assembly/ncbi_dataset/data/assembly_data_report.jsonl",
        marker="{source}_assembly/.rehydration_complete",
    params:
        unzip=unzip,
        output_dir="{source}_assembly",
        assembly_dir="{source}_assembly",
        progress_flag=datasets_progress_flag,
    shell:
        """
        {params.unzip} -o {input.dataset_package} -d {params.output_dir}
        datasets rehydrate \
            {params.progress_flag} \
            --directory {params.assembly_dir} \
        && touch {output.marker}
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