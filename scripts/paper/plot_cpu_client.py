from datetime import time
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

if __name__ == "__main__":
    fig, axs = plt.subplots(1, 2, figsize=(16, 7.5), gridspec_kw={'hspace': 0.1, 'wspace': 0.1}, sharey=True)
    sns.despine(top=True, right=True)
    sns.set_palette('Greys', n_colors=2)

    df_skyhook_client = pd.read_csv('cpu/skyhook-client.csv')
    rows = len(df_skyhook_client)

    timestamp = list()
    for i in range(rows):
        timestamp.append(i * 15)

    df_skyhook_client['Time'] = timestamp
    sns_plot = sns.lineplot(data=df_skyhook_client, x="Time", y="Usage", ax=axs[1])
    sns_plot.set(ylim=(0, 100))
    sns_plot.set_title("Skyhook", fontdict= { 'fontsize': 18})
    sns_plot.set_ylabel('Usage (%)', fontsize=18)
    sns_plot.set_xlabel('Timestamp (s)', fontsize=18)
    sns_plot.tick_params(axis="y", labelsize=18)
    sns_plot.tick_params(axis="x", labelsize=18)

    df_wskyhook_client = pd.read_csv('cpu/without-skyhook-client.csv')
    rows = len(df_wskyhook_client)

    timestamp = list()
    for i in range(rows):
        timestamp.append(i * 15)
    
    df_wskyhook_client['Time'] = timestamp

    sns_plot = sns.lineplot(data=df_wskyhook_client, x="Time", y="Usage", ax=axs[0])
    sns_plot.set(ylim=(0, 100))
    sns_plot.set_title("Without Skyhook", fontdict= { 'fontsize': 18})
    sns_plot.set_ylabel('Usage (%)', fontsize=18)
    sns_plot.set_xlabel('Timestamp (s)', fontsize=18)
    sns_plot.tick_params(axis="y", labelsize=18)
    sns_plot.tick_params(axis="x", labelsize=18)
    
    fig.savefig('cpu_client.pdf', bbox_inches='tight')
