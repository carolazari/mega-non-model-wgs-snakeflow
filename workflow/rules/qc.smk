rule fastqc_read1:
    input:
        lambda wc: (get_fastq(wc))["r1"],
    output:
        html="results/qc/fastqc/{sample}---{unit}_R1.html",
        zip="results/qc/fastqc/{sample}---{unit}_R1_fastqc.zip",
    log:
        "results/logs/fastqc/{sample}---{unit}_R1.log",
    wrapper:
        "0.59.2/bio/fastqc"


rule fastqc_read2:
    input:
        lambda wc: (get_fastq(wc))["r2"],
    output:
        html="results/qc/fastqc/{sample}---{unit}_R2.html",
        zip="results/qc/fastqc/{sample}---{unit}_R2_fastqc.zip",
    log:
        "results/logs/fastqc/{sample}---{unit}_R2.log",
    wrapper:
        "0.59.2/bio/fastqc"



rule samtools_stats:
    input:
        "results/bams_sampmerged/{sample}.bam",
    output:
        "results/qc/samtools-stats/{sample}.txt",
    log:
        "results/logs/samtools-stats/{sample}.log",
    wrapper:
        "0.59.2/bio/samtools/stats"


rule multiqc_and_index_bams:
    input:
        expand("results/qc/samtools-stats/{sample}.txt", sample=sample_list),
        expand("results/qc/fastqc/{u.sample}---{u.unit}_R{r}_fastqc.zip", u=units.itertuples(), r = [1, 2]),
        list(dict.fromkeys(expand("results/qc/mkdup/{u.sample}---{u.library}.metrics.txt", u=units.itertuples()))),
        expand("results/bams_sampmerged/{sample}.bam.bai", sample=sample_list)  # only here to force indexing of bams in this early step
    output:
        report(
            "results/qc/multiqc.html",
            caption="../../report/multiqc.rst",
            category="Quality control",
        ),
    log:
        "results/logs/multiqc.log",
    wrapper:
        "0.59.2/bio/multiqc"
