import os
from Bio import SeqIO
import json
import click

@click.command()
@click.option("--dataset-dir", required=True, type=click.Path(exists=True))
@click.option("--output-file", required=True, type=click.Path(exists=False))
@click.option("--ignore-list", required=True, type=click.Path(exists=False))
def main(dataset_dir: str, output_file: str, ignore_list: str) -> None:
    fasta_dict = {}

    with open(ignore_list, 'r') as file:
        ignore = [line.strip() for line in file]

    print(f"Ignoring {len(ignore)} segments")

    count = 0
    number_dict = {}
    for gca_folder in os.listdir(dataset_dir):
        gca_path = os.path.join(dataset_dir, gca_folder)
        if not os.path.isdir(gca_path):
            continue
        for file in os.listdir(gca_path):
            if file.endswith(".fna"):
                count += 1
                file_path = os.path.join(gca_path, file)
                segments = []

                with open(file_path, "r") as f:
                    segments = [record.id for record in SeqIO.parse(f, "fasta") if record.id not in ignore]
                number_dict[len(segments)] = number_dict.get(len(segments), 0) + 1
                if file.split(".")[0] in fasta_dict:
                    raise ValueError(f"Duplicate assembly found: {file.split('.')[0]}")
                fasta_dict[file.split(".")[0]] = segments

    print(f"Found {count} assemblies")
    print(f"Number of assemblies with x segments: {number_dict}")

    with open(output_file, "w") as outfile:
        json.dump(fasta_dict, outfile)


if __name__ == "__main__":
    main()