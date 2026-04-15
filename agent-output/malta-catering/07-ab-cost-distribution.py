"""Generate the as-built cost distribution chart for Malta Catering."""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def generate_cost_distribution_chart(categories: dict[str, float], output_path: str) -> None:
    palette = ["#0078D4", "#50E6FF", "#1490DF"]
    labels = list(categories.keys())
    values = list(categories.values())
    total = sum(values)

    fig, ax = plt.subplots(figsize=(8, 6))
    fig.patch.set_facecolor("#F8F9FA")
    ax.set_facecolor("#F8F9FA")

    wedges, _ = ax.pie(
        values,
        colors=palette,
        wedgeprops={"linewidth": 2, "edgecolor": "#F8F9FA"},
        startangle=140,
    )

    hole = plt.Circle((0, 0), 0.60, fc="#F8F9FA")
    ax.add_patch(hole)

    ax.text(0, 0.07, f"${total:,.2f}", ha="center", va="center", fontsize=16, fontweight="bold", color="#1A1A2E")
    ax.text(0, -0.16, "per month", ha="center", va="center", fontsize=10, color="#666")

    legend_labels = []
    for label, value in zip(labels, values):
        pct = value / total * 100
        legend_labels.append(f"{label}  ${value:,.2f}  ({pct:.1f}%)")
    patches = [mpatches.Patch(color=color, label=label) for color, label in zip(palette, legend_labels)]
    ax.legend(handles=patches, loc="lower center", bbox_to_anchor=(0.5, -0.18), ncol=1, fontsize=9, framealpha=0.0)

    ax.set_title("Monthly Cost Distribution", fontsize=13, fontweight="bold", color="#1A1A2E", pad=10)
    plt.tight_layout(pad=1.4)
    plt.savefig(output_path, dpi=150, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close()


if __name__ == "__main__":
    generate_cost_distribution_chart(
        {
            "Compute": 64.97,
            "Data Services": 50.69,
            "Networking": 23.40,
        },
        "agent-output/malta-catering/07-ab-cost-distribution.png",
    )
"""Generate the as-built cost distribution chart for Malta Catering."""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def generate_cost_distribution_chart(categories: dict[str, float], output_path: str) -> None:
    palette = ["#0078D4", "#50E6FF", "#1490DF"]
    labels = list(categories.keys())
    values = list(categories.values())
    total = sum(values)

    fig, ax = plt.subplots(figsize=(8, 6))
    fig.patch.set_facecolor("#F8F9FA")
    ax.set_facecolor("#F8F9FA")

    wedges, _ = ax.pie(
        values,
        colors=palette,
        wedgeprops={"linewidth": 2, "edgecolor": "#F8F9FA"},
        startangle=140,
    )

    hole = plt.Circle((0, 0), 0.60, fc="#F8F9FA")
    ax.add_patch(hole)

    ax.text(0, 0.07, f"${total:,.2f}", ha="center", va="center", fontsize=16, fontweight="bold", color="#1A1A2E")
    ax.text(0, -0.16, "per month", ha="center", va="center", fontsize=10, color="#666")

    legend_labels = []
    for label, value in zip(labels, values):
        pct = value / total * 100
        legend_labels.append(f"{label}  ${value:,.2f}  ({pct:.1f}%)")
    patches = [mpatches.Patch(color=color, label=label) for color, label in zip(palette, legend_labels)]
    ax.legend(handles=patches, loc="lower center", bbox_to_anchor=(0.5, -0.18), ncol=1, fontsize=9, framealpha=0.0)

    ax.set_title("Monthly Cost Distribution", fontsize=13, fontweight="bold", color="#1A1A2E", pad=10)
    plt.tight_layout(pad=1.4)
    plt.savefig(output_path, dpi=150, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close()


if __name__ == "__main__":
    generate_cost_distribution_chart(
        {
            "Compute": 64.97,
            "Data Services": 50.69,
            "Networking": 23.40,
        },
        "agent-output/malta-catering/07-ab-cost-distribution.png",
    )
