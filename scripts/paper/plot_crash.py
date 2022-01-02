from datetime import time
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from matplotlib.pyplot import figure

if __name__ == "__main__":
    ax = figure(figsize=(15, 12), dpi=80)
    sns.set_palette('Greys', n_colors=1)
    df = pd.read_csv('crash.csv')
    rows = len(df)

    timestamp = list()
    for i in range(rows):
        timestamp.append(i * 15)

    th = list()
    for val in df["Throughput"]:
        th.append(val / (1024*1024))

    df['Time'] = timestamp
    df['Throughput'] = th
    sns_plot = sns.lineplot(data=df, x="Time", y="Throughput", linewidth=2.5)
    sns_plot.set(ylim=(0, 1050))
    sns_plot.set_ylabel('Throughput (MBps)', fontsize=32)
    sns_plot.set_xlabel('Timestamp (s)', fontsize=32)
    sns_plot.tick_params(axis="y", labelsize=32)
    sns_plot.tick_params(axis="x", labelsize=32)
    plt.savefig('crash.png', bbox_inches='tight')
