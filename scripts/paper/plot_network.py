import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

if __name__ == "__main__":
    sns.despine(top=True, right=True)
    sns.set_palette('Greys', n_colors=2)

    pq = pd.read_csv('pq_net.csv')
    rows = len(pq)
    print(rows)

    timestamp = list()
    for i in range(rows):
        timestamp.append(i * 15)        

    th = list()
    for val in pq["Throughput"]:
        th.append(val / (1024*1024))

    pq['Time'] = timestamp
    pq['Throughput'] = th
    sns_plot_1 = sns.lineplot(data=pq, x="Time", y="Throughput", linestyle="dashed")
    # sns_plot_1.set(ylim=(0, 100))
    sns_plot_1.set_ylabel('Throughput (MBps)', fontsize=18)
    sns_plot_1.set_xlabel('Timestamp (s)', fontsize=18)
    sns_plot_1.tick_params(axis="y", labelsize=18)
    sns_plot_1.tick_params(axis="x", labelsize=18)

    sk = pd.read_csv('sk_net.csv')
    rows = len(sk)
    print(rows)

    timestamp = list()
    for i in range(rows):
        timestamp.append(i * 15)

    th = list()
    for val in sk["Throughput"]:
        th.append(val / (1024*1024))

    print(th)
    
    sk['Time'] = timestamp
    sk['Throughput'] = th

    sns_plot_2 = sns.lineplot(data=sk, x="Time", y="Throughput", linestyle="dashed")
    # sns_plot_2.set(ylim=(0, 100))
    sns_plot_2.set_ylabel('Throughput (MBps)', fontsize=18)
    sns_plot_2.set_xlabel('Timestamp (s)', fontsize=18)
    sns_plot_2.tick_params(axis="y", labelsize=18)
    sns_plot_2.tick_params(axis="x", labelsize=18)

    plt.legend(['Without Skyhook', 'With Skyhook'])
    plt.savefig('network.png', dpi=800, bbox_inches='tight')
