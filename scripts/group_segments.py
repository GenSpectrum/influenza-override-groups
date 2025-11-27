import os
from Bio import SeqIO
import json
import click

@click.command()
@click.option(
    "--dataset-dir",
    required=True,
    type=click.Path(exists=True),
    multiple=True,
    help=(
        "The dataset dir is the 'data' directory you get from an NCBI datasets download. "
        "It has individual directories inside, per assembly (named e.g. GCF_0002342342.1)."
    )
)
@click.option(
    "--output-file",
    required=True,
    type=click.Path(exists=False),
    help="The file to be generated, containing the groupings in JSON format."
)
@click.option(
    "--ignore-list",
    required=True,
    type=click.Path(exists=False),
    help="A file with one segment ID per line to be ignored."
)
def main(dataset_dir: list[str], output_file: str, ignore_list: str) -> None:
    assembly_segment_dict: dict[str, list[str]] = {}

    with open(ignore_list, 'r') as file:
        ignore = [line.strip() for line in file]

    print(f"Ignoring {len(ignore)} segments")

    count = 0
    number_dict = {}
    for dir in dataset_dir:
        for gca_folder in os.listdir(dir):
            gca_path = os.path.join(dir, gca_folder)
            if not os.path.isdir(gca_path):
                continue
            for file in os.listdir(gca_path):
                if not file.endswith(".fna"):
                    continue
                count += 1
                file_path = os.path.join(gca_path, file)
                segments = []

                with open(file_path, "r") as f:
                    segments = [record.id for record in SeqIO.parse(f, "fasta") if record.id not in ignore]
                number_dict[len(segments)] = number_dict.get(len(segments), 0) + 1
                if file.split(".")[0] in assembly_segment_dict:
                    raise ValueError(f"Duplicate assembly found: {file.split('.')[0]}")
                assembly_segment_dict[file.split(".")[0]] = segments

    print(f"Found {count} assemblies")
    print(f"Number of assemblies with x segments: {number_dict}")

    with open(output_file, "w") as outfile:
        json.dump(assembly_segment_dict, outfile)


if __name__ == "__main__":
    main()