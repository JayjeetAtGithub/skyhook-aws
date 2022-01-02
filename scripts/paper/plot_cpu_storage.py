from os import makedirs
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd


def stack_dataframe(df):
    df = df[[f"node{i}" for i in range(4, 20)]]
    print(df)
    col_list = [x for x in range(5, 20)]
    for i, _ in df.iterrows():
        for col in col_list:
            df.loc[i, f"node{col}"] = df.loc[i, f"node{col}"] + df.loc[i, f"node{col - 1}"]
    return df

if __name__ == "__main__":
    fig, axs = plt.subplots(1, 2, figsize=(16, 7.5), gridspec_kw={'hspace': 0.1, 'wspace': 0.1}, sharey=True)
    sns.despine(top=True, right=True)
    sns.set_palette('Greys', n_colors=2)
    df_skyhook_storage = pd.read_csv('cpu/skyhook-storage.csv')
    df_skyhook_storage = stack_dataframe(df_skyhook_storage)

    for i in range(4, 19):
        rows = len(df_skyhook_storage)

        timestamp = list()
        for j in range(rows):
            timestamp.append(j * 15)

        df_skyhook_storage['Time'] = timestamp
        sns_plot = sns.lineplot(data=df_skyhook_storage, x="Time", y="node{}".format(i), ax=axs[1], markers=True)
        sns_plot.set(ylim=(0, 180))
        sns_plot.set_title("Skyhook", fontdict= { 'fontsize': 18})
        sns_plot.set_ylabel('Usage (%)', fontsize=18)
        sns_plot.set_xlabel('Timestamp (s)', fontsize=18)
        sns_plot.tick_params(axis="y", labelsize=18)
        sns_plot.tick_params(axis="x", labelsize=18)
    
    df_wskyhook_storage = pd.read_csv('cpu/without-skyhook-storage.csv')
    df_wskyhook_storage = stack_dataframe(df_wskyhook_storage)
    
    for i in range(4, 19):
        rows = len(df_wskyhook_storage)

        timestamp = list()
        for j in range(rows):
            timestamp.append(j * 15)

        df_wskyhook_storage['Time'] = timestamp
        sns_plot = sns.lineplot(data=df_wskyhook_storage, x="Time", y="node{}".format(i), ax=axs[0])
        sns_plot.set(ylim=(0, 180))
        sns_plot.set_title("Without Skyhook", fontdict= { 'fontsize': 18})
        sns_plot.set_ylabel('Usage (%)', fontsize=18)
        sns_plot.set_xlabel('Timestamp (s)', fontsize=18)
        sns_plot.tick_params(axis="y", labelsize=18)
        sns_plot.tick_params(axis="x", labelsize=18)

    fig.savefig('cpu_storage_stacked.pdf', bbox_inches='tight')
