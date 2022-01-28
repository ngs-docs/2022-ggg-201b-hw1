rule all:
    input:
        "SRR2584857_1.ecoli-rel606.vcf"

rule download_data:
    conda: "env-wget.yml"
    output: "SRR2584857_1.fastq.gz"
    shell: """
        wget https://osf.io/4rdza/download -O {output}
    """

rule download_genome:
    conda: "env-wget.yml"
    output: "ecoli-rel606.fa.gz"
    shell:
        "wget https://osf.io/8sm92/download -O {output}"

rule map_reads:
    conda: "env-minimap.yml"
    input: ref="ecoli-rel606.fa.gz", reads="SRR2584857_1.fastq.gz"
    output: "SRR2584857_1.ecoli-rel606.sam"
    shell: """
        minimap2 -ax sr {input.ref} {input.reads} > {output}
    """

rule sam_to_bam:
    conda: "env-minimap.yml"
    input: "SRR2584857_1.ecoli-rel606.sam"
    output: "SRR2584857_1.ecoli-rel606.bam"
    shell: """
        samtools view -b -F 4 {input} > {output}
     """

rule sort_bam:
    conda: "env-minimap.yml"
    input: "SRR2584857_1.ecoli-rel606.bam"
    output: "SRR2584857_1.ecoli-rel606.bam.sorted"
    shell: """
        samtools sort {input} > {output}
    """

rule gunzip_fa:
    input:
        "ecoli-rel606.fa.gz"
    output:
        "ecoli-rel606.fa"
    shell: """  
        gunzip -c {input} > {output}
    """

rule call_variants:
    conda: "env-bcftools.yml"
    input:
        ref="ecoli-rel606.fa",
        bamsort="SRR2584857_1.ecoli-rel606.bam.sorted"
    output:
        pileup="SRR2584857_1.ecoli-rel606.pileup",
        bcf="SRR2584857_1.ecoli-rel606.bcf",
        vcf="SRR2584857_1.ecoli-rel606.vcf"
    shell: """
        bcftools mpileup -Ou -f {input.ref} {input.bamsort} > {output.pileup}
        bcftools call -mv -Ob {output.pileup} -o {output.bcf}
        bcftools view {output.bcf} > {output.vcf}
    """
