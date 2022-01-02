import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

if __name__ == "__main__":
    fig, axs = plt.subplots(1, 3, figsize=(16, 3.5), gridspec_kw={'hspace': 0.0, 'wspace': 0.1}, sharey=True)
    sns.despine(top=True, right=True)
    sns.set_palette('Greys', n_colors=2)

    # 4 nodes
    df_pq = pd.read_json("4nodes/8_pq.json")
    dict_pq = df_pq.to_dict()
    dict_pq.pop(90)

    df_sk = pd.read_json("4nodes/8_sk.json")
    dict_sk = df_sk.to_dict()
    dict_sk.pop(90)

    data = {
        "Selectivity": [],
        "Time (s)": [],
        "Format": []
    }

    for k, v in dict_pq.items():
        for vk, vv in v.items():
            data["Selectivity"].append(k)
            data["Time (s)"].append(vv)
            data["Format"].append("Without skyhook")

    for k, v in dict_sk.items():
        for vk, vv in v.items():
            data["Selectivity"].append(k)
            data["Time (s)"].append(vv)
            data["Format"].append("With skyhook")

    df = pd.DataFrame.from_dict(data)
    print(df)

    plot_4nodes = sns.barplot(x="Selectivity", y="Time (s)", capsize=.15, errwidth=0.5, hue="Format", data=df, ax=axs[0])
    plot_4nodes.set_title("4 Nodes", fontdict= { 'fontsize': 14})
    plot_4nodes.set_xlabel('Selectivity (%)', fontsize=14)
    plot_4nodes.set_ylabel('Time (s)', fontsize=14)
    plot_4nodes.set(ylim=(0, 50))
    plot_4nodes.tick_params(axis="y", labelsize=14)
    plot_4nodes.tick_params(axis="x", labelsize=14)

    axs[0].legend([],[], frameon=False)

    # 8 nodes
    df_pq = pd.read_json("8nodes/16_pq.json")
    dict_pq = df_pq.to_dict()
    dict_pq.pop(90)

    df_sk = pd.read_json("8nodes/16_sk.json")
    dict_sk = df_sk.to_dict()
    dict_sk.pop(90)

    data = {
        "Selectivity": [],
        "Time (s)": [],
        "Format": []
    }

    for k, v in dict_pq.items():
        for vk, vv in v.items():
            data["Selectivity"].append(k)
            data["Time (s)"].append(vv)
            data["Format"].append("Without skyhook")

    for k, v in dict_sk.items():
        for vk, vv in v.items():
            data["Selectivity"].append(k)
            data["Time (s)"].append(vv)
            data["Format"].append("With skyhook")

    df = pd.DataFrame.from_dict(data)
    print(df)

    plot_8nodes = sns.barplot(x="Selectivity", y="Time (s)", capsize=.15, errwidth=0.5, hue="Format", data=df, ax=axs[1])
    plot_8nodes.set_title("8 Nodes", fontdict= { 'fontsize': 14})
    plot_8nodes.set_xlabel('Selectivity (%)', fontsize=14)
    plot_8nodes.set_ylabel('Time (s)', fontsize=0)
    plot_8nodes.set(ylim=(0, 50))
    plot_8nodes.tick_params(axis="y", labelsize=14)
    plot_8nodes.tick_params(axis="x", labelsize=14)

    axs[1].legend([],[], frameon=False)

    # 14 nodes
    df_pq = pd.read_json("16nodes/32_pq.json")
    dict_pq = df_pq.to_dict()
    dict_pq.pop(90)

    df_sk = pd.read_json("16nodes/32_sk.json")
    dict_sk = df_sk.to_dict()
    dict_sk.pop(90)

    data = {
        "Selectivity": [],
        "Time (s)": [],
        "Format": []
    }

    for k, v in dict_pq.items():
        for vk, vv in v.items():
            data["Selectivity"].append(k)
            data["Time (s)"].append(vv)
            data["Format"].append("Without skyhook")

    for k, v in dict_sk.items():
        for vk, vv in v.items():
            data["Selectivity"].append(k)
            data["Time (s)"].append(vv)
            data["Format"].append("With skyhook")

    df = pd.DataFrame.from_dict(data)
    print(df)

    plot_16nodes = sns.barplot(x="Selectivity", y="Time (s)", hue="Format", capsize=.15, errwidth=0.5, data=df, ax=axs[2])
    plot_16nodes.set_title("16 Nodes", fontdict= { 'fontsize': 14})
    plot_16nodes.set_xlabel('Selectivity (%)', fontsize=14)
    plot_16nodes.set_ylabel('Time (s)', fontsize=0)
    plot_16nodes.set(ylim=(0, 50))
    plot_16nodes.tick_params(axis="y", labelsize=14)
    plot_16nodes.tick_params(axis="x", labelsize=14)

    axs[2].legend([],[], frameon=False)

    plotaxs = fig.axes[2]
    lines = plotaxs.get_legend_handles_labels()[0]
    labels = plotaxs.get_legend_handles_labels()[1]

    fig.legend(lines, labels, loc='upper right', fontsize=14, frameon=True)
    fig.tight_layout()
    fig.savefig('latency.pdf', bbox_inches='tight')
